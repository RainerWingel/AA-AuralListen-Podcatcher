import 'dart:io';

import 'package:aapodcastguru/data/feed/rss_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = RssParser();

  group('RssParser with a complete feed', () {
    late ParsedFeed feed;

    setUpAll(() {
      feed = parser.parse(
        File('test/fixtures/feed_basic.xml').readAsStringSync(),
      );
    });

    test('reads channel metadata', () {
      expect(feed.title, 'Testpodcast');
      expect(feed.author, 'Max Mustermann');
      expect(feed.websiteUrl, 'https://example.com');
      expect(feed.description, 'Ein Podcast über Tests');
    });

    test('prefers itunes:image over the RSS image', () {
      expect(feed.imageUrl, 'https://example.com/cover.jpg');
    });

    test('keeps only audio items with enclosure, without duplicates', () {
      expect(feed.episodes.map((e) => e.guid), [
        'ep-2',
        'https://example.com/ep1.mp3',
      ]);
    });

    test('reads all episode fields', () {
      final ep = feed.episodes.first;
      expect(ep.title, 'Folge 2');
      expect(ep.audioUrl, 'https://example.com/ep2.mp3');
      expect(ep.audioMimeType, 'audio/mpeg');
      expect(ep.audioSizeBytes, 12345);
      expect(ep.duration, const Duration(hours: 1, minutes: 2, seconds: 3));
      expect(ep.pubDate, DateTime.utc(2025, 6, 10, 2));
      expect(ep.imageUrl, 'https://example.com/ep2.jpg');
      expect(ep.chaptersUrl, 'https://example.com/ep2-chapters.json');
      expect(ep.description, 'Lange Shownotes\nZweiter Absatz');
    });

    test('falls back to the enclosure URL as guid', () {
      final ep = feed.episodes[1];
      expect(ep.guid, 'https://example.com/ep1.mp3');
      expect(ep.duration, const Duration(minutes: 45));
      expect(ep.pubDate, DateTime.utc(2025, 6, 3, 10, 30));
    });
  });

  test(
    'handles undeclared itunes prefix without confusing it with <image>',
    () {
      final feed = parser.parse('''
<rss><channel>
  <title>Schlampig</title>
  <image><url>https://example.com/rss.jpg</url></image>
  <itunes:image href="https://example.com/itunes.jpg"/>
</channel></rss>''');
      expect(feed.imageUrl, 'https://example.com/itunes.jpg');
    },
  );

  test('uses RSS image when there is no itunes:image', () {
    final feed = parser.parse(
      '<rss><channel><title>T</title>'
      '<image><url>https://example.com/rss.jpg</url></image></channel></rss>',
    );
    expect(feed.imageUrl, 'https://example.com/rss.jpg');
  });

  test('rejects HTML and broken XML', () {
    expect(
      () => parser.parse('<html><body>Hallo</body></html>'),
      throwsA(isA<FeedFormatException>()),
    );
    expect(
      () => parser.parse('<rss><channel>'),
      throwsA(isA<FeedFormatException>()),
    );
  });

  group('themes of network feeds (WRINT)', () {
    test('theme comes from the episode link', () {
      expect(
        episodeThemeFromLink(
          'https://wrint.network.podigee.io/podcast/85079-zum-thema/173-stadt-land',
        ),
        'zum-thema',
      );
      expect(
        episodeThemeFromLink(
          'https://wrint.network.podigee.io/podcast/85056-die-wrintheit/151-x',
        ),
        'die-wrintheit',
      );
      expect(episodeThemeFromLink('https://example.com/folge-1'), isNull);
      expect(episodeThemeFromLink(null), isNull);
    });

    test('display names', () {
      expect(themeDisplayName('die-wrintheit'), 'Die Wrintheit');
      expect(themeDisplayName('zum-thema'), 'Zum Thema');
      expect(themeDisplayName('geschichtsunterricht'), 'Geschichtsunterricht');
    });

    test('parser fills the theme', () {
      final feed = parser.parse('''
<rss><channel><title>WRINT</title>
  <item><title>A</title><guid>a</guid>
    <link>https://wrint.network.podigee.io/podcast/85079-zum-thema/1-a</link>
    <enclosure url="https://example.com/a.mp3" type="audio/mpeg"/></item>
  <item><title>B</title><guid>b</guid>
    <enclosure url="https://example.com/b.mp3" type="audio/mpeg"/></item>
</channel></rss>''');
      expect(feed.episodes.map((e) => e.theme), ['zum-thema', null]);
    });
  });
}
