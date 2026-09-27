// Manual smoke test against the real internet: searches Apple Podcasts + fyyd,
// then fetches and parses the top feeds.
// Run: dart run tool/smoke_feeds.dart "suchbegriff" ...
// ignore_for_file: avoid_print
import 'package:aapodcastguru/data/directory/directory_search.dart';
import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:aapodcastguru/data/feed/rss_parser.dart';
import 'package:http/http.dart' as http;

const _feedsPerTerm = 3;

Future<void> main(List<String> terms) async {
  final client = http.Client();
  final fetcher = FeedFetcher(client);
  final search = DirectorySearch([
    ItunesDirectory(client),
    FyydDirectory(client),
  ]);
  try {
    for (final term in terms) {
      final outcome = await search.search(term);
      print(
        '\n"$term": ${outcome.results.length} Treffer'
        '${outcome.failedDirectories.isEmpty ? '' : ' (ausgefallen: ${outcome.failedDirectories.join(', ')})'}',
      );
      for (final result in outcome.results.take(_feedsPerTerm)) {
        final sw = Stopwatch()..start();
        try {
          final fetched =
              await fetcher.fetch(Uri.parse(result.feedUrl)) as FeedFetched;
          final feed = const RssParser().parse(fetched.body);
          final withDate = feed.episodes.where((e) => e.pubDate != null).length;
          final withDur = feed.episodes.where((e) => e.duration != null).length;
          print(
            '  OK   ${feed.title} | ${feed.episodes.length} Folgen, '
            'Datum $withDate, Dauer $withDur, '
            '${(fetched.body.length / 1024).round()} KB, ${sw.elapsedMilliseconds} ms',
          );
        } on Exception catch (e) {
          print('  FAIL ${result.title} (${result.feedUrl}): $e');
        }
      }
    }
  } finally {
    client.close();
  }
}
