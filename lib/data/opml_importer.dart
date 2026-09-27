import 'dart:async';

import 'feed/opml.dart';
import 'podcast_repository.dart';

/// Summary shown to the user after an OPML import.
class OpmlImportResult {
  const OpmlImportResult({
    required this.added,
    required this.alreadySubscribed,
    required this.failed,
  });

  final int added;
  final int alreadySubscribed;

  /// Titles (or URLs) of feeds that could not be subscribed.
  final List<String> failed;
}

/// Subscribes to all feeds of an OPML file, a few in parallel.
class OpmlImporter {
  OpmlImporter(this._repository);

  final PodcastRepository _repository;

  static const concurrency = 4;

  /// [onProgress] is called with (done, total) after each feed.
  Future<OpmlImportResult> import(
    List<OpmlFeed> feeds, {
    void Function(int done, int total)? onProgress,
  }) async {
    final queue = feeds.iterator;
    var done = 0;
    var added = 0;
    var already = 0;
    final failed = <String>[];

    Future<void> worker() async {
      while (queue.moveNext()) {
        final feed = queue.current;
        try {
          await _repository.subscribe(feed.url);
          added++;
        } on SubscribeException catch (e) {
          if (e.error == SubscribeError.alreadySubscribed) {
            already++;
          } else {
            failed.add(feed.title ?? feed.url);
          }
        }
        onProgress?.call(++done, feeds.length);
      }
    }

    await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
    return OpmlImportResult(
      added: added,
      alreadySubscribed: already,
      failed: failed,
    );
  }
}
