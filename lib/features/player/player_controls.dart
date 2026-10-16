import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../audio/podcast_audio_handler.dart';
import '../../core/perceived_brightness.dart';
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

    // The button sizes itself by its content: the spinner sits in a box as
    // big as the icon, so the button keeps its size while loading.
    final icon = busy
        ? SizedBox.square(
            dimension: size,
            child: Center(
              child: SizedBox.square(
                dimension: size * 0.7,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: filled
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
              ),
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
            // Explicit: the player theme gives icon buttons a background
            // in dark mode, which would otherwise replace this one.
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
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

/// −15 s / +30 s button: circular arrow with the seconds inside. A tap skips;
/// holding it scans through the episode (docs/playback.md): the shown
/// position runs on by 15 s every 100 ms, nothing is played, and on release
/// playback continues from there if it was running (user wish 2026-10-20).
class SkipButton extends ConsumerStatefulWidget {
  const SkipButton.back({super.key}) : forward = false;
  const SkipButton.forward({super.key}) : forward = true;

  final bool forward;

  @override
  ConsumerState<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends ConsumerState<SkipButton> {
  bool _scanning = false;

  late final PodcastAudioHandler _handler = ref.read(audioHandlerProvider);

  void _start() {
    _scanning = true;
    unawaited(HapticFeedback.mediumImpact());
    unawaited(_handler.startScan(forward: widget.forward));
  }

  void _stop() {
    if (!_scanning) return;
    _scanning = false;
    unawaited(_handler.stopScan());
  }

  @override
  void dispose() {
    // The screen goes away while the finger is still down.
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forward = widget.forward;
    final outline = playerOutline(Theme.of(context));
    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _stop(),
      onLongPressCancel: _stop,
      // The tooltip must not claim the long press (its default trigger):
      // the long press is the scan.
      child: Tooltip(
        message: forward ? l10n.playerForward : l10n.playerRewind,
        triggerMode: TooltipTriggerMode.manual,
        child: IconButton(
          iconSize: 44,
          // Dark mode: outlined like the description section (user wish
          // 2026-10-09); the background comes from the player theme.
          style: outline == null
              ? null
              : IconButton.styleFrom(side: BorderSide(color: outline)),
          onPressed: forward ? _handler.fastForward : _handler.rewind,
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
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
