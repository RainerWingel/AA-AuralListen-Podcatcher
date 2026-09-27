import 'package:xml/xml.dart';

import '../db/app_database.dart';

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

/// OPML 2.0 with all subscriptions (for other apps or as a simple backup).
String buildOpml(List<Podcast> podcasts, {required DateTime created}) {
  final builder = XmlBuilder()
    ..processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(
    'opml',
    attributes: {'version': '2.0'},
    nest: () {
      builder.element(
        'head',
        nest: () {
          builder
            ..element('title', nest: 'AA-PodcastGuru Abos')
            ..element('dateCreated', nest: created.toUtc().toIso8601String());
        },
      );
      builder.element(
        'body',
        nest: () {
          for (final p in podcasts) {
            builder.element(
              'outline',
              attributes: {
                'type': 'rss',
                'text': p.title,
                'title': p.title,
                'xmlUrl': p.feedUrl,
                'htmlUrl': ?p.websiteUrl,
              },
            );
          }
        },
      );
    },
  );
  return builder.buildDocument().toXmlString(pretty: true);
}
