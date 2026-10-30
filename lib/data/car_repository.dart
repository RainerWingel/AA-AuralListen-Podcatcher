import 'package:drift/drift.dart';

import 'db/app_database.dart';
import 'podcast_repository.dart';

/// Read-only queries for the Android Auto menu (docs/playback.md).
///
/// One-off reads only (`get`, never `watch`): the car asks again whenever a
/// list is opened, so no stream stays open per car screen.
class CarRepository {
  CarRepository(this._db);

  final AppDatabase _db;

  /// Newest unplayed episodes of all subscriptions (like the home screen,
  /// without played ones).
  Future<List<EpisodeWithPodcast>> newEpisodes({required int limit}) =>
      _episodesWithPodcast(
        where:
            _db.podcasts.provisional.equals(false) &
            _db.episodes.status.equalsValue(EpisodeStatus.played).not(),
        orderBy: [
          OrderingTerm(
            expression: _db.episodes.pubDate,
            mode: OrderingMode.desc,
            nulls: NullsOrder.last,
          ),
          OrderingTerm.desc(_db.episodes.id),
        ],
        limit: limit,
      );

  /// Downloaded episodes, the latest download first.
  Future<List<EpisodeWithPodcast>> downloadedEpisodes({
    required int limit,
  }) async {
    final query =
        _db.select(_db.downloads).join([
            innerJoin(
              _db.episodes,
              _db.episodes.id.equalsExp(_db.downloads.episodeId),
            ),
            innerJoin(
              _db.podcasts,
              _db.podcasts.id.equalsExp(_db.episodes.podcastId),
            ),
          ])
          ..where(_db.downloads.state.equalsValue(DownloadState.done))
          ..orderBy([
            OrderingTerm(
              expression: _db.downloads.completedAt,
              mode: OrderingMode.desc,
              nulls: NullsOrder.last,
            ),
          ])
          ..limit(limit);
    return [
      for (final row in await query.get())
        (
          episode: row.readTable(_db.episodes),
          podcast: row.readTable(_db.podcasts),
        ),
    ];
  }

  /// Subscriptions (not provisional ones), alphabetically.
  Future<List<Podcast>> podcasts({required int limit}) =>
      (_db.select(_db.podcasts)
            ..where((p) => p.provisional.equals(false))
            ..orderBy([
              (p) => OrderingTerm(expression: p.title.collate(Collate.noCase)),
            ])
            ..limit(limit))
          .get();

  /// Episodes of one podcast: newest first, serial podcasts in listening
  /// order (as on the podcast page).
  Future<List<EpisodeWithPodcast>> podcastEpisodes(
    int podcastId, {
    required int limit,
  }) async {
    final podcast = await (_db.select(
      _db.podcasts,
    )..where((p) => p.id.equals(podcastId))).getSingleOrNull();
    if (podcast == null) return const [];
    final episodes =
        await (_db.select(_db.episodes)
              ..where((e) => e.podcastId.equals(podcastId))
              ..orderBy(
                podcast.serial
                    ? PodcastRepository.serialOrder
                    : [
                        (e) => OrderingTerm(
                          expression: e.pubDate,
                          mode: OrderingMode.desc,
                          nulls: NullsOrder.last,
                        ),
                        (e) => OrderingTerm.desc(e.id),
                      ],
              )
              ..limit(limit))
            .get();
    return [for (final e in episodes) (episode: e, podcast: podcast)];
  }

  Future<List<EpisodeWithPodcast>> _episodesWithPodcast({
    required Expression<bool> where,
    required List<OrderingTerm> orderBy,
    required int limit,
  }) async {
    final query =
        _db.select(_db.episodes).join([
            innerJoin(
              _db.podcasts,
              _db.podcasts.id.equalsExp(_db.episodes.podcastId),
            ),
          ])
          ..where(where)
          ..orderBy(orderBy)
          ..limit(limit);
    return [
      for (final row in await query.get())
        (
          episode: row.readTable(_db.episodes),
          podcast: row.readTable(_db.podcasts),
        ),
    ];
  }
}
