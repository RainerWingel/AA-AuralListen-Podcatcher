import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/clock.dart';
import 'db/app_database.dart';
import 'feed/feed_fetcher.dart';
import 'podcast_repository.dart';
import 'storage/cover_cache.dart';

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
  ),
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
