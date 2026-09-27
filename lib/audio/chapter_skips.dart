import 'dart:async';

/// Where playback continues after a skipped chapter; [to] null = the end of
/// the episode (the last chapter was skipped).
typedef SkipTarget = ({Duration? to});

/// Chapters the user wants to skip, per episode (docs/playback.md).
///
/// In memory only – deliberately not stored in the database, so it is gone
/// after an app restart. Bounded to [maxEpisodes] episodes (least recently
/// changed ones are dropped) so it cannot grow without limit.
class ChapterSkips {
  static const maxEpisodes = 20;

  /// episodeId → {chapter start ms → chapter end ms (null = episode end)}.
  /// Map literals keep insertion order: the first key is the oldest.
  final _byEpisode = <int, Map<int, int?>>{};

  /// Emits the episode id whose skips changed.
  final _changes = StreamController<int>.broadcast();

  /// Start times (ms) of the skipped chapters of [episodeId].
  Set<int> skippedStarts(int episodeId) => {...?_byEpisode[episodeId]?.keys};

  /// The skipped chapters of [episodeId], now and after every change.
  Stream<Set<int>> watch(int episodeId) async* {
    yield skippedStarts(episodeId);
    yield* _changes.stream
        .where((id) => id == episodeId)
        .map((_) => skippedStarts(episodeId));
  }

  /// Marks the chapter [startMs]..[endMs] of [episodeId] as skipped or not.
  /// [endMs] is the start of the next chapter, null for the last chapter.
  void setSkipped(
    int episodeId,
    int startMs, {
    required int? endMs,
    required bool skipped,
  }) {
    // Re-insert so the episode counts as most recently used.
    final chapters = _byEpisode.remove(episodeId) ?? <int, int?>{};
    if (skipped) {
      chapters[startMs] = endMs;
    } else {
      chapters.remove(startMs);
    }
    if (chapters.isNotEmpty) _byEpisode[episodeId] = chapters;
    while (_byEpisode.length > maxEpisodes) {
      _byEpisode.remove(_byEpisode.keys.first);
    }
    if (!_changes.isClosed) _changes.add(episodeId);
  }

  /// If [position] lies in a skipped chapter: where to continue – after that
  /// chapter and any skipped chapters directly following it. Null otherwise.
  SkipTarget? target(int episodeId, Duration position) {
    final chapters = _byEpisode[episodeId];
    if (chapters == null) return null;
    var ms = position.inMilliseconds;
    var moved = false;
    // Each round leaves one skipped chapter; at most one round per chapter.
    for (var round = 0; round <= chapters.length; round++) {
      final hit = chapters.entries.where(
        (c) => c.key <= ms && (c.value == null || ms < c.value!),
      );
      if (hit.isEmpty) break;
      final end = hit.first.value;
      if (end == null) return (to: null);
      ms = end;
      moved = true;
    }
    return moved ? (to: Duration(milliseconds: ms)) : null;
  }

  Future<void> dispose() => _changes.close();
}
