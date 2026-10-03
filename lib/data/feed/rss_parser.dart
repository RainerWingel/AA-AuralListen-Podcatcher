import 'package:xml/xml.dart';

import '../../core/text_utils.dart';
import '../chapters/parsed_chapter.dart';
import 'feed_dates.dart';

/// Result of parsing an RSS feed – plain data, independent of the database.
class ParsedFeed {
  const ParsedFeed({
    required this.title,
    required this.episodes,
    this.author,
    this.description,
    this.imageUrl,
    this.websiteUrl,
    this.fundingUrl,
    this.fundingLabel,
    this.newFeedUrl,
  });

  final String title;
  final String? author;
  final String? description;
  final String? imageUrl;
  final String? websiteUrl;

  /// First `podcast:funding` link (http/https only) and its text, e.g.
  /// "Unterstütze uns auf Steady".
  final String? fundingUrl;
  final String? fundingLabel;

  /// Announced new address of the feed (`<itunes:new-feed-url>`), set by the
  /// publisher when the podcast moves to another host.
  final String? newFeedUrl;
  final List<ParsedEpisode> episodes;
}

class ParsedEpisode {
  const ParsedEpisode({
    required this.guid,
    required this.title,
    required this.audioUrl,
    this.audioMimeType,
    this.audioSizeBytes,
    this.notes,
    this.duration,
    this.pubDate,
    this.imageUrl,
    this.chaptersUrl,
    this.theme,
    this.episodeNumber,
    this.chapters = const [],
  });

  final String guid;
  final String title;
  final String audioUrl;
  final String? audioMimeType;
  final int? audioSizeBytes;

  /// Show notes in the stored format (text plus links, see htmlToNotes).
  final String? notes;
  final Duration? duration;
  final DateTime? pubDate;
  final String? imageUrl;
  final String? chaptersUrl;

  /// Sub-series key (see [episodeThemeFromLink]).
  final String? theme;

  /// The feed's episode number (`itunes:episode`), if it has one.
  final int? episodeNumber;

  /// Podlove Simple Chapters embedded in the feed (`<psc:chapters>`).
  final List<ParsedChapter> chapters;
}

final RegExp _networkLink = RegExp(r'/podcast/(?:\d+-)?([a-z0-9-]+)/');

/// Theme of an episode in a "network" feed that bundles several shows, taken
/// from the episode link, e.g. `…/podcast/85079-zum-thema/173-…` → `zum-thema`
/// (Podigee networks such as WRINT). Null if the link has no such segment.
String? episodeThemeFromLink(String? link) {
  if (link == null) return null;
  return _networkLink.firstMatch(link.toLowerCase())?.group(1);
}

/// Readable name for a theme key: `die-wrintheit` → `Die Wrintheit`.
String themeDisplayName(String theme) => theme
    .split('-')
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

/// Thrown when a document is not a usable podcast feed.
class FeedFormatException implements Exception {
  const FeedFormatException(this.message);

  final String message;

  @override
  String toString() => 'FeedFormatException: $message';
}

/// Parses RSS 2.0 podcast feeds including the `itunes:`, `content:` and
/// Podcasting 2.0 `podcast:` namespaces. Only audio episodes are returned.
class RssParser {
  const RssParser();

  ParsedFeed parse(String xml) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xml);
    } on XmlException catch (e) {
      throw FeedFormatException('Invalid XML: ${e.message}');
    }

    final channel = document.rootElement.getElement('channel');
    if (document.rootElement.name.local != 'rss' || channel == null) {
      throw const FeedFormatException('Not an RSS feed');
    }

    final rawTitle = _text(channel.getElement('title'));
    final title = rawTitle == null ? null : cleanTitle(rawTitle);
    if (title == null || title.isEmpty) {
      throw const FeedFormatException('Feed has no title');
    }

    final episodes = <ParsedEpisode>[];
    final seenGuids = <String>{};
    for (final item in channel.findElements('item')) {
      final episode = _parseItem(item);
      // Some feeds contain duplicates; the first occurrence wins.
      if (episode != null && seenGuids.add(episode.guid)) {
        episodes.add(episode);
      }
    }

    final description =
        _text(channel.getElement('description')) ??
        _text(_ns(channel, _Ns.itunes, 'summary'));

    final funding = _ns(channel, _Ns.podcast, 'funding');
    final fundingUrl = _attr(funding, 'url');
    final hasFunding = fundingUrl != null && isWebUrl(fundingUrl);
    final website = _text(channel.getElement('link'));

    return ParsedFeed(
      title: title,
      author: _text(_ns(channel, _Ns.itunes, 'author')),
      description: description == null ? null : htmlToPlainText(description),
      imageUrl:
          _attr(_ns(channel, _Ns.itunes, 'image'), 'href') ??
          _text(channel.getElement('image')?.getElement('url')),
      websiteUrl: website != null && isWebUrl(website) ? website : null,
      fundingUrl: hasFunding ? fundingUrl : null,
      fundingLabel: hasFunding
          ? switch (_text(funding)) {
              final label? => cleanTitle(label),
              null => null,
            }
          : null,
      newFeedUrl: _text(_ns(channel, _Ns.itunes, 'new-feed-url')),
      episodes: episodes,
    );
  }

  ParsedEpisode? _parseItem(XmlElement item) {
    final enclosure = item.getElement('enclosure');
    final audioUrl = _attr(enclosure, 'url');
    if (audioUrl == null) return null;

    final mimeType = _attr(enclosure, 'type')?.toLowerCase();
    if (mimeType != null && mimeType.startsWith('video/')) return null;

    final rawDescription =
        _text(_ns(item, _Ns.content, 'encoded')) ??
        _text(item.getElement('description')) ??
        _text(_ns(item, _Ns.itunes, 'summary'));

    final size = int.tryParse(_attr(enclosure, 'length') ?? '');

    return ParsedEpisode(
      guid: _text(item.getElement('guid')) ?? audioUrl,
      title: switch (_text(item.getElement('title'))) {
        final t? when cleanTitle(t).isNotEmpty => cleanTitle(t),
        _ => audioUrl,
      },
      audioUrl: audioUrl,
      audioMimeType: mimeType,
      audioSizeBytes: size != null && size > 0 ? size : null,
      notes: rawDescription == null ? null : htmlToNotes(rawDescription),
      duration: parseFeedDuration(_text(_ns(item, _Ns.itunes, 'duration'))),
      pubDate: parseFeedDate(_text(item.getElement('pubDate'))),
      imageUrl: _attr(_ns(item, _Ns.itunes, 'image'), 'href'),
      // The spec says `url`; Podigee writes `href`.
      chaptersUrl:
          _attr(_ns(item, _Ns.podcast, 'chapters'), 'url') ??
          _attr(_ns(item, _Ns.podcast, 'chapters'), 'href'),
      theme: episodeThemeFromLink(_text(item.getElement('link'))),
      episodeNumber: switch (int.tryParse(
        _text(_ns(item, _Ns.itunes, 'episode')) ?? '',
      )) {
        final n? when n >= 0 => n,
        _ => null,
      },
      chapters: _pscChapters(item),
    );
  }

  List<ParsedChapter> _pscChapters(XmlElement item) {
    final container = _ns(item, _Ns.psc, 'chapters');
    if (container == null) return const [];
    return normalizeChapters([
      for (final c in container.childElements)
        if (c.name.local == 'chapter')
          if (parseChapterTime(c.getAttribute('start')) case final start?)
            ParsedChapter(
              start: start,
              title: (c.getAttribute('title') ?? '').trim(),
              url: _attr(c, 'href'),
              imageUrl: _attr(c, 'image'),
            ),
    ]);
  }

  /// Finds a namespaced child element. Matches by namespace URI; if the feed
  /// forgot to declare the namespace, falls back to the usual prefix.
  XmlElement? _ns(XmlElement parent, _Ns ns, String localName) {
    for (final element in parent.childElements) {
      if (element.name.local != localName) continue;
      final uri = element.name.namespaceUri;
      final matches = uri != null
          ? uri.toLowerCase().contains(ns.uriFragment)
          : element.name.prefix == ns.prefix;
      if (matches) return element;
    }
    return null;
  }

  String? _text(XmlElement? element) {
    final text = element?.innerText.trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _attr(XmlElement? element, String name) {
    final value = element?.getAttribute(name)?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

enum _Ns {
  itunes('itunes', 'itunes.com/dtds'),
  content('content', 'purl.org/rss/1.0/modules/content'),
  podcast('podcast', 'podcastindex.org/namespace'),
  psc('psc', 'podlove.org/simple-chapters');

  const _Ns(this.prefix, this.uriFragment);

  final String prefix;
  final String uriFragment;
}
