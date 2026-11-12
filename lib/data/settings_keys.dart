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

  /// Background of the player's control panel: a `PanelDesign` name.
  static const panelDesign = 'ui.panelDesign';

  /// UI language: an AppLanguage name (`de`, `en`, `fr` …). Missing = not
  /// chosen yet, the app asks on start.
  static const language = 'ui.language';

  /// AppLanguage names the user has seen in the language list, comma
  /// separated. Missing = updated from 1.3.5 or older (`de`, `en`): a newer
  /// language matching the phone is offered once (NewLanguageOffer).
  static const knownLanguages = 'ui.knownLanguages';

  /// Main color: an AppColor name (`orange` … `wallpaper`). Missing = orange.
  static const appColor = 'ui.appColor';

  /// Upper limit for all downloaded audio files in bytes (default 5 GB).
  static const downloadLimitBytes = 'downloads.limitBytes';

  /// Player shows the total length instead of the remaining time: `true`;
  /// missing = remaining time (default). Toggled by tapping the time.
  static const showTotalTime = 'player.showTotalTime';

  /// When an episode played to the end leaves its playlist: `now`,
  /// `after5Minutes` or `never` (FinishedRemoval names; missing =
  /// after5Minutes).
  static const removeFinished = 'playlists.removeFinished';

  /// Auto-Sleep-Timer: JSON of an AutoSleepSchedule (mode, night windows,
  /// timer). Missing = on, every night 22:00–04:00, 30 minutes.
  static const autoSleep = 'player.autoSleep';

  /// Playlist the current episode was started from (null = none).
  static const activePlaylistId = 'player.activePlaylistId';

  /// Milliseconds since epoch when an update brought video episodes (schema
  /// v30). A podcast's first refresh after that marks the old video episodes
  /// it finds as played (docs/feeds-and-directories.md). Missing = installed
  /// with video support, nothing to catch up.
  static const videoSince = 'feeds.videoSince';
}
