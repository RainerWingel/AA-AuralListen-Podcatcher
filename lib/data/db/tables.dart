import 'package:drift/drift.dart';

/// Auto-download setting per podcast (used from M4 on).
enum AutoDownloadMode { off, wifiOnly, always }

/// Lifecycle of a download (see docs/eviction.md).
enum DownloadState { queued, running, done, failed }

/// Listening state of an episode. See docs/data-model.md.
/// Stored by name (textEnum), so renaming a value needs a migration.
enum EpisodeStatus { newEpisode, inProgress, played }

/// Category color of a playlist (rainbow order). Stored by name (textEnum),
/// so renaming a value needs a migration. RGB values: playlist_colors.dart.
enum PlaylistColor { red, orange, yellow, green, blue, indigo, violet }

@DataClassName('Podcast')
class Podcasts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get feedUrl => text().unique()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get websiteUrl => text().nullable()();

  /// "Support" link from `podcast:funding` and its text (v17).
  TextColumn get fundingUrl => text().nullable()();
  TextColumn get fundingLabel => text().nullable()();

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

  /// Themes that are auto-downloaded (JSON list of theme keys, v5);
  /// null = all episodes regardless of theme.
  TextColumn get autoDownloadThemes => text().nullable()();
  IntColumn get autoDownloadMaxEpisodes =>
      integer().withDefault(const Constant(3))();
  BoolColumn get autoDeletePlayed =>
      boolean().withDefault(const Constant(true))();

  /// Loudness boost in dB; null = use the global default.
  RealColumn get boostDb => real().nullable()();

  /// Auto-downloaded episodes are also added to this playlist – schema v10.
  /// Null = none. No foreign key on purpose: if the playlist was deleted,
  /// the next auto-download creates it again under [autoPlaylistName].
  IntColumn get autoPlaylistId => integer().nullable()();
  TextColumn get autoPlaylistName => text().nullable()();

  /// Episode number on the covers (v11, docs/ui-ux.md): on/off and the
  /// offset added to the app's own count (not to the feed's numbers).
  BoolColumn get episodeCounter =>
      boolean().withDefault(const Constant(true))();
  IntColumn get episodeNumberOffset =>
      integer().withDefault(const Constant(0))();

  /// Count by date even if the feed numbers its episodes (v12); only then the
  /// offset applies to such feeds.
  BoolColumn get episodeOwnCount =>
      boolean().withDefault(const Constant(false))();

  /// The server delivered a streamed episode differently on a reload (e.g.
  /// newly inserted ads), so resuming a stream can land elsewhere (v16).
  /// Set by the player; the app then recommends downloading (playback.md).
  BoolColumn get streamVaries => boolean().withDefault(const Constant(false))();
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

  /// Unused since v13 (always NULL): show notes live in [EpisodeNotes], so
  /// episode lists do not load them into memory. Kept because dropping a
  /// column would rebuild the table (foreign keys of downloads, playlists …).
  TextColumn get description => text().nullable()();
  TextColumn get audioUrl => text()();
  TextColumn get audioMimeType => text().nullable()();
  IntColumn get audioSizeBytes => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get pubDate => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get chaptersUrl => text().nullable()();

  /// Sub-series of a network feed, e.g. `zum-thema` (v5). See feeds-and-directories.md.
  TextColumn get theme => text().nullable()();

  /// The feed's own episode number (`itunes:episode`), v11.
  IntColumn get episodeNumber => integer().nullable()();

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

  /// Episode last played from this playlist ("Resume") – schema v7. No
  /// foreign key: it may point to an episode that has left the playlist
  /// meanwhile; resuming then starts at the top (docs/playlists.md).
  IntColumn get lastEpisodeId => integer().nullable()();

  /// Category color (background in the lists) – schema v9. Null = none.
  TextColumn get color => textEnum<PlaylistColor>().nullable()();
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

/// Chapters of an episode (schema v6). Sources: feed (Podlove), JSON file,
/// ID3 tag of the MP3 – see docs/playback.md.
@DataClassName('Chapter')
class Chapters extends Table {
  IntColumn get episodeId =>
      integer().references(Episodes, #id, onDelete: KeyAction.cascade)();
  IntColumn get startMs => integer()();
  TextColumn get title => text()();
  TextColumn get url => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {episodeId, startMs};
}

/// Show notes per episode (schema v13), read only when shown (episode menu,
/// player). Plain text plus links, see `htmlToNotes` in core/text_utils.dart.
@DataClassName('EpisodeNote')
class EpisodeNotes extends Table {
  IntColumn get episodeId =>
      integer().references(Episodes, #id, onDelete: KeyAction.cascade)();
  TextColumn get notes => text()();

  @override
  Set<Column> get primaryKey => {episodeId};
}

/// Bookmarks with an optional note (schema v6). Kept when the audio file is
/// evicted; deleted with the episode (unsubscribe).
@DataClassName('Bookmark')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId =>
      integer().references(Episodes, #id, onDelete: KeyAction.cascade)();
  IntColumn get positionMs => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
