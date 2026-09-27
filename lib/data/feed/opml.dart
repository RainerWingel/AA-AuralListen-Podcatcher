import 'package:xml/xml.dart';

import 'rss_parser.dart' show FeedFormatException;

/// One subscription from an OPML file.
class OpmlFeed {
  const OpmlFeed({required this.url, this.title});

  final String url;
  final String? title;
}

/// Reads all feeds from an OPML file (also nested outlines, e.g. Castbox's
/// "feeds" folder). Duplicate URLs are removed. Throws [FeedFormatException].
List<OpmlFeed> parseOpml(String xml) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(xml);
  } on XmlException catch (e) {
    throw FeedFormatException('Invalid XML: ${e.message}');
  }
  if (document.rootElement.name.local.toLowerCase() != 'opml') {
    throw const FeedFormatException('Not an OPML file');
  }

  final feeds = <OpmlFeed>[];
  final seen = <String>{};
  for (final outline in document.rootElement.findAllElements('outline')) {
    final url =
        (outline.getAttribute('xmlUrl') ?? outline.getAttribute('xmlurl'))
            ?.trim();
    if (url == null || url.isEmpty || !seen.add(url)) continue;
    final title =
        (outline.getAttribute('title') ?? outline.getAttribute('text'))?.trim();
    feeds.add(
      OpmlFeed(url: url, title: title == null || title.isEmpty ? null : title),
    );
  }
  return feeds;
}
