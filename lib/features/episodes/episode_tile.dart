import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/clock.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/db/app_database.dart';
import '../../data/podcast_repository.dart' show isFreshEpisode;
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../playlists/playlist_actions.dart';

/// One episode row: cover, title, date · duration, listening state.
/// Tap plays the episode, long press opens the episode menu.
class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({
    required this.episode,
    required this.podcast,
    this.showPodcastTitle = false,
    this.playlistId,
    super.key,
  });

  final Episode episode;
  final Podcast podcast;
  final bool showPodcastTitle;

  /// Set when shown inside a playlist: playing continues with the playlist.
  final int? playlistId;

  /// Played episodes: thumbnail and text half transparent (like Castbox).
  static const playedOpacity = 0.5;

  Future<void> _showMenu(BuildContext context, WidgetRef ref) {
    // The sheet's own context is gone once it closes; dialogs/snackbars that
    // follow a menu action use the tile's context.
    final outerContext = context;
    final l10n = AppLocalizations.of(context);
    final playback = ref.read(playbackRepositoryProvider);
    final downloads = ref.read(downloadServiceProvider);
    final download = ref.read(downloadStatesProvider).value?[episode.id];
    final played = episode.status == EpisodeStatus.played;

    // Download entry depends on the current download state.
    final (
      IconData downloadIcon,
      String downloadLabel,
      VoidCallback onDownload,
    ) = switch (download?.state) {
      null => (
        Icons.download,
        l10n.download,
        () => downloads.download(episode.id),
      ),
      DownloadState.failed => (
        Icons.refresh,
        l10n.downloadRetry,
        () => downloads.download(episode.id),
      ),
      DownloadState.queued || DownloadState.running => (
        Icons.close,
        l10n.downloadCancel,
        () => downloads.cancel(episode.id),
      ),
      DownloadState.done => (
        Icons.delete_outline,
        l10n.downloadDelete,
        () => downloads.delete(episode.id),
      ),
    };
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
                ref
                    .read(audioHandlerProvider)
                    .playEpisode(episode.id, playlistId: playlistId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: Text(l10n.addToPlaylist),
              onTap: () {
                Navigator.of(context).pop();
                addToPlaylist(outerContext, ref, episode.id);
              },
            ),
            ListTile(
              leading: Icon(downloadIcon),
              title: Text(downloadLabel),
              onTap: () {
                Navigator.of(context).pop();
                onDownload();
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
    // The mini player keeps showing the last episode after it finished; a
    // played episode only counts as current while it still plays (the last
    // 2 % after the 98 % mark), otherwise it shows as played (user report).
    final inPlayer = ref.watch(mediaItemProvider).value?.id == '${episode.id}';
    final playing = ref.watch(playbackStateProvider).value?.playing ?? false;
    final isCurrent =
        inPlayer && (episode.status != EpisodeStatus.played || playing);

    // Date and duration get their own line so a long podcast name can
    // never push them out of view.
    final meta = [
      if (episode.pubDate case final date?)
        formatEpisodeDate(date, now: now, locale: l10n.localeName),
      if (episode.durationMs case final ms?)
        formatEpisodeDuration(l10n, Duration(milliseconds: ms)),
    ].join(' · ');

    // The episode in the player stays fully visible even when played.
    final dimmed = episode.status == EpisodeStatus.played && !isCurrent;
    Widget dim(Widget child) =>
        dimmed ? Opacity(opacity: playedOpacity, child: child) : child;
    final progress = switch ((episode.status, episode.durationMs)) {
      (EpisodeStatus.inProgress, final ms?) when ms > 0 =>
        (episode.positionMs / ms).clamp(0.0, 1.0),
      _ => null,
    };

    return ListTile(
      onTap: () => ref
          .read(audioHandlerProvider)
          .playEpisode(episode.id, playlistId: playlistId),
      onLongPress: () => _showMenu(context, ref),
      selected: isCurrent,
      leading: dim(
        CoverImage(url: episode.imageUrl ?? podcast.imageUrl, size: 56),
      ),
      title: dim(
        Text(episode.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      subtitle: dim(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPodcastTitle)
              Text(podcast.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                _DownloadIndicator(episodeId: episode.id),
                Expanded(
                  child: Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(value: progress),
              ),
          ],
        ),
      ),
      trailing: isCurrent
          ? Tooltip(
              message: l10n.nowPlaying,
              child: Icon(Icons.graphic_eq, color: theme.colorScheme.primary),
            )
          : switch (episode.status) {
              // The dot marks only fresh episodes (like "Alle neuen
              // Episoden spielen"), not everything never played.
              EpisodeStatus.newEpisode
                  when !isFreshEpisode(episode, podcast, now) =>
                null,
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

/// Small icon in front of the date: downloaded ✓, progress ring, or error.
class _DownloadIndicator extends ConsumerWidget {
  const _DownloadIndicator({required this.episodeId});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      downloadStatesProvider.select((s) => s.value?[episodeId]?.state),
    );
    if (state == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final Widget icon = switch (state) {
      DownloadState.done => Tooltip(
        message: l10n.downloadDone,
        child: Icon(Icons.download_done, size: 16, color: colors.primary),
      ),
      DownloadState.failed => Tooltip(
        message: l10n.downloadFailed,
        child: Icon(Icons.error_outline, size: 16, color: colors.error),
      ),
      DownloadState.queued || DownloadState.running => SizedBox.square(
        dimension: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: ref.watch(
            downloadProgressProvider.select((p) => p.value?[episodeId]),
          ),
        ),
      ),
    };
    return Padding(padding: const EdgeInsets.only(right: 6), child: icon);
  }
}
