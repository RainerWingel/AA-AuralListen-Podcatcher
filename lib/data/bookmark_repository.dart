import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'db/app_database.dart';

/// A bookmark with its episode and podcast (global bookmark list).
typedef BookmarkEntry = ({Bookmark bookmark, Episode episode, Podcast podcast});

class BookmarkRepository {
  BookmarkRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Future<int> add(int episodeId, Duration position, {String? note}) => _db
      .into(_db.bookmarks)
      .insert(
        BookmarksCompanion.insert(
          episodeId: episodeId,
          positionMs: position.inMilliseconds,
          note: Value(_clean(note)),
          createdAt: _clock(),
        ),
      );

  Future<void> updateNote(int bookmarkId, String? note) =>
      (_db.update(_db.bookmarks)..where((b) => b.id.equals(bookmarkId))).write(
        BookmarksCompanion(note: Value(_clean(note))),
      );

  Future<void> delete(int bookmarkId) =>
      (_db.delete(_db.bookmarks)..where((b) => b.id.equals(bookmarkId))).go();

  /// Bookmarks of one episode, in playback order.
  Stream<List<Bookmark>> watchForEpisode(int episodeId) =>
      (_db.select(_db.bookmarks)
            ..where((b) => b.episodeId.equals(episodeId))
            ..orderBy([(b) => OrderingTerm.asc(b.positionMs)]))
          .watch();

  /// All bookmarks, newest first.
  Stream<List<BookmarkEntry>> watchAll() {
    final query = _db.select(_db.bookmarks).join([
      innerJoin(
        _db.episodes,
        _db.episodes.id.equalsExp(_db.bookmarks.episodeId),
      ),
      innerJoin(
        _db.podcasts,
        _db.podcasts.id.equalsExp(_db.episodes.podcastId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.bookmarks.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            bookmark: row.readTable(_db.bookmarks),
            episode: row.readTable(_db.episodes),
            podcast: row.readTable(_db.podcasts),
          ),
      ],
    );
  }

  static String? _clean(String? note) {
    final text = note?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
