# audio_service 0.18.19 (MIT) – patched copy

Copy of https://pub.dev/packages/audio_service 0.18.19 (sha256
`95f3267f3449eb5cf71c8fcf1d556f57af1e898e2dc5815fb168d1843653edb7`), without
`example/` and `test/`. Used as a path dependency in `pubspec.yaml`.

## Patch (one place)

`android/src/main/java/com/ryanheise/audioservice/AudioService.java`,
`MediaSessionCallback.onMediaButtonEvent`:

- Before: `KEYCODE_MEDIA_PLAY` and `KEYCODE_MEDIA_PAUSE` were handled as a
  *toggle* (`onClick(media)`: playing → pause, paused → play).
- Now: `KEYCODE_MEDIA_PAUSE` only pauses and `KEYCODE_MEDIA_PLAY` only plays.
  `KEYCODE_MEDIA_PLAY_PAUSE` and `KEYCODE_HEADSETHOOK` (the real toggle keys)
  stay a toggle.

Why: a Bluetooth headset with multipoint sends an AVRCP "Pause" to every
connected phone when a call arrives on another one – sometimes twice. The
second "Pause" started a paused podcast again, which then played into the
void (docs/decisions.md, 2026-10-19).

Update to a new upstream version: take the new release, repeat the change
above, adjust the version in this file and in `pubspec.yaml` (path).
