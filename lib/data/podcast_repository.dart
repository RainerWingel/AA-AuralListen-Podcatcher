import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'db/app_database.dart';
import 'feed/feed_fetcher.dart';
import 'feed/rss_parser.dart';
import 'storage/cover_cache.dart';

enum SubscribeError { invalidUrl, alreadySubscribed, network, notAFeed }

class SubscribeException implements Exception {
  const SubscribeException(this.error, {this.existingPodcastId});

  final SubscribeError error;

  /// Set for [SubscribeError.alreadySubscribed].
  final int? existingPodcastId;

  @override
  String toString() => 'SubscribeException: $error';
}

typedef RefreshSummary = ({int succeeded, int failed});

/// One theme (sub-series) of a podcast with its newest episode's image.
typedef PodcastTheme = ({
  String theme,
  int count,
  String? imageUrl,
  DateTime? latest,
});

/// Themes selected for auto-download; null = all (column is JSON).
Set<String>? autoDownloadThemesOf(Podcast podcast) {
  final json = podcast.autoDownloadThemes;
  if (json == null) return null;
  return {...(jsonDecode(json) as List<Object?>).whereType<String>()};
}

/// Removes downloaded files of a podcast before it is unsubscribed
/// (implemented by the DownloadService).
abstract interface class PodcastFilesCleaner {
  Future<void> deleteForPodcast(int podcastId);
}

/// Subscriptions, feed refresh and episode queries.
class PodcastRepository {
  PodcastRepository({
    required this._db,
    required this._fetcher,
    required this._clock,
    required this._coverCache,
    this._parser = const RssParser(),
    this._filesCleaner,
  });

  final AppDatabase _db;
  final FeedFetcher _fetcher;
  final Clock _clock;
  final CoverCache _coverCache;
  final RssParser _parser;
  final PodcastFilesCleaner? _filesCleaner;

  /// Parallel feed downloads during a refresh.
  static const refreshConcurrency = 4;

  Future<RefreshSummary>? _runningRefresh;

  // ---------------------------------------------------------------- queries

  Stream<List<Podcast>> watchPodcasts() =>
      (_db.select(_db.podcasts)..orderBy([
            (p) => OrderingTerm(expression: p.title.collate(Collate.noCase)),
          ]))
          .watch();

  Stream<Podcast?> watchPodcast(int id) => (_db.select(
    _db.podcasts,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();

  Stream<List<Episode>> watchEpisodes(int podcastId) =>
      (_db.select(_db.episodes)
            ..where((e) => e.podcastId.equals(podcastId))
            ..orderBy([
              (e) => OrderingTerm(
                expression: e.pubDate,
                mode: OrderingMode.desc,
                nulls: NullsOrder.last,
              ),
            ]))
          .watch();

  /// Newest episodes across all subscriptions (home screen).
  Stream<List<EpisodeWithPodcast>> watchLatestEpisodes({int limit = 100}) {
    final query =
        _db.select(_db.episodes).join([
            innerJoin(
              _db.podcasts,
              _db.podcasts.id.equalsExp(_db.episodes.podcastId),
            ),
          ])
          ..orderBy([
            OrderingTerm(
              expression: _db.episodes.pubDate,
              mode: OrderingMode.desc,
              nulls: NullsOrder.last,
            ),
          ])
          ..limit(limit);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            episode: row.readTable(_db.episodes),
            podcast: row.readTable(_db.podcasts),
          ),
      ],
    );
  }

  // ---------------------------------------------------------- subscriptions

  /// Subscribes to the feed at [rawUrl] and returns the new podcast id.
  /// Throws [SubscribeException].
  Future<int> subscribe(String rawUrl) async {
    final url = normalizeFeedUrl(rawUrl);
    if (url == null) throw const SubscribeException(SubscribeError.invalidUrl);
    await _throwIfSubscribed(url.toString());

    final FeedFetched result;
    try {
      final fetched = await _fetcher.fetch(url);
      // A fresh request without validators cannot return 304.
      if (fetched is! FeedFetched) {
        throw const SubscribeException(SubscribeError.network);
      }
      result = fetched;
    } on FeedFetchException {
      throw const SubscribeException(SubscribeError.network);
    }

    final ParsedFeed feed;
    try {
      feed = _parser.parse(result.body);
    } on FeedFormatException {
      throw const SubscribeException(SubscribeError.notAFeed);
    }

    final feedUrl = result.movedPermanently
        ? result.finalUrl.toString()
        : url.toString();
    if (feedUrl != url.toString()) await _throwIfSubscribed(feedUrl);

    final now = _clock();
    return _db.transaction(() async {
      final id = await _db
          .into(_db.podcasts)
          .insert(
            PodcastsCompanion.insert(
              feedUrl: feedUrl,
              title: feed.title,
              author: Value(feed.author),
              description: Value(feed.description),
              imageUrl: Value(feed.imageUrl),
              websiteUrl: Value(feed.websiteUrl),
              etag: Value(result.etag),
              lastModified: Value(result.lastModified),
              lastRefreshAt: Value(now),
              subscribedAt: now,
            ),
          );
      await _upsertEpisodes(id, feed.episodes, now);
      return id;
    });
  }

  /// Deletes the podcast, its episodes (cascade) and its cached cover images.
  Future<void> unsubscribe(int podcastId) async {
    final podcast = await (_db.select(
      _db.podcasts,
    )..where((p) => p.id.equals(podcastId))).getSingleOrNull();
    if (podcast == null) return;

    final episodeImages =
        await (_db.selectOnly(_db.episodes, distinct: true)
              ..addColumns([_db.episodes.imageUrl])
              ..where(
                _db.episodes.podcastId.equals(podcastId) &
                    _db.episodes.imageUrl.isNotNull(),
              ))
            .map((row) => row.read(_db.episodes.imageUrl)!)
            .get();

    // Files first: afterwards the cascade delete removes the download rows.
    await _filesCleaner?.deleteForPodcast(podcastId);
    await (_db.delete(_db.podcasts)..where((p) => p.id.equals(podcastId))).go();

    for (final url in {?podcast.imageUrl, ...episodeImages}) {
      await _coverCache.evict(url);
    }
  }

  /// Themes of a podcast, newest first (only for network feeds with themes).
  Stream<List<PodcastTheme>> watchThemes(int podcastId) {
    final query = _db.selectOnly(_db.episodes)
      ..addColumns([
        _db.episodes.theme,
        _db.episodes.imageUrl,
        _db.episodes.pubDate,
      ])
      ..where(
        _db.episodes.podcastId.equals(podcastId) &
            _db.episodes.theme.isNotNull(),
      )
      ..orderBy([
        OrderingTerm(
          expression: _db.episodes.pubDate,
          mode: OrderingMode.desc,
          nulls: NullsOrder.last,
        ),
      ]);
    return query.watch().map((rows) {
      // Rows come newest first: the first row per theme has its latest image.
      final themes = <String, PodcastTheme>{};
      for (final row in rows) {
        final theme = row.read(_db.episodes.theme)!;
        final known = themes[theme];
        themes[theme] = known == null
            ? (
                theme: theme,
                count: 1,
                imageUrl: row.read(_db.episodes.imageUrl),
                latest: row.read(_db.episodes.pubDate),
              )
            : (
                theme: theme,
                count: known.count + 1,
                imageUrl: known.imageUrl,
                latest: known.latest,
              );
      }
      return themes.values.toList();
    });
  }

  /// Auto-download only these themes; null = all.
  Future<void> setAutoDownloadThemes(int podcastId, Set<String>? themes) =>
      _updatePodcast(
        podcastId,
        PodcastsCompanion(
          autoDownloadThemes: Value(
            themes == null ? null : jsonEncode(themes.toList()..sort()),
          ),
        ),
      );

  /// Per-podcast download settings (podcast settings sheet).
  Future<void> updatePodcastSettings(
    int podcastId, {
    AutoDownloadMode? autoDownloadMode,
    int? autoDownloadMaxEpisodes,
    bool? autoDeletePlayed,
  }) => _updatePodcast(
    podcastId,
    PodcastsCompanion(
      autoDownloadMode: Value.absentIfNull(autoDownloadMode),
      autoDownloadMaxEpisodes: Value.absentIfNull(autoDownloadMaxEpisodes),
      autoDeletePlayed: Value.absentIfNull(autoDeletePlayed),
    ),
  );

  // ---------------------------------------------------------------- refresh

  /// Refreshes all feeds. Never throws; errors are stored per podcast.
  /// Concurrent calls (app start + pull-to-refresh) share one run.
  Future<RefreshSummary> refreshAll() => _runningRefresh ??= _refreshAll()
      .whenComplete(() => _runningRefresh = null);

  Future<RefreshSummary> _refreshAll() async {
    final podcasts = await _db.select(_db.podcasts).get();
    final queue = podcasts.iterator;
    var succeeded = 0;
    var failed = 0;

    Future<void> worker() async {
      while (queue.moveNext()) {
        if (await refreshPodcast(queue.current)) {
          succeeded++;
        } else {
          failed++;
        }
      }
    }

    await Future.wait([for (var i = 0; i < refreshConcurrency; i++) worker()]);
    return (succeeded: succeeded, failed: failed);
  }

  /// Refreshes one feed. Returns false (and stores the error) on failure.
  Future<bool> refreshPodcast(Podcast podcast) async {
    final now = _clock();
    try {
      final result = await _fetcher.fetch(
        Uri.parse(podcast.feedUrl),
        etag: podcast.etag,
        lastModified: podcast.lastModified,
      );

      switch (result) {
        case FeedNotModified():
          await _updatePodcast(
            podcast.id,
            PodcastsCompanion(
              lastRefreshAt: Value(now),
              lastError: const Value(null),
            ),
          );
        case FeedFetched():
          final feed = _parser.parse(result.body);
          final newUrl = result.movedPermanently
              ? result.finalUrl.toString()
              : null;
          final urlIsFree =
              newUrl != null &&
              !await _isSubscribed(newUrl, except: podcast.id);
          await _db.transaction(() async {
            await _updatePodcast(
              podcast.id,
              PodcastsCompanion(
                feedUrl: urlIsFree ? Value(newUrl) : const Value.absent(),
                title: Value(feed.title),
                author: Value(feed.author),
                description: Value(feed.description),
                imageUrl: Value(feed.imageUrl),
                websiteUrl: Value(feed.websiteUrl),
                etag: Value(result.etag),
                lastModified: Value(result.lastModified),
                lastRefreshAt: Value(now),
                lastError: const Value(null),
              ),
            );
            await _upsertEpisodes(podcast.id, feed.episodes, now);
          });
      }
      return true;
    } on Exception catch (e) {
      await _updatePodcast(
        podcast.id,
        PodcastsCompanion(lastError: Value('$e')),
      );
      return false;
    }
  }

  // ---------------------------------------------------------------- helpers

  Future<void> _updatePodcast(int id, PodcastsCompanion changes) =>
      (_db.update(_db.podcasts)..where((p) => p.id.equals(id))).write(changes);

  /// Inserts new episodes and updates feed metadata of known ones.
  /// Listening state (status, position) is never touched here.
  Future<void> _upsertEpisodes(
    int podcastId,
    List<ParsedEpisode> episodes,
    DateTime now,
  ) => _db.batch((batch) {
    for (final e in episodes) {
      batch.insert(
        _db.episodes,
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: e.guid,
          title: e.title,
          audioUrl: e.audioUrl,
          audioMimeType: Value(e.audioMimeType),
          audioSizeBytes: Value(e.audioSizeBytes),
          description: Value(e.description),
          durationMs: Value(e.duration?.inMilliseconds),
          pubDate: Value(e.pubDate),
          imageUrl: Value(e.imageUrl),
          chaptersUrl: Value(e.chaptersUrl),
          theme: Value(e.theme),
          addedAt: now,
        ),
        onConflict: DoUpdate(
          (_) => EpisodesCompanion(
            title: Value(e.title),
            audioUrl: Value(e.audioUrl),
            audioMimeType: Value(e.audioMimeType),
            audioSizeBytes: Value(e.audioSizeBytes),
            description: Value(e.description),
            durationMs: Value(e.duration?.inMilliseconds),
            pubDate: Value(e.pubDate),
            imageUrl: Value(e.imageUrl),
            chaptersUrl: Value(e.chaptersUrl),
            theme: Value(e.theme),
          ),
          target: [_db.episodes.podcastId, _db.episodes.guid],
        ),
      );
    }
  });

  Future<bool> _isSubscribed(String feedUrl, {int? except}) async {
    final query = _db.select(_db.podcasts)
      ..where((p) => p.feedUrl.equals(feedUrl));
    if (except != null) query.where((p) => p.id.equals(except).not());
    return (await query.get()).isNotEmpty;
  }

  Future<void> _throwIfSubscribed(String feedUrl) async {
    final existing = await (_db.select(
      _db.podcasts,
    )..where((p) => p.feedUrl.equals(feedUrl))).getSingleOrNull();
    if (existing != null) {
      throw SubscribeException(
        SubscribeError.alreadySubscribed,
        existingPodcastId: existing.id,
      );
    }
  }
}

/// Trims user input, adds `https://` if the scheme is missing and turns
/// `feed://`/`itpc://`/`pcast://` links into https. Returns null if invalid.
Uri? normalizeFeedUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  text = text.replaceFirst(
    RegExp(r'^(feed|itpc|pcast|podcast)://', caseSensitive: false),
    'https://',
  );
  if (!text.contains('://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      uri.host.isEmpty ||
      !uri.host.contains('.')) {
    return null;
  }
  return uri;
}
