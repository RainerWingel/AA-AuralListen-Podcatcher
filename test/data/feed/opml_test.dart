import 'dart:io';

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
}
