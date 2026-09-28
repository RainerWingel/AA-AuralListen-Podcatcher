import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../data/db/app_database.dart';
import '../data/playback_repository.dart';
import '../data/playlist_repository.dart';
import '../data/settings_keys.dart';
import '../data/settings_repository.dart';
import 'chapter_skips.dart';
import 'player_engine.dart';
import 'sleep_timer.dart';
import 'stream_check.dart';

/// The app's single player (see docs/playback.md).
///
/// audio_service calls the overridden methods (play, pause, rewind …) from the
/// notification, lock screen and Bluetooth buttons; the UI calls the same
/// methods. The handler keeps the database in sync with what is playing.
class PodcastAudioHandler extends BaseAudioHandler with SeekHandler {
  PodcastAudioHandler({
    required this._engine,
    required this._playback,
    required this._settings,
    this._localAudioFile,
    this._playlists,
    this._checkStream,
    this._deleteDownload,
    this.stopAfterPause = const Duration(minutes: 10),
    this.stallCheckInterval = const Duration(seconds: 10),
    this.recoveryRetryDelay = const Duration(seconds: 15),
  }) {
    _subscriptions
      ..add(_engine.stateStream.listen(_onEngineState))
      ..add(
        _engine.positionStream.listen((p) {
          if (_loaded) {
            _knownPosition = p;
            _positions.add(p);
          }
          _onPosition(p);
        }),
      )
      ..add(_engine.durationStream.listen(_onDuration))
      ..add(_engine.errorStream.listen((e) => unawaited(_onEngineError(e))));
    _broadcastState();
  }

  final PlayerEngine _engine;
  final PlaybackRepository _playback;
  final SettingsRepository _settings;

  /// Returns the downloaded file of an episode, if any (DownloadService).
  final Future<File?> Function(int episodeId)? _localAudioFile;

  /// Needed for "continue with the next playlist episode" (docs/playlists.md).
  final PlaylistRepository? _playlists;

  /// Asks the server why a stream failed (only on errors; docs/playback.md).
  final Future<StreamCheck> Function(Uri uri)? _checkStream;

  /// Deletes a broken download (DownloadService.delete).
  final Future<void> Function(int episodeId)? _deleteDownload;

  static const rewindInterval = Duration(seconds: 15);
  static const fastForwardInterval = Duration(seconds: 30);

  /// When resuming, jump back a little to regain context.
  static const resumeRewind = Duration(seconds: 3);

  /// Minimum distance between two position writes to the database.
  static const saveInterval = Duration(seconds: 5);

  /// From this share of the duration on, an episode counts as played.
  static const playedThreshold = 0.98;

  /// A long pause releases the player and ends the foreground service.
  final Duration stopAfterPause;

  /// Hang detection (docs/playback.md): while playing, the position is
  /// checked this often; [stallChecks] checks without progress = hanging.
  final Duration stallCheckInterval;
  static const stallChecks = 3;

  /// Reload attempts before giving up, and the wait after a failed load.
  static const maxRecoveries = 3;
  final Duration recoveryRetryDelay;

  Timer? _watchdog;
  Timer? _retryTimer;
  Duration? _watchdogPosition;
  int _stalledChecks = 0;
  int _recoveries = 0;
  bool _recovering = false;

  /// What was loaded last (to tell a broken download from a network error).
  Uri? _source;
  bool _sourceIsLocal = false;

  /// Episode whose download turned out broken: stream it instead.
  int? _noLocalFileFor;

  /// A load failed although the server answered: try once more, then it
  /// counts as an unplayable format.
  bool _retriedReachable = false;

  /// The load in progress, shared by concurrent callers (user taps Play
  /// while a recovery is loading) – never two loads at once.
  Future<void>? _loadInFlight;

  final _problems = StreamController<PlaybackProblem>.broadcast();

  // Sleep timer: counts playing time only; one Timer while playing.
  SleepTimer _sleepTimer = const SleepTimerOff();
  final _sleepPlayed = Stopwatch();
  Timer? _sleepAlarm;
  final _sleepStates = StreamController<SleepTimerState>.broadcast();

  /// Whether the hang-detection timer runs (only while playing).
  @visibleForTesting
  bool get watchdogActive => _watchdog != null;

  /// Problems the user should be told about (info box in the app shell).
  Stream<PlaybackProblem> get problems => _problems.stream;

  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _pauseTimer;

  int? _episodeId;

  /// Playlist the current episode was started from, and the episode's
  /// position in it (kept after the episode was removed at 98 %).
  int? _activePlaylistId;
  int _playlistPosition = -1;

  bool _loaded = false;
  bool _markedPlayed = false;
  bool _completing = false;
  bool _skipping = false;

  /// Chapters marked "Skip" – in memory only (docs/playback.md).
  final chapterSkips = ChapterSkips();
  Duration _lastSaved = Duration.zero;

  /// Last position the player reported while loaded. After a playback error
  /// just_audio's own `position` falls back to its last *state* change –
  /// in the background that can be minutes (or the whole episode) earlier
  /// (bug 2026-09-28: recovery restarted from the beginning).
  Duration _knownPosition = Duration.zero;

  /// Position shown while no audio is loaded (after app start, after stop).
  Duration _idlePosition = Duration.zero;

  /// The user moved the position while unloaded: start exactly there
  /// instead of [resumeRewind] earlier.
  bool _exactStart = false;

  final _positions = StreamController<Duration>.broadcast();

  int? get currentEpisodeId => _episodeId;

  int? get activePlaylistId => _activePlaylistId;

  /// Current position – also correct while no audio is loaded.
  Duration get position => _loaded ? _engine.position : _idlePosition;

  /// Position updates for progress bars. Starts with the current position,
  /// so a freshly opened player shows the right place immediately.
  Stream<Duration> get positionStream async* {
    yield position;
    yield* _positions.stream;
  }

  // ------------------------------------------------------------ public API

  /// Current sleep timer with the playing time left.
  SleepTimerState get sleepTimerState => switch (_sleepTimer) {
    SleepTimerAfter(:final duration) => SleepTimerState(
      _sleepTimer,
      remaining: duration > _sleepPlayed.elapsed
          ? duration - _sleepPlayed.elapsed
          : Duration.zero,
    ),
    final timer => SleepTimerState(timer),
  };

  /// Sleep timer now and after every change (not every second – the UI
  /// computes the countdown from [sleepTimerState] while it is visible).
  Stream<SleepTimerState> get sleepTimerStream async* {
    yield sleepTimerState;
    yield* _sleepStates.stream;
  }

  /// Sets or clears the sleep timer (docs/playback.md). Minutes count only
  /// while playing; [SleepTimerAtEpisodeEnd] stops after this episode.
  void setSleepTimer(SleepTimer timer) {
    _sleepAlarm?.cancel();
    _sleepAlarm = null;
    _sleepPlayed
      ..stop()
      ..reset();
    _sleepTimer = timer;
    _updateSleepTimer(_engine.state.playing && _loaded);
    _emitSleepState();
  }

  /// Shows the last episode in the mini player after an app start, without
  /// loading audio (no network until the user presses play).
  Future<void> restoreLastEpisode() async {
    final id = await _settings.getInt(SettingsKeys.lastEpisodeId);
    if (id == null || _episodeId != null) return;
    final row = await _playback.load(id);
    if (row == null) return;
    _episodeId = id;
    final saved = (await _settings.get(SettingsKeys.activePlaylistId))
        ?.split(':');
    if (saved != null && saved.length == 2) {
      _activePlaylistId = int.tryParse(saved[0]);
      _playlistPosition = int.tryParse(saved[1]) ?? -1;
    }
    mediaItem.add(_withPlaylist(_toMediaItem(row)));
    _setIdlePosition(_savedPosition(row.episode));
    _broadcastState();
  }

  /// Starts [episodeId] (resuming at its saved position, or exactly at
  /// [startAt], e.g. a bookmark). With [playlistId]
  /// the playlist becomes active: when the episode ends, the next one of that
  /// playlist starts. Without it, playback stops at the end.
  Future<void> playEpisode(
    int episodeId, {
    int? playlistId,
    Duration? startAt,
  }) async {
    _resetRecovery();
    await _setActivePlaylist(episodeId, playlistId);
    if (episodeId == _episodeId && _loaded) {
      mediaItem.add(_withPlaylist(mediaItem.value));
      if (startAt != null) await seek(startAt);
      return play();
    }

    await _saveCurrentPosition();
    var row = await _playback.load(episodeId);
    if (row == null) return;

    if (startAt != null) {
      // E.g. from a bookmark: start exactly there (played episodes too).
      if (row.episode.status == EpisodeStatus.played) {
        await _playback.restartPlayed(episodeId);
      }
      await _playback.savePosition(episodeId, startAt);
      row = await _playback.load(episodeId);
      if (row == null) return;
    }

    _episodeId = episodeId;
    _loaded = false;
    _exactStart = startAt != null;
    mediaItem.add(_withPlaylist(_toMediaItem(row)));
    _setIdlePosition(_savedPosition(row.episode));
    await _settings.set(SettingsKeys.lastEpisodeId, '$episodeId');
    await play();
  }

  /// Applies a new boost level: for the current podcast only, or globally.
  Future<void> setBoost(double db, {required bool forPodcastOnly}) async {
    final podcastId = _currentPodcastId;
    if (forPodcastOnly && podcastId != null) {
      await _playback.setPodcastBoost(podcastId, db);
    } else {
      await _settings.set(SettingsKeys.boostDb, '$db');
      if (podcastId != null) await _playback.setPodcastBoost(podcastId, null);
    }
    await _engine.setBoostDb(db);
  }

  /// After a backup was restored: forget the current episode (its id may now
  /// mean something else) and show the restored "last episode" instead.
  Future<void> resetAfterRestore() async {
    await stop();
    _episodeId = null;
    _activePlaylistId = null;
    _playlistPosition = -1;
    _setIdlePosition(Duration.zero);
    mediaItem.add(null);
    _broadcastState();
    await restoreLastEpisode();
  }

  /// Marks a chapter as skipped (or not). If playback is inside it right
  /// now, it jumps ahead at once. [endMs]: next chapter's start, null for
  /// the last chapter (skipping it ends the episode).
  Future<void> setChapterSkipped(
    int episodeId,
    int startMs, {
    required int? endMs,
    required bool skipped,
  }) async {
    chapterSkips.setSkipped(episodeId, startMs, endMs: endMs, skipped: skipped);
    if (skipped && episodeId == _episodeId && _loaded) {
      await _onPosition(_engine.position);
    }
  }

  /// Removes the podcast's own boost; the global default applies again.
  Future<void> clearPodcastBoost() async {
    final podcastId = _currentPodcastId;
    if (podcastId == null) return;
    await _playback.setPodcastBoost(podcastId, null);
    await _engine.setBoostDb(
      await _settings.getDouble(SettingsKeys.boostDb) ?? 0,
    );
  }

  // ------------------------------------------------ audio_service overrides

  /// "Next" in the notification / full player: next playlist episode. The
  /// current one is NOT marked as played and stays in the playlist.
  @override
  Future<void> skipToNext() async {
    final next = await _nextInPlaylist();
    if (next != null) await playEpisode(next, playlistId: _activePlaylistId);
  }

  @override
  Future<void> play() async {
    final error = await _tryPlay();
    if (error != null) await _handleFailure(error, _Retry.none);
  }

  /// Loads if needed and plays. Returns the load error (null = playing or
  /// nothing to play) – never throws.
  Future<Object?> _tryPlay() async {
    if (_episodeId == null) return null;
    _pauseTimer?.cancel();
    if (!_loaded) {
      try {
        await (_loadInFlight ??= _load().whenComplete(
          () => _loadInFlight = null,
        ));
      } on Exception catch (e) {
        _loaded = false;
        _broadcastState();
        return e;
      }
    }
    if (!_loaded) return null; // episode vanished (e.g. unsubscribed)
    await _engine.play();
    // just_audio emits no event if it was already playing (e.g. when switching
    // episodes), so report the state ourselves.
    _broadcastState();
    return null;
  }

  @override
  Future<void> pause() async {
    _resetRecovery();
    await _engine.pause();
    _broadcastState();
    await _saveCurrentPosition();
    _pauseTimer?.cancel();
    _pauseTimer = Timer(stopAfterPause, stop);
  }

  @override
  Future<void> seek(Duration position) async {
    final id = _episodeId;
    if (id == null) return;
    if (_loaded) {
      _knownPosition = position;
      try {
        await _engine.seek(position);
      } on Exception {
        return; // player failed (e.g. offline) – the error handling reloads
      }
      await _saveCurrentPosition();
      return;
    }
    // Nothing loaded (e.g. after app start): just move the saved position.
    final target = _clamp(position);
    _exactStart = true;
    _setIdlePosition(target);
    _broadcastState();
    await _playback.savePosition(id, target);
  }

  @override
  Future<void> rewind() => seek(_clamp(position - rewindInterval));

  @override
  Future<void> fastForward() => seek(_clamp(position + fastForwardInterval));

  @override
  Future<void> stop() async {
    _pauseTimer?.cancel();
    _resetRecovery();
    await _saveCurrentPosition();
    // Keep showing where playback stopped (0 if the episode was finished).
    _setIdlePosition(_markedPlayed ? Duration.zero : _engine.position);
    await _engine.stop();
    _loaded = false;
    _broadcastState();
  }

  /// App swiped away in the task switcher: keep playing, otherwise clean up.
  @override
  Future<void> onTaskRemoved() async {
    if (!_engine.state.playing) await stop();
  }

  /// Releases everything (tests and app shutdown).
  Future<void> dispose() async {
    _pauseTimer?.cancel();
    _sleepAlarm?.cancel();
    _watchdog?.cancel();
    _retryTimer?.cancel();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    await _positions.close();
    await _problems.close();
    await _sleepStates.close();
    await chapterSkips.dispose();
    await _engine.dispose();
  }

  // --------------------------------------------------------------- internals

  Future<void> _setActivePlaylist(int episodeId, int? playlistId) async {
    final position = playlistId == null
        ? null
        : await _playlists?.positionOf(playlistId, episodeId);
    if (playlistId == null || position == null) {
      _activePlaylistId = null;
      _playlistPosition = -1;
      await _settings.remove(SettingsKeys.activePlaylistId);
    } else {
      _activePlaylistId = playlistId;
      _playlistPosition = position;
      await _settings.set(
        SettingsKeys.activePlaylistId,
        '$playlistId:$position',
      );
    }
  }

  /// Marks as played (also removes it from all playlists). The playlist
  /// position is refreshed first, in case the user reordered meanwhile.
  Future<void> _markPlayed(int episodeId) async {
    final playlistId = _activePlaylistId;
    if (playlistId != null) {
      final position = await _playlists?.positionOf(playlistId, episodeId);
      if (position != null) _playlistPosition = position;
    }
    await _playback.markPlayed(episodeId);
  }

  /// Next episode of the active playlist, read from the DB right now.
  Future<int?> _nextInPlaylist() async {
    final playlistId = _activePlaylistId;
    final current = _episodeId;
    if (playlistId == null || _playlists == null) return null;
    if (current != null) {
      final position = await _playlists.positionOf(playlistId, current);
      if (position != null) _playlistPosition = position;
    }
    return (await _playlists.nextAfter(
      playlistId,
      _playlistPosition,
    ))?.episodeId;
  }

  MediaItem? _withPlaylist(MediaItem? item) => item?.copyWith(
    extras: {...?item.extras, 'playlistId': _activePlaylistId},
  );

  int? get _currentPodcastId => mediaItem.value?.extras?['podcastId'] as int?;

  Duration _clamp(Duration position) {
    final max = _loaded ? _engine.duration : mediaItem.value?.duration;
    if (position < Duration.zero) return Duration.zero;
    if (max != null && position > max) return max;
    return position;
  }

  Future<void> _load() async {
    final id = _episodeId!;
    final row = await _playback.load(id);
    if (row == null) return;

    var episode = row.episode;
    if (episode.status == EpisodeStatus.played) {
      await _playback.restartPlayed(id);
      episode = episode.copyWith(
        status: EpisodeStatus.inProgress,
        positionMs: 0,
      );
    }

    final saved = Duration(milliseconds: episode.positionMs);
    final start = _exactStart
        ? saved
        : saved > resumeRewind
        ? saved - resumeRewind
        : Duration.zero;
    _exactStart = false;

    // Downloaded file first (unless it turned out broken), otherwise stream.
    final local = _noLocalFileFor == id
        ? null
        : await _localAudioFile?.call(id);
    final source = local != null
        ? Uri.file(local.path)
        : Uri.parse(episode.audioUrl);
    _source = source;
    _sourceIsLocal = local != null;
    await _engine.load(source, initialPosition: start);
    _knownPosition = start;
    _retriedReachable = false;
    await _engine.setBoostDb(await _boostFor(row.podcast));

    _loaded = true;
    _broadcastState();
    _markedPlayed = false;
    _lastSaved = start;
  }

  /// Where playback would continue; played episodes start over.
  Duration _savedPosition(Episode episode) =>
      episode.status == EpisodeStatus.played
      ? Duration.zero
      : Duration(milliseconds: episode.positionMs);

  void _setIdlePosition(Duration position) {
    _idlePosition = position;
    if (!_positions.isClosed) _positions.add(position);
  }

  Future<double> _boostFor(Podcast podcast) async =>
      podcast.boostDb ?? await _settings.getDouble(SettingsKeys.boostDb) ?? 0;

  Future<void> _saveCurrentPosition() async {
    final id = _episodeId;
    if (id == null || !_loaded || _markedPlayed) return;
    final position = _engine.position;
    _lastSaved = position;
    await _playback.savePosition(id, position);
  }

  Future<void> _onPosition(Duration position) async {
    final id = _episodeId;
    if (id == null || !_loaded || _markedPlayed) return;

    final duration = _engine.duration;
    if (!_skipping) {
      final skip = chapterSkips.target(id, position);
      if (skip != null) return _skipTo(skip.to, duration);
    }
    if (duration != null &&
        duration > Duration.zero &&
        position.inMilliseconds >= duration.inMilliseconds * playedThreshold) {
      _markedPlayed = true;
      await _markPlayed(id);
      return;
    }
    if ((position - _lastSaved).abs() >= saveInterval) {
      _lastSaved = position;
      await _playback.savePosition(id, position);
    }
  }

  /// Leaves a skipped chapter: seek behind it, or finish the episode if it
  /// was the last one (counts as played, playlist continues).
  Future<void> _skipTo(Duration? to, Duration? duration) async {
    _skipping = true;
    try {
      if (to == null || (duration != null && to >= duration)) {
        await _complete();
      } else {
        await _engine.seek(to);
        await _saveCurrentPosition();
        _broadcastState();
      }
    } finally {
      _skipping = false;
    }
  }

  Future<void> _onDuration(Duration? duration) async {
    final id = _episodeId;
    final item = mediaItem.value;
    if (id == null || duration == null || duration <= Duration.zero) return;
    if (item != null && item.duration != duration) {
      mediaItem.add(item.copyWith(duration: duration));
    }
    await _playback.updateDuration(id, duration);
  }

  Future<void> _onEngineState(EngineState state) async {
    _broadcastState();
    if (state.processing == EngineProcessing.completed) await _complete();
  }

  /// End of the episode: mark played, unload, continue with the playlist.
  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    try {
      final id = _episodeId;
      if (id != null && !_markedPlayed) {
        _markedPlayed = true;
        await _markPlayed(id);
      }
      await stop();
      if (_sleepTimer is SleepTimerAtEpisodeEnd) {
        // Sleep timer "Bis Ende der Folge": stay stopped, then it is off.
        setSleepTimer(const SleepTimerOff());
        return;
      }
      final next = await _nextInPlaylist();
      if (next != null) {
        await playEpisode(next, playlistId: _activePlaylistId);
      }
    } finally {
      _completing = false;
    }
  }

  // --------------------------------------------------------- sleep timer

  /// Counts playing time: the stopwatch and the alarm run only while playing.
  void _updateSleepTimer(bool playing) {
    final timer = _sleepTimer;
    if (timer is! SleepTimerAfter) return;
    if (playing && !_sleepPlayed.isRunning) {
      _sleepPlayed.start();
      final left = timer.duration - _sleepPlayed.elapsed;
      _sleepAlarm = Timer(
        left > Duration.zero ? left : Duration.zero,
        () => unawaited(_onSleepAlarm()),
      );
    } else if (!playing && _sleepPlayed.isRunning) {
      _sleepPlayed.stop();
      _sleepAlarm?.cancel();
      _sleepAlarm = null;
      _emitSleepState(); // remaining time is frozen now
    }
  }

  Future<void> _onSleepAlarm() async {
    setSleepTimer(const SleepTimerOff());
    await pause();
  }

  void _emitSleepState() {
    if (!_sleepStates.isClosed) _sleepStates.add(sleepTimerState);
  }

  // ------------------------------------------------------ hang detection

  /// Runs the watchdog timer only while audio is playing (no cost otherwise).
  void _updateWatchdog(bool playing) {
    if (playing) {
      _watchdog ??= Timer.periodic(stallCheckInterval, (_) => _checkStall());
    } else {
      _watchdog?.cancel();
      _watchdog = null;
      _watchdogPosition = null;
      _stalledChecks = 0;
    }
  }

  void _checkStall() {
    if (_recovering || _completing || !_loaded) return;
    final position = _engine.position;
    if (position != _watchdogPosition) {
      _watchdogPosition = position;
      _stalledChecks = 0;
      _recoveries = 0; // it plays again: a later hang gets fresh attempts
      return;
    }
    if (++_stalledChecks >= stallChecks) {
      _stalledChecks = 0;
      unawaited(_recover());
    }
  }

  /// The player failed (e.g. network timeout while streaming). just_audio
  /// then shuts its native player down; resuming that one later plays audio
  /// but freezes the position. So: keep the position, release the player
  /// and load fresh – right away if it was playing (with the hang
  /// detection's retries), otherwise on the next Play.
  Future<void> _onEngineError(EngineException error) async {
    final id = _episodeId;
    if (id == null || !_loaded || _recovering) return;
    // Read before just_audio pauses itself in reaction to the error.
    final wasPlaying = _engine.state.playing || _watchdog != null;
    final position = _knownPosition;
    if (!_markedPlayed) await _playback.savePosition(id, position);
    await _engine.stop();
    _loaded = false;
    _exactStart = true;
    _setIdlePosition(position);
    _broadcastState();
    if (wasPlaying) await _handleFailure(error, _Retry.now);
  }

  // ------------------------------------------------------- error kinds

  /// Reacts to a failed load or playback error by its cause:
  /// broken download → delete it and stream; episode gone / unplayable
  /// format → stop and say so; network → retry per [retry].
  Future<void> _handleFailure(Object error, _Retry retry) async {
    final id = _episodeId;
    if (id == null) return;
    final kind = error is EngineException ? error.kind : EngineErrorKind.other;
    switch (await _classify(kind, midPlayback: retry == _Retry.now)) {
      case _Failure.brokenDownload:
        _noLocalFileFor = id;
        await _deleteDownload?.call(id);
        _emitProblem(PlaybackProblem.brokenDownload);
        final again = await _tryPlay(); // streams now
        if (again != null) await _handleFailure(again, retry);
      case _Failure.retryOnce:
        _retriedReachable = true;
        final again = await _tryPlay();
        if (again != null) await _handleFailure(again, retry);
      case _Failure.gone:
        _stopFor(PlaybackProblem.episodeGone);
      case _Failure.unsupported:
        _stopFor(PlaybackProblem.unsupportedFormat);
      case _Failure.network:
        switch (retry) {
          case _Retry.none:
            _emitProblem(PlaybackProblem.loadFailed);
          case _Retry.now:
            await _recover();
          case _Retry.later:
            _retryTimer = Timer(
              recoveryRetryDelay,
              () => unawaited(_recover()),
            );
        }
    }
  }

  Future<_Failure> _classify(
    EngineErrorKind kind, {
    required bool midPlayback,
  }) async {
    // A local file never needs the network.
    if (_sourceIsLocal) return _Failure.brokenDownload;
    if (kind == EngineErrorKind.renderer) return _Failure.unsupported;
    final source = _source;
    final check = _checkStream;
    if (source == null || check == null) return _Failure.network;
    return switch (await check(source)) {
      StreamCheck.gone => _Failure.gone,
      StreamCheck.offline || StreamCheck.serverError => _Failure.network,
      // Server fine: mid-playback it was a hiccup (retry); a load failing
      // twice although the server answers means the data is unplayable.
      StreamCheck.reachable =>
        midPlayback
            ? _Failure.network
            : _retriedReachable
            ? _Failure.unsupported
            : _Failure.retryOnce,
    };
  }

  /// No retry makes sense: stay stopped (position kept) and tell the user.
  void _stopFor(PlaybackProblem problem) {
    _resetRecovery();
    _broadcastState();
    _emitProblem(problem);
  }

  /// Reloads the episode at the current position. Gives up after
  /// [maxRecoveries] attempts: stops cleanly and tells the user.
  Future<void> _recover() async {
    _retryTimer?.cancel();
    final id = _episodeId;
    if (id == null || _recovering) return;
    _recovering = true;
    try {
      if (_recoveries >= maxRecoveries) {
        _resetRecovery();
        // Loaded: stop saves the position. Not loaded (every reload failed):
        // the position is already saved and shown – just report "stopped".
        if (_loaded) {
          await stop();
        } else {
          _broadcastState();
        }
        _emitProblem(PlaybackProblem.stalled);
        return;
      }
      _recoveries++;
      final position = _loaded ? _knownPosition : _idlePosition;
      if (!_markedPlayed) await _playback.savePosition(id, position);
      await _engine.stop();
      _loaded = false;
      _setIdlePosition(position);
      _exactStart = true;
      final error = await _tryPlay();
      if (error != null) await _handleFailure(error, _Retry.later);
    } finally {
      _recovering = false;
    }
  }

  /// A user action (pause, stop, other episode) ends any recovery.
  void _resetRecovery() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _recoveries = 0;
    _stalledChecks = 0;
  }

  void _emitProblem(PlaybackProblem problem) {
    if (!_problems.isClosed) _problems.add(problem);
  }

  void _broadcastState() {
    final state = _engine.state;
    final playing = state.playing && _loaded;
    _updateWatchdog(playing);
    _updateSleepTimer(playing);
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          if (_activePlaylistId != null) MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.rewind,
          MediaAction.fastForward,
          MediaAction.skipToNext,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: !_loaded
            ? AudioProcessingState.idle
            : switch (state.processing) {
                EngineProcessing.idle => AudioProcessingState.idle,
                EngineProcessing.loading => AudioProcessingState.loading,
                EngineProcessing.buffering => AudioProcessingState.buffering,
                EngineProcessing.ready => AudioProcessingState.ready,
                EngineProcessing.completed => AudioProcessingState.completed,
              },
        playing: playing,
        updatePosition: position,
        bufferedPosition: _engine.bufferedPosition,
      ),
    );
  }

  MediaItem _toMediaItem(EpisodeWithPodcast row) {
    final e = row.episode;
    final p = row.podcast;
    final image = e.imageUrl ?? p.imageUrl;
    return MediaItem(
      id: '${e.id}',
      title: e.title,
      album: p.title,
      artist: p.author ?? p.title,
      artUri: image == null ? null : Uri.tryParse(image),
      duration: e.durationMs == null
          ? null
          : Duration(milliseconds: e.durationMs!),
      extras: {'episodeId': e.id, 'podcastId': p.id},
    );
  }
}

/// Why playback could not continue (shown as an info box).
enum PlaybackProblem {
  /// The episode could not be loaded (no network, server error).
  loadFailed,

  /// Playback hung and reloading did not help.
  stalled,

  /// The downloaded file was broken; it was deleted and is streamed now.
  brokenDownload,

  /// The server no longer offers the episode (404/410 …).
  episodeGone,

  /// The file cannot be played (format/decoder).
  unsupportedFormat,
}

/// Cause of a failure, see [PodcastAudioHandler._handleFailure].
enum _Failure { brokenDownload, retryOnce, gone, unsupported, network }

/// When to retry network failures: not at all (user tapped Play – just
/// report it), now (error during playback), or after a pause (reload failed).
enum _Retry { none, now, later }
