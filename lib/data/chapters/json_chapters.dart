import 'dart:convert';

import 'parsed_chapter.dart';

/// Podcasting 2.0 JSON chapters (`application/json+chapters`):
/// `{"chapters": [{"startTime": 12.5, "title": "…", "img": "…", "url": "…"}]}`.
/// Entries with `"toc": false` are hidden markers and skipped.
/// Throws [FormatException] for anything that is not such a document.
List<ParsedChapter> parseJsonChapters(String json) {
  final Object? data;
  try {
    data = jsonDecode(json);
  } on FormatException {
    rethrow;
  }
  if (data is! Map<String, Object?> || data['chapters'] is! List) {
    throw const FormatException('Not a chapters document');
  }
  final chapters = <ParsedChapter>[];
  for (final entry
      in (data['chapters']! as List).whereType<Map<String, Object?>>()) {
    if (entry['toc'] == false) continue;
    final start = entry['startTime'];
    final title = entry['title'];
    if (start is! num || title is! String) continue;
    chapters.add(
      ParsedChapter(
        start: Duration(milliseconds: (start * 1000).round()),
        title: title.trim(),
        url: entry['url'] as String?,
        imageUrl: entry['img'] as String?,
      ),
    );
  }
  return normalizeChapters(chapters);
}
