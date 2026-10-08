import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/clock.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/playback_repository.dart' show PlaybackRepository;
import '../../data/podcast_repository.dart' show isFreshEpisode;
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../playlists/playlist_actions.dart';
import 'episode_description.dart';

/// One episode row: cover, title, date · duration, listening state.
/// Tap plays the episode, long press opens the episode menu.
class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({
    required this.episode,
    required this.podcast,
    this.showPodcastTitle = false,
    this.playlistId,
    this.hot = false,
    super.key,
  });

  final Episode episode;
  final Podcast podcast;
  final bool showPodcastTitle;

  /// Set when shown inside a playlist: playing continues with the playlist.
  final int? playlistId;

  /// Its podcast or topic is (almost) never skipped: a 🔥 while not started
  /// yet (Start only, user wish 2026-10-08).
  final bool hot;

  /// Played episodes: thumbnail and text half transparent (like Castbox).
  static const playedOpacity = 0.5;

  Future<void> _showMenu(BuildContext context, WidgetRef ref) async {
    // The sheet's own context is gone once it closes; dialogs/snackbars that
    // follow a menu action use the tile's context.
    final outerContext = context;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Queue entries (user wish 2026-10-03): only outside a playlist view,
    // while another episode plays from an active playlist ("Aus Playlist
    // „X“" fully visible in the player).
    final handler = ref.read(audioHandlerProvider);
    final playlists = ref.read(playlistRepositoryProvider);
    final activeId = handler.activePlaylistId;
    final currentId = handler.currentEpisodeId;
    // Provisional podcast: only "Abspielen" and "Beschreibung" (user wish
    // 2026-10-05) – no queue, playlists, download or marking.
    final full = !podcast.provisional;
    final queue =
        full &&
            playlistId == null &&
            activeId != null &&
            currentId != null &&
            currentId != episode.id
        ? (
            id: activeId,
            current: currentId,
            name: (await playlists.playlists())
                .where((p) => p.id == activeId)
                .firstOrNull
                ?.name,
            contains: (await playlists.playlistIdsWith(episode.id))
                .contains(activeId),
          )
        : null;
    if (!context.mounted) return;
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
      // Six entries are taller than the default 9/16 of the screen.
      isScrollControlled: true,
      builder: (context) => SafeArea(
        // Up to eight entries: scroll instead of overflowing (large fonts).
        child: SingleChildScrollView(
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
              // Notes are loaded only when opened (not with the list).
              ListTile(
                leading: const Icon(Icons.notes),
                title: Text(l10n.episodeDescription),
                onTap: () {
                  Navigator.of(context).pop();
                  showEpisodeDescriptionSheet(
                    outerContext,
                    episodeId: episode.id,
                    title: episode.title,
                  );
                },
              ),
              if (queue case (
                :final id,
                :final current,
                name: final name?,
                :final contains,
              )) ...[
                ListTile(
                  leading: const Icon(Icons.queue_play_next),
                  title: Text(l10n.playNext),
                  subtitle: Text(l10n.playNextHint(name)),
                  onTap: () {
                    Navigator.of(context).pop();
                    playlists
                        .insertAfter(id, episode.id, afterEpisodeId: current)
                        .then(
                          (_) => showInfoSnackBar(
                            messenger,
                            l10n.playNextDone(name),
                          ),
                        );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: Text(l10n.appendToPlaylist(name)),
                  // Only when it is not in that playlist yet.
                  enabled: !contains,
                  onTap: () {
                    Navigator.of(context).pop();
                    playlists
                        .add(id, episode.id)
                        .then(
                          (_) => showInfoSnackBar(
                            messenger,
                            l10n.appendToPlaylistDone(name),
                          ),
                        );
                  },
                ),
              ],
              if (full) ...[
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: Text(l10n.addToPlaylist),
                  onTap: () {
                    Navigator.of(context).pop();
                    addToPlaylist(outerContext, ref, episode.id);
                  },
                ),
                // Waiting for Wi-Fi: start now over mobile data (user wish
                // 2026-10-05).
                if (download case Download(
                  state: DownloadState.queued,
                  wifiOnly: true,
                ))
                  ListTile(
                    leading: const Icon(Icons.network_cell),
                    title: Text(l10n.downloadNowMobile),
                    onTap: () {
                      Navigator.of(context).pop();
                      downloads.downloadNow(episode.id);
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
            ],
          ),
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
    // played episode only counts as current while it plays (a replay),
    // otherwise it shows as played (user report).
    final inPlayer =
        ref.watch(mediaItemProvider.select((s) => s.value?.mediaItem?.id)) ==
        '${episode.id}';
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
    // Like the status rule: under 15 s nothing counts, so no (empty) bar.
    final progress = switch ((episode.status, episode.durationMs)) {
      (EpisodeStatus.inProgress, final ms?)
          when ms > 0 &&
              episode.positionMs >=
                  PlaybackRepository.inProgressFrom.inMilliseconds =>
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
        _NumberedCover(
          episodeId: episode.id,
          podcastId: podcast.id,
          cover: CoverImage(
            url: episode.imageUrl ?? podcast.imageUrl,
            size: _coverSize,
          ),
        ),
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
                // Inside a playlist the mark would always be on.
                if (playlistId == null)
                  _PlaylistIndicator(episodeId: episode.id),
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
      // Always the same width, with or without a symbol: the progress bar
      // under the title must not change its length (user wish 2026-10-04).
      trailing: SizedBox(
        width: _trailingWidth,
        child: Center(
          child: isCurrent
              ? Tooltip(
                  message: l10n.nowPlaying,
                  child: Icon(
                    Icons.graphic_eq,
                    color: theme.colorScheme.primary,
                  ),
                )
              : switch (episode.status) {
                  // The dot marks only fresh episodes (like "Alle neuen
                  // Episoden spielen"), not everything never played.
                  EpisodeStatus.newEpisode => _NewMarks(
                    fresh: isFreshEpisode(episode, podcast, now),
                    hot: hot,
                  ),
                  EpisodeStatus.played => Tooltip(
                    message: l10n.episodePlayed,
                    child: Icon(Icons.check, color: theme.colorScheme.outline),
                  ),
                  EpisodeStatus.inProgress => null,
                },
        ),
      ),
    );
  }
}

/// Marks of an episode not started yet: 🔥 for a podcast/topic that is
/// (almost) never skipped, just above the dot of a fresh one; nothing if
/// neither applies.
class _NewMarks extends StatelessWidget {
  const _NewMarks({required this.fresh, required this.hot});

  final bool fresh;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final dot = Tooltip(
      message: l10n.episodeNew,
      child: Icon(Icons.circle, size: 10, color: colors.primary),
    );
    if (!hot) return fresh ? dot : const SizedBox.shrink();
    final flame = Tooltip(
      message: l10n.episodeHot,
      child: Icon(
        Icons.local_fire_department,
        size: 18,
        color: Colors.deepOrange.shade400,
      ),
    );
    if (!fresh) return flame;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [flame, const SizedBox(height: 1), dot],
    );
  }
}

/// Small icon in front of the date: downloaded ✓, waiting 🕓 (e.g. for
/// Wi-Fi), progress ring, or error.
class _DownloadIndicator extends ConsumerWidget {
  const _DownloadIndicator({required this.episodeId});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (state, wifiOnly) = ref.watch(
      downloadStatesProvider.select((s) {
        final row = s.value?[episodeId];
        return (row?.state, row?.wifiOnly ?? false);
      }),
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
      // Waiting (user wish 2026-10-05: a clock instead of an empty gap).
      DownloadState.queued => Tooltip(
        message: wifiOnly ? l10n.downloadWifiWaiting : l10n.downloadQueued,
        child: Icon(Icons.schedule, size: 16, color: colors.primary),
      ),
      // Without a progress value yet: spinning; the track keeps the ring
      // visible at 0 %.
      DownloadState.running => SizedBox.square(
        dimension: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: colors.primary.withValues(alpha: 0.25),
          value: ref.watch(
            downloadProgressProvider.select((p) => p.value?[episodeId]),
          ),
        ),
      ),
    };
    return Padding(padding: const EdgeInsets.only(right: 6), child: icon);
  }
}

/// Small icon next to the download mark: the episode is in a playlist.
class _PlaylistIndicator extends ConsumerWidget {
  const _PlaylistIndicator({required this.episodeId});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inPlaylist = ref.watch(
      episodesInPlaylistsProvider.select(
        (ids) => ids.value?.contains(episodeId) ?? false,
      ),
    );
    if (!inPlaylist) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Tooltip(
        message: AppLocalizations.of(context).episodeInPlaylist,
        child: Icon(
          Icons.playlist_add_check,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

const double _coverSize = 56;

/// Width of the status symbol on the right (an icon's size).
const double _trailingWidth = 24;

/// The cover with the episode number (if any) in a narrow dark strip on its
/// left edge, reading bottom to top (docs/ui-ux.md "Folgennummer").
class _NumberedCover extends ConsumerWidget {
  const _NumberedCover({
    required this.episodeId,
    required this.podcastId,
    required this.cover,
  });

  final int episodeId;
  final int podcastId;
  final Widget cover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final number = ref.watch(
      episodeNumbersProvider(podcastId).select((n) => n.value?[episodeId]),
    );
    if (number == null) return cover;
    return ClipRRect(
      // Same corners as CoverImage at this size.
      borderRadius: BorderRadius.circular(6),
      child: SizedBox.square(
        dimension: _coverSize,
        child: Stack(
          children: [
            cover,
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 15,
                // 75 % transparent so the cover shows through (user
                // request 2026-10-01); a text shadow keeps the number legible.
                color: Colors.black.withValues(alpha: 0.25),
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: FittedBox(
                    // Long labels ("-1234", "S12·105") shrink to the cover
                    // height.
                    fit: BoxFit.scaleDown,
                    child: Text(
                      number,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        shadows: [Shadow(blurRadius: 2)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
