import 'package:audio_service/audio_service.dart';

import '../data/car_repository.dart';
import '../data/db/app_database.dart';
import '../data/playback_repository.dart';
import '../data/playlist_repository.dart';
import '../data/settings_keys.dart';
import '../data/settings_repository.dart';
import '../l10n/app_localizations.dart';

/// What the car plays for a media id: the episode, and the playlist that
/// becomes active (only for entries opened from a playlist).
typedef CarPlayable = ({int episodeId, int? playlistId});

/// The Android Auto menu (docs/playback.md → Android Auto): four tabs
/// Playlists / New / Downloads / Subscriptions, read from the database
/// whenever the car opens a list. The car draws everything itself.
///
/// Media ids: tabs `tab:…`, folders `playlist:<id>` / `podcast:<id>`,
/// episodes `<episodeId>` – the same id as the playing [MediaItem], so the car
/// marks the episode that is playing – and `<episodeId>@<playlistId>` inside
/// a playlist.
class CarBrowser {
  CarBrowser({
    required this._cars,
    required this._playlists,
    required this._playback,
    required this._settings,
    required this._l10n,
    required this._coverUri,
  });

  final CarRepository _cars;
  final PlaylistRepository _playlists;
  final PlaybackRepository _playback;
  final SettingsRepository _settings;

  /// Texts in the app's current language (it may change while running).
  final Future<AppLocalizations> Function() _l10n;

  /// A `content://` address the car can load for a cover, or null when the
  /// cover is not in the cover cache (nothing is downloaded for the car).
  final Future<Uri?> Function(String imageUrl) _coverUri;

  /// Most episodes per list; the car shortens long lists while driving anyway.
  static const maxEpisodes = 50;

  /// Most subscriptions in the tab (alphabetical, so none silently missing).
  static const maxPodcasts = 200;

  static const tabPlaylists = 'tab:playlists';
  static const tabNew = 'tab:new';
  static const tabDownloads = 'tab:downloads';
  static const tabPodcasts = 'tab:podcasts';

  /// Tab icons in `res/drawable` (kept in release builds: `res/raw/keep.xml`).
  static const _iconBase =
      'android.resource://io.github.rainerwingel.aurallisten/drawable/';

  // Keys of androidx.media.utils.MediaConstants.
  static const contentStyleSupported =
      'android.media.browse.CONTENT_STYLE_SUPPORTED';
  static const contentStyleBrowsable =
      'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT';
  static const contentStylePlayable =
      'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT';
  static const contentStyleList = 1;
  static const contentStyleGrid = 2;
  static const completionStatus = 'android.media.extra.PLAYBACK_STATUS';

  /// Extras of the browse root: lists by default.
  static const rootExtras = <String, dynamic>{
    contentStyleSupported: true,
    contentStyleBrowsable: contentStyleList,
    contentStylePlayable: contentStyleList,
  };

  Future<List<MediaItem>> children(String parentId) async {
    switch (parentId) {
      case AudioService.browsableRootId:
        return _tabs();
      case AudioService.recentRootId:
        return _recent();
      case tabPlaylists:
        return [
          for (final p in await _playlists.playlists())
            MediaItem(id: 'playlist:${p.id}', title: p.name, playable: false),
        ];
      case tabNew:
        return _episodes(await _cars.newEpisodes(limit: maxEpisodes));
      case tabDownloads:
        return _episodes(await _cars.downloadedEpisodes(limit: maxEpisodes));
      case tabPodcasts:
        return [
          for (final p in await _cars.podcasts(limit: maxPodcasts))
            MediaItem(
              id: 'podcast:${p.id}',
              title: p.title,
              artUri: await _cover(p.imageUrl),
              playable: false,
            ),
        ];
    }
    final folder = _folderId(parentId, 'playlist:');
    if (folder != null) {
      final entries = await _playlists.entries(folder);
      return _episodes([
        for (final e in entries.take(maxEpisodes))
          (episode: e.episode, podcast: e.podcast),
      ], playlistId: folder);
    }
    final podcast = _folderId(parentId, 'podcast:');
    if (podcast != null) {
      return _episodes(
        await _cars.podcastEpisodes(podcast, limit: maxEpisodes),
      );
    }
    return const [];
  }

  /// One episode by its media id (the car asks for it e.g. after a restart).
  Future<MediaItem?> item(String mediaId) async {
    final playable = parsePlayable(mediaId);
    if (playable == null) return null;
    final row = await _playback.load(playable.episodeId);
    if (row == null) return null;
    return _episode(row, playlistId: playable.playlistId);
  }

  /// Episode and playlist of an episode's media id, null for other ids.
  static CarPlayable? parsePlayable(String mediaId) {
    final parts = mediaId.split('@');
    if (parts.length > 2) return null;
    final episodeId = int.tryParse(parts.first);
    if (episodeId == null) return null;
    if (parts.length == 1) return (episodeId: episodeId, playlistId: null);
    final playlistId = int.tryParse(parts.last);
    if (playlistId == null) return null;
    return (episodeId: episodeId, playlistId: playlistId);
  }

  Future<List<MediaItem>> _tabs() async {
    final l10n = await _l10n();
    MediaItem tab(String id, String title, String icon, {int? style}) =>
        MediaItem(
          id: id,
          title: title,
          playable: false,
          artUri: Uri.parse('$_iconBase$icon'),
          extras: style == null ? null : {contentStyleBrowsable: style},
        );
    return [
      tab(tabPlaylists, l10n.navPlaylists, 'ic_car_playlists'),
      tab(tabNew, l10n.carNew, 'ic_car_new'),
      tab(tabDownloads, l10n.navDownloads, 'ic_car_downloads'),
      // Covers as a grid, like the subscriptions tab in the app.
      tab(
        tabPodcasts,
        l10n.navSubscriptions,
        'ic_car_podcasts',
        style: contentStyleGrid,
      ),
    ];
  }

  /// "Continue listening" when the car starts: the last episode.
  Future<List<MediaItem>> _recent() async {
    final id = await _settings.getInt(SettingsKeys.lastEpisodeId);
    if (id == null) return const [];
    final row = await _playback.load(id);
    if (row == null) return const [];
    return [await _episode(row)];
  }

  Future<List<MediaItem>> _episodes(
    List<EpisodeWithPodcast> rows, {
    int? playlistId,
  }) async {
    // Most episodes of a list share a cover: look each one up only once.
    final covers = <String, Uri?>{};
    return [
      for (final row in rows)
        await _episode(row, playlistId: playlistId, covers: covers),
    ];
  }

  Future<MediaItem> _episode(
    EpisodeWithPodcast row, {
    int? playlistId,
    Map<String, Uri?>? covers,
  }) async {
    final e = row.episode;
    final p = row.podcast;
    final lookedUp = covers ?? <String, Uri?>{};
    Future<Uri?> cached(String? url) async => url == null
        ? null
        : lookedUp.containsKey(url)
        ? lookedUp[url]
        : lookedUp[url] = await _cover(url);
    // An episode's own picture is only cached once the app has shown it;
    // until then the podcast cover stands in (nothing is downloaded).
    final cover = await cached(e.imageUrl) ?? await cached(p.imageUrl);
    return MediaItem(
      id: playlistId == null ? '${e.id}' : '${e.id}@$playlistId',
      title: e.title,
      artist: p.title,
      album: p.title,
      artUri: cover,
      duration: e.durationMs == null
          ? null
          : Duration(milliseconds: e.durationMs!),
      extras: {
        completionStatus: switch (e.status) {
          EpisodeStatus.newEpisode => 0,
          EpisodeStatus.inProgress => 1,
          EpisodeStatus.played => 2,
        },
      },
    );
  }

  Future<Uri?> _cover(String? imageUrl) async =>
      imageUrl == null ? null : _coverUri(imageUrl);

  static int? _folderId(String mediaId, String prefix) =>
      mediaId.startsWith(prefix)
      ? int.tryParse(mediaId.substring(prefix.length))
      : null;
}
