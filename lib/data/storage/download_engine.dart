import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:http/http.dart' as http;

import '../../core/app_info.dart';
import 'download_url.dart';

/// What the download engine reports about one episode download.
sealed class DownloadEvent {
  const DownloadEvent(this.episodeId);

  final int episodeId;
}

/// Bytes are being transferred.
class DownloadStarted extends DownloadEvent {
  const DownloadStarted(super.episodeId);
}

/// Queued but not transferring: waiting for Wi-Fi ("Nur WLAN"), for a network
/// or for the next retry. Not a progress of 0 % (user report 2026-10-05: the
/// ring at 0 % showed as an empty gap).
class DownloadWaiting extends DownloadEvent {
  const DownloadWaiting(super.episodeId);
}

class DownloadProgress extends DownloadEvent {
  const DownloadProgress(super.episodeId, this.fraction);

  /// 0.0 … 1.0
  final double fraction;
}

/// The file is complete and has been moved to its final place.
class DownloadCompleted extends DownloadEvent {
  const DownloadCompleted(super.episodeId);
}

class DownloadFailed extends DownloadEvent {
  const DownloadFailed(super.episodeId, this.reason);

  final String reason;
}

class DownloadCanceled extends DownloadEvent {
  const DownloadCanceled(super.episodeId);
}

/// Translates a background_downloader status into our event.
DownloadEvent downloadEventFor(
  int episodeId,
  TaskStatus status,
  String? errorDescription,
) => switch (status) {
  TaskStatus.running => DownloadStarted(episodeId),
  TaskStatus.complete => DownloadCompleted(episodeId),
  TaskStatus.canceled => DownloadCanceled(episodeId),
  TaskStatus.failed || TaskStatus.notFound => DownloadFailed(
    episodeId,
    errorDescription ?? status.name,
  ),
  TaskStatus.enqueued ||
  TaskStatus.waitingToRetry ||
  TaskStatus.paused => DownloadWaiting(episodeId),
};

/// Downloads files into the episodes directory. Interface so the download and
/// eviction logic can be tested without network (think: IDownloadClient).
abstract interface class DownloadEngine {
  Stream<DownloadEvent> get events;

  /// Starts delivering events, including those that happened while the app
  /// was not running. Call once after listening to [events].
  Future<void> start();

  /// Queues a download of [url] to `episodes/<fileName>`.
  Future<bool> enqueue({
    required int episodeId,
    required String url,
    required String fileName,
    required bool wifiOnly,
  });

  Future<void> cancel(int episodeId);

  /// Episode ids that the engine is still working on.
  Future<Set<int>> activeEpisodeIds();

  /// Stops listening to the platform (running downloads continue natively).
  Future<void> dispose();
}

/// [DownloadEngine] based on background_downloader (Android WorkManager):
/// downloads continue when the app is in the background. Partial data is kept
/// in a temporary file and only moved into place when complete.
class BackgroundDownloadEngine implements DownloadEngine {
  BackgroundDownloadEngine(this._client);

  /// Only for [resolveProtocolSwitches]; owned by the caller.
  final http.Client _client;

  static const _group = 'episodes';
  static const _taskPrefix = 'episode-';
  static const _userAgent = appUserAgent;

  final _events = StreamController<DownloadEvent>.broadcast();
  StreamSubscription<TaskUpdate>? _subscription;

  static int? _episodeIdOf(Task task) => task.taskId.startsWith(_taskPrefix)
      ? int.tryParse(task.taskId.substring(_taskPrefix.length))
      : null;

  @override
  Stream<DownloadEvent> get events => _events.stream;

  @override
  Future<void> start() async {
    _subscription ??= FileDownloader().updates.listen(_onUpdate);
    // Delivers updates that happened while the app was suspended or killed.
    // No trackTasks(): our own `downloads` table is the only record we keep.
    await FileDownloader().resumeFromBackground();
  }

  void _onUpdate(TaskUpdate update) {
    final id = _episodeIdOf(update.task);
    if (id == null) return;
    switch (update) {
      case TaskStatusUpdate(:final status, :final exception):
        _events.add(downloadEventFor(id, status, exception?.description));
      case TaskProgressUpdate(:final progress):
        if (progress >= 0 && progress <= 1) {
          _events.add(DownloadProgress(id, progress));
        }
    }
  }

  @override
  Future<bool> enqueue({
    required int episodeId,
    required String url,
    required String fileName,
    required bool wifiOnly,
  }) async => FileDownloader().enqueue(
    DownloadTask(
      taskId: '$_taskPrefix$episodeId',
      url: await resolveProtocolSwitches(_client, url),
      filename: fileName,
      directory: 'episodes',
      baseDirectory: BaseDirectory.applicationSupport,
      group: _group,
      headers: const {'User-Agent': _userAgent},
      updates: Updates.statusAndProgress,
      requiresWiFi: wifiOnly,
      retries: 3,
      allowPause: true,
    ),
  );

  @override
  Future<void> cancel(int episodeId) async {
    await FileDownloader().cancelTaskWithId('$_taskPrefix$episodeId');
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _events.close();
  }

  @override
  Future<Set<int>> activeEpisodeIds() async {
    final tasks = await FileDownloader().allTasks(group: _group);
    return {...tasks.map(_episodeIdOf).nonNulls};
  }
}
