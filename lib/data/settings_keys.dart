/// Keys of the `settings` table. Never rename a key without a migration.
abstract final class SettingsKeys {
  /// Episode id shown in the mini player after an app restart.
  static const lastEpisodeId = 'player.lastEpisodeId';

  /// Global loudness boost in dB (default 0 = off).
  static const boostDb = 'player.boostDb';

  /// Light/dark mode: `system`, `light` or `dark` (ThemeMode names).
  static const themeMode = 'ui.themeMode';

  /// Upper limit for all downloaded audio files in bytes (default 5 GB).
  static const downloadLimitBytes = 'downloads.limitBytes';

  /// Playlist the current episode was started from (null = none).
  static const activePlaylistId = 'player.activePlaylistId';
}
