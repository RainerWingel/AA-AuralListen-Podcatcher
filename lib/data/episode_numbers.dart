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
Map<int, int> episodeNumbers(List<NumberedEpisode> episodes, {int offset = 0}) {
  if (episodes.any((e) => e.feedNumber != null)) {
    return {for (final e in episodes) e.id: ?e.feedNumber};
  }
  final dated = episodes.where((e) => e.pubDate != null).toList()
    ..sort((a, b) {
      final byDate = a.pubDate!.compareTo(b.pubDate!);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
  return {for (final (i, e) in dated.indexed) e.id: i + 1 + offset};
}
