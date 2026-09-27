// Manual smoke test: fetch + parse real feeds found via the iTunes search API.
// Run: dart run tool/smoke_feeds.dart "suchbegriff" ...
// ignore_for_file: avoid_print, avoid_dynamic_calls
import 'dart:convert';

import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:aapodcastguru/data/feed/rss_parser.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> terms) async {
  final client = http.Client();
  final fetcher = FeedFetcher(client);
  try {
    for (final term in terms) {
      final search = await client.get(
        Uri.https('itunes.apple.com', '/search', {
          'media': 'podcast',
          'country': 'DE',
          'limit': '3',
          'term': term,
        }),
      );
      final results = (jsonDecode(search.body) as Map)['results'] as List;
      for (final r in results) {
        final url = r['feedUrl'] as String?;
        if (url == null) continue;
        final sw = Stopwatch()..start();
        try {
          final result = await fetcher.fetch(Uri.parse(url)) as FeedFetched;
          final feed = const RssParser().parse(result.body);
          final withDate = feed.episodes.where((e) => e.pubDate != null).length;
          final withDur = feed.episodes.where((e) => e.duration != null).length;
          print(
            'OK   ${feed.title} | ${feed.episodes.length} Folgen, '
            'Datum $withDate, Dauer $withDur, '
            '${(result.body.length / 1024).round()} KB, ${sw.elapsedMilliseconds} ms',
          );
        } on Exception catch (e) {
          print('FAIL $url: $e');
        }
      }
    }
  } finally {
    client.close();
  }
}
