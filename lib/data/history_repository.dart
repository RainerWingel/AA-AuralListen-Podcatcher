import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'db/app_database.dart';

/// "Abspielverlauf" (Optionen): episodes played to the end, newest first
/// (user wish 2026-10-03, docs/ui-ux.md).
class HistoryRepository {
  HistoryRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Only the newest entries are kept (bounded, docs/eviction.md).
  static const maxEntries = 100;

  Stream<List<HistoryEntry>> watchAll() =>
      (_db.select(_db.playHistory)..orderBy([
            (h) => OrderingTerm.desc(h.playedAt),
            (h) => OrderingTerm.desc(h.id),
          ]))
          .watch();

  /// Records [episodeId] as played to the end now. A replay replaces its
  /// older entry; beyond [maxEntries] the oldest are dropped.
  Future<void> addFinished(int episodeId) => _db.transaction(() async {
    final row = await (_db.select(_db.episodes).join([
      innerJoin(
        _db.podcasts,
        _db.podcasts.id.equalsExp(_db.episodes.podcastId),
      ),
    ])..where(_db.episodes.id.equals(episodeId))).getSingleOrNull();
    if (row == null) return;
    final episode = row.readTable(_db.episodes);
    final podcast = row.readTable(_db.podcasts);
    await (_db.delete(_db.playHistory)..where(
          (h) =>
              h.feedUrl.equals(podcast.feedUrl) & h.guid.equals(episode.guid),
        ))
        .go();
    await _db
        .into(_db.playHistory)
        .insert(
          PlayHistoryCompanion.insert(
            feedUrl: podcast.feedUrl,
            guid: episode.guid,
            episodeTitle: episode.title,
            podcastTitle: podcast.title,
            imageUrl: Value(episode.imageUrl ?? podcast.imageUrl),
            durationMs: Value(episode.durationMs),
            playedAt: _clock(),
          ),
        );
    final keep = _db.selectOnly(_db.playHistory)
      ..addColumns([_db.playHistory.id])
      ..orderBy([
        OrderingTerm.desc(_db.playHistory.playedAt),
        OrderingTerm.desc(_db.playHistory.id),
      ])
      ..limit(maxEntries);
    await (_db.delete(
      _db.playHistory,
    )..where((h) => h.id.isNotInQuery(keep))).go();
  });

  /// The episode of [entry] if it is still subscribed (also after a new
  /// subscription to the same feed), else null.
  Future<int?> episodeIdOf(HistoryEntry entry) async {
    final id = _db.episodes.id;
    return (_db.selectOnly(_db.episodes).join([
            innerJoin(
              _db.podcasts,
              _db.podcasts.id.equalsExp(_db.episodes.podcastId),
            ),
          ])
          ..addColumns([id])
          ..where(
            _db.podcasts.feedUrl.equals(entry.feedUrl) &
                _db.episodes.guid.equals(entry.guid),
          ))
        .map((r) => r.read(id))
        .getSingleOrNull();
  }

  /// "Verlauf löschen".
  Future<void> clear() => _db.delete(_db.playHistory).go();
}
