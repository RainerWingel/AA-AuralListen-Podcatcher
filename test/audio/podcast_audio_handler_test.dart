import 'dart:io';

import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
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
  late PlaylistRepository playlists;
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
    playlists = PlaylistRepository(db, () => now);
    handler = PodcastAudioHandler(
      engine: engine,
      playback: PlaybackRepository(db, () => now),
      settings: settings,
      playlists: playlists,
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

  test('plays the downloaded file instead of streaming', () async {
    await handler.dispose();
    engine = FakePlayerEngine();
    handler = PodcastAudioHandler(
      engine: engine,
      playback: PlaybackRepository(db, () => now),
      settings: settings,
      localAudioFile: (id) async =>
          id == episodeId ? File('/data/episodes/$id.mp3') : null,
    );
    await handler.playEpisode(episodeId);
    expect(engine.loadedUri, Uri.file('/data/episodes/$episodeId.mp3'));
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

  // Regression: after a phone restart the player showed 0:00 instead of the
  // saved position until play was pressed.
  group('before audio is loaded (after app start)', () {
    setUp(() async {
      await settings.set(SettingsKeys.lastEpisodeId, '$episodeId');
      await handler.restoreLastEpisode(); // saved position: 60 s
    });

    test('shows the saved position', () async {
      expect(handler.position, const Duration(seconds: 60));
      expect(await handler.positionStream.first, const Duration(seconds: 60));
      expect(
        handler.playbackState.value.updatePosition,
        const Duration(seconds: 60),
      );
    });

    test('skip buttons move and store the position without loading', () async {
      await handler.fastForward();
      expect(handler.position, const Duration(seconds: 90));
      await handler.rewind();
      await handler.rewind();
      expect(handler.position, const Duration(seconds: 60));
      expect(engine.calls, isEmpty);
      expect((await episode()).positionMs, 60000);
    });

    test('after an explicit seek, play starts exactly there', () async {
      await handler.seek(const Duration(seconds: 120));
      await handler.play();
      expect(engine.loadedAt, const Duration(seconds: 120));
    });

    test('without a seek, play resumes 3 s earlier', () async {
      await handler.play();
      expect(engine.loadedAt, const Duration(seconds: 57));
    });
  });

  test('keeps showing the position after the pause timeout', () async {
    await handler.playEpisode(episodeId);
    engine.emitPosition(const Duration(seconds: 200));
    await handler.pause();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(engine.calls.last, 'stop');
    expect(handler.position, const Duration(seconds: 200));
  });

  // Regression: switching episodes while playing left the play button on
  // "play" (and pressing it did nothing) until the user seeked.
  test('switching episodes while playing reports "playing"', () async {
    final other = await addEpisode('2');
    await handler.playEpisode(episodeId);
    expect(handler.playbackState.value.playing, isTrue);

    await handler.playEpisode(other);
    expect(handler.playbackState.value.playing, isTrue);
    expect(handler.playbackState.value.controls, contains(MediaControl.pause));

    await handler.pause();
    expect(handler.playbackState.value.playing, isFalse);
    await handler.play();
    expect(handler.playbackState.value.playing, isTrue);
  });

  test(
    'startAt (bookmark) starts exactly there, also for played episodes',
    () async {
      await PlaybackRepository(db, () => now).markPlayed(episodeId);
      await handler.playEpisode(
        episodeId,
        startAt: const Duration(seconds: 42),
      );
      expect(engine.loadedAt, const Duration(seconds: 42));
      expect((await episode()).status, EpisodeStatus.inProgress);

      // Same episode already loaded → just seek.
      await handler.playEpisode(
        episodeId,
        startAt: const Duration(seconds: 99),
      );
      expect(handler.position, const Duration(seconds: 99));
      expect(engine.calls.where((c) => c == 'load'), hasLength(1));
    },
  );

  test('switching episodes saves the old position first', () async {
    final other = await addEpisode('2');
    await handler.playEpisode(episodeId);
    engine.emitPosition(const Duration(seconds: 100));
    await handler.playEpisode(other);

    expect((await episode()).positionMs, 100000);
    expect(handler.mediaItem.value!.title, 'Folge 2');
  });

  group('playlists (docs/playlists.md)', () {
    late int playlistId;
    late int ep2;
    late int ep3;

    Future<List<int>> itemsOf(int id) async =>
        (await playlists.entries(id)).map((e) => e.episode.id).toList();

    setUp(() async {
      playlistId = (await db.select(db.playlists).getSingle()).id;
      ep2 = await addEpisode('2');
      ep3 = await addEpisode('3');
      for (final id in [episodeId, ep2, ep3]) {
        await playlists.add(playlistId, id);
      }
    });

    test(
      'finished episode is played, removed and the next one starts',
      () async {
        await handler.playEpisode(episodeId, playlistId: playlistId);
        engine.complete();
        await pumpEventQueue();

        expect((await episode()).status, EpisodeStatus.played);
        expect(await itemsOf(playlistId), [ep2, ep3]);
        expect(handler.currentEpisodeId, ep2);
        expect(engine.loadedUri, Uri.parse('https://example.com/2.mp3'));
        expect(handler.playbackState.value.playing, isTrue);
      },
    );

    test('98 % already removes the episode from the playlist', () async {
      await handler.playEpisode(episodeId, playlistId: playlistId);
      engine.emitPosition(const Duration(minutes: 9, seconds: 50));
      await pumpEventQueue();
      expect(await itemsOf(playlistId), [ep2, ep3]);

      // The end still continues with the episode that followed it.
      engine.complete();
      await pumpEventQueue();
      expect(handler.currentEpisodeId, ep2);
    });

    test('an episode added during playback is played too', () async {
      await handler.playEpisode(ep3, playlistId: playlistId);
      final added = await addEpisode('4');
      await playlists.add(playlistId, added);

      engine.complete();
      await pumpEventQueue();
      expect(handler.currentEpisodeId, added);
    });

    test('starts after the played episode, not at the top', () async {
      await handler.playEpisode(ep2, playlistId: playlistId);
      engine.complete();
      await pumpEventQueue();
      expect(handler.currentEpisodeId, ep3);
    });

    test('playback stops at the end of the playlist', () async {
      await handler.playEpisode(ep3, playlistId: playlistId);
      engine.complete();
      await pumpEventQueue();
      expect(handler.currentEpisodeId, ep3);
      expect(handler.playbackState.value.playing, isFalse);
      expect(await itemsOf(playlistId), [episodeId, ep2]);
    });

    test('outside a playlist nothing follows', () async {
      await handler.playEpisode(episodeId);
      engine.complete();
      await pumpEventQueue();
      expect(handler.currentEpisodeId, episodeId);
      expect(handler.playbackState.value.playing, isFalse);
      // Played episodes leave all playlists, even when played elsewhere.
      expect(await itemsOf(playlistId), [ep2, ep3]);
    });

    test('skip: next starts, skipped stays unplayed in the playlist', () async {
      await handler.playEpisode(episodeId, playlistId: playlistId);
      expect(
        handler.playbackState.value.controls,
        contains(MediaControl.skipToNext),
      );
      await handler.skipToNext();

      expect(handler.currentEpisodeId, ep2);
      expect((await episode()).status, isNot(EpisodeStatus.played));
      expect(await itemsOf(playlistId), [episodeId, ep2, ep3]);
    });

    test('played episode leaves ALL playlists', () async {
      final other = await playlists.create('Unterwegs');
      await playlists.add(other, episodeId);
      await handler.playEpisode(episodeId, playlistId: playlistId);
      engine.complete();
      await pumpEventQueue();
      expect(await itemsOf(other), isEmpty);
    });

    test('active playlist survives an app restart', () async {
      await handler.playEpisode(episodeId, playlistId: playlistId);
      await handler.stop();

      final restarted = PodcastAudioHandler(
        engine: FakePlayerEngine(),
        playback: PlaybackRepository(db, () => now),
        settings: settings,
        playlists: playlists,
      );
      addTearDown(restarted.dispose);
      await restarted.restoreLastEpisode();
      expect(restarted.activePlaylistId, playlistId);
      expect(restarted.mediaItem.value!.extras!['playlistId'], playlistId);
    });
  });
}
