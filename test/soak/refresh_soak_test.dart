@Tags(['soak'])
library;

import 'dart:io';

import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:aapodcastguru/data/podcast_repository.dart';
import 'package:aapodcastguru/data/storage/cover_cache.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _NoCoverCache implements CoverCache {
  @override
  Future<void> evict(String url) async {}
}

/// M8 soak test: 50 full refreshes of 10 large feeds must not make the
/// process memory grow (docs/eviction.md). Skipped in normal runs; start with
///   flutter test --run-skipped --tags soak test/soak
void main() {
  test('50 refreshes of 10 feeds with 400 episodes: memory stays flat', () async {
    const podcasts = 10;
    const episodes = 400;
    var round = 0;

    // Each round adds one new episode, so every refresh parses and upserts
    // the whole feed (no 304 shortcut).
    String feed(int p) {
      final items = StringBuffer();
      for (var e = episodes + round; e > 0; e--) {
        items.write(
          '<item><title>Folge $e von Podcast $p</title><guid>$p-$e</guid>'
          '<pubDate>Mon, 01 Jan 2024 10:00:00 +0000</pubDate>'
          '<description>${'Shownotes ' * 40}</description>'
          '<enclosure url="https://example.com/$p/$e.mp3" '
          'type="audio/mpeg" length="12345678"/></item>',
        );
      }
      return '<rss><channel><title>Podcast $p</title>$items</channel></rss>';
    }

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = PodcastRepository(
      db: db,
      fetcher: FeedFetcher(
        MockClient((request) async {
          final p = int.parse(request.url.pathSegments.last);
          return http.Response(feed(p), 200);
        }),
      ),
      clock: DateTime.now,
      coverCache: _NoCoverCache(),
    );
    for (var p = 0; p < podcasts; p++) {
      await repo.subscribe('https://example.com/feed/$p');
    }

    int rssMb() => ProcessInfo.currentRss ~/ (1024 * 1024);

    // Warm-up: caches, JIT and SQLite pages settle first.
    for (var i = 0; i < 5; i++) {
      round++;
      await repo.refreshAll();
    }
    final before = rssMb();
    final samples = <int>[];
    for (var i = 0; i < 50; i++) {
      round++;
      final summary = await repo.refreshAll();
      expect(summary.failed, 0);
      if (i % 10 == 9) samples.add(rssMb());
    }
    final after = rssMb();
    // ignore: avoid_print
    print(
      'RSS before: $before MB, every 10 refreshes: $samples, after: $after MB',
    );

    // 550 new episode rows are expected; anything beyond a few MB would be
    // a leak (parsed feeds, streams or statements kept alive).
    expect(after - before, lessThan(40));
    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));
}
