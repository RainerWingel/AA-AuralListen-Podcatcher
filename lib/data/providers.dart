import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../audio/audio_providers.dart';
import '../core/clock.dart';
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
  final engine = BackgroundDownloadEngine();
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
