/// Maximum length of stored descriptions (see docs/eviction.md: keep the DB small).
const int maxDescriptionLength = 4000;

final RegExp _blockTags = RegExp(
  r'<\s*(br|/p|/div|/li|/h[1-6])\s*/?>',
  caseSensitive: false,
);
final RegExp _anyTag = RegExp(r'<[^>]*>');
final RegExp _spaces = RegExp(r'[ \t ]+');
final RegExp _blankLines = RegExp(r'\n\s*\n\s*(\n\s*)+');

// `&amp;` last, so "&amp;nbsp;" stays the literal text "&nbsp;".
const Map<String, String> _entities = {
  '&nbsp;': ' ',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&apos;': "'",
  '&auml;': 'ä',
  '&ouml;': 'ö',
  '&uuml;': 'ü',
  '&Auml;': 'Ä',
  '&Ouml;': 'Ö',
  '&Uuml;': 'Ü',
  '&szlig;': 'ß',
  '&ndash;': '–',
  '&mdash;': '—',
  '&hellip;': '…',
  '&amp;': '&',
};

final RegExp _numericEntity = RegExp(r'&#(x?)([0-9a-fA-F]+);');

/// Replaces HTML entities that feeds leave in their text ("&nbsp;",
/// "&#8211;" …) by the characters. Unknown entities stay as they are.
String decodeHtmlEntities(String text) {
  var result = text;
  _entities.forEach(
    (entity, value) => result = result.replaceAll(entity, value),
  );
  return result.replaceAllMapped(_numericEntity, (m) {
    final code = int.tryParse(m[2]!, radix: m[1]!.isEmpty ? 10 : 16);
    return code == null || code > 0x10FFFF ? m[0]! : String.fromCharCode(code);
  });
}

/// Titles: entities decoded, whitespace collapsed – but no tag stripping,
/// so a title like "C<3" stays intact.
String cleanTitle(String title) =>
    decodeHtmlEntities(title).replaceAll(_spaces, ' ').trim();

/// Converts HTML show notes to readable plain text and caps the length.
String htmlToPlainText(String html, {int maxLength = maxDescriptionLength}) {
  var text = decodeHtmlEntities(
    html.replaceAll(_blockTags, '\n').replaceAll(_anyTag, ''),
  );
  text = text
      .replaceAll('\r', '')
      .replaceAll(_spaces, ' ')
      .replaceAll(_blankLines, '\n\n')
      .trim();
  if (text.length > maxLength) {
    text = '${text.substring(0, maxLength).trimRight()}…';
  }
  return text;
}
