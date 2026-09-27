import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../db/app_database.dart';
import '../podcast_repository.dart' show PodcastFilesCleaner;
import '../settings_keys.dart';
import 'download_engine.dart';

/// A download row with its episode and podcast, for the Downloads tab.
typedef DownloadItem = ({Download download, Episode episode, Podcast podcast});

/// Result of one maintenance run (reconcile + evict + auto-download).
typedef MaintenanceResult = ({int freedBytes, int queued});

/// Downloads, the files on disk and all eviction rules (docs/eviction.md).
///
/// Invariants: the database is the only truth; every audio file in the
/// episodes directory has a `downloads` row with state `done` and vice versa.
/// Everything else is removed by [reconcile].
class DownloadService implements PodcastFilesCleaner {
  DownloadService({
    required this._db,
    required this._engine,
    required this._clock,
    required this._episodesDirectory,
    required this._currentEpisodeId,
  }) {
    // Listen right away so no completion event can be missed.
    _subscription = _engine.events.listen(_onEvent);
  }

  final AppDatabase _db;
  final DownloadEngine _engine;
  final Clock _clock;
  final Future<Directory> Function() _episodesDirectory;

  /// The episode loaded in the player – never deleted automatically.
  final int? Function() _currentEpisodeId;

  /// Played downloads are deleted this long after they were played.
  static const deletePlayedAfter = Duration(hours: 96);

  static const defaultLimitBytes = 5 * 1024 * 1024 * 1024;

  final _progress = <int, double>{};
  final _progressController = StreamController<Map<int, double>>.broadcast();
  late final StreamSubscription<DownloadEvent> _subscription;
  Future<MaintenanceResult>? _runningMaintenance;

  /// Progress (0…1) of running downloads by episode id.
  Stream<Map<int, double>> get progress async* {
    yield Map.unmodifiable(_progress);
    yield* _progressController.stream;
  }

  // -------------------------------------------------------------- lifecycle

  /// Fetches events that happened while the app was not running.
  Future<void> start() => _engine.start();

  Future<void> dispose() async {
    await _subscription.cancel();
    await _progressController.close();
  }

  // ---------------------------------------------------------------- queries

  Stream<Map<int, Download>> watchStates() => _db
      .select(_db.downloads)
      .watch()
      .map((rows) => {for (final r in rows) r.episodeId: r});

  Stream<List<DownloadItem>> watchAll() {
    final query =
        _db.select(_db.downloads).join([
          innerJoin(
            _db.episodes,
            _db.episodes.id.equalsExp(_db.downloads.episodeId),
          ),
          innerJoin(
            _db.podcasts,
            _db.podcasts.id.equalsExp(_db.episodes.podcastId),
          ),
        ])..orderBy([
          OrderingTerm.desc(_db.downloads.completedAt),
          OrderingTerm.desc(_db.downloads.createdAt),
        ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            download: row.readTable(_db.downloads),
            episode: row.readTable(_db.episodes),
            podcast: row.readTable(_db.podcasts),
          ),
      ],
    );
  }

  /// The downloaded file, or null (then the episode is streamed).
  Future<File?> localFile(int episodeId) async {
    final row = await _row(episodeId);
    if (row == null || row.state != DownloadState.done) return null;
    final file = await _file(row.relativePath);
    if (file.existsSync()) return file;
    await _deleteRow(episodeId); // file vanished – reconcile the DB
    return null;
  }

  Future<int> totalBytes() async {
    final sum = _db.downloads.sizeBytes.sum();
    final query = _db.selectOnly(_db.downloads)
      ..addColumns([sum])
      ..where(_db.downloads.state.equalsValue(DownloadState.done));
    return await query.map((r) => r.read(sum)).getSingle() ?? 0;
  }

  Future<int> limitBytes() async {
    final row =
        await (_db.select(_db.settings)
              ..where((s) => s.key.equals(SettingsKeys.downloadLimitBytes)))
            .getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? defaultLimitBytes;
  }

  // ---------------------------------------------------------------- actions

  /// Queues a download. Does nothing if it is already queued or done.
  Future<void> download(int episodeId, {bool wifiOnly = false}) async {
    final existing = await _row(episodeId);
    if (existing != null && existing.state != DownloadState.failed) return;
    final episode = await (_db.select(
      _db.episodes,
    )..where((e) => e.id.equals(episodeId))).getSingleOrNull();
    if (episode == null) return;

    final fileName = '$episodeId.${audioFileExtension(episode)}';
    await _db
        .into(_db.downloads)
        .insertOnConflictUpdate(
          DownloadsCompanion.insert(
            episodeId: Value(episodeId),
            relativePath: fileName,
            state: DownloadState.queued,
            wifiOnly: Value(wifiOnly),
            createdAt: _clock(),
          ),
        );
    final accepted = await _engine.enqueue(
      episodeId: episodeId,
      url: episode.audioUrl,
      fileName: fileName,
      wifiOnly: wifiOnly,
    );
    if (!accepted) await _setState(episodeId, DownloadState.failed);
  }

  /// Stops a running download and removes everything belonging to it.
  Future<void> cancel(int episodeId) async {
    await _engine.cancel(episodeId);
    await delete(episodeId);
  }

  /// Deletes the file and the row.
  Future<void> delete(int episodeId) async {
    final row = await _row(episodeId);
    if (row != null) await _deleteFile(row.relativePath);
    await _deleteRow(episodeId);
  }

  /// Called before a podcast is unsubscribed.
  @override
  Future<void> deleteForPodcast(int podcastId) async {
    final rows = await _rowsWhere(_db.episodes.podcastId.equals(podcastId));
    for (final row in rows) {
      if (row.state == DownloadState.queued ||
          row.state == DownloadState.running) {
        await _engine.cancel(row.episodeId);
      }
      await delete(row.episodeId);
    }
  }

  // ------------------------------------------------------------ maintenance

  /// Reconcile, delete played downloads, enforce the limit, auto-download.
  /// Runs at app start and after every refresh. Concurrent calls share a run.
  Future<MaintenanceResult> runMaintenance() => _runningMaintenance ??=
      _maintenance().whenComplete(() => _runningMaintenance = null);

  Future<MaintenanceResult> _maintenance() async {
    var freed = await reconcile();
    freed += await evictPlayed();
    freed += await enforceLimit();
    final queued = await autoDownload();
    return (freedBytes: freed, queued: queued);
  }

  /// Makes disk and database agree. Returns the number of bytes freed.
  Future<int> reconcile() async {
    final dir = await _episodesDirectory();
    final active = await _engine.activeEpisodeIds();
    final rows = {
      for (final r in await _db.select(_db.downloads).get()) r.relativePath: r,
    };

    // 1. Files without a matching row → delete (orphans, leftovers).
    var freed = 0;
    if (dir.existsSync()) {
      for (final entity in dir.listSync()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        final row = rows[name];
        // Files only appear here once complete (the engine moves them in at
        // the end), so any file with a non-failed row is valid; step 2 marks
        // it "done" if the completion event was missed.
        final keep = row != null && row.state != DownloadState.failed;
        if (!keep) {
          freed += entity.lengthSync();
          entity.deleteSync();
        }
      }
    }

    // 2. Rows without a file / without a running task → fix or remove.
    for (final row in rows.values) {
      final file = await _file(row.relativePath);
      switch (row.state) {
        case DownloadState.done when !file.existsSync():
          await _deleteRow(row.episodeId);
        case DownloadState.queued || DownloadState.running
            when !active.contains(row.episodeId):
          if (file.existsSync()) {
            await _markDone(row.episodeId, file);
          } else {
            await _deleteRow(row.episodeId);
          }
        default:
          break;
      }
    }
    return freed;
  }

  /// Deletes played downloads 96 h after they were played (per-podcast switch).
  Future<int> evictPlayed() async {
    final cutoff = _clock().subtract(deletePlayedAfter);
    final rows = await _rowsWhere(
      _db.downloads.state.equalsValue(DownloadState.done) &
          _db.episodes.status.equalsValue(EpisodeStatus.played) &
          _db.episodes.playedAt.isSmallerOrEqualValue(cutoff) &
          _db.podcasts.autoDeletePlayed.equals(true),
    );
    return _deleteAll(rows);
  }

  /// Over the limit: delete played downloads, oldest first. Unplayed
  /// downloads are never deleted automatically.
  Future<int> enforceLimit() async {
    var excess = await totalBytes() - await limitBytes();
    if (excess <= 0) return 0;
    final rows = await _rowsWhere(
      _db.downloads.state.equalsValue(DownloadState.done) &
          _db.episodes.status.equalsValue(EpisodeStatus.played),
      orderBy: OrderingTerm.asc(_db.episodes.playedAt),
    );
    final toDelete = <Download>[];
    for (final row in rows) {
      if (excess <= 0) break;
      if (row.episodeId == _currentEpisodeId()) continue;
      toDelete.add(row);
      excess -= row.sizeBytes ?? 0;
    }
    return _deleteAll(toDelete);
  }

  /// Queues the newest unplayed episodes of podcasts with auto-download, up to
  /// their limit, as long as the storage limit allows. Returns the count.
  Future<int> autoDownload() async {
    var budget = await limitBytes() - await totalBytes();
    if (budget <= 0) return 0;

    final podcasts =
        await (_db.select(_db.podcasts)..where(
              (p) => p.autoDownloadMode.equalsValue(AutoDownloadMode.off).not(),
            ))
            .get();

    var queued = 0;
    for (final podcast in podcasts) {
      final existing = await _rowsWhere(
        _db.episodes.podcastId.equals(podcast.id) &
            _db.episodes.status.equalsValue(EpisodeStatus.played).not() &
            _db.downloads.state.equalsValue(DownloadState.failed).not(),
      );
      var missing = podcast.autoDownloadMaxEpisodes - existing.length;
      if (missing <= 0) continue;

      final candidates =
          await (_db.select(_db.episodes)
                ..where(
                  (e) =>
                      e.podcastId.equals(podcast.id) &
                      e.status.equalsValue(EpisodeStatus.newEpisode) &
                      e.id.isNotInQuery(
                        _db.selectOnly(_db.downloads)
                          ..addColumns([_db.downloads.episodeId]),
                      ),
                )
                ..orderBy([
                  (e) => OrderingTerm(
                    expression: e.pubDate,
                    mode: OrderingMode.desc,
                    nulls: NullsOrder.last,
                  ),
                ])
                ..limit(missing))
              .get();

      for (final episode in candidates) {
        final size = episode.audioSizeBytes ?? 0;
        if (size > budget) return queued;
        budget -= size;
        await download(
          episode.id,
          wifiOnly: podcast.autoDownloadMode == AutoDownloadMode.wifiOnly,
        );
        queued++;
        missing--;
      }
    }
    return queued;
  }

  // --------------------------------------------------------------- internals

  Future<void> _onEvent(DownloadEvent event) async {
    final id = event.episodeId;
    switch (event) {
      case DownloadStarted():
        await _setState(id, DownloadState.running);
      case DownloadProgress(:final fraction):
        _progress[id] = fraction;
        _emitProgress();
      case DownloadCompleted():
        _clearProgress(id);
        final row = await _row(id);
        if (row == null) {
          // Row was deleted meanwhile (canceled / unsubscribed): drop the file.
          await reconcile();
          return;
        }
        final file = await _file(row.relativePath);
        if (file.existsSync()) {
          await _markDone(id, file);
        } else {
          await _setState(id, DownloadState.failed);
        }
      case DownloadFailed():
        _clearProgress(id);
        await _setState(id, DownloadState.failed);
      case DownloadCanceled():
        _clearProgress(id);
        await delete(id);
    }
  }

  void _emitProgress() {
    if (!_progressController.isClosed) {
      _progressController.add(Map.unmodifiable(_progress));
    }
  }

  void _clearProgress(int id) {
    if (_progress.remove(id) != null) _emitProgress();
  }

  Future<Download?> _row(int episodeId) => (_db.select(
    _db.downloads,
  )..where((d) => d.episodeId.equals(episodeId))).getSingleOrNull();

  Future<List<Download>> _rowsWhere(
    Expression<bool> where, {
    OrderingTerm? orderBy,
  }) async {
    final query = _db.select(_db.downloads).join([
      innerJoin(
        _db.episodes,
        _db.episodes.id.equalsExp(_db.downloads.episodeId),
      ),
      innerJoin(
        _db.podcasts,
        _db.podcasts.id.equalsExp(_db.episodes.podcastId),
      ),
    ])..where(where);
    if (orderBy != null) query.orderBy([orderBy]);
    return (await query.get()).map((r) => r.readTable(_db.downloads)).toList();
  }

  Future<int> _deleteAll(Iterable<Download> rows) async {
    var freed = 0;
    for (final row in rows) {
      if (row.episodeId == _currentEpisodeId()) continue;
      freed += row.sizeBytes ?? 0;
      await delete(row.episodeId);
    }
    return freed;
  }

  Future<void> _setState(int episodeId, DownloadState state) =>
      (_db.update(_db.downloads)..where((d) => d.episodeId.equals(episodeId)))
          .write(DownloadsCompanion(state: Value(state)));

  Future<void> _markDone(int episodeId, File file) =>
      (_db.update(
        _db.downloads,
      )..where((d) => d.episodeId.equals(episodeId))).write(
        DownloadsCompanion(
          state: const Value(DownloadState.done),
          sizeBytes: Value(file.lengthSync()),
          completedAt: Value(_clock()),
        ),
      );

  Future<void> _deleteRow(int episodeId) => (_db.delete(
    _db.downloads,
  )..where((d) => d.episodeId.equals(episodeId))).go();

  Future<File> _file(String relativePath) async =>
      File('${(await _episodesDirectory()).path}/$relativePath');

  Future<void> _deleteFile(String relativePath) async {
    final file = await _file(relativePath);
    if (file.existsSync()) file.deleteSync();
  }
}

const _extensionsByMime = {
  'audio/mpeg': 'mp3',
  'audio/mp3': 'mp3',
  'audio/mp4': 'm4a',
  'audio/x-m4a': 'm4a',
  'audio/m4a': 'm4a',
  'audio/aac': 'aac',
  'audio/ogg': 'ogg',
  'audio/opus': 'opus',
  'audio/wav': 'wav',
  'audio/x-wav': 'wav',
};

/// File extension for an episode: from the MIME type, else the URL, else mp3.
String audioFileExtension(Episode episode) {
  final byMime = _extensionsByMime[episode.audioMimeType];
  if (byMime != null) return byMime;
  final path = Uri.tryParse(episode.audioUrl)?.path.toLowerCase() ?? '';
  final dot = path.lastIndexOf('.');
  final ext = dot < 0 ? '' : path.substring(dot + 1);
  return _extensionsByMime.values.contains(ext) ? ext : 'mp3';
}
