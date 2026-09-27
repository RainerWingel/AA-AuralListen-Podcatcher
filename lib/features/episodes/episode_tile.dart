import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/db/app_database.dart';
import '../../l10n/app_localizations.dart';

/// One episode row: cover, title, date · duration, listening state.
class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({
    required this.episode,
    required this.podcast,
    this.showPodcastTitle = false,
    this.onTap,
    super.key,
  });

  final Episode episode;
  final Podcast podcast;
  final bool showPodcastTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();

    final meta = [
      if (showPodcastTitle) podcast.title,
      if (episode.pubDate case final date?) formatEpisodeDate(date, now: now),
      if (episode.durationMs case final ms?)
        formatEpisodeDuration(l10n, Duration(milliseconds: ms)),
    ].join(' · ');

    final played = episode.status == EpisodeStatus.played;
    final progress = switch ((episode.status, episode.durationMs)) {
      (EpisodeStatus.inProgress, final ms?) when ms > 0 =>
        (episode.positionMs / ms).clamp(0.0, 1.0),
      _ => null,
    };

    return ListTile(
      onTap: onTap,
      leading: CoverImage(url: episode.imageUrl ?? podcast.imageUrl, size: 56),
      title: Text(
        episode.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: played
            ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (progress != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(value: progress),
            ),
        ],
      ),
      trailing: switch (episode.status) {
        EpisodeStatus.newEpisode => Tooltip(
          message: l10n.episodeNew,
          child: Icon(Icons.circle, size: 10, color: theme.colorScheme.primary),
        ),
        EpisodeStatus.played => Tooltip(
          message: l10n.episodePlayed,
          child: Icon(Icons.check, color: theme.colorScheme.outline),
        ),
        EpisodeStatus.inProgress => null,
      },
    );
  }
}
