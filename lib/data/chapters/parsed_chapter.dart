/// A chapter as read from a feed, a JSON file or an MP3 – before storing.
class ParsedChapter {
  const ParsedChapter({
    required this.start,
    required this.title,
    this.url,
    this.imageUrl,
  });

  final Duration start;
  final String title;
  final String? url;
  final String? imageUrl;

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
