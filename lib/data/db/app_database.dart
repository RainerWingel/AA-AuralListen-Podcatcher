import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// An episode together with its podcast, for lists across all subscriptions.
typedef EpisodeWithPodcast = ({Episode episode, Podcast podcast});

/// The single SQLite database of the app (think: EF Core DbContext).
@DriftDatabase(tables: [Podcasts, Episodes, Settings])
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // One step per version; each step is covered by test/data/db/migration_test.dart.
      if (from < 2) {
        await m.createTable(settings);
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys (and ON DELETE CASCADE) unless enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
