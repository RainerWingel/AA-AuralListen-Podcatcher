import 'dart:io';

import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:aapodcastguru/data/feed/opml.dart';
import 'package:aapodcastguru/data/opml_importer.dart';
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

String _feed(String title) =>
    '<rss><channel><title>$title</title>'
    '<item><title>Folge</title><guid>1</guid>'
    '<enclosure url="https://example.com/1.mp3" type="audio/mpeg"/></item>'
    '</channel></rss>';

void main() {
  late AppDatabase db;
  late PodcastRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PodcastRepository(
      db: db,
      fetcher: FeedFetcher(
        MockClient((request) async {
          return switch (request.url.host) {
            'a.example.com' => http.Response(_feed('Podcast A'), 200),
            'b.example.com' => http.Response(_feed('Podcast B'), 200),
            _ => http.Response('', 500),
          };
        }),
      ),
      clock: DateTime.now,
      coverCache: _NoCoverCache(),
    );
  });

  tearDown(() => db.close());

  test('imports Castbox export and reports the outcome', () async {
    // Podcast B is already subscribed.
    await repo.subscribe('https://b.example.com/feed');

    final feeds = parseOpml(
      File('test/fixtures/castbox_export.opml').readAsStringSync(),
    );
    final progress = <int>[];
    final result = await OpmlImporter(repo)
        .import(feeds, onProgress: (done, total) => progress.add(done));

    expect(result.added, 1);
    expect(result.alreadySubscribed, 1);
    expect(result.failed, ['Kaputt']);
    expect(progress..sort(), [1, 2, 3]);

    final titles = (await db.select(db.podcasts).get()).map((p) => p.title);
    expect(titles, unorderedEquals(['Podcast A', 'Podcast B']));
  });
}
