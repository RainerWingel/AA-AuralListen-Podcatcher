import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../audio/audio_providers.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart' show DownloadState;
import '../../data/playlist_repository.dart' show PlaylistEntry;
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_description.dart';
import 'boost_sheet.dart';
import 'chapters_and_bookmarks.dart';
import 'player_controls.dart';
import 'speed_sheet.dart';

/// "Downloaded" mark in front of the podcast name – only when the file is
/// complete (playback then comes from the phone, not the network).
class _DownloadedIcon extends ConsumerWidget {
  const _DownloadedIcon({required this.episodeId});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(
      downloadStatesProvider.select(
        (s) => s.value?[episodeId]?.state == DownloadState.done,
      ),
    );
    if (!done) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Tooltip(
        message: AppLocalizations.of(context).downloadDone,
        child: Icon(
          Icons.download_done,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Full-screen player (opened from the mini player).
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = ref.watch(mediaItemProvider).value?.mediaItem;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.playerClose,
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.nowPlaying),
      ),
      body: item == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final coverSize = (constraints.maxWidth - 64).clamp(
                    120.0,
                    360.0,
                  );
                  final podcastId = item.extras?['podcastId'] as int?;
                  // Live, so "Abonnieren" during playback shows them at once.
                  final provisional = switch (podcastId) {
                    final id? =>
                      ref.watch(podcastProvider(id)).value?.provisional ??
                          false,
                    null => false,
                  };
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        CoverImage(
                          url: item.artUri?.toString(),
                          size: coverSize,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.extras?['episodeId'] case final int id)
                              _DownloadedIcon(episodeId: id),
                            Flexible(
                              child: Text(
                                item.album ?? '',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Above the seek bar, so the playlist context sits
                        // with the title (user request 2026-10-01).
                        if (item.extras?['playlistId'] case final int id)
                          _PlaylistRow(playlistId: id)
                        else if (item.extras?['suggestedPlaylistId']
                            case final int id)
                          _PlaylistRow(playlistId: id, offered: true),
                        const SizedBox(height: 16),
                        _SeekBar(total: item.duration),
                        if (item.extras?['episodeId'] case final int id)
                          CurrentChapterLine(episodeId: id),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SkipButton.back(),
                            PlayPauseButton(size: 48, filled: true),
                            SkipButton.forward(),
                          ],
                        ),
                        if (item.extras?['episodeId'] case final int id)
                          ChapterBookmarkButtons(
                            episodeId: id,
                            bookmarks: !provisional,
                          ),
                        const SizedBox(height: 8),
                        // Boost and speed side by side (wrap on narrow
                        // screens or large fonts).
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            if (podcastId != null && !provisional)
                              _BoostButton(podcastId),
                            const _SpeedButton(),
                          ],
                        ),
                        if (item.extras?['episodeId'] case final int id)
                          EpisodeDescriptionSection(
                            episodeId: id,
                            podcastId: podcastId,
                            pubDate: switch (item.extras?['pubDateMs']) {
                              final int ms =>
                                DateTime.fromMillisecondsSinceEpoch(ms),
                              _ => null,
                            },
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// Slider with elapsed / remaining time. While dragging, the slider follows
/// the finger; the seek happens on release.
class _SeekBar extends ConsumerStatefulWidget {
  const _SeekBar({required this.total});

  final Duration? total;

  @override
  ConsumerState<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);
    final total = widget.total ?? Duration.zero;
    final position = ref.watch(positionProvider).value ?? handler.position;
    final max = total.inMilliseconds.toDouble();
    final value = (_dragValue ?? position.inMilliseconds.toDouble()).clamp(
      0.0,
      max > 0 ? max : 1.0,
    );
    final shown = Duration(milliseconds: value.round());

    return Column(
      children: [
        Slider(
          max: max > 0 ? max : 1.0,
          value: value,
          onChanged: max > 0 ? (v) => setState(() => _dragValue = v) : null,
          onChangeEnd: (v) {
            // Release the finger value right away: without network the
            // player may never confirm the seek, and waiting for it froze
            // the time display (bug 2026-09-28). The position stream shows
            // the new place immediately anyway.
            unawaited(handler.seek(Duration(milliseconds: v.round())));
            setState(() => _dragValue = null);
          },
        ),
        Padding(
          // Right side 8 less: the tappable time brings its own padding.
          padding: const EdgeInsets.only(left: 24, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatClock(shown)),
              const SizedBox(width: 8),
              // "-1:05:00 (-43:20)" may not fit narrow screens or large
              // fonts: shrink rather than overflow.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _TotalOrRemaining(total: total, shown: shown),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Right time under the slider: remaining time ("-12:34", default) or the
/// total length. A tap switches; the choice is stored (settings).
class _TotalOrRemaining extends ConsumerWidget {
  const _TotalOrRemaining({required this.total, required this.shown});

  final Duration total;
  final Duration shown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTotal = ref.watch(showTotalTimeProvider).value ?? false;
    final speed = ref.watch(playbackSpeedProvider).value ?? 1;
    final remaining = total - shown;
    // Faster than normal: also the time it really takes, in brackets.
    final effective = speed == 1
        ? ''
        : ' (-${formatClock(remaining * (1 / speed))})';
    final settings = ref.read(settingsRepositoryProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showTotal
          ? settings.remove(SettingsKeys.showTotalTime)
          : settings.set(SettingsKeys.showTotalTime, 'true'),
      child: Padding(
        // A comfortable tap target around the short text.
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          showTotal
              ? formatClock(total)
              : '-${formatClock(remaining)}$effective',
        ),
      ),
    );
  }
}

class _SpeedButton extends ConsumerWidget {
  const _SpeedButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final speed = ref.watch(playbackSpeedProvider).value ?? 1;
    return TextButton.icon(
      onPressed: () => showSpeedSheet(context),
      icon: const Icon(Icons.speed),
      label: Text(
        l10n.speedButton(speed == 1 ? l10n.boostOff : formatSpeed(l10n, speed)),
      ),
    );
  }
}

class _BoostButton extends ConsumerWidget {
  const _BoostButton(this.podcastId);

  final int podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final boost = ref.watch(boostSettingProvider(podcastId));
    final value = boost.db <= 0
        ? l10n.boostOff
        : l10n.boostValue(boost.db.round());
    return TextButton.icon(
      onPressed: () => showBoostSheet(context, podcastId),
      icon: Icon(boost.db > 0 ? Icons.volume_up : Icons.volume_down),
      label: Text(l10n.boostButton(value)),
    );
  }
}

/// "Aus Playlist „X“" plus the "next episode" button.
///
/// [offered]: the episode was started elsewhere but is in this playlist –
/// shown half transparent; playback stops at the end unless the user taps
/// the row, which makes the playlist active (docs/playlists.md).
class _PlaylistRow extends ConsumerWidget {
  const _PlaylistRow({required this.playlistId, this.offered = false});

  final int playlistId;
  final bool offered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(playlistProvider(playlistId)).value?.name;
    if (name == null) return const SizedBox.shrink();
    final handler = ref.read(audioHandlerProvider);
    // Neighbours in the active playlist, live from the DB: ⏮/⏭ are off at
    // its start/end.
    final current = ref.watch(
      mediaItemProvider.select((s) => s.value?.mediaItem?.id),
    );
    final order = [
      for (final e
          in ref.watch(playlistEntriesProvider(playlistId)).value ??
              const <PlaylistEntry>[])
        '${e.episode.id}',
    ];
    final index = order.indexOf(current ?? '');
    final hasPrevious = index > 0;
    final hasNext = index >= 0 && index < order.length - 1;
    // Offered: switches the playlist on and says so (user wish 2026-10-06).
    void activate() {
      handler.continueWithSuggestedPlaylist();
      showInfoSnackBar(
        ScaffoldMessenger.of(context),
        l10n.playlistActivated(name),
      );
    }

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active: the symbol leads to the playlist, scrolled to this
        // episode; the player closes (user wish 2026-10-06).
        IconButton(
          tooltip: offered ? l10n.playlistContinueOffer : l10n.playlistOpen,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.playlist_play, size: 20),
          onPressed: offered
              ? activate
              : () => _openPlaylist(context, handler.currentEpisodeId),
        ),
        Flexible(
          child: Text(
            l10n.playingFromPlaylist(name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // ⏮ ⏭: neighbours in the active playlist (user wish 2026-10-06);
        // while only offered, both just switch the playlist on.
        IconButton(
          tooltip: offered ? l10n.playlistContinueOffer : l10n.playerPrevious,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.skip_previous),
          onPressed: offered
              ? activate
              : hasPrevious
              ? handler.skipToPrevious
              : null,
        ),
        IconButton(
          tooltip: offered ? l10n.playlistContinueOffer : l10n.playerNext,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.skip_next),
          onPressed: offered
              ? activate
              : hasNext
              ? handler.skipToNext
              : null,
        ),
      ],
    );
    if (!offered) return row;
    return Tooltip(
      message: l10n.playlistContinueOffer,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: activate,
        child: Opacity(opacity: 0.5, child: row),
      ),
    );
  }

  /// Closes the player (it is a route above the tabs) and shows the
  /// playlist in its tab, scrolled to [episodeId].
  void _openPlaylist(BuildContext context, int? episodeId) {
    context.go(
      episodeId == null
          ? Routes.playlist(playlistId)
          : Routes.playlistAt(
              playlistId,
              episodeId,
              DateTime.now().millisecondsSinceEpoch,
            ),
    );
  }
}
