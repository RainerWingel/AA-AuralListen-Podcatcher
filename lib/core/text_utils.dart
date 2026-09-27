/// Maximum length of stored descriptions (see docs/eviction.md: keep the DB small).
const int maxDescriptionLength = 4000;

final RegExp _blockTags = RegExp(
  r'<\s*(br|/p|/div|/li|/h[1-6])\s*/?>',
  caseSensitive: false,
);
final RegExp _anyTag = RegExp(r'<[^>]*>');
final RegExp _spaces = RegExp(r'[ \t ]+');
final RegExp _blankLines = RegExp(r'\n\s*\n\s*(\n\s*)+');

const Map<String, String> _entities = {
  '&nbsp;': ' ',
  '&amp;': '&',
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
};

final RegExp _numericEntity = RegExp(r'&#(x?)([0-9a-fA-F]+);');

/// Converts HTML show notes to readable plain text and caps the length.
String htmlToPlainText(String html, {int maxLength = maxDescriptionLength}) {
  var text = html.replaceAll(_blockTags, '\n').replaceAll(_anyTag, '');
  _entities.forEach((entity, value) => text = text.replaceAll(entity, value));
  text = text.replaceAllMapped(_numericEntity, (m) {
    final code = int.tryParse(m[2]!, radix: m[1]!.isEmpty ? 10 : 16);
    return code == null ? m[0]! : String.fromCharCode(code);
  });
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
