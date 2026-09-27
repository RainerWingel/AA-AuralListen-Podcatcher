import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'db/app_database.dart';

/// Listening state of episodes (position, played) and per-podcast playback
/// settings. All rules are described in docs/playback.md and docs/data-model.md.
class PlaybackRepository {
  PlaybackRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Future<EpisodeWithPodcast?> load(int episodeId) async {
    final row = await (_db.select(_db.episodes).join([
      innerJoin(
        _db.podcasts,
        _db.podcasts.id.equalsExp(_db.episodes.podcastId),
      ),
    ])..where(_db.episodes.id.equals(episodeId))).getSingleOrNull();
    if (row == null) return null;
    return (
      episode: row.readTable(_db.episodes),
      podcast: row.readTable(_db.podcasts),
    );
  }

  Future<void> _update(int episodeId, EpisodesCompanion changes) => (_db.update(
    _db.episodes,
  )..where((e) => e.id.equals(episodeId))).write(changes);

  /// Stores the listening position. Played episodes are left alone, so the
  /// last seconds after the 98 % mark cannot turn them back into "in progress".
  Future<void> savePosition(int episodeId, Duration position) =>
      (_db.update(_db.episodes)..where(
            (e) =>
                e.id.equals(episodeId) &
                e.status.equalsValue(EpisodeStatus.played).not(),
          ))
          .write(
            EpisodesCompanion(
              positionMs: Value(position.inMilliseconds),
              status: Value(
                position > Duration.zero
                    ? EpisodeStatus.inProgress
                    : EpisodeStatus.newEpisode,
              ),
            ),
          );

  /// Marks as played (≥ 98 % or finished) and removes the episode from ALL
  /// playlists (docs/playlists.md). `playedAt` starts the 96 h eviction timer.
  Future<void> markPlayed(int episodeId) => _db.transaction(() async {
    await _update(
      episodeId,
      EpisodesCompanion(
        status: const Value(EpisodeStatus.played),
        playedAt: Value(_clock()),
        positionMs: const Value(0),
      ),
    );
    await (_db.delete(
      _db.playlistItems,
    )..where((i) => i.episodeId.equals(episodeId))).go();
  });

  /// Manual "mark as unplayed": cancels the eviction timer.
  Future<void> markUnplayed(int episodeId) => _update(
    episodeId,
    const EpisodesCompanion(
      status: Value(EpisodeStatus.newEpisode),
      playedAt: Value(null),
      positionMs: Value(0),
    ),
  );

  /// Replaying a played episode: starts over and is "in progress" again.
  Future<void> restartPlayed(int episodeId) => _update(
    episodeId,
    const EpisodesCompanion(
      status: Value(EpisodeStatus.inProgress),
      playedAt: Value(null),
      positionMs: Value(0),
    ),
  );

  /// The real duration from the player is more reliable than the feed's.
  Future<void> updateDuration(int episodeId, Duration duration) => _update(
    episodeId,
    EpisodesCompanion(durationMs: Value(duration.inMilliseconds)),
  );

  /// Per-podcast loudness boost; null = use the global default.
  Future<void> setPodcastBoost(int podcastId, double? boostDb) =>
      (_db.update(_db.podcasts)..where((p) => p.id.equals(podcastId))).write(
        PodcastsCompanion(boostDb: Value(boostDb)),
      );
}
