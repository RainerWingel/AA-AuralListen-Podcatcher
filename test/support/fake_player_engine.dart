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

  final calls = <String>[];
  Uri? loadedUri;
  Duration? loadedAt;
  double boostDb = 0;
  Duration fakeDuration = const Duration(minutes: 10);

  /// While true, [load] fails like just_audio without network.
  bool failLoads = false;

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

  /// Simulates the end of the file.
  void complete() => _setState(false, EngineProcessing.completed);

  @override
  Future<Duration?> load(
    Uri uri, {
    Duration initialPosition = Duration.zero,
  }) async {
    calls.add('load');
    if (failLoads) throw Exception('Source error (no network)');
    loadedUri = uri;
    loadedAt = initialPosition;
    _pos = initialPosition;
    _dur = fakeDuration;
    _setState(_current.playing, EngineProcessing.ready);
    _duration.add(fakeDuration);
    return fakeDuration;
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
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _dur = null;
    _setState(false, EngineProcessing.idle);
  }

  @override
  Future<void> setBoostDb(double db) async => boostDb = db;

  @override
  Future<void> dispose() async {
    await _state.close();
    await _position.close();
    await _duration.close();
  }
}
