import 'dart:io';

import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:aapodcastguru/data/podcast_repository.dart';
import 'package:aapodcastguru/data/storage/cover_cache.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeCoverCache implements CoverCache {
  final evicted = <String>[];

  @override
  Future<void> evict(String url) async => evicted.add(url);
}

void main() {
  late AppDatabase db;
  late _FakeCoverCache coverCache;
  late Map<String, http.Response Function()> server;
  late PodcastRepository repo;
  final now = DateTime.utc(2026, 9, 27, 12);
  late DateTime clockNow; // movable for time-based rules

  final basicFeed = File('test/fixtures/feed_basic.xml').readAsStringSync();

  setUp(() {
    clockNow = now;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    coverCache = _FakeCoverCache();
    server = {};
    final client = MockClient((request) async {
      final handler = server[request.url.toString()];
      return handler == null ? http.Response('', 404) : handler();
    });
    repo = PodcastRepository(
      db: db,
      fetcher: FeedFetcher(client),
      clock: () => clockNow,
      coverCache: coverCache,
    );
  });

  tearDown(() => db.close());

  test('normalizeFeedUrl', () {
    expect(
      normalizeFeedUrl(' example.com/feed '),
      Uri.parse('https://example.com/feed'),
    );
    expect(
      normalizeFeedUrl('feed://example.com/rss'),
      Uri.parse('https://example.com/rss'),
    );
    expect(
      normalizeFeedUrl('http://example.com/rss'),
      Uri.parse('http://example.com/rss'),
    );
    expect(normalizeFeedUrl(''), isNull);
    expect(normalizeFeedUrl('ftp://example.com/x'), isNull);
    expect(normalizeFeedUrl('kein link'), isNull);
  });

  group('subscribe', () {
    test('stores podcast and audio episodes', () async {
      server['https://example.com/feed'] = () => http.Response(
        basicFeed,
        200,
        headers: {
          'etag': '"v1"',
          'content-type': 'application/rss+xml; charset=utf-8',
        },
      );

      final id = await repo.subscribe('example.com/feed');

      final podcast = await repo.watchPodcast(id).first;
      expect(podcast!.title, 'Testpodcast');
      expect(podcast.etag, '"v1"');
      expect(podcast.subscribedAt.isAtSameMomentAs(now), isTrue);

      final episodes = await repo.watchEpisodes(id).first;
      expect(episodes.map((e) => e.title), ['Folge 2', 'Folge 1']);
      expect(
        episodes.every((e) => e.status == EpisodeStatus.newEpisode),
        isTrue,
      );
    });

    test(
      'rejects duplicates, invalid URLs, non-feeds and network errors',
      () async {
        server['https://example.com/feed'] = () =>
            http.Response(basicFeed, 200);
        server['https://example.com/html'] = () =>
            http.Response('<html/>', 200);
        final id = await repo.subscribe('https://example.com/feed');

        Future<SubscribeError?> errorOf(String url) async {
          try {
            await repo.subscribe(url);
            return null;
          } on SubscribeException catch (e) {
            return e.error;
          }
        }

        expect(
          await errorOf('https://example.com/feed'),
          SubscribeError.alreadySubscribed,
        );
        expect(await errorOf('nix'), SubscribeError.invalidUrl);
        expect(
          await errorOf('https://example.com/html'),
          SubscribeError.notAFeed,
        );
        expect(
          await errorOf('https://example.com/404'),
          SubscribeError.network,
        );
        expect((await db.select(db.podcasts).get()).map((p) => p.id), [id]);
      },
    );

    test('stores the new URL after a permanent redirect', () async {
      server['https://old.example.com/feed'] = () => http.Response(
        '',
        301,
        headers: {'location': 'https://new.example.com/feed'},
      );
      server['https://new.example.com/feed'] = () =>
          http.Response(basicFeed, 200);

      final id = await repo.subscribe('https://old.example.com/feed');
      expect(
        (await repo.watchPodcast(id).first)!.feedUrl,
        'https://new.example.com/feed',
      );
    });
  });

  group('refresh', () {
    test('adds new episodes and keeps listening state', () async {
      server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
      final id = await repo.subscribe('https://example.com/feed');

      // The user listened to "Folge 2".
      await (db.update(db.episodes)..where((e) => e.guid.equals('ep-2'))).write(
        const EpisodesCompanion(
          status: Value(EpisodeStatus.inProgress),
          positionMs: Value(60000),
        ),
      );

      final updatedFeed = basicFeed
          .replaceFirst(
            '<title>Folge 2</title>',
            '<title>Folge 2 (korrigiert)</title>',
          )
          .replaceFirst(
            '<item>',
            '<item><title>Folge 3</title><guid>ep-3</guid>'
                '<enclosure url="https://example.com/ep3.mp3" type="audio/mpeg"/></item><item>',
          );
      server['https://example.com/feed'] = () =>
          http.Response(updatedFeed, 200);

      final summary = await repo.refreshAll();
      expect(summary, (succeeded: 1, failed: 0, moved: 0));

      final episodes = await repo.watchEpisodes(id).first;
      expect(episodes, hasLength(3));
      final ep2 = episodes.singleWhere((e) => e.guid == 'ep-2');
      expect(ep2.title, 'Folge 2 (korrigiert)');
      expect(ep2.status, EpisodeStatus.inProgress);
      expect(ep2.positionMs, 60000);
    });

    test('stores errors per podcast and clears them after success', () async {
      server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
      final id = await repo.subscribe('https://example.com/feed');

      server['https://example.com/feed'] = () => http.Response('', 500);
      expect(await repo.refreshAll(), (succeeded: 0, failed: 1, moved: 0));
      expect((await repo.watchPodcast(id).first)!.lastError, contains('500'));

      server['https://example.com/feed'] = () => http.Response('', 304);
      expect(await repo.refreshAll(), (succeeded: 1, failed: 0, moved: 0));
      expect((await repo.watchPodcast(id).first)!.lastError, isNull);
    });

    test('concurrent calls share one run', () async {
      var requests = 0;
      server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
      await repo.subscribe('https://example.com/feed');
      server['https://example.com/feed'] = () {
        requests++;
        return http.Response('', 304);
      };

      await Future.wait([repo.refreshAll(), repo.refreshAll()]);
      expect(requests, 1);
    });
  });

  group('podcast moves', () {
    const oldUrl = 'https://old.example.com/feed';
    const newUrl = 'https://new.example.com/feed';

    /// basicFeed announcing a move to [target] (`<itunes:new-feed-url>`).
    String announcing(String target) => basicFeed.replaceFirst(
      '<title>Testpodcast</title>',
      '<title>Testpodcast</title><itunes:new-feed-url>$target</itunes:new-feed-url>',
    );

    /// basicFeed on the new host with one more episode.
    final movedFeed = basicFeed.replaceFirst(
      '<item>',
      '<item><title>Folge 3</title><guid>ep-3</guid>'
          '<enclosure url="https://example.com/ep3.mp3" type="audio/mpeg"/></item><item>',
    );

    Future<int> subscribeOld() async {
      server[oldUrl] = () => http.Response(basicFeed, 200);
      final id = await repo.subscribe(oldUrl);
      await (db.update(db.episodes)..where((e) => e.guid.equals('ep-2'))).write(
        const EpisodesCompanion(
          status: Value(EpisodeStatus.inProgress),
          positionMs: Value(60000),
        ),
      );
      return id;
    }

    Future<Podcast> podcast(int id) async =>
        (await repo.watchPodcast(id).first)!;

    test('refresh follows itunes:new-feed-url and keeps the state', () async {
      final id = await subscribeOld();
      server[oldUrl] = () => http.Response(announcing(newUrl), 200);
      server[newUrl] = () =>
          http.Response(movedFeed, 200, headers: {'etag': '"neu"'});

      expect(await repo.refreshAll(), (succeeded: 1, failed: 0, moved: 1));

      final p = await podcast(id);
      expect(p.feedUrl, newUrl);
      expect(p.etag, '"neu"');
      final episodes = await repo.watchEpisodes(id).first;
      expect(episodes, hasLength(3));
      expect(episodes.singleWhere((e) => e.guid == 'ep-2').positionMs, 60000);

      // Next refresh asks only the new address.
      server.remove(oldUrl);
      expect(await repo.refreshAll(), (succeeded: 1, failed: 0, moved: 0));
    });

    test('a permanent redirect counts as a move', () async {
      final id = await subscribeOld();
      server[oldUrl] = () =>
          http.Response('', 301, headers: {'location': newUrl});
      server[newUrl] = () => http.Response(basicFeed, 200);

      expect(await repo.refreshAll(), (succeeded: 1, failed: 0, moved: 1));
      expect((await podcast(id)).feedUrl, newUrl);
    });

    test('broken new address: keeps the old one without error', () async {
      final id = await subscribeOld();
      server[oldUrl] = () => http.Response(announcing(newUrl), 200);
      server[newUrl] = () => http.Response('', 500);

      expect(await repo.refreshAll(), (succeeded: 1, failed: 0, moved: 0));
      final p = await podcast(id);
      expect(p.feedUrl, oldUrl);
      expect(p.lastError, isNull);
    });

    test('never takes over the address of another subscription', () async {
      final id = await subscribeOld();
      server[newUrl] = () =>
          http.Response(basicFeed.replaceFirst('Testpodcast', 'Anderer'), 200);
      await repo.subscribe(newUrl);
      server[oldUrl] = () => http.Response(announcing(newUrl), 200);

      expect(await repo.refreshAll(), (succeeded: 2, failed: 0, moved: 0));
      final p = await podcast(id);
      expect(p.feedUrl, oldUrl);
      expect(p.title, 'Testpodcast');
    });

    test('ignores feeds that point at each other', () async {
      final id = await subscribeOld();
      server[oldUrl] = () => http.Response(announcing(newUrl), 200);
      server[newUrl] = () => http.Response(announcing(oldUrl), 200);

      expect(await repo.refreshAll(), (succeeded: 1, failed: 0, moved: 0));
      expect((await podcast(id)).feedUrl, oldUrl);
    });

    test('subscribing to the old address uses the new one', () async {
      server[oldUrl] = () => http.Response(announcing(newUrl), 200);
      server[newUrl] = () => http.Response(movedFeed, 200);

      final id = await repo.subscribe(oldUrl);
      expect((await podcast(id)).feedUrl, newUrl);
      expect(await repo.watchEpisodes(id).first, hasLength(3));
    });

    test('changeFeedUrl switches the address and keeps the state', () async {
      final id = await subscribeOld();
      server[newUrl] = () => http.Response(movedFeed, 200);

      await repo.changeFeedUrl(id, 'new.example.com/feed');

      expect((await podcast(id)).feedUrl, newUrl);
      final episodes = await repo.watchEpisodes(id).first;
      expect(episodes, hasLength(3));
      expect(
        episodes.singleWhere((e) => e.guid == 'ep-2').status,
        EpisodeStatus.inProgress,
      );
    });

    test('changeFeedUrl rejects bad addresses, keeps the old one', () async {
      final id = await subscribeOld();
      server['https://other.example.com/feed'] = () =>
          http.Response(basicFeed.replaceFirst('Testpodcast', 'Anderer'), 200);
      await repo.subscribe('https://other.example.com/feed');
      server['https://example.com/page'] = () =>
          http.Response('<html></html>', 200);

      Future<SubscribeError?> errorOf(String url) async {
        try {
          await repo.changeFeedUrl(id, url);
          return null;
        } on SubscribeException catch (e) {
          return e.error;
        }
      }

      expect(await errorOf('kein url'), SubscribeError.invalidUrl);
      expect(
        await errorOf('https://other.example.com/feed'),
        SubscribeError.alreadySubscribed,
      );
      expect(await errorOf('https://example.com/404'), SubscribeError.network);
      expect(
        await errorOf('https://example.com/page'),
        SubscribeError.notAFeed,
      );
      expect((await podcast(id)).feedUrl, oldUrl);
    });
  });

  test(
    'searchEpisodes: title matches first, notes too, wildcards literal',
    () async {
      final podcastId = await db
          .into(db.podcasts)
          .insert(
            PodcastsCompanion.insert(
              feedUrl: 'https://example.com/s',
              title: 'CRE',
              subscribedAt: clockNow,
            ),
          );
      Future<void> add(String title, String? notes, int year) async {
        final id = await db
            .into(db.episodes)
            .insert(
              EpisodesCompanion.insert(
                podcastId: podcastId,
                guid: title,
                title: title,
                audioUrl: 'https://example.com/$title.mp3',
                pubDate: Value(DateTime.utc(year)),
                addedAt: clockNow,
              ),
            );
        if (notes != null) {
          await db
              .into(db.episodeNotes)
              .insert(
                EpisodeNotesCompanion.insert(
                  episodeId: Value(id),
                  notes: notes,
                ),
              );
        }
      }

      await add('CRE195 Das Gehirn', null, 2012);
      await add('CRE200 Neuronen', 'Wie das Gehirn lernt', 2014);
      await add('CRE201 Sterne', 'Astronomie', 2015);
      await add('100% Rabatt', null, 2016);

      Future<List<String>> titles(String q) async =>
          (await repo.searchEpisodes(q)).map((e) => e.episode.title).toList();
      // Case-insensitive; the title match comes before the newer notes match.
      expect(await titles('gehirn'), ['CRE195 Das Gehirn', 'CRE200 Neuronen']);
      expect(await titles('%'), ['100% Rabatt']);
      expect(await titles('_'), isEmpty);
      expect(await titles('  '), isEmpty);
    },
  );

  test('watchEpisodeNumbers follows switch and offset', () async {
    final podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/n',
            title: 'N',
            subscribedAt: clockNow,
          ),
        );
    Future<int> add(String guid, int day) => db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: guid,
            title: guid,
            audioUrl: 'https://example.com/$guid.mp3',
            pubDate: Value(DateTime.utc(2026, 1, day)),
            addedAt: clockNow,
          ),
        );
    final first = await add('a', 1);
    final second = await add('b', 2);
    Future<Map<int, String>> numbers() =>
        repo.watchEpisodeNumbers(podcastId).first;

    expect(await numbers(), {first: '1', second: '2'});
    await repo.setEpisodeCounter(podcastId, offset: -1);
    expect(await numbers(), {first: '0', second: '1'});
    await repo.setEpisodeCounter(podcastId, offset: 20000); // clamped
    expect(await numbers(), {first: '10000', second: '10001'});
    await repo.setEpisodeCounter(podcastId, enabled: false);
    expect(await numbers(), isEmpty);
    expect(await repo.watchHasFeedNumbers(podcastId).first, isFalse);
  });

  group('seasons and serial podcasts', () {
    late int podcastId;
    Future<int> add(String guid, {int? season, int? number, int day = 1}) => db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: guid,
            title: guid,
            audioUrl: 'https://example.com/$guid.mp3',
            season: Value(season),
            episodeNumber: Value(number),
            pubDate: Value(DateTime.utc(2026, 1, day)),
            addedAt: clockNow,
          ),
        );

    setUp(() async {
      podcastId = await db
          .into(db.podcasts)
          .insert(
            PodcastsCompanion.insert(
              feedUrl: 'https://example.com/s',
              title: 'S',
              subscribedAt: clockNow,
            ),
          );
    });

    test('cover labels per season; own count is ignored', () async {
      final a = await add('a', season: 1, number: 1, day: 1);
      final b = await add('b', season: 2, number: 1, day: 5);
      final trailer = await add('t', season: 2, day: 4);
      final loose = await add('x', day: 6);
      await repo.setEpisodeCounter(podcastId, ownCount: true, offset: 10);
      expect(await repo.watchEpisodeNumbers(podcastId).first, {
        a: 'S1·1',
        b: 'S2·1',
        trailer: 'S2',
      });
      expect(loose, isPositive); // no season, no number → no label
      expect(await repo.watchSeasons(podcastId).first, [1, 2]);
    });

    test('a single season is ignored (stray tags, "Hi Freaks")', () async {
      final tagged = await add('t', season: 1, number: 83, day: 2);
      final plain = await add('p', day: 1);
      await repo.setEpisodeCounter(podcastId, ownCount: true, offset: 100);
      // Own count with offset still applies, no "S1·" labels, no chips.
      expect(await repo.watchEpisodeNumbers(podcastId).first, {
        plain: '101',
        tagged: '102',
      });
      expect(await repo.watchSeasons(podcastId).first, isEmpty);
    });

    test('serial: listening order in lists and "play all"', () async {
      // Published out of order on purpose.
      final s2e1 = await add('s2e1', season: 2, number: 1, day: 1);
      final s1e2 = await add('s1e2', season: 1, number: 2, day: 2);
      final s1e1 = await add('s1e1', season: 1, number: 1, day: 3);
      Future<List<int>> listed({bool serial = false}) async => [
        for (final e
            in await repo.watchEpisodes(podcastId, serial: serial).first)
          e.id,
      ];
      // Episodic: newest first.
      expect(await listed(), [s1e1, s1e2, s2e1]);
      expect(await listed(serial: true), [s1e1, s1e2, s2e1]);

      await (db.update(db.podcasts)..where((p) => p.id.equals(podcastId)))
          .write(const PodcastsCompanion(serial: Value(true)));
      final unplayed = await repo.unplayedEpisodes(podcastId, freshOnly: false);
      expect(unplayed.map((e) => e.id), [s1e1, s1e2, s2e1]);
      final season2 = await repo.unplayedEpisodes(
        podcastId,
        freshOnly: false,
        season: 2,
      );
      expect(season2.map((e) => e.id), [s2e1]);
    });
  });

  test('unsubscribe deletes episodes and evicts cover images', () async {
    server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
    final id = await repo.subscribe('https://example.com/feed');

    await repo.unsubscribe(id);

    expect(await db.select(db.podcasts).get(), isEmpty);
    expect(await db.select(db.episodes).get(), isEmpty);
    expect(
      coverCache.evicted,
      unorderedEquals([
        'https://example.com/cover.jpg',
        'https://example.com/ep2.jpg',
      ]),
    );
  });

  test('unplayed counts per podcast ignore played episodes', () async {
    server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
    final id = await repo.subscribe('https://example.com/feed');
    expect(await repo.watchUnplayedCounts().first, {id: 2});

    // In progress still counts as unplayed; played does not.
    await (db.update(db.episodes)..where((e) => e.guid.equals('ep-2'))).write(
      const EpisodesCompanion(status: Value(EpisodeStatus.inProgress)),
    );
    expect(await repo.watchUnplayedCounts().first, {id: 2});
    await db
        .update(db.episodes)
        .write(const EpisodesCompanion(status: Value(EpisodeStatus.played)));
    expect(await repo.watchUnplayedCounts().first, isEmpty);
  });

  test(
    'fresh = fetched by a refresh within 96 h, never the initial import',
    () async {
      server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
      final id = await repo.subscribe('https://example.com/feed');
      Future<List<String>> guids({required bool freshOnly}) async => [
        for (final e in await repo.unplayedEpisodes(id, freshOnly: freshOnly))
          e.guid,
      ];
      expect(await guids(freshOnly: true), isEmpty);

      // A refresh an hour later brings two new episodes; one is heard at once.
      clockNow = now.add(const Duration(hours: 1));
      String item(String guid, String date) =>
          '<item><title>$guid</title><guid>$guid</guid>'
          '<pubDate>$date</pubDate>'
          '<enclosure url="https://example.com/$guid.mp3" type="audio/mpeg"/>'
          '</item>';
      server['https://example.com/feed'] = () => http.Response(
        basicFeed.replaceFirst(
          '<item>',
          '${item('ep-4', 'Sat, 26 Sep 2026 10:00:00 +0000')}'
              '${item('ep-3', 'Fri, 25 Sep 2026 10:00:00 +0000')}<item>',
        ),
        200,
      );
      await repo.refreshAll();
      await (db.update(db.episodes)..where((e) => e.guid.equals('ep-4'))).write(
        const EpisodesCompanion(status: Value(EpisodeStatus.played)),
      );

      expect(await guids(freshOnly: true), ['ep-3']);
      // Oldest first; in progress counts as unplayed, played does not.
      await (db.update(db.episodes)..where((e) => e.guid.equals('ep-2'))).write(
        const EpisodesCompanion(status: Value(EpisodeStatus.inProgress)),
      );
      expect(await guids(freshOnly: false), [
        'https://example.com/ep1.mp3',
        'ep-2',
        'ep-3',
      ]);

      // Still fresh 95 h after that refresh, no longer after 96 h.
      clockNow = now.add(const Duration(hours: 96));
      expect(await guids(freshOnly: true), ['ep-3']);
      clockNow = now.add(const Duration(hours: 97, seconds: 1));
      expect(await guids(freshOnly: true), isEmpty);
    },
  );

  test('unplayed since a date: from that moment on, oldest first', () async {
    server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
    final id = await repo.subscribe('https://example.com/feed');
    Future<List<String>> since(DateTime date) async => [
      for (final e in await repo.unplayedEpisodes(
        id,
        freshOnly: false,
        since: date,
      ))
        e.guid,
    ];
    // Folge 1: 3 Jun 2025, Folge 2: 10 Jun 2025.
    expect(await since(DateTime.utc(2025, 6, 4)), ['ep-2']);
    expect(await since(DateTime.utc(2025, 6)), [
      'https://example.com/ep1.mp3',
      'ep-2',
    ]);
    expect(await since(DateTime.utc(2025, 7)), isEmpty);
  });

  test('provisional: not on Start until subscribed', () async {
    server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
    final id = await repo.subscribe(
      'https://example.com/feed',
      provisional: true,
    );
    Future<Podcast> podcast() =>
        (db.select(db.podcasts)..where((p) => p.id.equals(id))).getSingle();
    expect((await podcast()).provisional, isTrue);
    expect(await repo.watchLatestEpisodes().first, isEmpty);

    await repo.confirmSubscription(id);
    expect((await podcast()).provisional, isFalse);
    expect(await repo.watchLatestEpisodes().first, isNotEmpty);
  });

  test('Abos order: best rated first, then by title', () async {
    Future<int> add(String title) => db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/$title',
            title: title,
            subscribedAt: clockNow,
          ),
        );
    final alpha = await add('alpha');
    final beta = await add('Beta');
    final gamma = await add('Gamma');
    await add('delta');
    Future<List<String>> order() async => [
      for (final p in await repo.watchPodcasts().first) p.title,
    ];

    // Unrated: by title, case ignored.
    expect(await order(), ['alpha', 'Beta', 'delta', 'Gamma']);

    await repo.setRating(gamma, 5);
    await repo.setRating(beta, 3);
    await repo.setRating(alpha, 3);
    expect(await order(), ['Gamma', 'alpha', 'Beta', 'delta']);

    // 0 removes the rating; values are kept within 0–5.
    await repo.setRating(gamma, 0);
    await repo.setRating(alpha, 9);
    expect(await order(), ['alpha', 'Beta', 'delta', 'Gamma']);
    expect(
      (await (db.select(
        db.podcasts,
      )..where((p) => p.id.equals(alpha))).getSingle()).rating,
      5,
    );
  });

  test('isFreshEpisode: refresh within 96 h, never the initial import', () {
    final subscribed = DateTime.utc(2026, 9, 1);
    final podcast = Podcast(
      id: 1,
      feedUrl: 'https://example.com/feed',
      title: 'P',
      subscribedAt: subscribed,
      autoDownloadMode: AutoDownloadMode.off,
      autoDownloadMaxEpisodes: 3,
      autoDeletePlayed: true,
      episodeCounter: true,
      episodeNumberOffset: 0,
      episodeOwnCount: false,
      streamVaries: false,
      serial: false,
      rating: 0,
      provisional: false,
    );
    Episode added(DateTime at) => Episode(
      id: 1,
      podcastId: 1,
      guid: 'g',
      title: 't',
      audioUrl: 'https://example.com/a.mp3',
      positionMs: 0,
      status: EpisodeStatus.newEpisode,
      addedAt: at,
    );
    final refreshAt = subscribed.add(const Duration(days: 3));
    expect(isFreshEpisode(added(subscribed), podcast, subscribed), isFalse);
    expect(isFreshEpisode(added(refreshAt), podcast, refreshAt), isTrue);
    expect(
      isFreshEpisode(
        added(refreshAt),
        podcast,
        refreshAt.add(const Duration(hours: 96)),
      ),
      isTrue,
    );
    expect(
      isFreshEpisode(
        added(refreshAt),
        podcast,
        refreshAt.add(const Duration(hours: 96, seconds: 1)),
      ),
      isFalse,
    );
  });

  test('latest episodes across podcasts are sorted by date', () async {
    server['https://example.com/feed'] = () => http.Response(basicFeed, 200);
    await repo.subscribe('https://example.com/feed');

    final latest = await repo.watchLatestEpisodes().first;
    expect(latest.map((e) => e.episode.title), ['Folge 2', 'Folge 1']);
    expect(latest.first.podcast.title, 'Testpodcast');
  });

  test('themes: count, newest image, filter round trip', () async {
    server['https://example.com/wrint'] = () => http.Response('''
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"><channel>
  <title>WRINT</title>
  <item><title>Neu Thema</title><guid>1</guid>
    <pubDate>Thu, 17 Sep 2026 08:00:00 +0000</pubDate>
    <link>https://wrint.network.podigee.io/podcast/85079-zum-thema/2-b</link>
    <itunes:image href="https://img.example.com/thema-neu.jpg"/>
    <enclosure url="https://example.com/1.mp3" type="audio/mpeg"/></item>
  <item><title>Wrintheit</title><guid>2</guid>
    <pubDate>Wed, 16 Sep 2026 08:00:00 +0000</pubDate>
    <link>https://wrint.network.podigee.io/podcast/85056-die-wrintheit/1-a</link>
    <enclosure url="https://example.com/2.mp3" type="audio/mpeg"/></item>
  <item><title>Alt Thema</title><guid>3</guid>
    <pubDate>Tue, 15 Sep 2026 08:00:00 +0000</pubDate>
    <link>https://wrint.network.podigee.io/podcast/85079-zum-thema/1-a</link>
    <itunes:image href="https://img.example.com/thema-alt.jpg"/>
    <enclosure url="https://example.com/3.mp3" type="audio/mpeg"/></item>
</channel></rss>''', 200);
    final id = await repo.subscribe('https://example.com/wrint');

    final themes = await repo.watchThemes(id).first;
    expect(themes.map((t) => (t.theme, t.count)), [
      ('zum-thema', 2),
      ('die-wrintheit', 1),
    ]);
    expect(themes.first.imageUrl, 'https://img.example.com/thema-neu.jpg');

    await repo.setAutoDownloadThemes(id, {'zum-thema'});
    var podcast = (await repo.watchPodcast(id).first)!;
    expect(autoDownloadThemesOf(podcast), {'zum-thema'});

    await repo.setAutoDownloadThemes(id, null);
    podcast = (await repo.watchPodcast(id).first)!;
    expect(autoDownloadThemesOf(podcast), isNull);
  });

  test('topic "mark new ones as played": only new episodes of it', () async {
    String item(String guid, String theme) =>
        '<item><title>T$guid</title><guid>$guid</guid>'
        '<link>https://wrint.network.podigee.io/podcast/1-$theme/$guid</link>'
        '<enclosure url="https://example.com/$guid.mp3" type="audio/mpeg"/>'
        '</item>';
    String feed(List<String> items) =>
        '<rss><channel><title>WRINT</title>${items.join()}</channel></rss>';
    var body = feed([item('1', 'zum-thema'), item('2', 'die-wrintheit')]);
    server['https://example.com/wrint'] = () => http.Response(body, 200);
    final id = await repo.subscribe('https://example.com/wrint');

    await repo.setAutoPlayedTheme(id, 'zum-thema', enabled: true);
    expect(autoPlayedThemesOf((await repo.watchPodcast(id).first)!), {
      'zum-thema',
    });

    body = feed([
      item('3', 'zum-thema'),
      item('4', 'die-wrintheit'),
      item('1', 'zum-thema'),
      item('2', 'die-wrintheit'),
    ]);
    clockNow = clockNow.add(const Duration(hours: 1));
    await repo.refreshPodcast((await repo.watchPodcast(id).first)!);

    Future<EpisodeStatus> status(String guid) async => (await (db.select(
      db.episodes,
    )..where((e) => e.guid.equals(guid))).getSingle()).status;
    expect(await status('3'), EpisodeStatus.played); // new, the topic
    expect(await status('4'), EpisodeStatus.newEpisode); // other topic
    expect(await status('1'), EpisodeStatus.newEpisode); // known before

    await repo.setAutoPlayedTheme(id, 'zum-thema', enabled: false);
    expect(autoPlayedThemesOf((await repo.watchPodcast(id).first)!), isEmpty);
  });

  test('Podlove chapters from the feed are stored once', () async {
    String feed(String firstTitle) =>
        '''
<rss xmlns:psc="http://podlove.org/simple-chapters"><channel><title>P</title>
  <item><title>A</title><guid>a</guid>
    <enclosure url="https://example.com/a.mp3" type="audio/mpeg"/>
    <psc:chapters><psc:chapter title="$firstTitle" start="0"/>
      <psc:chapter title="Zwei" start="00:01:00"/></psc:chapters>
  </item>
</channel></rss>''';
    server['https://example.com/psc'] = () => http.Response(feed('Eins'), 200);
    await repo.subscribe('https://example.com/psc');
    expect(
      (await db.select(db.chapters).get()).map((c) => c.title),
      unorderedEquals(['Eins', 'Zwei']),
    );

    // A later refresh does not rewrite existing chapters.
    server['https://example.com/psc'] = () =>
        http.Response(feed('Geändert'), 200);
    await repo.refreshAll();
    expect(
      (await db.select(db.chapters).get()).map((c) => c.title),
      unorderedEquals(['Eins', 'Zwei']),
    );
  });
}
