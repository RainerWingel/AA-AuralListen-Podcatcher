import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';

import '../data/db/app_database.dart';
import '../data/playback_repository.dart';
import '../data/settings_keys.dart';
import '../data/settings_repository.dart';
import 'player_engine.dart';

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
    this.stopAfterPause = const Duration(minutes: 10),
  }) {
    _subscriptions
      ..add(_engine.stateStream.listen(_onEngineState))
      ..add(
        _engine.positionStream.listen((p) {
          if (_loaded) _positions.add(p);
          _onPosition(p);
        }),
      )
      ..add(_engine.durationStream.listen(_onDuration));
    _broadcastState();
  }

  final PlayerEngine _engine;
  final PlaybackRepository _playback;
  final SettingsRepository _settings;

  /// Returns the downloaded file of an episode, if any (DownloadService).
  final Future<File?> Function(int episodeId)? _localAudioFile;

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

  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _pauseTimer;

  int? _episodeId;
  bool _loaded = false;
  bool _markedPlayed = false;
  bool _completing = false;
  Duration _lastSaved = Duration.zero;

  /// Position shown while no audio is loaded (after app start, after stop).
  Duration _idlePosition = Duration.zero;

  /// The user moved the position while unloaded: start exactly there
  /// instead of [resumeRewind] earlier.
  bool _exactStart = false;

  final _positions = StreamController<Duration>.broadcast();

  int? get currentEpisodeId => _episodeId;

  /// Current position – also correct while no audio is loaded.
  Duration get position => _loaded ? _engine.position : _idlePosition;

  /// Position updates for progress bars. Starts with the current position,
  /// so a freshly opened player shows the right place immediately.
  Stream<Duration> get positionStream async* {
    yield position;
    yield* _positions.stream;
  }

  // ------------------------------------------------------------ public API

  /// Shows the last episode in the mini player after an app start, without
  /// loading audio (no network until the user presses play).
  Future<void> restoreLastEpisode() async {
    final id = await _settings.getInt(SettingsKeys.lastEpisodeId);
    if (id == null || _episodeId != null) return;
    final row = await _playback.load(id);
    if (row == null) return;
    _episodeId = id;
    mediaItem.add(_toMediaItem(row));
    _setIdlePosition(_savedPosition(row.episode));
    _broadcastState();
  }

  /// Starts [episodeId] (resuming at its saved position).
  Future<void> playEpisode(int episodeId) async {
    if (episodeId == _episodeId && _loaded) return play();

    await _saveCurrentPosition();
    final row = await _playback.load(episodeId);
    if (row == null) return;

    _episodeId = episodeId;
    _loaded = false;
    _exactStart = false;
    mediaItem.add(_toMediaItem(row));
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

  @override
  Future<void> play() async {
    if (_episodeId == null) return;
    _pauseTimer?.cancel();
    if (!_loaded) await _load();
    if (!_loaded) return;
    await _engine.play();
  }

  @override
  Future<void> pause() async {
    await _engine.pause();
    await _saveCurrentPosition();
    _pauseTimer?.cancel();
    _pauseTimer = Timer(stopAfterPause, stop);
  }

  @override
  Future<void> seek(Duration position) async {
    final id = _episodeId;
    if (id == null) return;
    if (_loaded) {
      await _engine.seek(position);
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
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    await _positions.close();
    await _engine.dispose();
  }

  // --------------------------------------------------------------- internals

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

    // Downloaded file first, otherwise stream.
    final local = await _localAudioFile?.call(id);
    final source = local != null
        ? Uri.file(local.path)
        : Uri.parse(episode.audioUrl);
    await _engine.load(source, initialPosition: start);
    await _engine.setBoostDb(await _boostFor(row.podcast));

    _loaded = true;
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
    if (duration != null &&
        duration > Duration.zero &&
        position.inMilliseconds >= duration.inMilliseconds * playedThreshold) {
      _markedPlayed = true;
      await _playback.markPlayed(id);
      return;
    }
    if ((position - _lastSaved).abs() >= saveInterval) {
      _lastSaved = position;
      await _playback.savePosition(id, position);
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
    if (state.processing == EngineProcessing.completed && !_completing) {
      _completing = true;
      try {
        final id = _episodeId;
        if (id != null && !_markedPlayed) {
          _markedPlayed = true;
          await _playback.markPlayed(id);
        }
        // M5: continue with the next playlist episode here.
        await stop();
      } finally {
        _completing = false;
      }
    }
  }

  void _broadcastState() {
    final state = _engine.state;
    final playing = state.playing && _loaded;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.rewind,
          MediaAction.fastForward,
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
