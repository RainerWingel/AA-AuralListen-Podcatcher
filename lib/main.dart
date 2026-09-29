import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'audio/audio_providers.dart';
import 'audio/player_engine.dart';
import 'audio/podcast_audio_handler.dart';
import 'audio/stream_check.dart';
import 'core/app_language.dart';
import 'data/db/app_database.dart';
import 'data/playback_repository.dart';
import 'data/playlist_repository.dart';
import 'data/providers.dart';
import 'data/settings_keys.dart';
import 'data/settings_repository.dart';
import 'data/storage/cover_cache.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The database is created first because the audio handler (which lives
  // outside the widget tree, in the playback service) needs it too.
  final db = AppDatabase();
  // The notification channel is named before the widget tree exists, so the
  // language is read here directly (null = not chosen yet → device language).
  final language =
      AppLanguage.fromSetting(
        await SettingsRepository(db).get(SettingsKeys.language),
      ) ??
      AppLanguage.forDevice(PlatformDispatcher.instance.locale);
  final l10n = lookupAppLocalizations(language.locale);
  // The container is created after the handler; the handler only calls this
  // lookup when playback starts, long after both exist.
  late final ProviderContainer container;
  final handler = await AudioService.init(
    builder: () => PodcastAudioHandler(
      engine: JustAudioEngine(),
      playback: PlaybackRepository(db, DateTime.now),
      settings: SettingsRepository(db),
      playlists: PlaylistRepository(db, DateTime.now),
      localAudioFile: (id) =>
          container.read(downloadServiceProvider).localFile(id),
      // Only used when playback failed, to tell the cause (docs/playback.md).
      checkStream: (uri) =>
          checkStream(container.read(httpClientProvider), uri),
      deleteDownload: (id) =>
          container.read(downloadServiceProvider).delete(id),
    ),
    // Reuse the bounded cover cache instead of a second, separate image cache.
    cacheManager: CoverCacheManager.instance,
    config: AudioServiceConfig(
      androidNotificationChannelId:
          'io.github.rainerwingel.aurallisten.playback',
      androidNotificationChannelName: l10n.notificationChannelPlayback,
      // White silhouette for the status bar (tool/icon/make_icons.py); the
      // coloured launcher icon would show up as a blank square there.
      androidNotificationIcon: 'drawable/ic_stat_podcast',
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

  container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      audioHandlerProvider.overrideWithValue(handler),
    ],
  );

  unawaited(handler.restoreLastEpisode());
  unawaited(_startup(container));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AuralListenApp(),
    ),
  );
}

/// Background work after the UI is up: finish downloads that completed while
/// the app was closed, refresh feeds (only on app start – no background
/// refresh, see docs/decisions.md), then clean up / auto-download.
Future<void> _startup(ProviderContainer container) async {
  final downloads = container.read(downloadServiceProvider);
  await downloads.start();
  await container.read(podcastRepositoryProvider).refreshAll();
  await downloads.runMaintenance();
}
