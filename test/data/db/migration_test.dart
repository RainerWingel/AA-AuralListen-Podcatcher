import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generated_migrations/schema.dart';

// Verifies every schema migration against the snapshots in drift_schemas/.
// Migrations are kept from schema 20 (app 1.3.1) on; v12 (app 1.3.0) stays
// only to test the "start empty" fallback for older databases.
// After changing tables: bump schemaVersion, add the migration step, then run
//   dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
// and add a "vN → latest" test case here (see docs/data-model.md).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('upgrade v20 → latest matches the current schema', () async {
    final connection = await verifier.startAt(20);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v21 keeps downloads, with no failures counted', () async {
    final schema = await verifier.schemaAt(20);
    schema.rawDatabase
      ..execute(
        'INSERT INTO podcasts (feed_url, title, subscribed_at) '
        "VALUES ('https://example.com/feed', 'P', 1767225600)",
      )
      ..execute(
        'INSERT INTO episodes (podcast_id, guid, title, audio_url, added_at) '
        "VALUES (1, 'g', 'E', 'https://example.com/e.mp3', 1767225600)",
      )
      ..execute(
        'INSERT INTO downloads (episode_id, relative_path, state, created_at) '
        "VALUES (1, '1.mp3', 'failed', 1767225600)",
      );
    final db = AppDatabase.forTesting(schema.newConnection());
    final download = await db.select(db.downloads).getSingle();
    expect(download.state, DownloadState.failed);
    expect(download.failedAttempts, 0);
    await db.close();
  });

  test('upgrade v21 → latest matches the current schema', () async {
    final connection = await verifier.startAt(21);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v22 keeps subscriptions, all unrated', () async {
    final schema = await verifier.schemaAt(21);
    schema.rawDatabase.execute(
      'INSERT INTO podcasts (feed_url, title, subscribed_at) '
      "VALUES ('https://example.com/feed', 'P', 1767225600)",
    );
    final db = AppDatabase.forTesting(schema.newConnection());
    final podcast = await db.select(db.podcasts).getSingle();
    expect(podcast.title, 'P');
    expect(podcast.rating, 0);
    await db.close();
  });

  test(
    'a database older than 1.3.1 starts empty instead of crashing',
    () async {
      expect(AppDatabase.oldestMigratedSchema, 20);
      final schema = await verifier.schemaAt(12);
      schema.rawDatabase
        ..execute(
          'INSERT INTO podcasts (feed_url, title, subscribed_at) '
          "VALUES ('https://example.com/feed', 'Alt', 1767225600)",
        )
        ..execute(
          'INSERT INTO episodes (podcast_id, guid, title, audio_url, added_at) '
          "VALUES (1, 'g', 'E', 'https://example.com/e.mp3', 1767225600)",
        );
      final db = AppDatabase.forTesting(schema.newConnection());
      expect(await db.select(db.podcasts).get(), isEmpty);
      expect(await db.select(db.episodes).get(), isEmpty);
      // Like a fresh install: the default playlist exists.
      final playlists = await db.select(db.playlists).get();
      expect(playlists.single.name, AppDatabase.defaultPlaylistName);
      await db.close();

      // And the resulting schema is exactly the current one.
      final connection = await verifier.startAt(12);
      final migrated = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(migrated, migrated.schemaVersion);
      await migrated.close();
    },
  );
}
