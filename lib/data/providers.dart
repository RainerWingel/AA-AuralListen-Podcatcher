import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../audio/audio_providers.dart';
import '../core/app_language.dart';
import '../core/clock.dart';
import 'backup/backup_service.dart';
import 'bookmark_repository.dart';
import 'chapters/chapter_service.dart';
import 'db/app_database.dart';
import 'directory/directory_search.dart';
import 'feed/feed_fetcher.dart';
import 'opml_importer.dart';
import 'playback_repository.dart';
import 'playlist_repository.dart';
import 'podcast_repository.dart';
import 'settings_keys.dart';
import 'settings_repository.dart';
import 'storage/cover_cache.dart';
import 'storage/download_engine.dart';
import 'storage/download_service.dart';

// App-wide singletons (think: services registered in a DI container).
// Each one closes its resources in ref.onDispose – see docs/eviction.md.

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final coverCacheProvider = Provider<CoverCache>(
  (ref) => const DefaultCoverCache(),
);

final podcastRepositoryProvider = Provider<PodcastRepository>(
  (ref) => PodcastRepository(
    db: ref.watch(databaseProvider),
    fetcher: FeedFetcher(ref.watch(httpClientProvider)),
    clock: ref.watch(clockProvider),
    coverCache: ref.watch(coverCacheProvider),
    filesCleaner: ref.watch(downloadServiceProvider),
  ),
);

/// Native downloader; tests override it with a fake.
final downloadEngineProvider = Provider<DownloadEngine>((ref) {
  final engine = BackgroundDownloadEngine(ref.watch(httpClientProvider));
  ref.onDispose(engine.dispose);
  return engine;
});

/// Where downloaded episodes live (app-private, no permission needed).
Future<Directory> defaultEpisodesDirectory() async =>
    Directory('${(await getApplicationSupportDirectory()).path}/episodes');

final episodesDirectoryProvider = Provider<Future<Directory> Function()>(
  (ref) => defaultEpisodesDirectory,
);

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final service = DownloadService(
    db: ref.watch(databaseProvider),
    engine: ref.watch(downloadEngineProvider),
    clock: ref.watch(clockProvider),
    episodesDirectory: ref.watch(episodesDirectoryProvider),
    currentEpisodeId: () => ref.read(audioHandlerProvider).currentEpisodeId,
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Download row per episode id (small: only downloaded episodes).
final downloadStatesProvider = StreamProvider<Map<int, Download>>(
  (ref) => ref.watch(downloadServiceProvider).watchStates(),
);

/// Progress 0…1 of running downloads by episode id.
final downloadProgressProvider = StreamProvider.autoDispose<Map<int, double>>(
  (ref) => ref.watch(downloadServiceProvider).progress,
);

final downloadItemsProvider = StreamProvider.autoDispose<List<DownloadItem>>(
  (ref) => ref.watch(downloadServiceProvider).watchAll(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final playbackRepositoryProvider = Provider<PlaybackRepository>(
  (ref) =>
      PlaybackRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final playlistRepositoryProvider = Provider<PlaylistRepository>(
  (ref) =>
      PlaylistRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final playlistsProvider = StreamProvider.autoDispose<List<PlaylistSummary>>(
  (ref) => ref.watch(playlistRepositoryProvider).watchPlaylists(),
);

final playlistProvider = StreamProvider.autoDispose.family<Playlist?, int>(
  (ref, id) => ref.watch(playlistRepositoryProvider).watchPlaylist(id),
);

final playlistEntriesProvider = StreamProvider.autoDispose
    .family<List<PlaylistEntry>, int>(
      (ref, id) => ref.watch(playlistRepositoryProvider).watchEntries(id),
    );

final directorySearchProvider = Provider<DirectorySearch>((ref) {
  final client = ref.watch(httpClientProvider);
  return DirectorySearch([ItunesDirectory(client), FyydDirectory(client)]);
});

final opmlImporterProvider = Provider<OpmlImporter>(
  (ref) => OpmlImporter(ref.watch(podcastRepositoryProvider)),
);

// Screen-level data streams. autoDispose cancels the DB query when no
// widget listens any more.

final podcastsProvider = StreamProvider.autoDispose<List<Podcast>>(
  (ref) => ref.watch(podcastRepositoryProvider).watchPodcasts(),
);

/// Unplayed episodes per podcast id (badges in the subscriptions grid).
final unplayedCountsProvider = StreamProvider.autoDispose<Map<int, int>>(
  (ref) => ref.watch(podcastRepositoryProvider).watchUnplayedCounts(),
);

final podcastProvider = StreamProvider.autoDispose.family<Podcast?, int>(
  (ref, id) => ref.watch(podcastRepositoryProvider).watchPodcast(id),
);

final podcastEpisodesProvider = StreamProvider.autoDispose
    .family<List<Episode>, int>(
      (ref, podcastId) =>
          ref.watch(podcastRepositoryProvider).watchEpisodes(podcastId),
    );

final latestEpisodesProvider =
    StreamProvider.autoDispose<List<EpisodeWithPodcast>>(
      (ref) => ref.watch(podcastRepositoryProvider).watchLatestEpisodes(),
    );

/// Comparison keys of all subscribed feed URLs (see [feedUrlKey]),
/// used to mark search results as "already subscribed".
final subscribedFeedKeysProvider = Provider.autoDispose<Set<String>>((ref) {
  final podcasts = ref.watch(podcastsProvider).value ?? const <Podcast>[];
  return {for (final p in podcasts) feedUrlKey(p.feedUrl)};
});

/// Directory search for one term; cached while the search screen shows it.
final directorySearchResultsProvider = FutureProvider.autoDispose
    .family<DirectorySearchOutcome, String>(
      (ref, term) => ref.watch(directorySearchProvider).search(term),
    );

/// Storage limit for downloads in bytes (setting, default 5 GB).
final downloadLimitProvider = StreamProvider.autoDispose<int>(
  (ref) => ref
      .watch(settingsRepositoryProvider)
      .watch(SettingsKeys.downloadLimitBytes)
      .map((v) => int.tryParse(v ?? '') ?? DownloadService.defaultLimitBytes),
);

final podcastThemesProvider = StreamProvider.autoDispose
    .family<List<PodcastTheme>, int>(
      (ref, podcastId) =>
          ref.watch(podcastRepositoryProvider).watchThemes(podcastId),
    );

final chapterServiceProvider = Provider<ChapterService>(
  (ref) => ChapterService(
    db: ref.watch(databaseProvider),
    client: ref.watch(httpClientProvider),
    localFile: (id) => ref.read(downloadServiceProvider).localFile(id),
  ),
);

/// Chapters of an episode; triggers loading from JSON/ID3 on first use.
final chaptersProvider = StreamProvider.autoDispose.family<List<Chapter>, int>((
  ref,
  episodeId,
) {
  final service = ref.watch(chapterServiceProvider);
  unawaited(service.ensureLoaded(episodeId));
  return service.watch(episodeId);
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>(
  (ref) =>
      BookmarkRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final episodeBookmarksProvider = StreamProvider.autoDispose
    .family<List<Bookmark>, int>(
      (ref, episodeId) =>
          ref.watch(bookmarkRepositoryProvider).watchForEpisode(episodeId),
    );

final allBookmarksProvider = StreamProvider.autoDispose<List<BookmarkEntry>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watchAll(),
);

/// Directory for short-lived files (backup snapshots); overridden in tests.
final tempDirectoryProvider = Provider<Future<Directory> Function()>(
  (ref) =>
      () async =>
          Directory('${(await getTemporaryDirectory()).path}/aapodcastguru'),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    tempDirectory: ref.watch(tempDirectoryProvider),
  ),
);

/// UI language chosen by the user; null = not chosen yet (first start).
final appLanguageProvider = StreamProvider<AppLanguage?>(
  (ref) => ref
      .watch(settingsRepositoryProvider)
      .watch(SettingsKeys.language)
      .map(AppLanguage.fromSetting),
);

/// Light/dark mode chosen in Optionen (default: follow the system).
final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref
      .watch(settingsRepositoryProvider)
      .watch(SettingsKeys.themeMode)
      .map(
        (v) => ThemeMode.values.firstWhere(
          (m) => m.name == v,
          orElse: () => ThemeMode.system,
        ),
      ),
);
