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

  final basicFeed = File('test/fixtures/feed_basic.xml').readAsStringSync();

  setUp(() {
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
      clock: () => now,
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
