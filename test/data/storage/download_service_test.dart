import 'dart:io';

import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
import 'package:aapodcastguru/data/settings_keys.dart';
import 'package:aapodcastguru/data/storage/download_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_download_engine.dart';

void main() {
  late AppDatabase db;
  late Directory dir;
  late FakeDownloadEngine engine;
  late DownloadService service;
  late DateTime now;
  int? currentEpisode;
  late int podcastId;

  File fileOf(int episodeId) => File('${dir.path}/$episodeId.mp3');

  Future<Download?> row(int episodeId) => (db.select(
    db.downloads,
  )..where((d) => d.episodeId.equals(episodeId))).getSingleOrNull();

  Future<int> addEpisode(
    String guid, {
    EpisodeStatus status = EpisodeStatus.newEpisode,
    DateTime? playedAt,
    DateTime? pubDate,
    int? podcast,
  }) => db
      .into(db.episodes)
      .insert(
        EpisodesCompanion.insert(
          podcastId: podcast ?? podcastId,
          guid: guid,
          title: 'Folge $guid',
          audioUrl: 'https://example.com/$guid.mp3',
          audioMimeType: const Value('audio/mpeg'),
          status: Value(status),
          playedAt: Value(playedAt),
          pubDate: Value(pubDate),
          addedAt: now,
        ),
      );

  Future<void> setPodcast(PodcastsCompanion changes) => (db.update(
    db.podcasts,
  )..where((p) => p.id.equals(podcastId))).write(changes);

  /// Downloads [episodeId] completely (file on disk + row "done").
  Future<void> downloaded(int episodeId, {int bytes = 1000}) async {
    await service.download(episodeId);
    await engine.finish(episodeId, bytes: bytes);
  }

  setUp(() async {
    now = DateTime.utc(2026, 9, 27, 12);
    currentEpisode = null;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('episodes_test_');
    engine = FakeDownloadEngine(dir);
    service = DownloadService(
      db: db,
      engine: engine,
      clock: () => now,
      episodesDirectory: () async => dir,
      currentEpisodeId: () => currentEpisode,
      playlists: PlaylistRepository(db, () => now),
    );
    await service.start();
    podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/feed',
            title: 'Testpodcast',
            subscribedAt: now,
          ),
        );
  });

  tearDown(() async {
    await service.dispose();
    await engine.dispose();
    await db.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test(
    'dispose releases the engine subscription and progress stream',
    () async {
      var progressDone = false;
      final sub = service.progress.listen(
        null,
        onDone: () => progressDone = true,
      );
      await pumpEventQueue();
      expect(engine.hasListener, isTrue);

      await service.dispose();
      await pumpEventQueue();
      expect(engine.hasListener, isFalse);
      expect(progressDone, isTrue);
      await sub.cancel();
    },
  );

  group('download', () {
    test('queues, completes and provides the local file', () async {
      final id = await addEpisode('1');
      await service.download(id);
      expect((await row(id))!.state, DownloadState.queued);
      expect(engine.active[id]!.fileName, '$id.mp3');

      await engine.finish(id, bytes: 1234);
      final done = (await row(id))!;
      expect(done.state, DownloadState.done);
      expect(done.sizeBytes, 1234);
      expect((await service.localFile(id))!.path, fileOf(id).path);
      expect(await service.totalBytes(), 1234);
    });

    test('failure is recorded and can be retried', () async {
      final id = await addEpisode('1');
      await service.download(id);
      await engine.fail(id);
      expect((await row(id))!.state, DownloadState.failed);
      expect(await service.localFile(id), isNull);

      await service.download(id); // retry
      expect(engine.active, contains(id));
    });

    test('cancel stops the engine and leaves nothing behind', () async {
      final id = await addEpisode('1');
      await service.download(id);
      await service.cancel(id);
      expect(engine.canceled, [id]);
      expect(await row(id), isNull);
      expect(fileOf(id).existsSync(), isFalse);
    });

    test('delete removes file and row', () async {
      final id = await addEpisode('1');
      await downloaded(id);
      await service.delete(id);
      expect(fileOf(id).existsSync(), isFalse);
      expect(await row(id), isNull);
    });

    test('a vanished file is noticed and the episode streams again', () async {
      final id = await addEpisode('1');
      await downloaded(id);
      fileOf(id).deleteSync();
      expect(await service.localFile(id), isNull);
      expect(await row(id), isNull);
    });

    test('file extension follows the MIME type', () async {
      final id = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: 'm4a',
              title: 'M4A',
              audioUrl: 'https://example.com/x?y=1',
              audioMimeType: const Value('audio/x-m4a'),
              addedAt: now,
            ),
          );
      await service.download(id);
      expect(engine.active[id]!.fileName, '$id.m4a');
    });
  });

  group('eviction of played episodes (96 h)', () {
    test('deletes 96 h after playing, not earlier, never unplayed', () async {
      final oldPlayed = await addEpisode(
        'old',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(hours: 97)),
      );
      final freshPlayed = await addEpisode(
        'fresh',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(hours: 95)),
      );
      final inProgress = await addEpisode(
        'half',
        status: EpisodeStatus.inProgress,
      );
      final unplayed = await addEpisode('new');
      for (final id in [oldPlayed, freshPlayed, inProgress, unplayed]) {
        await downloaded(id);
      }

      final freed = await service.evictPlayed();

      expect(freed, 1000);
      expect(fileOf(oldPlayed).existsSync(), isFalse);
      expect(await row(oldPlayed), isNull);
      for (final id in [freshPlayed, inProgress, unplayed]) {
        expect(fileOf(id).existsSync(), isTrue);
      }
    });

    test('respects the per-podcast switch', () async {
      await setPodcast(const PodcastsCompanion(autoDeletePlayed: Value(false)));
      final id = await addEpisode(
        'old',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(days: 30)),
      );
      await downloaded(id);
      await service.evictPlayed();
      expect(fileOf(id).existsSync(), isTrue);
    });

    test('keeps played episodes that are still in a playlist', () async {
      final id = await addEpisode(
        'old',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(days: 30)),
      );
      await downloaded(id);
      final list = (await db.select(db.playlists).get()).first.id;
      await PlaylistRepository(db, () => now).add(list, id);
      await service.evictPlayed();
      expect(fileOf(id).existsSync(), isTrue);
    });

    test('never deletes the episode in the player', () async {
      final id = await addEpisode(
        'old',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(days: 30)),
      );
      await downloaded(id);
      currentEpisode = id;
      await service.evictPlayed();
      expect(fileOf(id).existsSync(), isTrue);
    });
  });

  group('storage limit', () {
    test('deletes played downloads oldest first, never unplayed', () async {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: SettingsKeys.downloadLimitBytes,
              value: '2500',
            ),
          );
      final older = await addEpisode(
        'a',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(hours: 2)),
      );
      final newer = await addEpisode(
        'b',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(hours: 1)),
      );
      final unplayed1 = await addEpisode('c');
      final unplayed2 = await addEpisode('d');
      for (final id in [older, newer, unplayed1, unplayed2]) {
        await downloaded(id);
      }

      await service.enforceLimit(); // 4000 bytes, limit 2500

      expect(fileOf(older).existsSync(), isFalse);
      expect(fileOf(newer).existsSync(), isFalse);
      expect(fileOf(unplayed1).existsSync(), isTrue);
      expect(fileOf(unplayed2).existsSync(), isTrue);
    });

    test('keeps played episodes that are still in a playlist', () async {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: SettingsKeys.downloadLimitBytes,
              value: '500',
            ),
          );
      final id = await addEpisode(
        'a',
        status: EpisodeStatus.played,
        playedAt: now.subtract(const Duration(hours: 2)),
      );
      await downloaded(id);
      final list = (await db.select(db.playlists).get()).first.id;
      await PlaylistRepository(db, () => now).add(list, id);
      await service.enforceLimit();
      expect(fileOf(id).existsSync(), isTrue);
    });
  });

  group('auto-download', () {
    test('off by default', () async {
      await addEpisode('1');
      expect(await service.autoDownload(), 0);
      expect(engine.active, isEmpty);
    });

    test('queues the newest unplayed episodes up to the maximum', () async {
      await setPodcast(
        const PodcastsCompanion(
          autoDownloadMode: Value(AutoDownloadMode.wifiOnly),
          autoDownloadMaxEpisodes: Value(2),
        ),
      );
      final oldest = await addEpisode('1', pubDate: DateTime(2026, 9, 1));
      final middle = await addEpisode('2', pubDate: DateTime(2026, 9, 2));
      final newest = await addEpisode('3', pubDate: DateTime(2026, 9, 3));
      await addEpisode(
        'played',
        status: EpisodeStatus.played,
        pubDate: DateTime(2026, 9, 4),
      );

      expect(await service.autoDownload(), 2);
      expect(engine.active.keys, unorderedEquals([newest, middle]));
      expect(engine.active[newest]!.wifiOnly, isTrue);
      expect(engine.active, isNot(contains(oldest)));

      // Already at the maximum → nothing more.
      expect(await service.autoDownload(), 0);
    });

    test(
      'auto-downloads go into the podcast\'s playlist, even a deleted one',
      () async {
        final playlists = PlaylistRepository(db, () => now);
        final target = await playlists.create('Morgens');
        await setPodcast(
          PodcastsCompanion(
            autoDownloadMode: const Value(AutoDownloadMode.always),
            autoDownloadMaxEpisodes: const Value(1),
            autoPlaylistId: Value(target),
            autoPlaylistName: const Value('Morgens'),
          ),
        );
        Future<List<int>> itemsOf(int id) async => [
          for (final e in await playlists.entries(id)) e.episode.id,
        ];

        final first = await addEpisode('1', pubDate: DateTime(2026, 9, 1));
        await playlists.add(target, first); // already there: not twice
        expect(await service.autoDownload(), 1);
        expect(await itemsOf(target), [first]);

        // Renamed: followed, the stored name is updated.
        await playlists.rename(target, 'Früh');
        await engine.finish(first, bytes: 10);
        await (db.update(db.episodes)..where((e) => e.id.equals(first))).write(
          const EpisodesCompanion(status: Value(EpisodeStatus.played)),
        );
        final second = await addEpisode('2', pubDate: DateTime(2026, 9, 2));
        expect(await service.autoDownload(), 1);
        expect(await itemsOf(target), [first, second]);

        // Deleted: created again under the stored name.
        await playlists.delete(target);
        await engine.finish(second, bytes: 10);
        await (db.update(db.episodes)..where((e) => e.id.equals(second))).write(
          const EpisodesCompanion(status: Value(EpisodeStatus.played)),
        );
        final third = await addEpisode('3', pubDate: DateTime(2026, 9, 3));
        expect(await service.autoDownload(), 1);
        final recreated = (await playlists.playlists()).singleWhere(
          (p) => p.name == 'Früh',
        );
        expect(await itemsOf(recreated.id), [third]);
        final podcast = await (db.select(
          db.podcasts,
        )..where((p) => p.id.equals(podcastId))).getSingle();
        expect(podcast.autoPlaylistId, recreated.id);
      },
    );

    test('only selected themes are auto-downloaded', () async {
      await setPodcast(
        const PodcastsCompanion(
          autoDownloadMode: Value(AutoDownloadMode.always),
          autoDownloadMaxEpisodes: Value(2),
          autoDownloadThemes: Value('["zum-thema"]'),
        ),
      );
      Future<int> themed(String guid, String? theme, int day) async {
        final id = await addEpisode(guid, pubDate: DateTime(2026, 9, day));
        await (db.update(db.episodes)..where((e) => e.id.equals(id))).write(
          EpisodesCompanion(theme: Value(theme)),
        );
        return id;
      }

      final wanted1 = await themed('1', 'zum-thema', 1);
      final wanted2 = await themed('2', 'zum-thema', 2);
      final other = await themed('3', 'die-wrintheit', 3);
      final noTheme = await themed('4', null, 4);
      // A manual download of another theme does not count against the limit.
      await downloaded(other);

      expect(await service.autoDownload(), 2);
      expect(engine.active.keys, unorderedEquals([wanted1, wanted2]));
      expect(engine.active, isNot(contains(noTheme)));
    });

    test('an empty theme selection downloads nothing', () async {
      await setPodcast(
        const PodcastsCompanion(
          autoDownloadMode: Value(AutoDownloadMode.always),
          autoDownloadThemes: Value('[]'),
        ),
      );
      await addEpisode('1');
      expect(await service.autoDownload(), 0);
    });

    test('stops at the storage limit', () async {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: SettingsKeys.downloadLimitBytes,
              value: '1500',
            ),
          );
      final existing = await addEpisode('x');
      await downloaded(existing, bytes: 1500);
      await setPodcast(
        const PodcastsCompanion(
          autoDownloadMode: Value(AutoDownloadMode.always),
        ),
      );
      await addEpisode('1');
      expect(await service.autoDownload(), 0);
    });
  });

  group('reconcile', () {
    test('removes orphan files and repairs rows', () async {
      final kept = await addEpisode('kept');
      await downloaded(kept);

      // Orphan file (no row) and leftover of an interrupted download.
      File('${dir.path}/999.mp3').writeAsBytesSync(List.filled(500, 0));
      File('${dir.path}/tmp.part').writeAsBytesSync(List.filled(10, 0));

      // Row "done" whose file is gone.
      final gone = await addEpisode('gone');
      await downloaded(gone);
      fileOf(gone).deleteSync();

      // Row "running" but the engine forgot the task (app was killed).
      final stale = await addEpisode('stale');
      await service.download(stale);
      engine.active.remove(stale);

      // Still running for real → keep.
      final running = await addEpisode('running');
      await service.download(running);

      final freed = await service.reconcile();

      expect(freed, 510);
      expect(dir.listSync().map((f) => f.uri.pathSegments.last), ['$kept.mp3']);
      expect((await row(kept))!.state, DownloadState.done);
      expect(await row(gone), isNull);
      expect(await row(stale), isNull);
      expect((await row(running))!.state, DownloadState.queued);
    });

    test('a completed file whose event was missed becomes "done"', () async {
      final id = await addEpisode('1');
      await service.download(id);
      engine.active.remove(id);
      fileOf(id).writeAsBytesSync(List.filled(700, 0));

      await service.reconcile();
      final done = (await row(id))!;
      expect(done.state, DownloadState.done);
      expect(done.sizeBytes, 700);
    });
  });

  test('cancelAll stops every running download', () async {
    final a = await addEpisode('a');
    final b = await addEpisode('b');
    await service.download(a);
    await service.download(b);
    await service.cancelAll();
    expect(engine.canceled, unorderedEquals([a, b]));
    expect(engine.active, isEmpty);
  });

  test(
    'deleteForPodcast cancels and deletes everything of a podcast',
    () async {
      final done = await addEpisode('done');
      await downloaded(done);
      final running = await addEpisode('running');
      await service.download(running);

      await service.deleteForPodcast(podcastId);

      expect(engine.canceled, [running]);
      expect(await db.select(db.downloads).get(), isEmpty);
      expect(dir.listSync(), isEmpty);
    },
  );

  test('maintenance runs everything and reports freed bytes', () async {
    final played = await addEpisode(
      'p',
      status: EpisodeStatus.played,
      playedAt: now.subtract(const Duration(days: 5)),
    );
    await downloaded(played, bytes: 3000);
    await setPodcast(
      const PodcastsCompanion(autoDownloadMode: Value(AutoDownloadMode.always)),
    );
    await addEpisode('new');

    final result = await service.runMaintenance();
    expect(result.freedBytes, 3000);
    expect(result.queued, 1);
  });

  test('progress is published while downloading', () async {
    final id = await addEpisode('1');
    await service.download(id);
    final updates = <Map<int, double>>[];
    final sub = service.progress.listen(updates.add);
    await Future<void>.delayed(Duration.zero);
    await engine.finish(id);
    await sub.cancel();
    expect(updates.any((m) => m[id] == 0.5), isTrue);
    expect(updates.last, isEmpty);
  });
}
