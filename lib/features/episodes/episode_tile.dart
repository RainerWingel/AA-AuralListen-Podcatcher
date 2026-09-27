import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/clock.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// One episode row: cover, title, date · duration, listening state.
/// Tap plays the episode, long press opens the episode menu.
class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({
    required this.episode,
    required this.podcast,
    this.showPodcastTitle = false,
    super.key,
  });

  final Episode episode;
  final Podcast podcast;
  final bool showPodcastTitle;

  Future<void> _showMenu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playback = ref.read(playbackRepositoryProvider);
    final played = episode.status == EpisodeStatus.played;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                episode.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: Text(l10n.playerPlay),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(audioHandlerProvider).playEpisode(episode.id);
              },
            ),
            ListTile(
              leading: Icon(played ? Icons.replay : Icons.check),
              title: Text(played ? l10n.markUnplayed : l10n.markPlayed),
              onTap: () {
                Navigator.of(context).pop();
                played
                    ? playback.markUnplayed(episode.id)
                    : playback.markPlayed(episode.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final isCurrent = ref.watch(mediaItemProvider).value?.id == '${episode.id}';

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
      onTap: () => ref.read(audioHandlerProvider).playEpisode(episode.id),
      onLongPress: () => _showMenu(context, ref),
      selected: isCurrent,
      leading: CoverImage(url: episode.imageUrl ?? podcast.imageUrl, size: 56),
      title: Text(
        episode.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: played && !isCurrent
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
      trailing: isCurrent
          ? Tooltip(
              message: l10n.nowPlaying,
              child: Icon(Icons.graphic_eq, color: theme.colorScheme.primary),
            )
          : switch (episode.status) {
              EpisodeStatus.newEpisode => Tooltip(
                message: l10n.episodeNew,
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: theme.colorScheme.primary,
                ),
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
