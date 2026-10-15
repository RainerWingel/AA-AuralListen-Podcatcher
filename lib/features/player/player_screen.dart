import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../audio/audio_providers.dart';
import '../../core/formatting.dart';
import '../../core/perceived_brightness.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart' show DownloadState, EpisodeStatus;
import '../../data/playlist_repository.dart' show PlaylistEntry;
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_description.dart';
import 'chapter_cover.dart';
import 'chapters_and_bookmarks.dart';
import 'player_action_bar.dart';
import 'player_backdrop.dart';
import 'player_controls.dart';

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

/// Gap above the button rows and above the description, so they are as far
/// apart as the two button rows (see the comment at its first use).
const double _controlGap = 12;

/// Full-screen player (opened from the mini player).
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Dark mode: buttons and description on a slightly brighter background
    // (Weber–Fechner, perceived_brightness.dart).
    final theme = playerTheme(Theme.of(context));
    final item = ref.watch(mediaItemProvider).value?.mediaItem;
    final podcastId = item?.extras?['podcastId'] as int?;
    final episodeId = item?.extras?['episodeId'] as int?;
    // Live, so "Abonnieren" during playback shows them at once.
    final provisional = switch (podcastId) {
      final id? => ref.watch(podcastProvider(id)).value?.provisional ?? false,
      null => false,
    };

    // The blurred picture lies behind everything, also behind the app bar;
    // the Scaffold on top is transparent, its colors follow the picture
    // (user wishes 2026-10-17). The control panel keeps the normal theme.
    return Theme(
      data: theme,
      child: PlayerBackdrop(
        episodeId: episodeId,
        coverUrl: item?.artUri?.toString(),
        builder: (context, adapted) => Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            // Status bar icons dark on a light picture, light on a dark one.
            systemOverlayStyle:
                adapted.colorScheme.onSurface.computeLuminance() > 0.5
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
            leading: IconButton(
              tooltip: l10n.playerClose,
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(l10n.nowPlaying),
          ),
          body: item == null
              ? const SizedBox.shrink()
              : _isLandscape(context)
              // Landscape phone: info on the left, controls on the right –
              // the height is too short for pinned controls below (user wish
              // 2026-10-16).
              ? SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoArea(
                          item: item,
                          theme: adapted,
                          provisional: provisional,
                        ),
                      ),
                      // The control panel lies above the picture and casts a
                      // shadow onto it (user wish 2026-10-17).
                      Expanded(
                        child: Theme(
                          data: theme,
                          child: Builder(
                            builder: (context) => _PanelMaterial(
                              child: DecoratedBox(
                                decoration: _panelDecoration(
                                  context,
                                  const Offset(-6, 0),
                                ),
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      8,
                                      24,
                                      8,
                                    ),
                                    child: _PlayerControls(
                                      item: item,
                                      podcastId: podcastId,
                                      provisional: provisional,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              // Portrait: the info scrolls, the controls stay pinned below
              // (user wish 2026-10-16).
              : SafeArea(
                  bottom: false,
                  child: _InfoArea(
                    item: item,
                    theme: adapted,
                    provisional: provisional,
                  ),
                ),
          // As the bottom bar of the scaffold, so info boxes float above the
          // pinned buttons instead of covering them.
          bottomNavigationBar: item == null || _isLandscape(context)
              ? null
              // A card inset from all edges, lying above the picture with a
              // shadow on all four sides (user wish 2026-10-17).
              : Theme(
                  data: theme,
                  child: Builder(
                    builder: (context) => SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: _PanelMaterial(
                          child: DecoratedBox(
                            decoration: _cardDecoration(context),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: _PlayerControls(
                                item: item,
                                podcastId: podcastId,
                                provisional: provisional,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// The portrait control card: rounded, its own surface color and a shadow
  /// on every side.
  static BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 24,
        spreadRadius: 2,
      ),
      // More weight toward the picture above.
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, -6),
      ),
    ],
  );

  /// The landscape control panel: its own surface color and a shadow toward
  /// the picture, so it looks like lying above it.
  static BoxDecoration _panelDecoration(BuildContext context, Offset toward) =>
      BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 24,
            spreadRadius: 3,
            offset: toward,
          ),
        ],
      );

  /// A short, wide screen (phone turned sideways).
  static bool _isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height && size.height < 500;
  }
}

/// Resets the default text style for the control panel: the Scaffold's
/// Material sits inside the picture-adapted theme, so plain `Text` (the time
/// marks) would otherwise take the picture's text color – white on the
/// panel's light surface in light mode.
class _PanelMaterial extends StatelessWidget {
  const _PanelMaterial({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Material(type: MaterialType.transparency, child: child);
}

/// The scrolling info part: cover (never taller than the visible area), title,
/// chapters and description.
class _InfoArea extends StatelessWidget {
  const _InfoArea({
    required this.item,
    required this.theme,
    required this.provisional,
  });

  final MediaItem item;
  final ThemeData theme;
  final bool provisional;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final coverSize = max(
        72.0,
        min(constraints.maxWidth - 64, min(360.0, constraints.maxHeight - 32)),
      );
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _PlayerInfo(
          item: item,
          coverSize: coverSize,
          theme: theme,
          provisional: provisional,
        ),
      );
    },
  );
}

/// Seek bar, play row and the four buttons – pinned below in portrait, in the
/// right half in landscape.
class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.item,
    required this.podcastId,
    required this.provisional,
  });

  final MediaItem item;
  final int? podcastId;
  final bool provisional;

  @override
  Widget build(BuildContext context) {
    final episodeId = item.extras?['episodeId'] as int?;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Own semantics group: the slider below the scrolling area otherwise
        // trips a Flutter semantics assertion when the episode changes under
        // an open sheet (tests).
        Semantics(
          container: true,
          explicitChildNodes: true,
          child: _SeekBar(total: item.duration),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SkipButton.back(),
            PlayPauseButton(size: 48, filled: true),
            SkipButton.forward(),
          ],
        ),
        // Same visible gap (16) between the control blocks (user wish
        // 2026-10-09): text buttons carry 4 invisible tap-target padding on
        // each side, so 12 here + 4 = 16.
        const SizedBox(height: _controlGap),
        if (episodeId != null)
          PlayerActionBar(
            episodeId: episodeId,
            podcastId: podcastId,
            bookmarks: !provisional,
          ),
      ],
    );
  }
}

/// The scrolling part of the player: cover, title, podcast, playlist row,
/// the chapter button and – one step below it – the description.
class _PlayerInfo extends ConsumerWidget {
  const _PlayerInfo({
    required this.item,
    required this.coverSize,
    required this.theme,
    required this.provisional,
  });

  final MediaItem item;
  final double coverSize;
  final ThemeData theme;
  final bool provisional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastId = item.extras?['podcastId'] as int?;
    final episodeId = item.extras?['episodeId'] as int?;
    return Column(
      children: [
        const SizedBox(height: 16),
        PlayerCover(
          episodeId: episodeId,
          coverUrl: item.artUri?.toString(),
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
            if (episodeId != null) _DownloadedIcon(episodeId: episodeId),
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
        // Under the title, so the playlist context sits with it (user
        // request 2026-10-01).
        if (item.extras?['playlistId'] case final int id)
          _PlaylistRow(playlistId: id)
        else if (item.extras?['suggestedPlaylistId'] case final int id)
          _PlaylistRow(playlistId: id, offered: true),
        const SizedBox(height: 8),
        if (episodeId != null) ...[
          CurrentChapterLine(episodeId: episodeId),
          const SizedBox(height: _controlGap),
          _OnPlayerBackground(
            child: EpisodeDescriptionSection(
              episodeId: episodeId,
              podcastId: podcastId,
              pubDate: switch (item.extras?['pubDateMs']) {
                final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
                _ => null,
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
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
    final entries =
        ref.watch(playlistEntriesProvider(playlistId)).value ??
        const <PlaylistEntry>[];
    final index = entries.indexWhere((e) => '${e.episode.id}' == current);
    final hasPrevious = index > 0;
    // ⏭ skips played episodes, like the playlist does (user report
    // 2026-10-06): only an unplayed one further down counts.
    final hasNext =
        index >= 0 &&
        entries
            .skip(index + 1)
            .any((e) => e.episode.status != EpisodeStatus.played);
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

/// The description section lies on the blurred picture as a translucent
/// plate in the text color, outlined by a thin line (user wishes 2026-10-09
/// and 2026-10-17).
class _OnPlayerBackground extends StatelessWidget {
  const _OnPlayerBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.12),
        border: Border.all(color: ink.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    );
  }
}
