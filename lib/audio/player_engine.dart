import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../core/app_info.dart';

enum EngineProcessing { idle, loading, buffering, ready, completed }

class EngineState {
  const EngineState({required this.playing, required this.processing});

  static const idle = EngineState(
    playing: false,
    processing: EngineProcessing.idle,
  );

  final bool playing;
  final EngineProcessing processing;
}

/// Kind of a player failure (just_audio only reports ExoPlayer's type).
enum EngineErrorKind {
  /// Loading the data failed (network, server, missing/broken file).
  source,

  /// The decoder failed (e.g. unsupported format, broken data).
  renderer,

  /// Anything else.
  other,
}

/// A failed load or a playback error of the engine.
class EngineException implements Exception {
  const EngineException(this.kind, [this.message]);

  final EngineErrorKind kind;
  final String? message;

  @override
  String toString() => 'EngineException(${kind.name}): $message';
}

/// The raw audio player, behind an interface so the playback logic in
/// [PodcastAudioHandler] can be unit-tested with a fake (think: IAudioPlayer).
abstract interface class PlayerEngine {
  Stream<EngineState> get stateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  /// Playback errors (e.g. network timeout while streaming). Afterwards the
  /// engine is unusable until the next [load].
  Stream<EngineException> get errorStream;

  EngineState get state;
  Duration get position;
  Duration get bufferedPosition;
  Duration? get duration;

  /// Prepares [uri] (http(s) or file) and returns its duration if known.
  /// Throws [EngineException] if it cannot be loaded.
  Future<Duration?> load(Uri uri, {Duration initialPosition = Duration.zero});

  /// Starts playback. Returns immediately (does not wait until playback ends).
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);

  /// Releases the decoder/network; [load] is needed before playing again.
  Future<void> stop();

  /// Loudness boost in dB; 0 disables it. Android only.
  Future<void> setBoostDb(double db);

  /// Playback volume 0…1 (sleep timer fade-out); independent of the boost.
  Future<void> setVolume(double volume);

  Future<void> dispose();
}

/// [PlayerEngine] based on just_audio (ExoPlayer on Android).
class JustAudioEngine implements PlayerEngine {
  JustAudioEngine() {
    _player = AudioPlayer(
      userAgent: appUserAgent,
      // Send the user agent natively via ExoPlayer. The default routes every
      // stream through just_audio's local HTTP proxy inside the app: extra
      // work, uncaught errors when offline, and ExoPlayer then times out
      // against the proxy instead of waiting for the network.
      useProxyForRequestHeaders: false,
      audioPipeline: _enhancer == null
          ? null
          : AudioPipeline(androidAudioEffects: [_enhancer]),
    );
  }

  final AndroidLoudnessEnhancer? _enhancer = Platform.isAndroid
      ? AndroidLoudnessEnhancer()
      : null;
  late final AudioPlayer _player;

  static EngineState _map(PlayerState s) => EngineState(
    playing: s.playing,
    processing: switch (s.processingState) {
      ProcessingState.idle => EngineProcessing.idle,
      ProcessingState.loading => EngineProcessing.loading,
      ProcessingState.buffering => EngineProcessing.buffering,
      ProcessingState.ready => EngineProcessing.ready,
      ProcessingState.completed => EngineProcessing.completed,
    },
  );

  @override
  Stream<EngineState> get stateStream => _player.playerStateStream.map(_map);

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<EngineException> get errorStream =>
      _player.errorStream.map(_toEngineException);

  /// ExoPlayer's type as sent by just_audio: 0 source, 1 renderer.
  static EngineException _toEngineException(PlayerException e) =>
      EngineException(switch (e.code) {
        0 => EngineErrorKind.source,
        1 => EngineErrorKind.renderer,
        _ => EngineErrorKind.other,
      }, e.message);

  @override
  EngineState get state => _map(_player.playerState);

  @override
  Duration get position => _player.position;

  @override
  Duration get bufferedPosition => _player.bufferedPosition;

  @override
  Duration? get duration => _player.duration;

  @override
  Future<Duration?> load(
    Uri uri, {
    Duration initialPosition = Duration.zero,
  }) async {
    try {
      return await _player.setAudioSource(
        AudioSource.uri(uri),
        initialPosition: initialPosition,
      );
    } on PlayerException catch (e) {
      throw _toEngineException(e);
    }
  }

  @override
  Future<void> play() {
    // just_audio's play() completes only when playback pauses/stops.
    unawaited(_player.play());
    return Future.value();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setBoostDb(double db) async {
    final enhancer = _enhancer;
    if (enhancer == null) return;
    await enhancer.setTargetGain(db);
    await enhancer.setEnabled(db > 0);
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> dispose() => _player.dispose();
}
