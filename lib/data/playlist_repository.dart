import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/text_utils.dart';
import 'db/app_database.dart';

/// Setting "Fertige Folgen aus Playlist entfernen" (user wish 2026-10-06):
/// when an episode played to the end leaves the playlist it was played
/// from. Manual "mark as played" always removes it from all playlists.
enum FinishedRemoval {
  now,
  after10Minutes,
  never;

  /// How long a finished episode stays (null = for good).
  Duration? get delay => switch (this) {
    now => Duration.zero,
    after10Minutes => const Duration(minutes: 10),
    never => null,
  };

  /// Default: after 10 minutes (user wish 2026-10-06).
  static const standard = after10Minutes;

  static FinishedRemoval fromSetting(String? value) =>
      values.where((v) => v.name == value).firstOrNull ?? standard;
}

/// A playlist with its episode count and total duration (Playlists tab).
typedef PlaylistSummary = ({Playlist playlist, int count, Duration duration});

/// One entry of a playlist with its episode and podcast.
typedef PlaylistEntry = ({PlaylistItem item, Episode episode, Podcast podcast});

/// Orders for "Sortieren" in the playlist menu.
enum PlaylistSort { dateAscending, dateDescending, nameAscending }

/// Title order for people: case-insensitive, umlauts like their base letter,
/// numbers by value ("Folge 2" before "Folge 10").
int compareTitles(String a, String b) {
  const fold = foldForSearch;
  final digits = RegExp(r'\d+|\D+');
  final pa = digits.allMatches(fold(a)).map((m) => m[0]!).toList();
  final pb = digits.allMatches(fold(b)).map((m) => m[0]!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final na = int.tryParse(pa[i]);
    final nb = int.tryParse(pb[i]);
    final c = na != null && nb != null
        ? na.compareTo(nb)
        : pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return pa.length.compareTo(pb.length);
}

/// Playlists and their items. Rules: docs/playlists.md.
class PlaylistRepository {
  PlaylistRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  // ---------------------------------------------------------------- queries

  Stream<List<PlaylistSummary>> watchPlaylists() {
    final count = _db.playlistItems.episodeId.count();
    final duration = _db.episodes.durationMs.sum();
    final query =
        _db.select(_db.playlists).join([
            leftOuterJoin(
              _db.playlistItems,
              _db.playlistItems.playlistId.equalsExp(_db.playlists.id),
            ),
            leftOuterJoin(
              _db.episodes,
              _db.episodes.id.equalsExp(_db.playlistItems.episodeId),
            ),
          ])
          ..addColumns([count, duration])
          ..groupBy([_db.playlists.id])
          ..orderBy([
            OrderingTerm.asc(_db.playlists.sortOrder),
            OrderingTerm.asc(_db.playlists.id),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            playlist: row.readTable(_db.playlists),
            count: row.read(count) ?? 0,
            duration: Duration(milliseconds: row.read(duration) ?? 0),
          ),
      ],
    );
  }

  Stream<Playlist?> watchPlaylist(int id) => (_db.select(
    _db.playlists,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();

  JoinedSelectStatement<HasResultSet, dynamic> _entries(int playlistId) =>
      _db.select(_db.playlistItems).join([
          innerJoin(
            _db.episodes,
            _db.episodes.id.equalsExp(_db.playlistItems.episodeId),
          ),
          innerJoin(
            _db.podcasts,
            _db.podcasts.id.equalsExp(_db.episodes.podcastId),
          ),
        ])
        ..where(_db.playlistItems.playlistId.equals(playlistId))
        ..orderBy([OrderingTerm.asc(_db.playlistItems.position)]);

  PlaylistEntry _toEntry(TypedResult row) => (
    item: row.readTable(_db.playlistItems),
    episode: row.readTable(_db.episodes),
    podcast: row.readTable(_db.podcasts),
  );

  Stream<List<PlaylistEntry>> watchEntries(int playlistId) =>
      _entries(playlistId).watch().map((rows) => rows.map(_toEntry).toList());

  Future<List<PlaylistEntry>> entries(int playlistId) async =>
      (await _entries(playlistId).get()).map(_toEntry).toList();

  /// Position of [episodeId] in [playlistId], or null if it is not in there.
  Future<int?> positionOf(int playlistId, int episodeId) async =>
      (await (_db.select(_db.playlistItems)..where(
                (i) =>
                    i.playlistId.equals(playlistId) &
                    i.episodeId.equals(episodeId),
              ))
              .getSingleOrNull())
          ?.position;

  /// The item is kept after being played to the end from its playlist and
  /// the episode is still played (any "mark as unplayed" ends that).
  Expression<bool> _finished($PlaylistItemsTable i) =>
      i.finishedAt.isNotNull() &
      existsQuery(
        _db.selectOnly(_db.episodes)
          ..addColumns([_db.episodes.id])
          ..where(
            _db.episodes.id.equalsExp(i.episodeId) &
                _db.episodes.status.equalsValue(EpisodeStatus.played),
          ),
      );

  /// The entry after [position] – read at the moment it is needed, so items
  /// added during playback are included (docs/playlists.md). Finished ones
  /// that are kept in the playlist are skipped.
  Future<PlaylistItem?> nextAfter(int playlistId, int position) =>
      (_db.select(_db.playlistItems)
            ..where(
              (i) =>
                  i.playlistId.equals(playlistId) &
                  i.position.isBiggerThanValue(position) &
                  _finished(i).not(),
            )
            ..orderBy([(i) => OrderingTerm.asc(i.position)])
            ..limit(1))
          .getSingleOrNull();

  /// The entry before [position] (⏮ in the player's playlist row).
  Future<PlaylistItem?> previousBefore(int playlistId, int position) =>
      (_db.select(_db.playlistItems)
            ..where(
              (i) =>
                  i.playlistId.equals(playlistId) &
                  i.position.isSmallerThanValue(position),
            )
            ..orderBy([(i) => OrderingTerm.desc(i.position)])
            ..limit(1))
          .getSingleOrNull();

  /// Ids of all playlists that contain [episodeId].
  Future<Set<int>> playlistIdsWith(int episodeId) async => {
    for (final item in await (_db.select(
      _db.playlistItems,
    )..where((i) => i.episodeId.equals(episodeId))).get())
      item.playlistId,
  };

  /// Like [playlistIdsWith], updated whenever the episode is added to or
  /// removed from a playlist.
  Stream<Set<int>> watchPlaylistIdsWith(int episodeId) =>
      (_db.select(_db.playlistItems)
            ..where((i) => i.episodeId.equals(episodeId)))
          .watch()
          .map((items) => {for (final i in items) i.playlistId});

  /// Ids of all episodes that are in at least one playlist; emits again
  /// whenever an episode is added to or removed from any playlist.
  Stream<Set<int>> watchEpisodeIdsInPlaylists() {
    final episodeId = _db.playlistItems.episodeId;
    return (_db.selectOnly(_db.playlistItems, distinct: true)
          ..addColumns([episodeId]))
        .watch()
        .map((rows) => {for (final r in rows) r.read(episodeId)!});
  }

  /// "Resume": the episode last played from [playlistId] if it is still in
  /// there, otherwise the first entry. Null = the playlist is empty.
  Future<int?> resumeEpisode(int playlistId) async {
    final last = (await (_db.select(
      _db.playlists,
    )..where((p) => p.id.equals(playlistId))).getSingleOrNull())?.lastEpisodeId;
    final position = last == null ? null : await positionOf(playlistId, last);
    if (last != null && position != null) {
      // Finished but kept there: go on with the next one instead.
      if (!await _isFinished(playlistId, last)) return last;
      final next = await nextAfter(playlistId, position);
      if (next != null) return next.episodeId;
    }
    return (await nextAfter(playlistId, -1))?.episodeId ??
        (await (_db.select(_db.playlistItems)
                  ..where((i) => i.playlistId.equals(playlistId))
                  ..orderBy([(i) => OrderingTerm.asc(i.position)])
                  ..limit(1))
                .getSingleOrNull())
            ?.episodeId;
  }

  Future<bool> _isFinished(int playlistId, int episodeId) async =>
      await (_db.select(_db.playlistItems)..where(
            (i) =>
                i.playlistId.equals(playlistId) &
                i.episodeId.equals(episodeId) &
                _finished(i),
          ))
          .getSingleOrNull() !=
      null;

  /// Keeps [episodeId] in [playlistId] as finished (instead of removing it).
  Future<void> markFinishedIn(int playlistId, int episodeId) =>
      (_db.update(_db.playlistItems)..where(
            (i) =>
                i.playlistId.equals(playlistId) & i.episodeId.equals(episodeId),
          ))
          .write(PlaylistItemsCompanion(finishedAt: Value(_clock())));

  /// Started again from [playlistId]: no longer finished there (a replay must
  /// not be removed after 10 minutes).
  Future<void> clearFinished(int playlistId, int episodeId) =>
      (_db.update(_db.playlistItems)..where(
            (i) =>
                i.playlistId.equals(playlistId) &
                i.episodeId.equals(episodeId) &
                i.finishedAt.isNotNull(),
          ))
          .write(const PlaylistItemsCompanion(finishedAt: Value(null)));

  /// Removes finished items whose time is up under [mode] (all of them for
  /// "now", none for "never"). Returns the number removed.
  Future<int> removeFinished(FinishedRemoval mode) {
    final delay = mode.delay;
    if (delay == null) return Future.value(0);
    final cutoff = _clock().subtract(delay);
    return (_db.delete(_db.playlistItems)..where(
          (i) => _finished(i) & i.finishedAt.isSmallerOrEqualValue(cutoff),
        ))
        .go();
  }

  /// Sets the category color (null = none).
  Future<void> setColor(int playlistId, PlaylistColor? color) =>
      (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
        PlaylistsCompanion(color: Value(color)),
      );

  /// Remembers [episodeId] as the one last played from [playlistId].
  Future<void> setLastEpisode(int playlistId, int episodeId) =>
      (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
        PlaylistsCompanion(lastEpisodeId: Value(episodeId)),
      );

  Future<List<Playlist>> playlists() =>
      (_db.select(_db.playlists)..orderBy([
            (p) => OrderingTerm.asc(p.sortOrder),
            (p) => OrderingTerm.asc(p.id),
          ]))
          .get();

  // ------------------------------------------------------------ playlists

  Future<int> create(String name) async {
    final maxOrder = _db.playlists.sortOrder.max();
    final current =
        await (_db.selectOnly(
          _db.playlists,
        )..addColumns([maxOrder])).map((r) => r.read(maxOrder)).getSingle() ??
        -1;
    return _db
        .into(_db.playlists)
        .insert(
          PlaylistsCompanion.insert(
            name: name.trim(),
            sortOrder: Value(current + 1),
            createdAt: _clock(),
          ),
        );
  }

  Future<void> rename(int playlistId, String name) =>
      (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
        PlaylistsCompanion(name: Value(name.trim())),
      );

  /// Deletes the playlist and its items (the episodes stay).
  Future<void> delete(int playlistId) =>
      (_db.delete(_db.playlists)..where((p) => p.id.equals(playlistId))).go();

  /// Stores a new order of playlists (ids in display order).
  Future<void> reorderPlaylists(List<int> orderedIds) => _db.batch((batch) {
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update(
        _db.playlists,
        PlaylistsCompanion(sortOrder: Value(i)),
        where: (p) => p.id.equals(orderedIds[i]),
      );
    }
  });

  // ---------------------------------------------------------------- items

  /// Appends [episodeId] to the end. Returns false if it was already there.
  Future<bool> add(int playlistId, int episodeId) async {
    if (await positionOf(playlistId, episodeId) != null) return false;
    final maxPosition = _db.playlistItems.position.max();
    final current =
        await (_db.selectOnly(_db.playlistItems)
              ..addColumns([maxPosition])
              ..where(_db.playlistItems.playlistId.equals(playlistId)))
            .map((r) => r.read(maxPosition))
            .getSingle() ??
        -1;
    await _db
        .into(_db.playlistItems)
        .insert(
          PlaylistItemsCompanion.insert(
            playlistId: playlistId,
            episodeId: episodeId,
            position: current + 1,
            addedAt: _clock(),
          ),
        );
    return true;
  }

  /// Appends [episodeIds] in this order, skipping those already in the
  /// playlist. Returns the ids actually added.
  Future<List<int>> addAll(int playlistId, List<int> episodeIds) =>
      _db.transaction(() async {
        final added = <int>[];
        for (final id in episodeIds) {
          if (await add(playlistId, id)) added.add(id);
        }
        return added;
      });

  Future<void> remove(int playlistId, int episodeId) =>
      (_db.delete(_db.playlistItems)..where(
            (i) =>
                i.playlistId.equals(playlistId) & i.episodeId.equals(episodeId),
          ))
          .go();

  /// Rewrites the whole order of [playlistId]. Date = publication date;
  /// episodes without one go last in both date orders.
  Future<void> sort(int playlistId, PlaylistSort order) async {
    final entries = await this.entries(playlistId);
    int byDate(PlaylistEntry a, PlaylistEntry b, {required bool ascending}) {
      final da = a.episode.pubDate;
      final db = b.episode.pubDate;
      if (da == null || db == null) {
        return da == null ? (db == null ? 0 : 1) : -1;
      }
      return ascending ? da.compareTo(db) : db.compareTo(da);
    }

    entries.sort(
      (a, b) => switch (order) {
        PlaylistSort.dateAscending => byDate(a, b, ascending: true),
        PlaylistSort.dateDescending => byDate(a, b, ascending: false),
        PlaylistSort.nameAscending => compareTitles(
          a.episode.title,
          b.episode.title,
        ),
      },
    );
    await _writeOrder(playlistId, [for (final e in entries) e.item.episodeId]);
  }

  Future<void> _writeOrder(int playlistId, List<int> episodeIds) =>
      _db.batch((batch) {
        for (var i = 0; i < episodeIds.length; i++) {
          batch.update(
            _db.playlistItems,
            PlaylistItemsCompanion(position: Value(i)),
            where: (item) =>
                item.playlistId.equals(playlistId) &
                item.episodeId.equals(episodeIds[i]),
          );
        }
      });

  /// "Als nächstes spielen": puts [episodeId] directly behind
  /// [afterEpisodeId]; an entry already in the playlist is moved there.
  /// Without [afterEpisodeId] in the playlist it goes to the end.
  Future<void> insertAfter(
    int playlistId,
    int episodeId, {
    required int afterEpisodeId,
  }) => _db.transaction(() async {
    await add(playlistId, episodeId);
    final ids = (await entries(
      playlistId,
    )).map((e) => e.item.episodeId).toList()..remove(episodeId);
    final at = ids.indexOf(afterEpisodeId);
    ids.insert(at < 0 ? ids.length : at + 1, episodeId);
    await _writeOrder(playlistId, ids);
  });

  /// Moves the entry at [oldIndex] to [newIndex] (display order; [newIndex]
  /// is the final index, as ReorderableListView.onReorderItem reports it).
  Future<void> move(int playlistId, int oldIndex, int newIndex) async {
    final ids = (await entries(playlistId))
        .map((e) => e.item.episodeId)
        .toList();
    if (oldIndex < 0 || oldIndex >= ids.length) return;
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex.clamp(0, ids.length), moved);
    await _writeOrder(playlistId, ids);
  }
}
