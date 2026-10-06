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

  /// The episode belongs to a provisional podcast: playing it stores
  /// nothing (position, status, duration, history; user wish 2026-10-05).
  /// Read at every write, so subscribing during playback takes effect at once.
  Future<bool> isProvisional(int episodeId) async =>
      (await load(episodeId))?.podcast.provisional ?? false;

  Future<void> _update(int episodeId, EpisodesCompanion changes) => (_db.update(
    _db.episodes,
  )..where((e) => e.id.equals(episodeId))).write(changes);

  /// From this position on a new episode counts as "angespielt" (user rule):
  /// a few seconds of listening in do not take away its "new" state.
  static const inProgressFrom = Duration(seconds: 15);

  /// Stores the listening position. Played episodes are left alone, so a
  /// late position report after the end cannot turn them back into "in
  /// progress" (replays restart via [restartPlayed]).
  /// The status only moves forward: new → in progress at [inProgressFrom];
  /// below that it stays as it is (also when seeking back to the start).
  Future<void> savePosition(int episodeId, Duration position) =>
      (_db.update(_db.episodes)..where(
            (e) =>
                e.id.equals(episodeId) &
                e.status.equalsValue(EpisodeStatus.played).not(),
          ))
          .write(
            EpisodesCompanion(
              positionMs: Value(position.inMilliseconds),
              status: position >= inProgressFrom
                  ? const Value(EpisodeStatus.inProgress)
                  : const Value.absent(),
            ),
          );

  /// `playedAt` of a played episode, null otherwise (the player stops when
  /// the current episode gets marked as played elsewhere).
  Stream<DateTime?> watchPlayedAt(int episodeId) =>
      (_db.select(_db.episodes)..where((e) => e.id.equals(episodeId)))
          .watchSingleOrNull()
          .map((e) => e?.status == EpisodeStatus.played ? e?.playedAt : null)
          .distinct();

  /// Marked as played by the user: removes the episode from ALL playlists
  /// (docs/playlists.md). `playedAt` starts the 96 h eviction timer.
  Future<void> markPlayed(int episodeId) => _db.transaction(() async {
    await _setPlayed(episodeId);
    await (_db.delete(
      _db.playlistItems,
    )..where((i) => i.episodeId.equals(episodeId))).go();
  });

  /// Played to the end: leaves only [playlistId] – the playlist it was
  /// played from – and stays in all others (user wish 2026-10-03). Without
  /// an active playlist it stays everywhere. [keepInPlaylist] (setting
  /// "after 10 minutes" / "never"): marked as finished there instead.
  Future<void> markFinished(
    int episodeId, {
    int? playlistId,
    bool keepInPlaylist = false,
  }) => _db.transaction(() async {
    await _setPlayed(episodeId);
    if (playlistId == null) return;
    final item = _db.playlistItems;
    Expression<bool> where($PlaylistItemsTable i) =>
        i.episodeId.equals(episodeId) & i.playlistId.equals(playlistId);
    if (keepInPlaylist) {
      await (_db.update(item)..where(where)).write(
        PlaylistItemsCompanion(finishedAt: Value(_clock())),
      );
    } else {
      await (_db.delete(item)..where(where)).go();
    }
  });

  Future<void> _setPlayed(int episodeId) => _update(
    episodeId,
    EpisodesCompanion(
      status: const Value(EpisodeStatus.played),
      playedAt: Value(_clock()),
      positionMs: const Value(0),
    ),
  );

  Expression<bool> _unplayedUntil(
    $EpisodesTable e,
    int podcastId,
    DateTime until,
  ) =>
      e.podcastId.equals(podcastId) &
      e.pubDate.isSmallerOrEqualValue(until) &
      e.status.equalsValue(EpisodeStatus.played).not();

  /// Number of not yet played episodes published up to [until] (inclusive).
  Future<int> countUnplayedUntil(int podcastId, DateTime until) async {
    final count = _db.episodes.id.count();
    return await (_db.selectOnly(_db.episodes)
              ..addColumns([count])
              ..where(_unplayedUntil(_db.episodes, podcastId, until)))
            .map((r) => r.read(count))
            .getSingle() ??
        0;
  }

  /// Marks all not yet played episodes published up to [until] (inclusive)
  /// as played – same rules as [markPlayed]: removed from all playlists,
  /// downloads are deleted 96 h later. Episodes without a date are skipped.
  /// Returns the number of episodes marked.
  Future<int> markPlayedUntil(int podcastId, DateTime until) =>
      _db.transaction(() async {
        final ids =
            await (_db.selectOnly(_db.episodes)
                  ..addColumns([_db.episodes.id])
                  ..where(_unplayedUntil(_db.episodes, podcastId, until)))
                .map((r) => r.read(_db.episodes.id)!)
                .get();
        if (ids.isEmpty) return 0;
        await (_db.update(_db.episodes)..where((e) => e.id.isIn(ids))).write(
          EpisodesCompanion(
            status: const Value(EpisodeStatus.played),
            playedAt: Value(_clock()),
            positionMs: const Value(0),
          ),
        );
        await (_db.delete(
          _db.playlistItems,
        )..where((i) => i.episodeId.isIn(ids))).go();
        return ids.length;
      });

  Expression<bool> _playedSince(
    $EpisodesTable e,
    int podcastId,
    DateTime since,
  ) =>
      e.podcastId.equals(podcastId) &
      e.pubDate.isBiggerOrEqualValue(since) &
      e.status.equalsValue(EpisodeStatus.played);

  /// Number of played episodes published at or after [since].
  Future<int> countPlayedSince(int podcastId, DateTime since) async {
    final count = _db.episodes.id.count();
    return await (_db.selectOnly(_db.episodes)
              ..addColumns([count])
              ..where(_playedSince(_db.episodes, podcastId, since)))
            .map((r) => r.read(count))
            .getSingle() ??
        0;
  }

  /// "Als ungespielt markieren seit …": played episodes published at or after
  /// [since] become new again (like [markUnplayed]: position 0, no eviction).
  /// Episodes in progress keep their position; undated ones are skipped.
  /// Returns the number of episodes changed.
  Future<int> markUnplayedSince(int podcastId, DateTime since) =>
      (_db.update(
        _db.episodes,
      )..where((e) => _playedSince(e, podcastId, since))).write(
        const EpisodesCompanion(
          status: Value(EpisodeStatus.newEpisode),
          playedAt: Value(null),
          positionMs: Value(0),
        ),
      );

  Expression<bool> _ofPodcast(
    $EpisodesTable e,
    int podcastId,
    String? theme, [
    int? season,
  ]) =>
      e.podcastId.equals(podcastId) &
      (theme == null ? const Constant(true) : e.theme.equals(theme)) &
      (season == null ? const Constant(true) : e.season.equals(season));

  /// Number of all episodes of a podcast (or of one [theme] / [season]).
  Future<int> countEpisodes(int podcastId, {String? theme, int? season}) async {
    final count = _db.episodes.id.count();
    return await (_db.selectOnly(_db.episodes)
              ..addColumns([count])
              ..where(_ofPodcast(_db.episodes, podcastId, theme, season)))
            .map((r) => r.read(count))
            .getSingle() ??
        0;
  }

  /// "Alle als gespielt markieren" (whole podcast or one [theme]): like
  /// [markPlayedUntil], but for every not yet played episode, undated ones
  /// too. Returns the number of episodes marked.
  Future<int> markAllPlayed(int podcastId, {String? theme, int? season}) =>
      _db.transaction(() async {
        final ids =
            await (_db.selectOnly(_db.episodes)
                  ..addColumns([_db.episodes.id])
                  ..where(
                    _ofPodcast(_db.episodes, podcastId, theme, season) &
                        _db.episodes.status
                            .equalsValue(EpisodeStatus.played)
                            .not(),
                  ))
                .map((r) => r.read(_db.episodes.id)!)
                .get();
        if (ids.isEmpty) return 0;
        await (_db.update(_db.episodes)..where((e) => e.id.isIn(ids))).write(
          EpisodesCompanion(
            status: const Value(EpisodeStatus.played),
            playedAt: Value(_clock()),
            positionMs: const Value(0),
          ),
        );
        await (_db.delete(
          _db.playlistItems,
        )..where((i) => i.episodeId.isIn(ids))).go();
        return ids.length;
      });

  /// "Alle als ungespielt markieren": all played episodes of the podcast (or
  /// [theme]) become new again, like [markUnplayedSince]. Returns the count.
  Future<int> markAllUnplayed(int podcastId, {String? theme, int? season}) =>
      (_db.update(_db.episodes)..where(
            (e) =>
                _ofPodcast(e, podcastId, theme, season) &
                e.status.equalsValue(EpisodeStatus.played),
          ))
          .write(
            const EpisodesCompanion(
              status: Value(EpisodeStatus.newEpisode),
              playedAt: Value(null),
              positionMs: Value(0),
            ),
          );

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

  /// Remembers that the podcast's server builds streamed files anew per
  /// request (see PodcastAudioHandler, docs/playback.md).
  Future<void> markStreamVaries(int podcastId) =>
      (_db.update(_db.podcasts)..where((p) => p.id.equals(podcastId))).write(
        const PodcastsCompanion(streamVaries: Value(true)),
      );

  /// Per-podcast loudness boost; null = use the global default.
  Future<void> setPodcastBoost(int podcastId, double? boostDb) =>
      (_db.update(_db.podcasts)..where((p) => p.id.equals(podcastId))).write(
        PodcastsCompanion(boostDb: Value(boostDb)),
      );
}
