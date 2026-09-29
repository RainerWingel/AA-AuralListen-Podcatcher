import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../core/clock.dart';
import '../db/app_database.dart';

/// Contents of a backup file, shown before restoring.
class BackupPreview {
  BackupPreview._({
    required this.createdAt,
    required this.podcasts,
    required this.episodes,
    required this.playlists,
    required this.bookmarks,
    required this._databaseFile,
  });

  final DateTime? createdAt;
  final int podcasts;
  final int episodes;
  final int playlists;
  final int bookmarks;

  /// Extracted (and migrated) copy of the backed-up database.
  final File _databaseFile;

  /// Deletes the temporary copy. Always call when done (restored or not).
  Future<void> discard() async {
    if (_databaseFile.existsSync()) await _databaseFile.delete();
  }
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Backup = ZIP with the SQLite database and a manifest. Audio files are not
/// included. Restore replaces all data (docs/backup.md).
class BackupService {
  BackupService({
    required this._db,
    required this._clock,
    required this._tempDirectory,
  });

  final AppDatabase _db;
  final Clock _clock;
  final Future<Directory> Function() _tempDirectory;

  static const manifestName = 'manifest.json';
  static const databaseName = 'aapodcastguru.sqlite';
  static const formatVersion = 1;
  static const _appId = 'AA-AuralListen';

  /// Backups of the app's former name are still accepted – the only way to
  /// move data from the old app id (io.github.rainerwingel.aapodcastguru).
  static const _legacyAppIds = {'AA-PodcastGuru'};

  /// Largest backup accepted for restore (guards the RAM).
  static const maxBackupBytes = 200 * 1024 * 1024;

  /// Tables in "parents first" order. `downloads` is intentionally missing:
  /// files are not part of a backup.
  List<TableInfo<Table, Object?>> get _restoredTables => [
    _db.podcasts,
    _db.episodes,
    _db.chapters,
    _db.bookmarks,
    _db.playlists,
    _db.playlistItems,
    _db.settings,
  ];

  // ------------------------------------------------------------------ backup

  /// Creates the backup file content (ZIP bytes).
  Future<Uint8List> createBackup() async {
    final temp = await _tempFile('backup');
    try {
      // Consistent snapshot of the live database, compacted.
      await _db.customStatement('VACUUM INTO ?', [temp.path]);
      final manifest = {
        'app': _appId,
        'format': formatVersion,
        'schemaVersion': _db.schemaVersion,
        'createdAt': _clock().toUtc().toIso8601String(),
      };
      final archive = Archive()
        ..addFile(ArchiveFile.string(manifestName, jsonEncode(manifest)))
        ..addFile(ArchiveFile.bytes(databaseName, await temp.readAsBytes()));
      return ZipEncoder().encodeBytes(archive);
    } finally {
      if (temp.existsSync()) await temp.delete();
    }
  }

  /// File name suggestion, e.g. `AA-AuralListen-Backup-2026-09-27.zip`.
  String suggestedFileName() {
    final d = _clock();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'AA-AuralListen-Backup-${d.year}-${two(d.month)}-${two(d.day)}.zip';
  }

  // ----------------------------------------------------------------- restore

  /// Checks a backup and returns what it contains. Throws
  /// [BackupFormatException] if it is not a valid backup of this app.
  Future<BackupPreview> inspect(Uint8List zipBytes) async {
    if (zipBytes.length > maxBackupBytes) {
      throw const BackupFormatException('too large');
    }
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } on Object {
      throw const BackupFormatException('not a zip file');
    }
    final manifestFile = archive.findFile(manifestName);
    final dbFile = archive.findFile(databaseName);
    if (manifestFile == null || dbFile == null) {
      throw const BackupFormatException('missing files');
    }
    final Map<String, Object?> manifest;
    try {
      manifest =
          jsonDecode(utf8.decode(manifestFile.content)) as Map<String, Object?>;
    } on Object {
      throw const BackupFormatException('broken manifest');
    }
    final schema = manifest['schemaVersion'];
    final app = manifest['app'];
    if ((app != _appId && !_legacyAppIds.contains(app)) || schema is! int) {
      throw const BackupFormatException('not an AA-AuralListen backup');
    }
    if (schema > _db.schemaVersion) {
      throw const BackupFormatException('backup from a newer app version');
    }

    // Every SQLite file starts with this header. SQLite itself would treat a
    // tiny non-database file as an empty database, so check explicitly.
    final dbBytes = dbFile.content;
    if (dbBytes.length < 100 ||
        ascii.decode(dbBytes.sublist(0, 15), allowInvalid: true) !=
            'SQLite format 3') {
      throw const BackupFormatException('not a database');
    }

    final file = await _tempFile('restore');
    await file.writeAsBytes(dbBytes, flush: true);
    try {
      // Opening it with the app's database class migrates it to the current
      // schema, so the copy below works column by column.
      final copy = AppDatabase.forTesting(NativeDatabase(file));
      try {
        Future<int> count(TableInfo<Table, Object?> table) async {
          final c = countAll();
          return await (copy.selectOnly(
                table,
              )..addColumns([c])).map((r) => r.read(c)).getSingle() ??
              0;
        }

        return BackupPreview._(
          createdAt: DateTime.tryParse('${manifest['createdAt']}')?.toLocal(),
          podcasts: await count(copy.podcasts),
          episodes: await count(copy.episodes),
          playlists: await count(copy.playlists),
          bookmarks: await count(copy.bookmarks),
          databaseFile: file,
        );
      } finally {
        await copy.close();
      }
    } on Object catch (e) {
      if (file.existsSync()) await file.delete();
      if (e is BackupFormatException) rethrow;
      throw const BackupFormatException('database cannot be read');
    }
  }

  /// Replaces all data with the backup (downloads are cleared – the caller
  /// cancels running downloads and runs the download maintenance afterwards).
  Future<void> restore(BackupPreview preview) async {
    final path = preview._databaseFile.path;
    await _db.customStatement('ATTACH DATABASE ? AS backup', [path]);
    try {
      await _db.transaction(() async {
        // Children first, then parents (foreign keys).
        await _db.delete(_db.downloads).go();
        for (final table in _restoredTables.reversed) {
          await _db.delete(table).go();
        }
        for (final table in _restoredTables) {
          // Explicit column lists: migrated databases may order columns
          // differently than freshly created ones.
          final columns = table.$columns.map((c) => '"${c.name}"').join(', ');
          final name = table.actualTableName;
          await _db.customStatement(
            'INSERT INTO main."$name" ($columns) '
            'SELECT $columns FROM backup."$name"',
          );
        }
      });
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
      await preview.discard();
    }
    // Raw SQL does not notify drift's streams – tell them everything changed.
    _db.markTablesUpdated(_db.allTables);
  }

  Future<File> _tempFile(String prefix) async {
    final dir = await _tempDirectory();
    await dir.create(recursive: true);
    return File(
      '${dir.path}/$prefix-${_clock().microsecondsSinceEpoch}.sqlite',
    );
  }
}
