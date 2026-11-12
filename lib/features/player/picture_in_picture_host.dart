import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../l10n/app_localizations.dart';
import 'video_picture.dart';

/// Wraps the whole app (MaterialApp.builder): tells Android when leaving
/// the app should show the video in a small window, and fills that window
/// with the video only. The app below stays alive (offstage) meanwhile.
class PictureInPictureHost extends ConsumerWidget {
  const PictureInPictureHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pip = ref.watch(pictureInPictureProvider);
    final output = ref.watch(videoOutputProvider);
    final enabled =
        (ref.watch(videoPipOnProvider).value ?? true) &&
        (ref.watch(videoPictureOnProvider).value ?? true);
    final playing = ref.watch(
      playbackStateProvider.select((s) => s.value?.playing ?? false),
    );
    return ListenableBuilder(
      listenable: Listenable.merge([output.format, output.picture, pip.active]),
      child: child,
      builder: (context, child) {
        final format = output.format.value;
        // A playing video is on screen right now (player or full screen).
        final shown = format != null && output.picture.value != null;
        unawaited(
          pip.update(
            wanted: enabled && shown && playing,
            playing: playing,
            width: format == null
                ? 16
                : (format.width * format.pixelRatio).round(),
            height: format?.height ?? 9,
            labels: {
              'rewind': l10n.playerRewind,
              'play': l10n.playerPlay,
              'pause': l10n.playerPause,
              'forward': l10n.playerForward,
            },
          ),
        );
        final active = pip.active.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: active,
              child: TickerMode(enabled: !active, child: child!),
            ),
            if (active)
              ColoredBox(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: format?.aspectRatio ?? 16 / 9,
                    child: const VideoPicture(fallback: SizedBox.shrink()),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
