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

/// Named HTML entities feeds use: all of Latin-1 plus typographic ones
/// (generated from Python's `html.entities`; no-break and thin spaces become
/// plain spaces, invisible marks are dropped). Unknown names stay as text.
const Map<String, String> _namedEntities = {
  'AElig': 'Æ',
  'Aacute': 'Á',
  'Acirc': 'Â',
  'Agrave': 'À',
  'Aring': 'Å',
  'Atilde': 'Ã',
  'Auml': 'Ä',
  'Ccedil': 'Ç',
  'Dagger': '‡',
  'ETH': 'Ð',
  'Eacute': 'É',
  'Ecirc': 'Ê',
  'Egrave': 'È',
  'Euml': 'Ë',
  'Iacute': 'Í',
  'Icirc': 'Î',
  'Igrave': 'Ì',
  'Iuml': 'Ï',
  'Ntilde': 'Ñ',
  'OElig': 'Œ',
  'Oacute': 'Ó',
  'Ocirc': 'Ô',
  'Ograve': 'Ò',
  'Oslash': 'Ø',
  'Otilde': 'Õ',
  'Ouml': 'Ö',
  'Prime': '″',
  'Scaron': 'Š',
  'THORN': 'Þ',
  'Uacute': 'Ú',
  'Ucirc': 'Û',
  'Ugrave': 'Ù',
  'Uuml': 'Ü',
  'Yacute': 'Ý',
  'Yuml': 'Ÿ',
  'aacute': 'á',
  'acirc': 'â',
  'acute': '´',
  'aelig': 'æ',
  'agrave': 'à',
  'amp': '&',
  'apos': "'",
  'aring': 'å',
  'atilde': 'ã',
  'auml': 'ä',
  'bdquo': '„',
  'brvbar': '¦',
  'bull': '•',
  'ccedil': 'ç',
  'cedil': '¸',
  'cent': '¢',
  'circ': 'ˆ',
  'clubs': '♣',
  'copy': '©',
  'curren': '¤',
  'dagger': '†',
  'darr': '↓',
  'deg': '°',
  'diams': '♦',
  'divide': '÷',
  'eacute': 'é',
  'ecirc': 'ê',
  'egrave': 'è',
  'emsp': ' ',
  'ensp': ' ',
  'eth': 'ð',
  'euml': 'ë',
  'euro': '€',
  'fnof': 'ƒ',
  'frac12': '½',
  'frac14': '¼',
  'frac34': '¾',
  'gt': '>',
  'harr': '↔',
  'hearts': '♥',
  'hellip': '…',
  'iacute': 'í',
  'icirc': 'î',
  'iexcl': '¡',
  'igrave': 'ì',
  'iquest': '¿',
  'iuml': 'ï',
  'laquo': '«',
  'larr': '←',
  'ldquo': '“',
  'lrm': '',
  'lsaquo': '‹',
  'lsquo': '‘',
  'lt': '<',
  'macr': '¯',
  'mdash': '—',
  'micro': 'µ',
  'middot': '·',
  'minus': '−',
  'nbsp': ' ',
  'ndash': '–',
  'not': '¬',
  'ntilde': 'ñ',
  'oacute': 'ó',
  'ocirc': 'ô',
  'oelig': 'œ',
  'ograve': 'ò',
  'ordf': 'ª',
  'ordm': 'º',
  'oslash': 'ø',
  'otilde': 'õ',
  'ouml': 'ö',
  'para': '¶',
  'permil': '‰',
  'plusmn': '±',
  'pound': '£',
  'prime': '′',
  'quot': '"',
  'raquo': '»',
  'rarr': '→',
  'rdquo': '”',
  'reg': '®',
  'rlm': '',
  'rsaquo': '›',
  'rsquo': '’',
  'sbquo': '‚',
  'scaron': 'š',
  'sect': '§',
  'shy': '',
  'spades': '♠',
  'sup1': '¹',
  'sup2': '²',
  'sup3': '³',
  'szlig': 'ß',
  'thinsp': ' ',
  'thorn': 'þ',
  'tilde': '˜',
  'times': '×',
  'trade': '™',
  'uacute': 'ú',
  'uarr': '↑',
  'ucirc': 'û',
  'ugrave': 'ù',
  'uml': '¨',
  'uuml': 'ü',
  'yacute': 'ý',
  'yen': '¥',
  'yuml': 'ÿ',
  'zwj': '',
  'zwnj': '',
};

final RegExp _namedEntity = RegExp('&([A-Za-z][A-Za-z0-9]*);');
final RegExp _numericEntity = RegExp(r'&#(x?)([0-9a-fA-F]+);');

/// "&amp;Uuml;": an entity escaped twice (Podlove feeds like Freak Show do
/// that in link titles) – collapsed to "&Uuml;" when the inner one is known.
final RegExp _doubleEncoded = RegExp(
  '&amp;(#x[0-9a-fA-F]+|#[0-9]+|[A-Za-z][A-Za-z0-9]*);',
);

/// Replaces HTML entities that feeds leave in their text ("&nbsp;",
/// "&#8211;", "&rsquo;" …) by the characters, also when the feed escaped
/// them twice ("&amp;Uuml;" → "Ü", bug 2026-10-04). Unknown entities stay.
String decodeHtmlEntities(String text) {
  final collapsed = text.replaceAllMapped(_doubleEncoded, (m) {
    final inner = m[1]!;
    final known = inner.startsWith('#') || _namedEntities.containsKey(inner);
    return known ? '&$inner;' : m[0]!;
  });
  // One pass over the text: a decoded "&" can never start a new entity.
  return collapsed.replaceAllMapped(
    RegExp('${_namedEntity.pattern}|${_numericEntity.pattern}'),
    (m) {
      if (m[1] case final name?) return _namedEntities[name] ?? m[0]!;
      final code = int.tryParse(m[3]!, radix: m[2]!.isEmpty ? 10 : 16);
      return code == null || code > 0x10FFFF
          ? m[0]!
          : String.fromCharCode(code);
    },
  );
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

/// True for an absolute http(s) address – the only links the app opens.
bool isWebUrl(String url) => _isWebUrl(url);

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
