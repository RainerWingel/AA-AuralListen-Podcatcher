import 'dart:io';

import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/opml.dart';
import 'package:aapodcastguru/data/feed/rss_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads nested outlines, removes duplicates, skips folders', () {
    final feeds = parseOpml(
      File('test/fixtures/castbox_export.opml').readAsStringSync(),
    );
    expect(feeds.map((f) => f.url), [
      'https://a.example.com/feed',
      'https://b.example.com/feed',
      'https://broken.example.com/feed',
    ]);
    expect(feeds.map((f) => f.title), ['Podcast A', 'Podcast B', 'Kaputt']);
  });

  test('rejects non-OPML documents', () {
    expect(
      () => parseOpml('<rss><channel/></rss>'),
      throwsA(isA<FeedFormatException>()),
    );
    expect(() => parseOpml('kein xml'), throwsA(isA<FeedFormatException>()));
  });

  test('empty OPML gives an empty list', () {
    expect(parseOpml('<opml><body/></opml>'), isEmpty);
  });

  test('export → import round trip keeps all feeds', () {
    Podcast podcast(int id, String title, String url, {String? site}) =>
        Podcast(
          id: id,
          feedUrl: url,
          title: title,
          websiteUrl: site,
          subscribedAt: DateTime(2026),
          autoDownloadMode: AutoDownloadMode.off,
          autoDownloadMaxEpisodes: 3,
          autoDeletePlayed: true,
          episodeCounter: true,
          episodeNumberOffset: 0,
        );
    final xml = buildOpml([
      podcast(1, 'Freak Show', 'https://feeds.metaebene.me/freakshow/mp3'),
      podcast(
        2,
        'Sonderzeichen & <Test>',
        'https://example.com/a?b=1&c=2',
        site: 'https://example.com',
      ),
    ], created: DateTime.utc(2026, 9, 27));

    expect(xml, contains('<opml version="2.0">'));
    expect(xml, contains('htmlUrl="https://example.com"'));
    final feeds = parseOpml(xml);
    expect(feeds.map((f) => f.url), [
      'https://feeds.metaebene.me/freakshow/mp3',
      'https://example.com/a?b=1&c=2',
    ]);
    expect(feeds[1].title, 'Sonderzeichen & <Test>');
  });
}
