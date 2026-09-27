import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'boost_sheet.dart';
import 'player_controls.dart';

/// Full-screen player (opened from the mini player).
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = ref.watch(mediaItemProvider).value;

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
                        Text(
                          item.album ?? '',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SeekBar(total: item.duration),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SkipButton.back(),
                            PlayPauseButton(size: 48, filled: true),
                            SkipButton.forward(),
                          ],
                        ),
                        if (item.extras?['playlistId'] case final int id)
                          _PlaylistRow(playlistId: id),
                        const SizedBox(height: 8),
                        if (podcastId != null) _BoostButton(podcastId),
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
          onChangeEnd: (v) async {
            await handler.seek(Duration(milliseconds: v.round()));
            if (mounted) setState(() => _dragValue = null);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatClock(shown)),
              Text('-${formatClock(total - shown)}'),
            ],
          ),
        ),
      ],
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
class _PlaylistRow extends ConsumerWidget {
  const _PlaylistRow({required this.playlistId});

  final int playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(playlistProvider(playlistId)).value?.name;
    if (name == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.playlist_play, size: 20),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.playingFromPlaylist(name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          tooltip: l10n.playerNext,
          icon: const Icon(Icons.skip_next),
          onPressed: ref.read(audioHandlerProvider).skipToNext,
        ),
      ],
    );
  }
}
