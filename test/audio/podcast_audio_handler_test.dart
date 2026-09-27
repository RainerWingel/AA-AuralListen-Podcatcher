import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/settings_keys.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_player_engine.dart';

void main() {
  late AppDatabase db;
  late FakePlayerEngine engine;
  late SettingsRepository settings;
  late PodcastAudioHandler handler;
  late int podcastId;
  late int episodeId;
  final now = DateTime.utc(2026, 9, 27, 12);

  Future<Episode> episode([int? id]) => (db.select(
    db.episodes,
  )..where((e) => e.id.equals(id ?? episodeId))).getSingle();

  Future<int> addEpisode(String guid, {int positionMs = 0}) => db
      .into(db.episodes)
      .insert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: guid,
          title: 'Folge $guid',
          audioUrl: 'https://example.com/$guid.mp3',
          positionMs: Value(positionMs),
          status: Value(
            positionMs > 0
                ? EpisodeStatus.inProgress
                : EpisodeStatus.newEpisode,
          ),
          addedAt: now,
        ),
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    engine = FakePlayerEngine();
    settings = SettingsRepository(db);
    handler = PodcastAudioHandler(
      engine: engine,
      playback: PlaybackRepository(db, () => now),
      settings: settings,
      stopAfterPause: const Duration(milliseconds: 50),
    );
    podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/feed',
            title: 'Testpodcast',
            imageUrl: const Value('https://example.com/cover.jpg'),
            subscribedAt: now,
          ),
        );
    episodeId = await addEpisode('1', positionMs: 60000);
  });

  tearDown(() async {
    await handler.dispose();
    await db.close();
  });

  test('plays an episode from its saved position minus 3 s', () async {
    await handler.playEpisode(episodeId);

    expect(engine.loadedUri, Uri.parse('https://example.com/1.mp3'));
    expect(engine.loadedAt, const Duration(seconds: 57));
    expect(engine.calls, containsAllInOrder(['load', 'play']));
    expect(handler.playbackState.value.playing, isTrue);

    final item = handler.mediaItem.value!;
    expect(item.title, 'Folge 1');
    expect(item.album, 'Testpodcast');
    expect(item.artUri, Uri.parse('https://example.com/cover.jpg'));
    expect(await settings.getInt(SettingsKeys.lastEpisodeId), episodeId);
  });

  test('stores the duration reported by the player', () async {
    await handler.playEpisode(episodeId);
    expect(
      (await episode()).durationMs,
      const Duration(minutes: 10).inMilliseconds,
    );
  });

  test('saves the position at most every 5 s and on pause', () async {
    final fresh = await addEpisode('2');
    await handler.playEpisode(fresh);

    engine.emitPosition(const Duration(seconds: 3));
    await pumpEventQueue();
    expect((await episode(fresh)).positionMs, 0);

    engine.emitPosition(const Duration(seconds: 6));
    await pumpEventQueue();
    final saved = await episode(fresh);
    expect(saved.positionMs, 6000);
    expect(saved.status, EpisodeStatus.inProgress);

    engine.emitPosition(const Duration(seconds: 8));
    await handler.pause();
    expect((await episode(fresh)).positionMs, 8000);
  });

  test('marks as played at 98 % and never overwrites that', () async {
    await handler.playEpisode(episodeId);

    engine.emitPosition(const Duration(minutes: 9, seconds: 48)); // 98 %
    await pumpEventQueue();
    var e = await episode();
    expect(e.status, EpisodeStatus.played);
    expect(e.playedAt!.isAtSameMomentAs(now), isTrue);

    engine.emitPosition(const Duration(minutes: 9, seconds: 58));
    await handler.pause();
    e = await episode();
    expect(e.status, EpisodeStatus.played);
    expect(e.positionMs, 0);
  });

  test('completion marks as played and unloads; play again restarts', () async {
    await handler.playEpisode(episodeId);
    engine.complete();
    await pumpEventQueue();

    expect((await episode()).status, EpisodeStatus.played);
    expect(engine.calls.last, 'stop');
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.idle,
    );

    await handler.play();
    expect(engine.loadedAt, Duration.zero);
    final e = await episode();
    expect(e.status, EpisodeStatus.inProgress);
    expect(e.playedAt, isNull);
  });

  test('skips −15 s / +30 s within bounds', () async {
    await handler.playEpisode(episodeId); // starts at 57 s
    await handler.rewind();
    expect(handler.position, const Duration(seconds: 42));
    await handler.fastForward();
    expect(handler.position, const Duration(seconds: 72));

    engine.emitPosition(const Duration(seconds: 5));
    await handler.rewind();
    expect(handler.position, Duration.zero);

    engine.emitPosition(const Duration(minutes: 9, seconds: 50));
    await handler.fastForward();
    expect(handler.position, const Duration(minutes: 10));
  });

  test('a long pause stops the player', () async {
    await handler.playEpisode(episodeId);
    await handler.pause();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(engine.calls.last, 'stop');

    // Resuming loads again from the saved position.
    await handler.play();
    expect(engine.calls.where((c) => c == 'load'), hasLength(2));
  });

  group('boost', () {
    test('uses the global default, podcast override wins', () async {
      await settings.set(SettingsKeys.boostDb, '6');
      await handler.playEpisode(episodeId);
      expect(engine.boostDb, 6);

      await handler.setBoost(9, forPodcastOnly: true);
      expect(engine.boostDb, 9);
      final podcast = await db.select(db.podcasts).getSingle();
      expect(podcast.boostDb, 9);
      expect(await settings.getDouble(SettingsKeys.boostDb), 6);
    });

    test('global change removes the podcast override', () async {
      await handler.playEpisode(episodeId);
      await handler.setBoost(9, forPodcastOnly: true);
      await handler.setBoost(3, forPodcastOnly: false);

      expect(engine.boostDb, 3);
      expect((await db.select(db.podcasts).getSingle()).boostDb, isNull);
      expect(await settings.getDouble(SettingsKeys.boostDb), 3);
    });
  });

  test('clearing the podcast boost falls back to the global value', () async {
    await settings.set(SettingsKeys.boostDb, '3');
    await handler.playEpisode(episodeId);
    await handler.setBoost(12, forPodcastOnly: true);
    await handler.clearPodcastBoost();

    expect(engine.boostDb, 3);
    expect((await db.select(db.podcasts).getSingle()).boostDb, isNull);
  });

  test('restores the last episode without loading audio', () async {
    await settings.set(SettingsKeys.lastEpisodeId, '$episodeId');
    await handler.restoreLastEpisode();

    expect(handler.mediaItem.value!.title, 'Folge 1');
    expect(engine.calls, isEmpty);
    expect(handler.playbackState.value.playing, isFalse);
  });

  test('switching episodes saves the old position first', () async {
    final other = await addEpisode('2');
    await handler.playEpisode(episodeId);
    engine.emitPosition(const Duration(seconds: 100));
    await handler.playEpisode(other);

    expect((await episode()).positionMs, 100000);
    expect(handler.mediaItem.value!.title, 'Folge 2');
  });
}
