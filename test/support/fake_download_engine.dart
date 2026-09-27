import 'dart:async';
import 'dart:io';

import 'package:aapodcastguru/data/storage/download_engine.dart';

/// Scriptable [DownloadEngine]: records enqueued downloads; the test decides
/// when they finish ([finish] writes a real file into [directory]).
class FakeDownloadEngine implements DownloadEngine {
  FakeDownloadEngine(this.directory);

  final Directory directory;
  final _events = StreamController<DownloadEvent>.broadcast(sync: true);

  /// episodeId → (fileName, wifiOnly) of downloads that are still active.
  final active = <int, ({String fileName, bool wifiOnly})>{};
  final canceled = <int>[];
  bool acceptEnqueue = true;

  @override
  Stream<DownloadEvent> get events => _events.stream;

  /// Whether someone (the DownloadService) still listens – leak tests.
  bool get hasListener => _events.hasListener;

  @override
  Future<void> start() async {}

  @override
  Future<bool> enqueue({
    required int episodeId,
    required String url,
    required String fileName,
    required bool wifiOnly,
  }) async {
    if (!acceptEnqueue) return false;
    active[episodeId] = (fileName: fileName, wifiOnly: wifiOnly);
    return true;
  }

  /// Simulates a successful download of [bytes] bytes.
  Future<void> finish(int episodeId, {int bytes = 1000}) async {
    final task = active.remove(episodeId)!;
    directory.createSync(recursive: true);
    File('${directory.path}/${task.fileName}')
        .writeAsBytesSync(List.filled(bytes, 0));
    _events
      ..add(DownloadStarted(episodeId))
      ..add(DownloadProgress(episodeId, 0.5))
      ..add(DownloadCompleted(episodeId));
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> fail(int episodeId) async {
    active.remove(episodeId);
    _events.add(DownloadFailed(episodeId, 'HTTP 404'));
    await Future<void>.delayed(Duration.zero);
  }

  void emit(DownloadEvent event) => _events.add(event);

  @override
  Future<void> cancel(int episodeId) async {
    canceled.add(episodeId);
    active.remove(episodeId);
  }

  @override
  Future<Set<int>> activeEpisodeIds() async => active.keys.toSet();

  @override
  Future<void> dispose() => _events.close();
}
