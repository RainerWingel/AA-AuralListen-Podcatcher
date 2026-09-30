import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'db/app_database.dart';
import 'episode_numbers.dart';
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

/// [moved]: podcasts whose feed address changed (docs/feeds-and-directories.md).
typedef RefreshSummary = ({int succeeded, int failed, int moved});

enum RefreshOutcome { updated, moved, failed }

/// A feed that was fetched and parsed, with the address to store for it.
typedef _LoadedFeed = ({String url, FeedFetched fetched, ParsedFeed feed});

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

/// "Fresh": fetched by a refresh within [PodcastRepository.freshFor]; the
/// initial import when subscribing never counts (docs/playlists.md). Same
/// rule as the SQL in [PodcastRepository.unplayedEpisodes].
bool isFreshEpisode(Episode episode, Podcast podcast, DateTime now) =>
    episode.addedAt.isAfter(podcast.subscribedAt) &&
    !episode.addedAt.isBefore(now.subtract(PodcastRepository.freshFor));

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

  /// How long an episode counts as "fresh" after it was first fetched.
  static const freshFor = Duration(hours: 96);

  /// Unplayed episodes (new or in progress) of a podcast, oldest first – for
  /// "Alle ungespielten Episoden spielen". With [freshOnly] only those a
  /// refresh fetched within [freshFor] ("Alle neuen Episoden spielen"); the
  /// initial import when subscribing never counts as fresh (docs/playlists.md).
  /// With [since] only those published at or after it ("Ungespielte Episoden
  /// seit … spielen"); episodes without a date are left out then.
  /// With [theme] only episodes of that sub-series (network feeds, long press
  /// on a topic in the podcast settings).
  Future<List<Episode>> unplayedEpisodes(
    int podcastId, {
    required bool freshOnly,
    DateTime? since,
    String? theme,
  }) async {
    final podcast = await (_db.select(
      _db.podcasts,
    )..where((p) => p.id.equals(podcastId))).getSingleOrNull();
    if (podcast == null) return const [];
    final query = _db.select(_db.episodes)
      ..where(
        (e) =>
            e.podcastId.equals(podcastId) &
            e.status.equalsValue(EpisodeStatus.played).not(),
      )
      ..orderBy([
        (e) => OrderingTerm(expression: e.pubDate, nulls: NullsOrder.first),
        (e) => OrderingTerm.asc(e.id),
      ]);
    if (since != null) {
      query.where((e) => e.pubDate.isBiggerOrEqualValue(since));
    }
    if (theme != null) {
      query.where((e) => e.theme.equals(theme));
    }
    if (freshOnly) {
      query.where(
        (e) =>
            e.addedAt.isBiggerOrEqualValue(_clock().subtract(freshFor)) &
            e.addedAt.isBiggerThanValue(podcast.subscribedAt),
      );
    }
    return query.get();
  }

  /// Unplayed episodes (new or in progress) per podcast id, for the badges
  /// in the subscriptions grid. One grouped query for all podcasts; podcasts
  /// without unplayed episodes are missing from the map.
  Stream<Map<int, int>> watchUnplayedCounts() {
    final count = _db.episodes.id.count();
    final query = _db.selectOnly(_db.episodes)
      ..addColumns([_db.episodes.podcastId, count])
      ..where(_db.episodes.status.equalsValue(EpisodeStatus.played).not())
      ..groupBy([_db.episodes.podcastId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(_db.episodes.podcastId)!: row.read(count) ?? 0,
      },
    );
  }

  /// Search in the subscriptions (Abos tab): episodes whose title or show
  /// notes contain [query]. Title matches first, then newest first; at most
  /// [limit] (the list is for finding, not browsing). SQLite's LIKE ignores
  /// case for ASCII letters only, so "ä"/"Ä" still differ here.
  Future<List<EpisodeWithPodcast>> searchEpisodes(
    String query, {
    int limit = 50,
  }) async {
    final text = query.trim();
    if (text.isEmpty) return const [];
    // Escape LIKE wildcards typed by the user.
    final escaped = text
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final pattern = '%$escaped%';
    final inTitle = _db.episodes.title.like(pattern, escapeChar: r'\');
    final inNotes = _db.episodes.description.like(pattern, escapeChar: r'\');
    final rows =
        await (_db.select(_db.episodes).join([
                innerJoin(
                  _db.podcasts,
                  _db.podcasts.id.equalsExp(_db.episodes.podcastId),
                ),
              ])
              ..where(inTitle | inNotes)
              ..orderBy([
                OrderingTerm(
                  expression: CaseWhenExpression(
                    cases: [CaseWhen(inTitle, then: const Constant(0))],
                    orElse: const Constant(1),
                  ),
                ),
                OrderingTerm(
                  expression: _db.episodes.pubDate,
                  mode: OrderingMode.desc,
                  nulls: NullsOrder.last,
                ),
              ])
              ..limit(limit))
            .get();
    return [
      for (final row in rows)
        (
          episode: row.readTable(_db.episodes),
          podcast: row.readTable(_db.podcasts),
        ),
    ];
  }

  /// Cover numbers of one podcast's episodes (episode id → number), updated
  /// on refresh and when the counter settings change. Empty when the counter
  /// is switched off for this podcast.
  Stream<Map<int, int>> watchEpisodeNumbers(int podcastId) {
    final e = _db.episodes;
    final p = _db.podcasts;
    final query =
        _db.selectOnly(e).join([innerJoin(p, p.id.equalsExp(e.podcastId))])
          ..addColumns([
            e.id,
            e.pubDate,
            e.episodeNumber,
            p.episodeCounter,
            p.episodeNumberOffset,
            p.episodeOwnCount,
          ])
          ..where(e.podcastId.equals(podcastId));
    return query.watch().map((rows) {
      if (rows.isEmpty || rows.first.read(p.episodeCounter) != true) {
        return const <int, int>{};
      }
      return episodeNumbers(
        [
          for (final r in rows)
            (
              id: r.read(e.id)!,
              pubDate: r.read(e.pubDate),
              feedNumber: r.read(e.episodeNumber),
            ),
        ],
        offset: rows.first.read(p.episodeNumberOffset) ?? 0,
        ownCount: rows.first.read(p.episodeOwnCount) ?? false,
      );
    });
  }

  /// Whether the feed numbers its episodes itself (then the podcast settings
  /// offer the choice between its numbers and the app's own count).
  Stream<bool> watchHasFeedNumbers(int podcastId) =>
      (_db.selectOnly(_db.episodes)
            ..addColumns([_db.episodes.id])
            ..where(
              _db.episodes.podcastId.equals(podcastId) &
                  _db.episodes.episodeNumber.isNotNull(),
            )
            ..limit(1))
          .watch()
          .map((rows) => rows.isNotEmpty);

  /// Episode counter on the covers: on/off, own count instead of the feed's
  /// numbers, and offset (−9999 … 9999).
  Future<void> setEpisodeCounter(
    int podcastId, {
    bool? enabled,
    bool? ownCount,
    int? offset,
  }) => _updatePodcast(
    podcastId,
    PodcastsCompanion(
      episodeCounter: Value.absentIfNull(enabled),
      episodeOwnCount: Value.absentIfNull(ownCount),
      episodeNumberOffset: Value.absentIfNull(offset?.clamp(-9999, 9999)),
    ),
  );

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

    _LoadedFeed loaded;
    try {
      loaded = await _loadFeed(url);
    } on FeedFetchException {
      throw const SubscribeException(SubscribeError.network);
    } on FeedFormatException {
      throw const SubscribeException(SubscribeError.notAFeed);
    }
    // An old address whose feed announces a move: subscribe to the new one.
    if (loaded.feed.newFeedUrl case final announced?) {
      final target = normalizeFeedUrl(announced);
      if (target != null && target.toString() != loaded.url) {
        try {
          loaded = await _loadFeed(target);
        } on Exception {
          // New address not working (yet): keep the old one.
        }
      }
    }
    if (loaded.url != url.toString()) await _throwIfSubscribed(loaded.url);
    final (url: feedUrl, fetched: result, :feed) = loaded;

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

  /// Playlist for auto-downloaded episodes of this podcast (null = none).
  /// The name is kept so a deleted playlist can be created again.
  Future<void> setAutoPlaylist(int podcastId, Playlist? playlist) =>
      _updatePodcast(
        podcastId,
        PodcastsCompanion(
          autoPlaylistId: Value(playlist?.id),
          autoPlaylistName: Value(playlist?.name),
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
    var moved = 0;

    Future<void> worker() async {
      while (queue.moveNext()) {
        switch (await refreshPodcast(queue.current)) {
          case RefreshOutcome.updated:
            succeeded++;
          case RefreshOutcome.moved:
            succeeded++;
            moved++;
          case RefreshOutcome.failed:
            failed++;
        }
      }
    }

    await Future.wait([for (var i = 0; i < refreshConcurrency; i++) worker()]);
    return (succeeded: succeeded, failed: failed, moved: moved);
  }

  /// Refreshes one feed and follows a move of the podcast: permanent HTTP
  /// redirects and `<itunes:new-feed-url>`. Never throws; on failure the
  /// error is stored in `lastError`.
  Future<RefreshOutcome> refreshPodcast(Podcast podcast) async {
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
          return RefreshOutcome.updated;
        case FeedFetched():
          final original = (
            url: result.movedPermanently
                ? result.finalUrl.toString()
                : podcast.feedUrl,
            fetched: result,
            feed: _parser.parse(result.body),
          );
          var loaded =
              await _followAnnouncedMove(podcast, original) ?? original;
          // Never take over the address of another subscription.
          if (loaded.url != podcast.feedUrl &&
              await _isSubscribed(loaded.url, except: podcast.id)) {
            loaded = (
              url: podcast.feedUrl,
              fetched: original.fetched,
              feed: original.feed,
            );
          }
          final moved = loaded.url != podcast.feedUrl;
          await _storeFeed(podcast.id, loaded, now);
          return moved ? RefreshOutcome.moved : RefreshOutcome.updated;
      }
    } on Exception catch (e) {
      await _updatePodcast(
        podcast.id,
        PodcastsCompanion(lastError: Value('$e')),
      );
      return RefreshOutcome.failed;
    }
  }

  /// Loads the feed announced in `<itunes:new-feed-url>`, or returns null
  /// when there is no usable announcement. If the new address does not work
  /// (yet), the old feed stays in use and the move is retried next time.
  Future<_LoadedFeed?> _followAnnouncedMove(
    Podcast podcast,
    _LoadedFeed current,
  ) async {
    final announced = current.feed.newFeedUrl;
    if (announced == null) return null;
    final target = normalizeFeedUrl(announced);
    if (target == null || target.toString() == current.url) return null;
    if (await _isSubscribed(target.toString(), except: podcast.id)) {
      return null;
    }
    try {
      final loaded = await _loadFeed(target);
      // A new feed pointing back would make the podcast jump back and forth.
      final back = loaded.feed.newFeedUrl;
      if (back != null &&
          {
            podcast.feedUrl,
            current.url,
          }.contains(normalizeFeedUrl(back)?.toString())) {
        return null;
      }
      return loaded;
    } on Exception {
      return null;
    }
  }

  /// Fetches and parses [url] without validators; follows permanent
  /// redirects. Throws [FeedFetchException] or [FeedFormatException].
  Future<_LoadedFeed> _loadFeed(Uri url) async {
    final fetched = await _fetcher.fetch(url);
    // A request without validators cannot return 304.
    if (fetched is! FeedFetched) {
      throw const FeedFetchException('Unexpected 304');
    }
    return (
      url: fetched.movedPermanently
          ? fetched.finalUrl.toString()
          : url.toString(),
      fetched: fetched,
      feed: _parser.parse(fetched.body),
    );
  }

  /// Writes feed metadata and episodes (listening state stays untouched).
  Future<void> _storeFeed(int podcastId, _LoadedFeed loaded, DateTime now) =>
      _db.transaction(() async {
        final feed = loaded.feed;
        await _updatePodcast(
          podcastId,
          PodcastsCompanion(
            feedUrl: Value(loaded.url),
            title: Value(feed.title),
            author: Value(feed.author),
            description: Value(feed.description),
            imageUrl: Value(feed.imageUrl),
            websiteUrl: Value(feed.websiteUrl),
            etag: Value(loaded.fetched.etag),
            lastModified: Value(loaded.fetched.lastModified),
            lastRefreshAt: Value(now),
            lastError: const Value(null),
          ),
        );
        await _upsertEpisodes(podcastId, feed.episodes, now);
      });

  /// Manually points a subscription to a new feed address (the publisher
  /// moved without redirect or announcement). The new feed must load;
  /// episodes are matched by guid, so the listening state stays.
  /// Throws [SubscribeException].
  Future<void> changeFeedUrl(int podcastId, String rawUrl) async {
    final url = normalizeFeedUrl(rawUrl);
    if (url == null) throw const SubscribeException(SubscribeError.invalidUrl);
    await _throwIfSubscribed(url.toString(), except: podcastId);

    final _LoadedFeed loaded;
    try {
      loaded = await _loadFeed(url);
    } on FeedFetchException {
      throw const SubscribeException(SubscribeError.network);
    } on FeedFormatException {
      throw const SubscribeException(SubscribeError.notAFeed);
    }
    await _throwIfSubscribed(loaded.url, except: podcastId);
    await _storeFeed(podcastId, loaded, _clock());
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
  ) async {
    await _upsertEpisodeRows(podcastId, episodes, now);
    await _storeFeedChapters(podcastId, episodes);
  }

  /// Podlove chapters from the feed – only for episodes without chapters yet,
  /// so a refresh does not rewrite them every time.
  Future<void> _storeFeedChapters(
    int podcastId,
    List<ParsedEpisode> episodes,
  ) async {
    final withChapters = {
      for (final e in episodes)
        if (e.chapters.isNotEmpty) e.guid: e.chapters,
    };
    if (withChapters.isEmpty) return;

    final ids = {
      for (final row
          in await (_db.select(_db.episodes)..where(
                (e) =>
                    e.podcastId.equals(podcastId) &
                    e.guid.isIn(withChapters.keys),
              ))
              .get())
        row.guid: row.id,
    };
    final alreadyStored =
        (await (_db.selectOnly(_db.chapters, distinct: true)
                  ..addColumns([_db.chapters.episodeId])
                  ..where(_db.chapters.episodeId.isIn(ids.values)))
                .map((r) => r.read(_db.chapters.episodeId)!)
                .get())
            .toSet();

    await _db.batch((batch) {
      withChapters.forEach((guid, chapters) {
        final id = ids[guid];
        if (id == null || alreadyStored.contains(id)) return;
        batch.insertAll(_db.chapters, [
          for (final c in chapters)
            ChaptersCompanion.insert(
              episodeId: id,
              startMs: c.start.inMilliseconds,
              title: c.title,
              url: Value(c.url),
              imageUrl: Value(c.imageUrl),
            ),
        ]);
      });
    });
  }

  Future<void> _upsertEpisodeRows(
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
          episodeNumber: Value(e.episodeNumber),
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
            episodeNumber: Value(e.episodeNumber),
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

  Future<void> _throwIfSubscribed(String feedUrl, {int? except}) async {
    final query = _db.select(_db.podcasts)
      ..where((p) => p.feedUrl.equals(feedUrl));
    if (except != null) query.where((p) => p.id.equals(except).not());
    final existing = await query.getSingleOrNull();
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
