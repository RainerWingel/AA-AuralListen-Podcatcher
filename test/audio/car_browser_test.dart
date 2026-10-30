import 'dart:ui';

import 'package:aapodcastguru/audio/car_browser.dart';
import 'package:aapodcastguru/data/car_repository.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
import 'package:aapodcastguru/data/settings_keys.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:aapodcastguru/l10n/app_localizations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PlaylistRepository playlists;
  late SettingsRepository settings;
  late CarBrowser car;
  late List<String> coverLookups;
  final now = DateTime.utc(2026, 10, 30, 12);

  Future<int> addPodcast(String title, {bool provisional = false}) => db
      .into(db.podcasts)
      .insert(
        PodcastsCompanion.insert(
          feedUrl: 'https://example.com/$title',
          title: title,
          imageUrl: Value('https://example.com/$title.jpg'),
          provisional: Value(provisional),
          subscribedAt: now,
        ),
      );

  Future<int> addEpisode(
    int podcastId,
    String guid, {
    required int day,
    EpisodeStatus status = EpisodeStatus.newEpisode,
  }) => db
      .into(db.episodes)
      .insert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: guid,
          title: 'Folge $guid',
          audioUrl: 'https://example.com/$guid.mp3',
          pubDate: Value(DateTime.utc(2026, 10, day)),
          status: Value(status),
          addedAt: now,
        ),
      );

  List<String> ids(List<MediaItem> items) => [for (final i in items) i.id];

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    playlists = PlaylistRepository(db, () => now);
    settings = SettingsRepository(db);
    coverLookups = [];
    car = CarBrowser(
      cars: CarRepository(db),
      playlists: playlists,
      playback: PlaybackRepository(db, () => now),
      settings: settings,
      l10n: () async => lookupAppLocalizations(const Locale('de')),
      coverUri: (url) async {
        coverLookups.add(url);
        return url.endsWith('Kein.jpg')
            ? null
            : Uri.parse('content://covers/${url.split('/').last}');
      },
    );
  });

  tearDown(() => db.close());

  test('the root has four tabs, none playable', () async {
    final tabs = await car.children(AudioService.browsableRootId);
    expect(ids(tabs), [
      CarBrowser.tabPlaylists,
      CarBrowser.tabNew,
      CarBrowser.tabDownloads,
      CarBrowser.tabPodcasts,
    ]);
    expect(
      [for (final t in tabs) t.title],
      ['Playlists', 'Neu', 'Downloads', 'Abos'],
    );
    expect(tabs.every((t) => !t.playable!), isTrue);
    expect(
      tabs.last.extras![CarBrowser.contentStyleBrowsable],
      CarBrowser.contentStyleGrid,
    );
  });

  test(
    '"New": unplayed episodes, newest first, no provisional podcasts',
    () async {
      final a = await addPodcast('A');
      final trial = await addPodcast('Probe', provisional: true);
      final old = await addEpisode(a, 'old', day: 1);
      final started = await addEpisode(
        a,
        'started',
        day: 2,
        status: EpisodeStatus.inProgress,
      );
      await addEpisode(a, 'played', day: 3, status: EpisodeStatus.played);
      await addEpisode(trial, 'trial', day: 4);

      final items = await car.children(CarBrowser.tabNew);
      expect(ids(items), ['$started', '$old']);
      expect(items.first.artist, 'A');
      expect(items.first.extras![CarBrowser.completionStatus], 1);
      expect(items.last.extras![CarBrowser.completionStatus], 0);
      // Same cover for both: looked up once.
      expect(coverLookups, ['https://example.com/A.jpg']);
      expect(items.first.artUri, Uri.parse('content://covers/A.jpg'));
    },
  );

  test('an episode picture not in the cache: the podcast cover', () async {
    final a = await addPodcast('A');
    Future<int> withImage(String guid, String image) => db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: a,
            guid: guid,
            title: 'Folge $guid',
            audioUrl: 'https://example.com/$guid.mp3',
            imageUrl: Value('https://example.com/$image.jpg'),
            pubDate: Value(DateTime.utc(2026, 10, guid.length)),
            addedAt: now,
          ),
        );
    await withImage('own', 'Eigen');
    await withImage('notyet', 'Kein');

    final items = await car.children(CarBrowser.tabNew);
    expect(
      [for (final i in items) i.artUri],
      [
        Uri.parse('content://covers/A.jpg'),
        Uri.parse('content://covers/Eigen.jpg'),
      ],
    );
  });

  test('a playlist: its order, ids carry the playlist', () async {
    final a = await addPodcast('A');
    final first = await addEpisode(a, '1', day: 1);
    final second = await addEpisode(a, '2', day: 2);
    final playlistId = await playlists.create('Auto');
    await playlists.add(playlistId, second);
    await playlists.add(playlistId, first);

    final folders = await car.children(CarBrowser.tabPlaylists);
    expect(
      folders.map((f) => (f.id, f.title, f.playable)),
      contains(('playlist:$playlistId', 'Auto', false)),
    );
    final items = await car.children('playlist:$playlistId');
    expect(ids(items), ['$second@$playlistId', '$first@$playlistId']);
  });

  test('"Downloads": only finished downloads, latest first', () async {
    final a = await addPodcast('A');
    final early = await addEpisode(a, 'early', day: 1);
    final late = await addEpisode(a, 'late', day: 2);
    final running = await addEpisode(a, 'running', day: 3);
    Future<void> download(int id, DownloadState state, int hour) => db
        .into(db.downloads)
        .insert(
          DownloadsCompanion.insert(
            episodeId: Value(id),
            relativePath: '$id.mp3',
            state: state,
            createdAt: now,
            completedAt: Value(now.add(Duration(hours: hour))),
          ),
        );
    await download(early, DownloadState.done, 1);
    await download(late, DownloadState.done, 2);
    await download(running, DownloadState.running, 3);

    expect(ids(await car.children(CarBrowser.tabDownloads)), [
      '$late',
      '$early',
    ]);
  });

  test('"Subscriptions": alphabetical, folders with their episodes', () async {
    final b = await addPodcast('beta');
    final a = await addPodcast('Alpha');
    await addPodcast('Probe', provisional: true);
    final none = await addPodcast('Kein');
    final older = await addEpisode(b, 'older', day: 1);
    final newer = await addEpisode(b, 'newer', day: 2);

    final podcasts = await car.children(CarBrowser.tabPodcasts);
    expect(ids(podcasts), ['podcast:$a', 'podcast:$b', 'podcast:$none']);
    expect(podcasts.first.artUri, Uri.parse('content://covers/Alpha.jpg'));
    // Not in the cover cache: no picture.
    expect(podcasts.last.artUri, isNull);
    expect(ids(await car.children('podcast:$b')), ['$newer', '$older']);
  });

  test('"recent" offers the last episode', () async {
    expect(await car.children(AudioService.recentRootId), isEmpty);
    final a = await addPodcast('A');
    final id = await addEpisode(a, '1', day: 1);
    await settings.set(SettingsKeys.lastEpisodeId, '$id');
    expect(ids(await car.children(AudioService.recentRootId)), ['$id']);
  });

  test('unknown or broken ids give nothing', () async {
    expect(await car.children('playlist:x'), isEmpty);
    expect(await car.children('something'), isEmpty);
    expect(await car.item('tab:new'), isNull);
    expect(await car.item('999'), isNull);
  });

  group('voice search', () {
    test('a playlist goes on where it was', () async {
      final a = await addPodcast('A');
      final first = await addEpisode(a, '1', day: 1);
      final second = await addEpisode(a, '2', day: 2);
      final list = await playlists.create('Fürs Auto');
      await playlists.add(list, first);
      await playlists.add(list, second);
      await playlists.setLastEpisode(list, second);

      expect(
        await car.search("Spiele die Playlist 'Fürs Auto' in AA-AuralListen"),
        (episodeId: second, playlistId: list),
      );
      expect(await car.search('spiele die Playlist fürs auto'), (
        episodeId: second,
        playlistId: list,
      ));
    });

    test('a podcast: its newest unplayed episode', () async {
      final a = await addPodcast('Lage der Nation');
      await addEpisode(a, 'old', day: 1);
      final newer = await addEpisode(a, 'new', day: 2);
      await addEpisode(a, 'newest', day: 3, status: EpisodeStatus.played);

      expect(await car.search('Lage der Nation'), (
        episodeId: newer,
        playlistId: null,
      ));
    });

    test('nothing matching, or only filler words', () async {
      await addPodcast('A');
      expect(await car.search('Hotel Matze'), isNull);
      expect(await car.search('spiele den Podcast'), isNull);
    });
  });

  test('media ids of episodes', () {
    expect(CarBrowser.parsePlayable('12'), (episodeId: 12, playlistId: null));
    expect(CarBrowser.parsePlayable('12@3'), (episodeId: 12, playlistId: 3));
    expect(CarBrowser.parsePlayable('12@'), isNull);
    expect(CarBrowser.parsePlayable('1@2@3'), isNull);
    expect(CarBrowser.parsePlayable('podcast:1'), isNull);
  });
}
