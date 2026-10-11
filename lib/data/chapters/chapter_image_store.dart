import 'dart:io';
import 'dart:typed_data';

/// Pictures embedded in MP3 chapters, kept as files (never in the database).
/// Layout: `<directory>/<episodeId>/<startMs>.<ext>`; the database holds
/// [prefix] + `<episodeId>/<startMs>.<ext>` as the chapter's image reference.
/// Bounded like every cache (docs/eviction.md): pictures of episodes that are
/// gone are deleted, and the rest stays under [maxBytes] (oldest first).
class ChapterImageStore {
  ChapterImageStore(this._directory);

  final Future<Directory> Function() _directory;

  /// Marks a stored reference as a local file (otherwise it is a web address).
  static const prefix = 'chapter:';

  /// Upper limit of all chapter pictures together.
  static const maxBytes = 60 * 1024 * 1024;

  static bool isLocal(String? reference) =>
      reference != null && reference.startsWith(prefix);

  /// Writes [bytes] and returns the reference to store in the chapter.
  Future<String> save(
    int episodeId,
    int startMs,
    Uint8List bytes,
    String extension,
  ) async {
    final relative = '$episodeId/$startMs.$extension';
    final file = File('${(await _directory()).path}/$relative');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return '$prefix$relative';
  }

  /// The file behind [reference]; null if it is no local reference or the
  /// file is gone (cleaned up).
  Future<File?> file(String reference) async {
    if (!isLocal(reference)) return null;
    final relative = reference.substring(prefix.length);
    if (relative.contains('..')) return null;
    final file = File('${(await _directory()).path}/$relative');
    return file.existsSync() ? file : null;
  }

  /// Deletes the pictures of one episode.
  Future<void> deleteEpisode(int episodeId) async {
    final dir = Directory('${(await _directory()).path}/$episodeId');
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  /// Deletes pictures of episodes not in [knownEpisodeIds], then – if the rest
  /// is still over [limit] bytes – whole episodes, least recently written
  /// first. Returns the number of deleted episode folders.
  Future<int> cleanUp(Set<int> knownEpisodeIds, {int limit = maxBytes}) async {
    final root = await _directory();
    if (!root.existsSync()) return 0;
    var deleted = 0;
    final kept = <({Directory dir, DateTime modified, int bytes})>[];
    for (final entity in root.listSync(followLinks: false)) {
      if (entity is! Directory) continue;
      final id = int.tryParse(
        entity.uri.pathSegments.lastWhere(
          (s) => s.isNotEmpty,
          orElse: () => '',
        ),
      );
      if (id == null || !knownEpisodeIds.contains(id)) {
        await entity.delete(recursive: true);
        deleted++;
        continue;
      }
      var bytes = 0;
      var modified = DateTime.fromMillisecondsSinceEpoch(0);
      for (final f in entity.listSync(followLinks: false).whereType<File>()) {
        final stat = f.statSync();
        bytes += stat.size;
        if (stat.modified.isAfter(modified)) modified = stat.modified;
      }
      kept.add((dir: entity, modified: modified, bytes: bytes));
    }
    var total = kept.fold<int>(0, (sum, e) => sum + e.bytes);
    kept.sort((a, b) => a.modified.compareTo(b.modified));
    for (final e in kept) {
      if (total <= limit) break;
      await e.dir.delete(recursive: true);
      total -= e.bytes;
      deleted++;
    }
    return deleted;
  }
}
