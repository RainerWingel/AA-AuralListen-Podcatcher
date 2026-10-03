/// One episode as far as numbering is concerned.
typedef NumberedEpisode = ({int id, DateTime? pubDate, int? feedNumber});

/// Numbers shown on the episode covers of one podcast (user wish
/// 2026-09-30, docs/ui-ux.md): episode id → number.
///
/// - If the feed numbers its episodes (`itunes:episode`), those numbers are
///   shown as they are; episodes without one get no number (a bonus episode
///   must not clash with an official number).
/// - Otherwise the app counts by publication date over the whole feed:
///   oldest = 1 + [offset]. Undated episodes cannot be placed and get none.
/// - [ownCount] forces the app's own count even for numbered feeds (chosen
///   per podcast); only then the offset applies to them.
Map<int, int> episodeNumbers(
  List<NumberedEpisode> episodes, {
  int offset = 0,
  bool ownCount = false,
}) {
  if (!ownCount && episodes.any((e) => e.feedNumber != null)) {
    return {for (final e in episodes) e.id: ?e.feedNumber};
  }
  final dated = episodes.where((e) => e.pubDate != null).toList()
    ..sort((a, b) {
      final byDate = a.pubDate!.compareTo(b.pubDate!);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
  return {for (final (i, e) in dated.indexed) e.id: i + 1 + offset};
}

/// Cover label of an episode of a podcast with seasons: "S2·5", "S2" for an
/// unnumbered episode of a season, "5" for a numbered one without season.
String? seasonLabel(int? season, int? number) => switch ((season, number)) {
  (final s?, final n?) => 'S$s·$n',
  (final s?, null) => 'S$s',
  (null, final n?) => '$n',
  (null, null) => null,
};
