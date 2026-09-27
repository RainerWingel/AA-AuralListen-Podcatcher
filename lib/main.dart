import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'audio/audio_providers.dart';
import 'audio/player_engine.dart';
import 'audio/podcast_audio_handler.dart';
import 'data/db/app_database.dart';
import 'data/playback_repository.dart';
import 'data/providers.dart';
import 'data/settings_repository.dart';
import 'data/storage/cover_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The database is created first because the audio handler (which lives
  // outside the widget tree, in the playback service) needs it too.
  final db = AppDatabase();
  final handler = await AudioService.init(
    builder: () => PodcastAudioHandler(
      engine: JustAudioEngine(),
      playback: PlaybackRepository(db, DateTime.now),
      settings: SettingsRepository(db),
    ),
    // Reuse the bounded cover cache instead of a second, separate image cache.
    cacheManager: CoverCacheManager.instance,
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'io.github.rainerwingel.aapodcastguru.playback',
      androidNotificationChannelName: 'Wiedergabe',
      // Keep the service in the foreground while paused: Android 12+ may forbid
      // restarting it from the background (Samsung is strict). The handler stops
      // it itself after 10 minutes of pause (docs/playback.md).
      androidStopForegroundOnPause: false,
      rewindInterval: PodcastAudioHandler.rewindInterval,
      fastForwardInterval: PodcastAudioHandler.fastForwardInterval,
      // Notification artwork is decoded small to save RAM.
      artDownscaleWidth: 512,
      artDownscaleHeight: 512,
    ),
  );

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      audioHandlerProvider.overrideWithValue(handler),
    ],
  );

  unawaited(handler.restoreLastEpisode());
  // Feeds are refreshed on app start only (no background refresh, see docs/decisions.md).
  unawaited(container.read(podcastRepositoryProvider).refreshAll());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PodcastGuruApp(),
    ),
  );
}
