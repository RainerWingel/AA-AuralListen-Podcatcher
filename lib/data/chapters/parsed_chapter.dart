import 'dart:typed_data';

/// A chapter as read from a feed, a JSON file or an MP3 – before storing.
class ParsedChapter {
  const ParsedChapter({
    required this.start,
    required this.title,
    this.url,
    this.imageUrl,
    this.imageBytes,
    this.imageExtension,
  });

  final Duration start;
  final String title;
  final String? url;

  /// Web address of the chapter picture (JSON `img`, or an ID3 picture frame
  /// that only links to it).
  final String? imageUrl;

  /// Picture embedded in the MP3 (ID3 APIC frame of the chapter), with its
  /// file extension (`jpg`, `png` …). Stored as a file, not in the database.
  final Uint8List? imageBytes;
  final String? imageExtension;

  @override
  String toString() => 'ParsedChapter($start, $title)';
}

/// Sorts by start time, drops duplicates of the same start and empty titles.
List<ParsedChapter> normalizeChapters(Iterable<ParsedChapter> chapters) {
  final byStart = <Duration, ParsedChapter>{};
  for (final c in chapters) {
    if (c.title.trim().isEmpty || c.start.isNegative) continue;
    byStart.putIfAbsent(c.start, () => c);
  }
  return byStart.values.toList()..sort((a, b) => a.start.compareTo(b.start));
}
