/// Text for comparing and searching: lower case, umlauts like their base
/// letter ("Äpfel" ~ "apfel"), ß as ss.
String foldForSearch(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss');

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

// ------------------------------------------------------------ show notes
//
// Episode show notes are stored as plain text plus links (docs/data-model.md
// "episode_notes"): a link is `\uE000text\uE001url\uE002` (Unicode private use
// characters, never part of real text). No HTML is kept – lean on purpose,
// see docs/decisions.md.

/// Maximum stored length of show notes including link addresses.
const int maxNotesLength = 18000;

const String _linkStart = '\uE000';
const String _linkUrl = '\uE001';
const String _linkEnd = '\uE002';

final RegExp _markers = RegExp('[$_linkStart$_linkUrl$_linkEnd]');
final RegExp _anchor = RegExp(
  r'''<a\s[^>]*?href\s*=\s*(?:"([^"]*)"|'([^']*)')[^>]*>(.*?)</a\s*>''',
  caseSensitive: false,
  dotAll: true,
);
final RegExp _listItem = RegExp(r'<\s*li(\s[^>]*)?>', caseSensitive: false);
final RegExp _listItemEnd = RegExp(r'<\s*/li\s*>', caseSensitive: false);
final RegExp _anyWhitespace = RegExp(r'\s+');
// "•" followed by line breaks (item content in its own <p>) → same line.
final RegExp _bulletBreak = RegExp(r'•[ \t]*\n\s*');
// Blank lines before a list item → one line break (compact lists).
final RegExp _blankBeforeBullet = RegExp(r'\n[ \t]*\n\s*(?=• )');
final RegExp _storedLink = RegExp(
  '$_linkStart([^$_linkStart$_linkUrl$_linkEnd]*)'
  '$_linkUrl([^$_linkStart$_linkUrl$_linkEnd]*)$_linkEnd',
);
final RegExp _bareUrl = RegExp(r'''https?://[^\s<>"' ]+''');
final RegExp _trailingPunctuation = RegExp(r'[.,;:!?)\]]+$');

bool _isWebUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

/// Converts HTML show notes to the stored notes format: paragraphs and list
/// items become line breaks, `<a href>` links (http/https only) are kept,
/// everything else is dropped. Capped at [maxLength].
String htmlToNotes(String html, {int maxLength = maxNotesLength}) {
  var text = html
      .replaceAll(_markers, '')
      .replaceAllMapped(_anchor, (m) {
        final url = decodeHtmlEntities(m[1] ?? m[2] ?? '').trim();
        final label = decodeHtmlEntities(m[3]!.replaceAll(_anyTag, ''))
            .replaceAll(_anyWhitespace, ' ')
            .trim();
        if (label.isEmpty) return '';
        // A link whose text is its address needs no marker: shown as is
        // and linked on display like any bare address.
        if (!_isWebUrl(url) || label == url) return label;
        return '$_linkStart$label$_linkUrl$url$_linkEnd';
      })
      // Each item starts its own line; the end tag adds none.
      .replaceAll(_listItemEnd, '')
      .replaceAll(_listItem, '\n• ');
  text = decodeHtmlEntities(
    text.replaceAll(_blockTags, '\n').replaceAll(_anyTag, ''),
  );
  text = text
      .replaceAll('\r', '')
      .replaceAll(_spaces, ' ')
      .replaceAll(_blankLines, '\n\n')
      .replaceAll(_bulletBreak, '• ')
      .replaceAll(_blankBeforeBullet, '\n')
      .trim();
  if (text.length > maxLength) {
    text = text.substring(0, maxLength);
    // Never cut a link in half: drop an unfinished one.
    final open = text.lastIndexOf(_linkStart);
    if (open > text.lastIndexOf(_linkEnd)) text = text.substring(0, open);
    text = '${text.trimRight()}…';
  }
  return text;
}

/// One piece of stored show notes: plain text, or a link if [url] is set.
typedef NotesPart = ({String text, String? url});

/// Splits stored notes into text and links. Bare web addresses in the text
/// become links too (also covers notes stored before links were kept).
List<NotesPart> parseNotes(String stored) {
  // Notes stored before lists were compacted get the same treatment here.
  final notes = stored
      .replaceAll(_bulletBreak, '• ')
      .replaceAll(_blankBeforeBullet, '\n');
  final parts = <NotesPart>[];
  void addText(String text) {
    var start = 0;
    for (final m in _bareUrl.allMatches(text)) {
      final raw = m[0]!;
      final url = raw.replaceFirst(_trailingPunctuation, '');
      if (!_isWebUrl(url)) continue;
      if (m.start > start) {
        parts.add((text: text.substring(start, m.start), url: null));
      }
      parts.add((text: url, url: url));
      start = m.start + url.length;
    }
    if (start < text.length) {
      parts.add((text: text.substring(start), url: null));
    }
  }

  var start = 0;
  for (final m in _storedLink.allMatches(notes)) {
    addText(notes.substring(start, m.start));
    parts.add((text: m[1]!, url: m[2]!));
    start = m.end;
  }
  addText(notes.substring(start));
  return parts;
}
