import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../l10n/app_localizations.dart';

/// Play/pause button that shows a spinner while loading or buffering.
class PlayPauseButton extends ConsumerWidget {
  const PlayPauseButton({this.size = 32, this.filled = false, super.key});

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final state = ref.watch(playbackStateProvider).value;
    final playing = state?.playing ?? false;
    final busy =
        state != null &&
        playing &&
        (state.processingState == AudioProcessingState.loading ||
            state.processingState == AudioProcessingState.buffering);

    final icon = busy
        ? SizedBox.square(
            dimension: size * 0.7,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: filled ? Theme.of(context).colorScheme.onPrimary : null,
            ),
          )
        : Icon(playing ? Icons.pause : Icons.play_arrow, size: size);

    void onPressed() => playing ? handler.pause() : handler.play();
    final tooltip = playing ? l10n.playerPause : l10n.playerPlay;

    return filled
        ? IconButton.filled(
            tooltip: tooltip,
            iconSize: size,
            padding: EdgeInsets.all(size / 3),
            onPressed: onPressed,
            icon: icon,
          )
        : IconButton(
            tooltip: tooltip,
            iconSize: size,
            onPressed: onPressed,
            icon: icon,
          );
  }
}

/// −15 s / +30 s button: circular arrow with the seconds inside.
class SkipButton extends ConsumerWidget {
  const SkipButton.back({super.key}) : forward = false;
  const SkipButton.forward({super.key}) : forward = true;

  final bool forward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final handler = ref.watch(audioHandlerProvider);
    return IconButton(
      tooltip: forward ? l10n.playerForward : l10n.playerRewind,
      iconSize: 44,
      onPressed: forward ? handler.fastForward : handler.rewind,
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Transform.flip(
            flipX: forward,
            child: const Icon(Icons.replay, size: 44),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              forward ? '30' : '15',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
