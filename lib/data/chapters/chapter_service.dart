import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../db/app_database.dart';
import 'id3_chapters.dart';
import 'json_chapters.dart';
import 'parsed_chapter.dart';
import 'remote_id3.dart';

/// Chapters of an episode, loaded once and then read from the database.
///
/// Sources, in this order (docs/playback.md):
/// 1. Podlove chapters from the feed – stored during refresh already.
/// 2. Podcasting 2.0 JSON file (`chaptersUrl`).
/// 3. ID3 CHAP frames of the MP3 – from the downloaded file, otherwise only
///    the tag at the start of the remote file (HTTP range request).
class ChapterService {
  ChapterService({
    required this._db,
    required this._client,
    required this._localFile,
  });

  final AppDatabase _db;
  final http.Client _client;
  final Future<File?> Function(int episodeId) _localFile;

  static const _maxJsonBytes = 1024 * 1024;

  /// Episodes already looked up in this app session (also those without
  /// chapters) – avoids repeated network requests.
  final _attempted = <int>{};

  Stream<List<Chapter>> watch(int episodeId) =>
      (_db.select(_db.chapters)
            ..where((c) => c.episodeId.equals(episodeId))
            ..orderBy([(c) => OrderingTerm.asc(c.startMs)]))
          .watch();

  /// Loads chapters from the JSON file or the MP3 if none are stored yet.
  Future<void> ensureLoaded(int episodeId) async {
    if (!_attempted.add(episodeId)) return;
    final count = _db.chapters.startMs.count();
    final stored =
        await (_db.selectOnly(_db.chapters)
              ..addColumns([count])
              ..where(_db.chapters.episodeId.equals(episodeId)))
            .map((r) => r.read(count))
            .getSingle();
    if ((stored ?? 0) > 0) return;

    final episode = await (_db.select(
      _db.episodes,
    )..where((e) => e.id.equals(episodeId))).getSingleOrNull();
    if (episode == null) return;

    var chapters = await _fromJson(episode.chaptersUrl);
    if (chapters.isEmpty) chapters = await _fromId3(episode);
    if (chapters.isEmpty) return;

    await _db.batch(
      (batch) => batch.insertAll(_db.chapters, [
        for (final c in chapters)
          ChaptersCompanion.insert(
            episodeId: episodeId,
            startMs: c.start.inMilliseconds,
            title: c.title,
            url: Value(c.url),
            imageUrl: Value(c.imageUrl),
          ),
      ], mode: InsertMode.insertOrIgnore),
    );
  }

  Future<List<ParsedChapter>> _fromJson(String? url) async {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null) return const [];
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 ||
          response.bodyBytes.length > _maxJsonBytes) {
        return const []; // e.g. Podigee answers 404 with an HTML page
      }
      return parseJsonChapters(response.body);
    } on Exception {
      return const [];
    }
  }

  Future<List<ParsedChapter>> _fromId3(Episode episode) async {
    final file = await _localFile(episode.id);
    final Uint8List? tag;
    if (file != null) {
      tag = await _readLocalTag(file);
    } else {
      final uri = Uri.tryParse(episode.audioUrl);
      tag = uri == null ? null : await fetchId3Tag(_client, uri);
    }
    return tag == null ? const [] : parseId3Chapters(tag);
  }

  /// Reads just the ID3 tag from the start of a downloaded file.
  Future<Uint8List?> _readLocalTag(File file) async {
    final raf = await file.open();
    try {
      final length = id3TagLength(await raf.read(10));
      if (length == null || length > maxId3TagBytes) return null;
      await raf.setPosition(0);
      return await raf.read(length);
    } on FileSystemException {
      return null;
    } finally {
      await raf.close();
    }
  }
}

/// The chapter that contains [position] (the last one starting before it).
Chapter? currentChapter(List<Chapter> chapters, Duration position) {
  Chapter? current;
  for (final c in chapters) {
    if (c.startMs > position.inMilliseconds) break;
    current = c;
  }
  return current;
}
