import 'dart:convert';
import 'dart:io';

import 'package:aapodcastguru/data/backup/backup_service.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generated_migrations/schema.dart';

void main() {
  late Directory temp;
  final now = DateTime.utc(2026, 9, 27, 12);

  BackupService serviceFor(AppDatabase db) =>
      BackupService(db: db, clock: () => now, tempDirectory: () async => temp);

  /// A database with one of everything.
  Future<AppDatabase> filledDb({String title = 'Original'}) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/$title',
            title: title,
            subscribedAt: now,
            autoDownloadThemes: const Value('["zum-thema"]'),
          ),
        );
    final episodeId = await db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: 'g',
            title: '$title-Folge',
            audioUrl: 'https://example.com/a.mp3',
            theme: const Value('zum-thema'),
            positionMs: const Value(42000),
            status: const Value(EpisodeStatus.inProgress),
            addedAt: now,
          ),
        );
    await db
        .into(db.chapters)
        .insert(
          ChaptersCompanion.insert(
            episodeId: episodeId,
            startMs: 0,
            title: 'Kapitel',
          ),
        );
    await db
        .into(db.bookmarks)
        .insert(
          BookmarksCompanion.insert(
            episodeId: episodeId,
            positionMs: 1000,
            note: const Value('Notiz'),
            createdAt: now,
          ),
        );
    final playlistId = (await db.select(db.playlists).getSingle()).id;
    await db
        .into(db.playlistItems)
        .insert(
          PlaylistItemsCompanion.insert(
            playlistId: playlistId,
            episodeId: episodeId,
            position: 0,
            addedAt: now,
          ),
        );
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'player.boostDb', value: '6'));
    await db
        .into(db.downloads)
        .insert(
          DownloadsCompanion.insert(
            episodeId: Value(episodeId),
            relativePath: '$episodeId.mp3',
            state: DownloadState.done,
            createdAt: now,
          ),
        );
    return db;
  }

  setUp(() => temp = Directory.systemTemp.createTempSync('backup_test_'));
  tearDown(() => temp.deleteSync(recursive: true));

  test('backup → restore into a database with other data', () async {
    final source = await filledDb();
    final bytes = await serviceFor(source).createBackup();
    await source.close();
    expect(temp.listSync(), isEmpty, reason: 'no temp files left behind');

    final target = await filledDb(title: 'Andere');
    final service = serviceFor(target);
    final updates = <List<Podcast>>[];
    final sub = target.select(target.podcasts).watch().listen(updates.add);

    final preview = await service.inspect(bytes);
    expect(
      (
        preview.podcasts,
        preview.episodes,
        preview.playlists,
        preview.bookmarks,
      ),
      (1, 1, 1, 1),
    );
    expect(preview.createdAt!.isAtSameMomentAs(now), isTrue);

    await service.restore(preview);
    await Future<void>.delayed(Duration.zero);

    final podcast = await target.select(target.podcasts).getSingle();
    expect(podcast.title, 'Original');
    expect(podcast.autoDownloadThemes, '["zum-thema"]');
    final episode = await target.select(target.episodes).getSingle();
    expect(
      (episode.title, episode.positionMs, episode.theme),
      ('Original-Folge', 42000, 'zum-thema'),
    );
    expect((await target.select(target.chapters).getSingle()).title, 'Kapitel');
    expect((await target.select(target.bookmarks).getSingle()).note, 'Notiz');
    expect(await target.select(target.playlistItems).get(), hasLength(1));
    expect((await target.select(target.settings).getSingle()).value, '6');
    // Audio files are not part of a backup.
    expect(await target.select(target.downloads).get(), isEmpty);
    // The UI is told about the change.
    expect(updates.last.single.title, 'Original');
    expect(temp.listSync(), isEmpty);

    await sub.cancel();
    await target.close();
  });

  test('a backup from an older schema is migrated on restore', () async {
    // Build a v3 database file (before themes, playlists, chapters …).
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    schema.rawDatabase.execute(
      'INSERT INTO podcasts (feed_url, title, subscribed_at) '
      "VALUES ('https://example.com/alt', 'Alt', 1767225600)",
    );
    final v3File = File('${temp.path}/v3.sqlite');
    schema.rawDatabase.execute('VACUUM INTO ?', [v3File.path]);
    final zip = ZipEncoder().encodeBytes(
      Archive()
        ..addFile(
          ArchiveFile.string(
            BackupService.manifestName,
            jsonEncode({
              // The app's former name: backups of the old app must still
              // restore (moving data to the new application id).
              'app': 'AA-PodcastGuru',
              'format': 1,
              'schemaVersion': 3,
              'createdAt': now.toIso8601String(),
            }),
          ),
        )
        ..addFile(
          ArchiveFile.bytes(
            BackupService.databaseName,
            v3File.readAsBytesSync(),
          ),
        ),
    );
    v3File.deleteSync();

    final target = await filledDb(title: 'Neu');
    final service = serviceFor(target);
    final preview = await service.inspect(zip);
    await service.restore(preview);

    expect((await target.select(target.podcasts).getSingle()).title, 'Alt');
    // v4 migration created the default playlist inside the backup copy.
    expect(
      (await target.select(target.playlists).getSingle()).name,
      AppDatabase.defaultPlaylistName,
    );
    await target.close();
  });

  test('rejects files that are not a backup of this app', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = serviceFor(db);

    Future<void> expectRejected(List<int> bytes) => expectLater(
      service.inspect(Uint8List.fromList(bytes)),
      throwsA(isA<BackupFormatException>()),
    );

    await expectRejected(utf8.encode('kein zip'));
    await expectRejected(ZipEncoder().encodeBytes(Archive()));
    Uint8List zipWith(Map<String, Object?> manifest, List<int> dbBytes) =>
        ZipEncoder().encodeBytes(
          Archive()
            ..addFile(
              ArchiveFile.string(
                BackupService.manifestName,
                jsonEncode(manifest),
              ),
            )
            ..addFile(ArchiveFile.bytes(BackupService.databaseName, dbBytes)),
        );
    await expectRejected(
      zipWith({'app': 'Andere App', 'schemaVersion': 1}, [1, 2, 3]),
    );
    await expectRejected(
      zipWith({'app': 'AA-PodcastGuru', 'schemaVersion': 999}, [1, 2, 3]),
    );
    await expectRejected(
      zipWith({'app': 'AA-PodcastGuru', 'schemaVersion': 1}, utf8.encode('x')),
    );
    expect(temp.listSync(), isEmpty, reason: 'temp copies are cleaned up');
    await db.close();
  });

  test('new backups carry the new app name', () async {
    final source = await filledDb();
    final bytes = await serviceFor(source).createBackup();
    await source.close();
    final manifest = ZipDecoder()
        .decodeBytes(bytes)
        .findFile(BackupService.manifestName)!;
    final json = jsonDecode(
      utf8.decode(manifest.content as List<int>),
    ) as Map<String, Object?>;
    expect(json['app'], 'AA-AuralListen');
  });

  test('suggested file name', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    expect(
      serviceFor(db).suggestedFileName(),
      'AA-AuralListen-Backup-2026-09-27.zip',
    );
    await db.close();
  });
}
