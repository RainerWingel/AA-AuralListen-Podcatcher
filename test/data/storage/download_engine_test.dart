import 'package:aapodcastguru/data/storage/download_engine.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every downloader status maps to the right event', () {
    DownloadEvent of(TaskStatus status) => downloadEventFor(7, status, null);

    expect(of(TaskStatus.running), isA<DownloadStarted>());
    expect(of(TaskStatus.complete), isA<DownloadCompleted>());
    expect(of(TaskStatus.canceled), isA<DownloadCanceled>());
    expect(of(TaskStatus.failed), isA<DownloadFailed>());
    expect(of(TaskStatus.notFound), isA<DownloadFailed>());
    // Waiting for Wi-Fi / network / retry is not "0 % progress" (that ring
    // was invisible, user report 2026-10-05).
    for (final waiting in [
      TaskStatus.enqueued,
      TaskStatus.waitingToRetry,
      TaskStatus.paused,
    ]) {
      expect(of(waiting), isA<DownloadWaiting>(), reason: waiting.name);
    }
    expect(of(TaskStatus.enqueued).episodeId, 7);
  });

  test('a failure keeps the error description', () {
    final event = downloadEventFor(1, TaskStatus.failed, 'HTTP 503');
    expect((event as DownloadFailed).reason, 'HTTP 503');
  });
}
