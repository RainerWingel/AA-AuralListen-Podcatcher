import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generated_migrations/schema.dart';
import '../../generated_migrations/schema_v1.dart' as v1;

// Verifies every schema migration against the snapshots in drift_schemas/.
// After changing tables: bump schemaVersion, add the migration step, then run
//   dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
// and add a "vN → latest" test case here (see docs/data-model.md).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('upgrade from v1 keeps subscriptions and episodes', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    // The generated v1 schema has no data classes – insert with plain SQL.
    await oldDb.customStatement(
      'INSERT INTO podcasts (feed_url, title, subscribed_at) '
      "VALUES ('https://example.com/feed', 'Alt', 1767225600)",
    );
    await oldDb.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    final podcasts = await db.select(db.podcasts).get();
    expect(podcasts.single.title, 'Alt');
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'k', value: 'v'));
    expect((await db.select(db.settings).getSingle()).value, 'v');
    await db.close();
  });

  test('upgrade v2 → latest matches the current schema', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v1 → latest matches the current schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v3 → latest matches the current schema', () async {
    final connection = await verifier.startAt(3);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v4 creates the default playlist', () async {
    final db = AppDatabase.forTesting(
      (await verifier.schemaAt(3)).newConnection(),
    );
    final playlists = await db.select(db.playlists).get();
    expect(playlists.single.name, AppDatabase.defaultPlaylistName);
    await db.close();
  });

  test('upgrade v4 → latest matches the current schema', () async {
    final connection = await verifier.startAt(4);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test(
    'upgrade to v5 forces a full feed refresh (clears validators)',
    () async {
      final schema = await verifier.schemaAt(4);
      // Insert directly into the v4 database, then open it with the app (→ v5).
      schema.rawDatabase.execute(
        'INSERT INTO podcasts '
        '(feed_url, title, subscribed_at, etag, last_modified) '
        "VALUES ('https://example.com/feed', 'P', 1767225600, 'v1', 'Mon')",
      );
      final db = AppDatabase.forTesting(schema.newConnection());
      final podcast = await db.select(db.podcasts).getSingle();
      expect(podcast.etag, isNull);
      expect(podcast.lastModified, isNull);
      expect(podcast.autoDownloadThemes, isNull);
      await db.close();
    },
  );

  test('upgrade v5 → latest matches the current schema', () async {
    final connection = await verifier.startAt(5);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });
}
