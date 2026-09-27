import 'package:drift/drift.dart';

/// Auto-download setting per podcast (used from M4 on).
enum AutoDownloadMode { off, wifiOnly, always }

/// Lifecycle of a download (see docs/eviction.md).
enum DownloadState { queued, running, done, failed }

/// Listening state of an episode. See docs/data-model.md.
/// Stored by name (textEnum), so renaming a value needs a migration.
enum EpisodeStatus { newEpisode, inProgress, played }

@DataClassName('Podcast')
class Podcasts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get feedUrl => text().unique()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get websiteUrl => text().nullable()();

  // HTTP caching for conditional GET.
  TextColumn get etag => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  DateTimeColumn get lastRefreshAt => dateTime().nullable()();

  /// Last refresh error as a short technical message; null when the last refresh succeeded.
  TextColumn get lastError => text().nullable()();

  DateTimeColumn get subscribedAt => dateTime()();

  // Per-podcast settings (used from M3/M4 on).
  TextColumn get autoDownloadMode => textEnum<AutoDownloadMode>().withDefault(
    Constant(AutoDownloadMode.off.name),
  )();
  IntColumn get autoDownloadMaxEpisodes =>
      integer().withDefault(const Constant(3))();
  BoolColumn get autoDeletePlayed =>
      boolean().withDefault(const Constant(true))();

  /// Loudness boost in dB; null = use the global default.
  RealColumn get boostDb => real().nullable()();
}

@DataClassName('Episode')
@TableIndex(name: 'episodes_pub_date', columns: {#pubDate})
class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get podcastId =>
      integer().references(Podcasts, #id, onDelete: KeyAction.cascade)();

  /// Feed guid, falling back to the enclosure URL. Unique per podcast.
  TextColumn get guid => text()();
  TextColumn get title => text()();

  /// Plain text, shortened (see docs/eviction.md).
  TextColumn get description => text().nullable()();
  TextColumn get audioUrl => text()();
  TextColumn get audioMimeType => text().nullable()();
  IntColumn get audioSizeBytes => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get pubDate => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get chaptersUrl => text().nullable()();

  TextColumn get status => textEnum<EpisodeStatus>().withDefault(
    Constant(EpisodeStatus.newEpisode.name),
  )();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get playedAt => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {podcastId, guid},
  ];
}

/// Simple key/value store for app settings and player state (schema v2).
/// Keys are defined in `lib/data/settings_keys.dart`.
@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// One row per downloaded (or downloading) episode – schema v3.
/// The file lives at `<app support>/episodes/<relativePath>`.
@DataClassName('Download')
class Downloads extends Table {
  IntColumn get episodeId =>
      integer().references(Episodes, #id, onDelete: KeyAction.cascade)();

  /// File name inside the episodes directory, e.g. `42.mp3`.
  TextColumn get relativePath => text()();
  TextColumn get state => textEnum<DownloadState>()();
  IntColumn get sizeBytes => integer().nullable()();

  /// Auto-downloads are queued with "Wi-Fi only" when the podcast says so.
  BoolColumn get wifiOnly => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {episodeId};
}

/// User playlists (Castbox-like, filled manually) – schema v4.
@DataClassName('Playlist')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Order in the Playlists tab (ascending).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Episodes in a playlist. An episode appears at most once per playlist.
@DataClassName('PlaylistItem')
class PlaylistItems extends Table {
  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn get episodeId =>
      integer().references(Episodes, #id, onDelete: KeyAction.cascade)();

  /// Order inside the playlist (ascending). New items get max + 1.
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {playlistId, episodeId};
}
