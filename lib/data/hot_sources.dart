import 'package:flutter/foundation.dart' show setEquals;

import 'db/app_database.dart';

/// What the 🔥 rule needs to know about one episode.
typedef HotEpisodeFacts = ({
  int podcastId,
  String? theme,
  DateTime? pubDate,
  EpisodeStatus status,
  bool finishedListening,
});

/// Podcasts and topics whose episodes are (almost) never skipped – their
/// new episodes get a 🔥 on Start (user wish 2026-10-08, docs/ui-ux.md).
class HotSources {
  const HotSources(this.podcasts, this.themes);

  static const empty = HotSources({}, {});

  /// The newest episodes looked at per podcast or topic.
  static const window = 10;

  /// Fewer judged episodes than this: no verdict, no 🔥.
  static const minEpisodes = 5;

  /// Share of judged episodes that were heard.
  static const minShare = 0.8;

  /// Newer episodes are not judged yet – there was no time to hear them.
  static const grace = Duration(days: 7);

  final Set<int> podcasts;

  /// (podcast id, topic key) – topics of network feeds count on their own.
  final Set<(int, String)> themes;

  @override
  bool operator ==(Object other) =>
      other is HotSources &&
      setEquals(other.podcasts, podcasts) &&
      setEquals(other.themes, themes);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(podcasts),
    Object.hashAllUnordered(themes),
  );

  bool contains(Episode episode) =>
      podcasts.contains(episode.podcastId) ||
      (episode.theme != null &&
          themes.contains((episode.podcastId, episode.theme!)));

  /// Judges every podcast and every topic: of its [window] newest episodes
  /// older than [grace] – counting only from the oldest one ever heard, so a
  /// backlog from before subscribing does not count as skipped – at least
  /// [minShare] must be heard ("finishedListening": 90 % of it; or started).
  static HotSources compute(Iterable<HotEpisodeFacts> facts, DateTime now) {
    final byPodcast = <int, List<HotEpisodeFacts>>{};
    final byTheme = <(int, String), List<HotEpisodeFacts>>{};
    for (final f in facts) {
      (byPodcast[f.podcastId] ??= []).add(f);
      if (f.theme case final theme?) {
        (byTheme[(f.podcastId, theme)] ??= []).add(f);
      }
    }
    final cutoff = now.subtract(grace);
    return HotSources(
      {
        for (final e in byPodcast.entries)
          if (_isHot(e.value, cutoff)) e.key,
      },
      {
        for (final e in byTheme.entries)
          if (_isHot(e.value, cutoff)) e.key,
      },
    );
  }

  static bool _isHot(List<HotEpisodeFacts> episodes, DateTime cutoff) {
    DateTime? start;
    for (final e in episodes) {
      final pub = e.pubDate;
      if (e.finishedListening && pub != null) {
        if (start == null || pub.isBefore(start)) start = pub;
      }
    }
    if (start == null) return false;
    final judged = [
      for (final e in episodes)
        if (e.pubDate case final pub?
            when !pub.isBefore(start) && !pub.isAfter(cutoff))
          e,
    ]..sort((a, b) => b.pubDate!.compareTo(a.pubDate!));
    final recent = judged.take(window).toList();
    if (recent.length < minEpisodes) return false;
    final heard = recent
        .where(
          (e) => e.finishedListening || e.status == EpisodeStatus.inProgress,
        )
        .length;
    return heard / recent.length >= minShare;
  }
}
