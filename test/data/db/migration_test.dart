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

  test('upgrade v6 → latest matches the current schema', () async {
    final connection = await verifier.startAt(6);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v7 keeps playlists; nothing to resume yet', () async {
    final schema = await verifier.schemaAt(6);
    schema.rawDatabase.execute(
      'INSERT INTO playlists (name, sort_order, created_at) '
      "VALUES ('Morgens', 1, 1767225600)",
    );
    final db = AppDatabase.forTesting(schema.newConnection());
    final playlists = await db.select(db.playlists).get();
    expect(playlists.map((p) => p.name), contains('Morgens'));
    expect(playlists.every((p) => p.lastEpisodeId == null), isTrue);
    await db.close();
  });

  test('upgrade v7 → latest matches the current schema', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v8: "in progress" under 15 s becomes new again', () async {
    final schema = await verifier.schemaAt(7);
    schema.rawDatabase
      ..execute(
        'INSERT INTO podcasts (id, feed_url, title, subscribed_at) '
        "VALUES (1, 'https://example.com/feed', 'P', 1767225600)",
      )
      ..execute(
        'INSERT INTO episodes '
        '(podcast_id, guid, title, audio_url, added_at, status, position_ms) '
        "VALUES (1, 'short', 'short', 'u1', 1767225600, 'inProgress', 5000), "
        "(1, 'long', 'long', 'u2', 1767225600, 'inProgress', 15000), "
        "(1, 'played', 'played', 'u3', 1767225600, 'played', 0), "
        "(1, 'new', 'new', 'u4', 1767225600, 'newEpisode', 0)",
      );
    final db = AppDatabase.forTesting(schema.newConnection());
    final byGuid = {
      for (final e in await db.select(db.episodes).get())
        e.guid: (e.status, e.positionMs),
    };
    expect(byGuid, {
      'short': (EpisodeStatus.newEpisode, 0),
      'long': (EpisodeStatus.inProgress, 15000),
      'played': (EpisodeStatus.played, 0),
      'new': (EpisodeStatus.newEpisode, 0),
    });
    await db.close();
  });

  test('upgrade v8 → latest matches the current schema', () async {
    final connection = await verifier.startAt(8);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v9: playlists have no color yet', () async {
    final db = AppDatabase.forTesting(
      (await verifier.schemaAt(8)).newConnection(),
    );
    expect(
      (await db.select(db.playlists).get()).every((p) => p.color == null),
      isTrue,
    );
    await db.close();
  });

  test('upgrade v9 → latest matches the current schema', () async {
    final connection = await verifier.startAt(9);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v10 → latest matches the current schema', () async {
    final connection = await verifier.startAt(10);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v11 → latest matches the current schema', () async {
    final connection = await verifier.startAt(11);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v12 → latest matches the current schema', () async {
    final connection = await verifier.startAt(12);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v13 moves show notes into episode_notes', () async {
    final schema = await verifier.schemaAt(12);
    schema.rawDatabase.execute(
      'INSERT INTO podcasts (id, feed_url, title, subscribed_at, etag) '
      "VALUES (1, 'https://example.com/feed', 'P', 1767225600, 'e1')",
    );
    schema.rawDatabase.execute(
      'INSERT INTO episodes '
      '(id, podcast_id, guid, title, audio_url, added_at, description) '
      "VALUES (1, 1, 'a', 'A', 'u1', 1767225600, 'Notizen A'), "
      "(2, 1, 'b', 'B', 'u2', 1767225600, NULL), "
      "(3, 1, 'c', 'C', 'u3', 1767225600, '')",
    );
    final db = AppDatabase.forTesting(schema.newConnection());
    final notes = await db.select(db.episodeNotes).get();
    expect(notes.map((n) => (n.episodeId, n.notes)), [(1, 'Notizen A')]);
    // Episode rows no longer carry the text; feeds are read again once.
    final episodes = await db.select(db.episodes).get();
    expect(episodes.every((e) => e.description == null), isTrue);
    expect((await db.select(db.podcasts).getSingle()).etag, isNull);
    await db.close();
  });

  test('upgrade v13 → latest matches the current schema', () async {
    final connection = await verifier.startAt(13);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade to v14/v15 re-reads every feed once', () async {
    final schema = await verifier.schemaAt(13);
    schema.rawDatabase.execute(
      'INSERT INTO podcasts (feed_url, title, subscribed_at, etag, last_modified) '
      "VALUES ('https://example.com/feed', 'P', 1767225600, 'e1', 'm1')",
    );
    final db = AppDatabase.forTesting(schema.newConnection());
    final podcast = await db.select(db.podcasts).getSingle();
    expect((podcast.etag, podcast.lastModified), (null, null));
    await db.close();
  });

  test('upgrade v14 → latest matches the current schema', () async {
    final connection = await verifier.startAt(14);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v14 → v15 re-reads every feed once', () async {
    final schema = await verifier.schemaAt(14);
    schema.rawDatabase.execute(
      'INSERT INTO podcasts (feed_url, title, subscribed_at, etag) '
      "VALUES ('https://example.com/feed', 'P', 1767225600, 'e1')",
    );
    final db = AppDatabase.forTesting(schema.newConnection());
    expect((await db.select(db.podcasts).getSingle()).etag, isNull);
    await db.close();
  });

  test('upgrade v15 → latest matches the current schema', () async {
    final connection = await verifier.startAt(15);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('upgrade v16 → latest matches the current schema', () async {
    final connection = await verifier.startAt(16);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });
}
