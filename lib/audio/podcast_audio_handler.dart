import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';

import '../data/db/app_database.dart';
import '../data/playback_repository.dart';
import '../data/playlist_repository.dart';
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
    this._playlists,
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

  /// Needed for "continue with the next playlist episode" (docs/playlists.md).
  final PlaylistRepository? _playlists;

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

  /// Playlist the current episode was started from, and the episode's
  /// position in it (kept after the episode was removed at 98 %).
  int? _activePlaylistId;
  int _playlistPosition = -1;

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
    if (_episodeId == null) return;
    _pauseTimer?.cancel();
    if (!_loaded) await _load();
    if (!_loaded) return;
    await _engine.play();
    // just_audio emits no event if it was already playing (e.g. when switching
    // episodes), so report the state ourselves.
    _broadcastState();
  }

  @override
  Future<void> pause() async {
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

    // Downloaded file first, otherwise stream.
    final local = await _localAudioFile?.call(id);
    final source = local != null
        ? Uri.file(local.path)
        : Uri.parse(episode.audioUrl);
    await _engine.load(source, initialPosition: start);
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
          await _markPlayed(id);
        }
        await stop();
        final next = await _nextInPlaylist();
        if (next != null) {
          await playEpisode(next, playlistId: _activePlaylistId);
        }
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
