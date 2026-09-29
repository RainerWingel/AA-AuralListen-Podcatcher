import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// An episode together with its podcast, for lists across all subscriptions.
typedef EpisodeWithPodcast = ({Episode episode, Podcast podcast});

/// The single SQLite database of the app (think: EF Core DbContext).
@DriftDatabase(
  tables: [
    Podcasts,
    Episodes,
    Settings,
    Downloads,
    Playlists,
    PlaylistItems,
    Chapters,
    Bookmarks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'aapodcastguru',
          native: const DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
        ),
      );

  /// For tests: pass e.g. `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  /// Name of the playlist that exists from the first start on (German-only app).
  static const defaultPlaylistName = 'Wiedergabeliste';

  Future<void> _createDefaultPlaylist() => into(playlists).insert(
    PlaylistsCompanion.insert(
      name: defaultPlaylistName,
      createdAt: DateTime.now(),
    ),
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createDefaultPlaylist();
    },
    onUpgrade: (m, from, to) async {
      // One step per version; each step is covered by test/data/db/migration_test.dart.
      if (from < 2) {
        await m.createTable(settings);
      }
      if (from < 3) {
        await m.createTable(downloads);
      }
      if (from < 4) {
        await m.createTable(playlists);
        await m.createTable(playlistItems);
        await _createDefaultPlaylist();
      }
      if (from < 5) {
        await m.addColumn(episodes, episodes.theme);
        await m.addColumn(podcasts, podcasts.autoDownloadThemes);
        // Forget HTTP validators so the next refresh re-reads every feed
        // and fills in the new `theme` column for existing episodes.
        await customStatement(
          'UPDATE podcasts SET etag = NULL, last_modified = NULL',
        );
      }
      if (from < 6) {
        await m.createTable(chapters);
        await m.createTable(bookmarks);
        // Re-read feeds once more so Podlove chapters in the feed get stored.
        await customStatement(
          'UPDATE podcasts SET etag = NULL, last_modified = NULL',
        );
      }
      // Before v4 the table was just created above, already with the column.
      if (from >= 4 && from < 7) {
        await m.addColumn(playlists, playlists.lastEpisodeId);
      }
      if (from < 8) {
        // New rule "under 15 s nothing counts" (PlaybackRepository
        // .inProgressFrom): episodes that became "in progress" after a few
        // seconds under the old rule are new again. No schema change.
        await customStatement(
          "UPDATE episodes SET status = 'newEpisode', position_ms = 0 "
          "WHERE status = 'inProgress' AND position_ms < 15000",
        );
      }
      // Before v4 the table was created above, already with this column.
      if (from >= 4 && from < 9) {
        await m.addColumn(playlists, playlists.color);
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys (and ON DELETE CASCADE) unless enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
