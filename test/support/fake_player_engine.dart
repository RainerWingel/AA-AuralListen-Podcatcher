import 'dart:async';

import 'package:aapodcastguru/audio/player_engine.dart';

/// Scriptable [PlayerEngine] for tests: records calls, lets the test emit
/// positions, durations and completion.
///
/// Mimics just_audio where it matters: loading a new source keeps the
/// "playing" flag, and play() while already playing emits no state event.
class FakePlayerEngine implements PlayerEngine {
  final _state = StreamController<EngineState>.broadcast(sync: true);
  final _position = StreamController<Duration>.broadcast(sync: true);
  final _duration = StreamController<Duration?>.broadcast(sync: true);
  final _errors = StreamController<EngineException>.broadcast(sync: true);

  final calls = <String>[];
  Uri? loadedUri;
  Duration? loadedAt;
  double boostDb = 0;
  Duration fakeDuration = const Duration(minutes: 10);

  /// Duration reported by loads without exact MP3 seeking (null = same as
  /// [fakeDuration]) – simulates ExoPlayer's estimate for VBR files.
  Duration? estimatedDuration;

  /// [load]'s exactMp3Seeking flag of every load, in order.
  final exactLoads = <bool>[];

  /// While true, [load] fails like just_audio without network.
  bool failLoads = false;

  /// The next [failNextLoads] loads fail, then loading works again.
  int failNextLoads = 0;

  /// Local files fail to load (broken download).
  bool failFileLoads = false;

  /// Kind of the load failures above (renderer = unplayable format).
  EngineErrorKind loadErrorKind = EngineErrorKind.source;

  /// While true, seek never completes (just_audio offline after an error).
  bool hangSeeks = false;

  /// Simulates slow loading (e.g. waiting for the network).
  Duration loadDelay = Duration.zero;

  EngineState _current = EngineState.idle;
  Duration _pos = Duration.zero;
  Duration? _dur;

  @override
  Stream<EngineState> get stateStream => _state.stream;
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<Duration?> get durationStream => _duration.stream;
  @override
  Stream<EngineException> get errorStream => _errors.stream;
  @override
  EngineState get state => _current;
  @override
  Duration get position => _pos;
  @override
  Duration get bufferedPosition => _pos;
  @override
  Duration? get duration => _dur;

  void _setState(bool playing, EngineProcessing processing) {
    _current = EngineState(playing: playing, processing: processing);
    _state.add(_current);
  }

  /// Simulates playback progress.
  void emitPosition(Duration position) {
    _pos = position;
    _position.add(position);
  }

  /// Simulates a playback error like just_audio: error event, then the
  /// player is idle and paused. [staleAfterError]: what just_audio's
  /// `position` then reports – its last state change, not the real place.
  Duration? staleAfterError;

  void emitError([
    EngineException error = const EngineException(
      EngineErrorKind.source,
      'SocketTimeoutException',
    ),
  ]) {
    if (staleAfterError case final stale?) _pos = stale;
    _errors.add(error);
    _setState(false, EngineProcessing.idle);
  }

  /// Simulates the end of the file.
  void complete() => _setState(false, EngineProcessing.completed);

  @override
  Future<Duration?> load(
    Uri uri, {
    Duration initialPosition = Duration.zero,
    bool exactMp3Seeking = false,
  }) async {
    calls.add('load');
    exactLoads.add(exactMp3Seeking);
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    final failOnce = failNextLoads > 0;
    if (failOnce) failNextLoads--;
    if (failOnce || failLoads || (failFileLoads && uri.isScheme('file'))) {
      throw EngineException(loadErrorKind, 'Source error');
    }
    loadedUri = uri;
    loadedAt = initialPosition;
    _pos = initialPosition;
    final duration = exactMp3Seeking
        ? fakeDuration
        : estimatedDuration ?? fakeDuration;
    _dur = duration;
    _setState(_current.playing, EngineProcessing.ready);
    _duration.add(duration);
    return duration;
  }

  @override
  Future<void> play() async {
    calls.add('play');
    if (!_current.playing) _setState(true, EngineProcessing.ready);
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    _setState(false, _current.processing);
  }

  @override
  Future<void> seek(Duration position) async {
    calls.add('seek');
    _pos = position;
    // just_audio reports the new position right away, but asynchronously
    // (a seek may happen while a position event is being delivered).
    scheduleMicrotask(() {
      if (!_position.isClosed) _position.add(position);
    });
    if (hangSeeks) await Completer<void>().future;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _dur = null;
    _setState(false, EngineProcessing.idle);
  }

  @override
  Future<void> setBoostDb(double db) async => boostDb = db;

  /// Current volume and every value set (sleep timer fade-out).
  double volume = 1;
  final volumes = <double>[];

  @override
  Future<void> setVolume(double value) async {
    volume = value;
    volumes.add(value);
    if (value == 1) calls.add('volume full');
    if (value == 0) calls.add('volume zero');
  }

  @override
  Future<void> dispose() async {
    await _state.close();
    await _position.close();
    await _duration.close();
    await _errors.close();
  }
}
