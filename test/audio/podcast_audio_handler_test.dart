import 'dart:io';
import 'dart:math';

import 'package:aapodcastguru/audio/player_engine.dart';
import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/audio/sleep_timer.dart';
import 'package:aapodcastguru/audio/stream_check.dart';
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

  test('resetAfterRestore forgets the current episode and shows the '
      'restored last episode', () async {
    await handler.playEpisode(episodeId);
    final other = await addEpisode('2');
    // As if a backup was restored whose last episode is "other".
    await settings.set(SettingsKeys.lastEpisodeId, '$other');

    await handler.resetAfterRestore();
    expect(handler.currentEpisodeId, other);
    expect(handler.mediaItem.value!.title, 'Folge 2');
    expect(handler.playbackState.value.playing, isFalse);
    expect(engine.calls.last, 'stop');
  });

  test('switching episodes saves the old position first', () async {
    final other = await addEpisode('2');
    await handler.playEpisode(episodeId);
    engine.emitPosition(const Duration(seconds: 100));
    await handler.playEpisode(other);

    expect((await episode()).positionMs, 100000);
    expect(handler.mediaItem.value!.title, 'Folge 2');
  });

  test('dispose ends every stream it owns (no leaks)', () async {
    await handler.playEpisode(episodeId);
    final done = <String>[];
    handler.positionStream.listen(null, onDone: () => done.add('position'));
    handler.chapterSkips
        .watch(episodeId)
        .listen(null, onDone: () => done.add('skips'));
    await pumpEventQueue();

    await handler.dispose();
    await pumpEventQueue();
    expect(done, unorderedEquals(['position', 'skips']));
  });

  group('sleep timer (in memory)', () {
    Future<void> ms(int n) => Future<void>.delayed(Duration(milliseconds: n));

    setUp(() async {
      await handler.dispose();
      engine = FakePlayerEngine();
      handler = PodcastAudioHandler(
        engine: engine,
        playback: PlaybackRepository(db, () => now),
        settings: settings,
        playlists: playlists,
        sleepFadeDuration: const Duration(milliseconds: 40),
      );
    });

    test(
      'fades out over the last seconds, then pauses at full volume',
      () async {
        await handler.playEpisode(episodeId);
        handler.setSleepTimer(
          const SleepTimerAfter(Duration(milliseconds: 150)),
        );
        await ms(80);
        expect(engine.volumes, isEmpty, reason: 'no fade before the end');

        await ms(50); // inside the last 40 ms
        expect(engine.volume, lessThan(1));
        expect(engine.volume, greaterThanOrEqualTo(0));
        expect(handler.playbackState.value.playing, isTrue);

        await ms(80);
        expect(handler.playbackState.value.playing, isFalse);
        // Lower and lower, then back to full – only after pausing.
        final fade = engine.volumes.sublist(0, engine.volumes.length - 1);
        for (var i = 1; i < fade.length; i++) {
          expect(fade[i], lessThanOrEqualTo(fade[i - 1]));
        }
        expect(engine.volume, 1);
        // No loud blip: full volume comes back only after the pause.
        expect(
          engine.calls.lastIndexOf('volume full'),
          greaterThan(engine.calls.lastIndexOf('pause')),
        );
      },
    );

    test('the fade follows hearing, not a straight line', () {
      double db(double v) => 20 * log(v) / ln10;
      const vol = PodcastAudioHandler.sleepFadeVolume;
      expect(vol(1), 1);
      expect(vol(0), 0);
      // Clearly quieter early on: a quarter into the fade already −7 dB …
      expect(db(vol(0.75)), lessThan(-7));
      // … and evenly on towards silence (roughly equal dB steps).
      expect(db(vol(0.5)), closeTo(-18, 0.5));
      expect(db(vol(0.25)), closeTo(-36, 0.5));
      for (var s = 0.0; s < 1; s += 0.05) {
        expect(vol(s), lessThanOrEqualTo(vol(s + 0.05)));
      }
    });

    test('pausing during the fade restores the volume', () async {
      await handler.playEpisode(episodeId);
      handler.setSleepTimer(const SleepTimerAfter(Duration(milliseconds: 60)));
      await ms(35);
      expect(engine.volume, lessThan(1));
      await handler.pause();
      expect(engine.volume, 1);
      expect(handler.sleepTimerState.isActive, isTrue);

      await handler.play(); // the fade continues from where it was
      await ms(10);
      expect(engine.volume, lessThan(1));
      await ms(60);
      expect(handler.playbackState.value.playing, isFalse);
      expect(engine.volume, 1);
    });

    test('"Aus" during the fade restores the volume', () async {
      await handler.playEpisode(episodeId);
      handler.setSleepTimer(const SleepTimerAfter(Duration(milliseconds: 60)));
      await ms(35);
      handler.setSleepTimer(const SleepTimerOff());
      expect(engine.volume, 1);
      await ms(60);
      expect(handler.playbackState.value.playing, isTrue);
      expect(engine.volume, 1);
    });

    test('pauses after the chosen playing time, then is off', () async {
      await handler.playEpisode(episodeId);
      handler.setSleepTimer(const SleepTimerAfter(Duration(milliseconds: 60)));
      expect(handler.sleepTimerState.isActive, isTrue);
      await ms(120);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.sleepTimerState.isActive, isFalse);
    });

    test('paused time does not count', () async {
      await handler.playEpisode(episodeId);
      handler.setSleepTimer(const SleepTimerAfter(Duration(milliseconds: 150)));
      await ms(50);
      await handler.pause();
      final left = handler.sleepTimerState.remaining!;
      await ms(200); // longer than the whole timer
      expect(handler.sleepTimerState.remaining, left);
      expect(handler.sleepTimerState.isActive, isTrue);

      await handler.play();
      await ms(30);
      expect(handler.playbackState.value.playing, isTrue);
      await ms(200);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.sleepTimerState.isActive, isFalse);
    });

    test('"Aus" cancels a running timer', () async {
      await handler.playEpisode(episodeId);
      handler.setSleepTimer(const SleepTimerAfter(Duration(milliseconds: 40)));
      handler.setSleepTimer(const SleepTimerOff());
      await ms(100);
      expect(handler.playbackState.value.playing, isTrue);
    });

    test('end of episode: played, but the playlist does not go on', () async {
      final playlistId = (await db.select(db.playlists).getSingle()).id;
      final ep2 = await addEpisode('2');
      await playlists.add(playlistId, episodeId);
      await playlists.add(playlistId, ep2);
      await handler.playEpisode(episodeId, playlistId: playlistId);
      handler.setSleepTimer(const SleepTimerAtEpisodeEnd());

      engine.complete();
      await pumpEventQueue();

      expect((await episode()).status, EpisodeStatus.played);
      expect(handler.currentEpisodeId, episodeId);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.sleepTimerState.isActive, isFalse);
    });

    test('dispose ends the sleep timer stream', () async {
      var done = false;
      handler.sleepTimerStream.listen(null, onDone: () => done = true);
      await pumpEventQueue();
      await handler.dispose();
      await pumpEventQueue();
      expect(done, isTrue);
    });
  });

  group('hang detection', () {
    const tick = Duration(milliseconds: 20);
    late List<PlaybackProblem> problems;

    setUp(() async {
      await handler.dispose();
      engine = FakePlayerEngine();
      handler = PodcastAudioHandler(
        engine: engine,
        playback: PlaybackRepository(db, () => now),
        settings: settings,
        playlists: playlists,
        stallCheckInterval: tick,
        recoveryRetryDelay: tick,
      );
      problems = [];
      handler.problems.listen(problems.add);
    });

    Future<void> wait(int ticks) =>
        Future<void>.delayed(tick * ticks + const Duration(milliseconds: 5));

    int loads() => engine.calls.where((c) => c == 'load').length;

    test('the watchdog only runs while playing', () async {
      expect(handler.watchdogActive, isFalse);
      await handler.playEpisode(episodeId);
      expect(handler.watchdogActive, isTrue);
      await handler.pause();
      expect(handler.watchdogActive, isFalse);
    });

    test('no reload while the position moves', () async {
      await handler.playEpisode(episodeId);
      for (var i = 1; i <= 8; i++) {
        engine.emitPosition(Duration(minutes: 1, seconds: i));
        await wait(1);
      }
      expect(loads(), 1);
    });

    test('a hang reloads exactly at the current position', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 2));
      await wait(HangTicks.detect);

      expect(loads(), 2);
      expect(engine.loadedAt, const Duration(minutes: 2));
      expect(handler.playbackState.value.playing, isTrue);
      expect((await episode()).positionMs, 2 * 60000);
      expect(problems, isEmpty);
    });

    test('without network: retries, then stops and tells the user', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 2));
      engine.failLoads = true;
      await wait(HangTicks.detect + PodcastAudioHandler.maxRecoveries + 3);

      expect(loads(), 1 + PodcastAudioHandler.maxRecoveries);
      expect(problems, [PlaybackProblem.stalled]);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.position, const Duration(minutes: 2));
      expect((await episode()).positionMs, 2 * 60000);

      // Nothing keeps running afterwards.
      await wait(5);
      expect(loads(), 1 + PodcastAudioHandler.maxRecoveries);
    });

    test('pausing ends a pending retry', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 2));
      engine.failLoads = true;
      // Pause right after the first failed reload, while a retry is pending.
      while (loads() < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      await handler.pause();
      await wait(5);
      expect(loads(), 2);
      expect(problems, isEmpty);
    });

    test('player error while playing: fresh load at the same spot', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 7));
      engine.emitError();
      await pumpEventQueue();

      // Not the half-dead just_audio player: stopped and loaded anew.
      expect(engine.calls.sublist(engine.calls.length - 3), [
        'stop',
        'load',
        'play',
      ]);
      expect(engine.loadedAt, const Duration(minutes: 7));
      expect(handler.playbackState.value.playing, isTrue);
      expect((await episode()).positionMs, 7 * 60000);
      expect(problems, isEmpty);

      // The position display runs again.
      final seen = <Duration>[];
      final sub = handler.positionStream.listen(seen.add);
      engine.emitPosition(const Duration(minutes: 7, seconds: 1));
      await pumpEventQueue();
      await sub.cancel();
      expect(seen.last, const Duration(minutes: 7, seconds: 1));
    });

    test('error in the background: resumes where it really was', () async {
      await handler.playEpisode(episodeId);
      // Background playback: positions stream in, but just_audio's own
      // position after the error is its last state change (start).
      engine.emitPosition(const Duration(minutes: 4, seconds: 22));
      engine.staleAfterError = const Duration(seconds: 57);
      engine.emitError();
      await pumpEventQueue();

      expect(engine.loadedAt, const Duration(minutes: 4, seconds: 22));
      expect((await episode()).positionMs, (4 * 60 + 22) * 1000);
    });

    test(
      'player error while offline: retries until the network is back',
      () async {
        await handler.playEpisode(episodeId);
        engine.emitPosition(const Duration(minutes: 7));
        engine.failLoads = true;
        engine.emitError();
        await wait(1);
        expect(handler.playbackState.value.playing, isFalse);
        expect(handler.position, const Duration(minutes: 7));

        engine.failLoads = false; // network back
        await wait(2);
        expect(handler.playbackState.value.playing, isTrue);
        expect(engine.loadedAt, const Duration(minutes: 7));
        expect(problems, isEmpty);
      },
    );

    test('player error while paused: reload only on the next Play', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 7));
      await handler.pause();
      final before = loads();
      engine.emitError();
      await wait(3);
      expect(loads(), before);

      await handler.play();
      expect(loads(), before + 1);
      expect(engine.loadedAt, const Duration(minutes: 7));
      expect(handler.playbackState.value.playing, isTrue);
    });

    test('Play during a pending reload does not start a second load', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 7));
      engine.loadDelay = const Duration(milliseconds: 80);
      engine.emitError(); // starts the reload (slow network)
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final before = loads();
      await handler.play(); // user taps Play meanwhile
      await wait(3);
      expect(loads(), before);
      expect(handler.playbackState.value.playing, isTrue);
    });

    test('an episode that cannot be loaded reports it, never throws', () async {
      engine.failLoads = true;
      await handler.playEpisode(episodeId);
      await pumpEventQueue();
      expect(problems, [PlaybackProblem.loadFailed]);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.watchdogActive, isFalse);
    });
  });

  group('error kinds (docs/playback.md)', () {
    const tick = Duration(milliseconds: 20);
    late List<PlaybackProblem> problems;
    late List<int> deleted;
    late StreamCheck serverSays;
    late int checks;
    late bool hasDownload;

    setUp(() async {
      await handler.dispose();
      engine = FakePlayerEngine();
      deleted = [];
      serverSays = StreamCheck.offline;
      checks = 0;
      hasDownload = false;
      handler = PodcastAudioHandler(
        engine: engine,
        playback: PlaybackRepository(db, () => now),
        settings: settings,
        playlists: playlists,
        stallCheckInterval: tick,
        recoveryRetryDelay: tick,
        localAudioFile: (id) async => hasDownload && !deleted.contains(id)
            ? File('/data/episodes/$id.mp3')
            : null,
        deleteDownload: (id) async => deleted.add(id),
        checkStream: (uri) async {
          checks++;
          return serverSays;
        },
      );
      problems = [];
      handler.problems.listen(problems.add);
    });

    int loads() => engine.calls.where((c) => c == 'load').length;
    final stream = Uri.parse('https://example.com/1.mp3');

    test('broken download: deleted, then streamed right away', () async {
      hasDownload = true;
      engine.failFileLoads = true;
      await handler.playEpisode(episodeId);
      await pumpEventQueue();

      expect(deleted, [episodeId]);
      expect(engine.loadedUri, stream);
      expect(handler.playbackState.value.playing, isTrue);
      expect(problems, [PlaybackProblem.brokenDownload]);
      expect(checks, 0, reason: 'a local file never asks the server');
    });

    test('download breaks during playback: streamed from there', () async {
      hasDownload = true;
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 5));
      engine.emitError();
      await pumpEventQueue();

      expect(deleted, [episodeId]);
      expect(engine.loadedUri, stream);
      expect(engine.loadedAt, const Duration(minutes: 5));
      expect(problems, [PlaybackProblem.brokenDownload]);
    });

    test('episode gone at the provider: no retries, clear message', () async {
      serverSays = StreamCheck.gone;
      engine.failLoads = true;
      await handler.playEpisode(episodeId);
      await Future<void>.delayed(tick * 5);

      expect(problems, [PlaybackProblem.episodeGone]);
      expect(loads(), 1);
      expect(handler.playbackState.value.playing, isFalse);
    });

    test('episode disappears during playback: stops, no retries', () async {
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 5));
      serverSays = StreamCheck.gone;
      engine.failLoads = true;
      engine.emitError();
      await Future<void>.delayed(tick * 5);

      expect(problems, [PlaybackProblem.episodeGone]);
      expect(loads(), 1);
      expect(handler.position, const Duration(minutes: 5));
    });

    test('decoder error: unplayable format, no retries', () async {
      engine
        ..failLoads = true
        ..loadErrorKind = EngineErrorKind.renderer;
      await handler.playEpisode(episodeId);
      await Future<void>.delayed(tick * 5);

      expect(problems, [PlaybackProblem.unsupportedFormat]);
      expect(loads(), 1);
    });

    test('server fine but loading fails twice: unplayable format', () async {
      serverSays = StreamCheck.reachable;
      engine.failLoads = true;
      await handler.playEpisode(episodeId);
      await pumpEventQueue();

      expect(loads(), 2, reason: 'one more try in case it was a hiccup');
      expect(problems, [PlaybackProblem.unsupportedFormat]);
    });

    test('server fine, hiccup on the retry: plays', () async {
      serverSays = StreamCheck.reachable;
      engine.failNextLoads = 1; // the extra try succeeds
      await handler.playEpisode(episodeId);
      await pumpEventQueue();

      expect(loads(), 2);
      expect(handler.playbackState.value.playing, isTrue);
      expect(problems, isEmpty);
    });

    test('no network when tapping Play: network message', () async {
      engine.failLoads = true;
      await handler.playEpisode(episodeId);
      await pumpEventQueue();
      expect(problems, [PlaybackProblem.loadFailed]);
      expect(deleted, isEmpty);
    });
  });

  group('skipped chapters (in memory)', () {
    Future<void> skip(int startMin, int? endMin, [int? id]) =>
        handler.setChapterSkipped(
          id ?? episodeId,
          startMin * 60000,
          endMs: endMin == null ? null : endMin * 60000,
          skipped: true,
        );

    test('entering a skipped chapter jumps to its end', () async {
      await handler.playEpisode(episodeId);
      await skip(2, 4);
      engine.emitPosition(const Duration(minutes: 1, seconds: 59));
      await pumpEventQueue();
      expect(engine.position, const Duration(minutes: 1, seconds: 59));

      engine.emitPosition(const Duration(minutes: 2));
      await pumpEventQueue();
      expect(engine.position, const Duration(minutes: 4));
      expect((await episode()).positionMs, 4 * 60000);
    });

    test('skipping the current chapter jumps at once', () async {
      await handler.playEpisode(episodeId); // starts at 0:57
      await skip(0, 3);
      expect(engine.position, const Duration(minutes: 3));
    });

    test('skipping the last chapter finishes the episode', () async {
      final playlistId = (await db.select(db.playlists).getSingle()).id;
      final ep2 = await addEpisode('2');
      await playlists.add(playlistId, episodeId);
      await playlists.add(playlistId, ep2);
      await handler.playEpisode(episodeId, playlistId: playlistId);

      await skip(8, null);
      engine.emitPosition(const Duration(minutes: 8, seconds: 1));
      await pumpEventQueue();

      expect((await episode()).status, EpisodeStatus.played);
      expect(handler.currentEpisodeId, ep2);
    });

    test('skips only apply to their own episode', () async {
      final ep2 = await addEpisode('2');
      await skip(2, 4, ep2);
      await handler.playEpisode(episodeId);
      engine.emitPosition(const Duration(minutes: 3));
      await pumpEventQueue();
      expect(engine.position, const Duration(minutes: 3));
    });
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

/// Ticks until a hang is detected (checks without progress, plus one to
/// register the starting position).
abstract final class HangTicks {
  static const detect = PodcastAudioHandler.stallChecks + 2;
}
