/// Keys of the `settings` table. Never rename a key without a migration.
abstract final class SettingsKeys {
  /// Episode id shown in the mini player after an app restart.
  static const lastEpisodeId = 'player.lastEpisodeId';

  /// Playback speed for all podcasts: 1.0, 1.2, 1.5 or 2.0 (missing = 1.0).
  static const playbackSpeed = 'player.speed';

  /// Global loudness boost in dB (default 0 = off).
  static const boostDb = 'player.boostDb';

  /// Light/dark mode: `system`, `light` or `dark` (ThemeMode names).
  static const themeMode = 'ui.themeMode';

  /// UI language: `de` or `en` (AppLanguage names). Missing = not chosen yet,
  /// the app asks on start.
  static const language = 'ui.language';

  /// Main color: an AppColor name (`orange` … `wallpaper`). Missing = orange.
  static const appColor = 'ui.appColor';

  /// Upper limit for all downloaded audio files in bytes (default 5 GB).
  static const downloadLimitBytes = 'downloads.limitBytes';

  /// Player shows the total length instead of the remaining time: `true`;
  /// missing = remaining time (default). Toggled by tapping the time.
  static const showTotalTime = 'player.showTotalTime';

  /// When an episode played to the end leaves its playlist: `now`,
  /// `after10Minutes` or `never` (FinishedRemoval names; missing = now).
  static const removeFinished = 'playlists.removeFinished';

  /// Playlist the current episode was started from (null = none).
  static const activePlaylistId = 'player.activePlaylistId';
}
