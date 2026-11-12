# just_audio 0.10.6 (MIT) – patched copy

Copy of https://pub.dev/packages/just_audio 0.10.6 (sha256
`e60aa97b233ddea025e13dfac59195207f528fa5e9e4a4a49a8c0766701e5fe6`), without
`example/` and `test/`. Used as a path dependency in `pubspec.yaml`.

## Patch: video picture on a Flutter texture

Video podcasts play through the **same** ExoPlayer that plays the sound
(docs/decisions.md, 2026-11-12), so background playback, notification,
Android Auto, timers and the listening position need no second player.
The Dart part of the package is unchanged.

- New file `android/src/main/java/com/ryanheise/just_audio/VideoOutput.java`:
  method channel `com.ryanheise.just_audio.video` with `attach` (creates a
  `SurfaceProducer`, returns its texture id, every player renders into it),
  `detach` (players render nowhere – ExoPlayer then skips decoding –, the
  producer is released) and `videoFormat`; it sends `videoFormat`
  `{width, height, pixelRatio}` or `null` when the tracks change.
- `JustAudioPlugin.java`: `VideoOutput.install(...)` in `onAttachedToEngine`,
  `VideoOutput.uninstall()` in `onDetachedFromEngine`.
- `AudioPlayer.java`: `VideoOutput.onPlayerCreated(player)` after the
  ExoPlayer is built (`ensurePlayerInitialized`),
  `VideoOutput.onPlayerReleased(player)` before `player.release()` (`dispose`).

Dart side: `lib/audio/video_output.dart` in the app.

Housekeeping (no behavior): the Dart files are run through `dart format`
(CI checks the whole repo), and `analysis_options.yaml` turns off
`use_super_parameters`, so `flutter analyze` stays at 0 issues.

Update to a new upstream version: take the new release, copy
`VideoOutput.java`, repeat the three hook lines above, adjust the version in
this file and in `pubspec.yaml` (path).
