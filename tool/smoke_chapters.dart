// Manual smoke test: reads ID3 chapters of the newest episodes of a feed,
// fetching only the tag at the start of each MP3 (HTTP range request).
// Run: dart run tool/smoke_chapters.dart https://wrint.network.podigee.io/feed/aac
// ignore_for_file: avoid_print
import 'package:aapodcastguru/data/chapters/id3_chapters.dart';
import 'package:aapodcastguru/data/chapters/parsed_chapter.dart';
import 'package:aapodcastguru/data/chapters/remote_id3.dart';
import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:aapodcastguru/data/feed/rss_parser.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final client = http.Client();
  try {
    final fetched =
        await FeedFetcher(client).fetch(Uri.parse(args.single)) as FeedFetched;
    final feed = const RssParser().parse(fetched.body);
    for (final e in feed.episodes.take(5)) {
      final sw = Stopwatch()..start();
      final tag = await fetchId3Tag(client, Uri.parse(e.audioUrl));
      final chapters = tag == null
          ? const <ParsedChapter>[]
          : parseId3Chapters(tag);
      print(
        '${e.title} | Tag ${tag?.length ?? 0} B, ${sw.elapsedMilliseconds} ms, '
        '${chapters.length} Kapitel${chapters.isEmpty ? '' : ': ${chapters.take(3).map((c) => c.title).join(' / ')} …'}',
      );
    }
  } finally {
    client.close();
  }
}
