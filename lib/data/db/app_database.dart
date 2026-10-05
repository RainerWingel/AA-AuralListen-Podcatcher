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
    EpisodeNotes,
    PlayHistory,
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
  int get schemaVersion => 23;

  /// Oldest schema that is still migrated (app 1.3.1); see [migration].
  static const oldestMigratedSchema = 20;

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
      // Migrations are kept from schema 20 (app 1.3.1, first F-Droid
      // submission) on; older steps were removed (user decision 2026-10-05,
      // no installs older than that are known). An older database starts
      // empty instead of crashing. Each step is covered by
      // test/data/db/migration_test.dart.
      if (from < oldestMigratedSchema) {
        for (final table in allTables.toList().reversed) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
        await _createDefaultPlaylist();
        return;
      }
      if (from < 21) {
        await m.addColumn(downloads, downloads.failedAttempts);
      }
      if (from < 22) {
        await m.addColumn(podcasts, podcasts.rating);
      }
      if (from < 23) {
        await m.addColumn(podcasts, podcasts.provisional);
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys (and ON DELETE CASCADE) unless enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
