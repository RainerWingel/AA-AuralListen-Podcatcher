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

    test('has no announced move', () => expect(feed.newFeedUrl, isNull));

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
      expect(ep.notes, 'Lange Shownotes\nZweiter Absatz');
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

  test('reads itunes:episode as the episode number', () {
    final feed = parser.parse(
      '<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">'
      '<channel><title>T</title>'
      '<item><title>A</title><itunes:episode>42</itunes:episode>'
      '<enclosure url="https://example.com/1.mp3"/></item>'
      '<item><title>B</title><itunes:episode>bonus</itunes:episode>'
      '<enclosure url="https://example.com/2.mp3"/></item>'
      '<item><title>C</title><enclosure url="https://example.com/3.mp3"/></item>'
      '</channel></rss>',
    );
    expect(feed.episodes.map((e) => e.episodeNumber), [42, null, null]);
  });

  test('HTML entities in titles are decoded', () {
    final feed = parser.parse(
      '<rss><channel><title>Tom&amp;nbsp;&amp;amp; Jerry</title>'
      '<item><title>Folge&nbsp;1 &amp;#8211; Start</title>'
      '<enclosure url="https://example.com/1.mp3"/></item>'
      '<item><title>&nbsp;</title>'
      '<enclosure url="https://example.com/2.mp3"/></item>'
      '</channel></rss>',
    );
    // Feeds often escape twice; the result is still the intended text.
    expect(feed.title, 'Tom & Jerry');
    expect(feed.episodes.map((e) => e.title), [
      'Folge 1 – Start',
      // Nothing left of the title: fall back to the file address.
      'https://example.com/2.mp3',
    ]);
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

  group('chapters in the feed', () {
    test('Podlove simple chapters are parsed and sorted', () {
      final feed = parser.parse('''
<rss xmlns:psc="http://podlove.org/simple-chapters"><channel><title>T</title>
  <item><title>A</title><guid>a</guid>
    <enclosure url="https://example.com/a.mp3" type="audio/mpeg"/>
    <psc:chapters version="1.2">
      <psc:chapter title="Heimweh" start="00:03:20"/>
      <psc:chapter title="Neueste Geschichte" start="00:00:00"/>
      <psc:chapter title="Kurz" start="1:02.5" href="https://example.com"/>
    </psc:chapters>
  </item>
</channel></rss>''');
      final chapters = feed.episodes.single.chapters;
      expect(chapters.map((c) => c.title), [
        'Neueste Geschichte',
        'Kurz',
        'Heimweh',
      ]);
      expect(chapters[1].start, const Duration(milliseconds: 62500));
      expect(chapters[1].url, 'https://example.com');
      expect(chapters[2].start, const Duration(minutes: 3, seconds: 20));
    });

    test('podcast:chapters with href (Podigee) is understood', () {
      final feed = parser.parse('''
<rss xmlns:podcast="https://podcastindex.org/namespace/1.0"><channel><title>T</title>
  <item><title>A</title><guid>a</guid>
    <enclosure url="https://example.com/a.mp3" type="audio/mpeg"/>
    <podcast:chapters href="https://example.com/c.json" type="application/json+chapters"/>
  </item>
</channel></rss>''');
      expect(feed.episodes.single.chaptersUrl, 'https://example.com/c.json');
    });
  });

  test('reads itunes:new-feed-url', () {
    final feed = parser.parse('''
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"><channel>
  <title>Umgezogen</title>
  <itunes:new-feed-url> https://neu.example.com/feed </itunes:new-feed-url>
</channel></rss>''');
    expect(feed.newFeedUrl, 'https://neu.example.com/feed');
  });

  group('website and support link', () {
    ParsedFeed parse(String channelExtra) => parser.parse('''
<rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>P</title>
    $channelExtra
  </channel>
</rss>''');

    test('reads podcast:funding with its text', () {
      final feed = parse(
        '<link>https://example.com/</link>'
        '<podcast:funding url="https://steadyhq.com/de/p">'
        '  Unterstütze uns auf Steady </podcast:funding>'
        '<podcast:funding url="https://paypal.me/p">PayPal</podcast:funding>',
      );
      expect(feed.websiteUrl, 'https://example.com/');
      // The first one wins.
      expect(feed.fundingUrl, 'https://steadyhq.com/de/p');
      expect(feed.fundingLabel, 'Unterstütze uns auf Steady');
    });

    test('only web links are kept', () {
      final feed = parse(
        '<link>javascript:alert(1)</link>'
        '<podcast:funding url="mailto:x@example.com">Mail</podcast:funding>',
      );
      expect(feed.websiteUrl, isNull);
      expect((feed.fundingUrl, feed.fundingLabel), (null, null));
    });

    test('funding without text has no label', () {
      final feed = parse('<podcast:funding url="https://ko-fi.com/p"/>');
      expect(
        (feed.fundingUrl, feed.fundingLabel),
        ('https://ko-fi.com/p', null),
      );
    });
  });
}
