import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PlaybackRepository playback;
  late int podcastId;
  final now = DateTime(2026, 9, 27, 12);

  Future<int> addEpisode(
    String guid, {
    DateTime? pubDate,
    EpisodeStatus status = EpisodeStatus.newEpisode,
    DateTime? playedAt,
    int? podcast,
  }) => db
      .into(db.episodes)
      .insert(
        EpisodesCompanion.insert(
          podcastId: podcast ?? podcastId,
          guid: guid,
          title: guid,
          audioUrl: 'https://example.com/$guid.mp3',
          pubDate: Value(pubDate),
          status: Value(status),
          playedAt: Value(playedAt),
          positionMs: const Value(5000),
          addedAt: now,
        ),
      );

  Future<Episode> episode(int id) =>
      (db.select(db.episodes)..where((e) => e.id.equals(id))).getSingle();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    playback = PlaybackRepository(db, () => now);
    podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/feed',
            title: 'P',
            subscribedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  group('markPlayedUntil', () {
    // "until" = end of 15 Sep 2026 (local time), as the UI computes it.
    final until = DateTime(
      2026,
      9,
      16,
    ).subtract(const Duration(milliseconds: 1));

    test('marks everything up to and including the chosen day', () async {
      final old = await addEpisode('old', pubDate: DateTime(2026, 1, 1));
      final sameDayLate = await addEpisode(
        'late',
        pubDate: DateTime(2026, 9, 15, 23, 30),
      );
      final nextDay = await addEpisode('next', pubDate: DateTime(2026, 9, 16));
      final noDate = await addEpisode('nodate');
      final earlierPlayed = DateTime(2026, 2, 1);
      final alreadyPlayed = await addEpisode(
        'played',
        pubDate: DateTime(2026, 1, 2),
        status: EpisodeStatus.played,
        playedAt: earlierPlayed,
      );
      final otherPodcast = await db
          .into(db.podcasts)
          .insert(
            PodcastsCompanion.insert(
              feedUrl: 'https://example.com/other',
              title: 'O',
              subscribedAt: now,
            ),
          );
      final foreign = await addEpisode(
        'foreign',
        pubDate: DateTime(2026, 1, 1),
        podcast: otherPodcast,
      );

      expect(await playback.countUnplayedUntil(podcastId, until), 2);
      expect(await playback.markPlayedUntil(podcastId, until), 2);

      for (final id in [old, sameDayLate]) {
        final e = await episode(id);
        expect(e.status, EpisodeStatus.played);
        expect(e.playedAt, isNotNull);
        expect(e.positionMs, 0);
      }
      for (final id in [nextDay, noDate, foreign]) {
        expect((await episode(id)).status, isNot(EpisodeStatus.played));
      }
      // Already played episodes keep their original playedAt (96 h timer).
      expect(
        (await episode(alreadyPlayed)).playedAt!
            .isAtSameMomentAs(earlierPlayed),
        isTrue,
      );
    });

    test('marked episodes leave all playlists', () async {
      final playlists = PlaylistRepository(db, () => now);
      final listId = (await playlists.playlists()).single.id;
      final old = await addEpisode('old', pubDate: DateTime(2026, 1, 1));
      final newer = await addEpisode('new', pubDate: DateTime(2026, 9, 20));
      await playlists.add(listId, old);
      await playlists.add(listId, newer);

      await playback.markPlayedUntil(podcastId, until);
      expect((await playlists.entries(listId)).map((e) => e.episode.id), [
        newer,
      ]);
    });

    test('nothing to do → 0', () async {
      await addEpisode('new', pubDate: DateTime(2026, 9, 20));
      expect(await playback.markPlayedUntil(podcastId, until), 0);
    });
  });

  group('markUnplayedSince', () {
    final since = DateTime(2026, 9, 10);

    test('played episodes from the chosen day on become new again', () async {
      final before = await addEpisode(
        'before',
        pubDate: DateTime(2026, 9, 9, 23, 59),
        status: EpisodeStatus.played,
        playedAt: now,
      );
      final onDay = await addEpisode(
        'onDay',
        pubDate: DateTime(2026, 9, 10),
        status: EpisodeStatus.played,
        playedAt: now,
      );
      final later = await addEpisode(
        'later',
        pubDate: DateTime(2026, 9, 20),
        status: EpisodeStatus.played,
        playedAt: now,
      );
      final inProgress = await addEpisode(
        'inProgress',
        pubDate: DateTime(2026, 9, 20),
        status: EpisodeStatus.inProgress,
      );
      final undated = await addEpisode(
        'undated',
        status: EpisodeStatus.played,
        playedAt: now,
      );

      expect(await playback.countPlayedSince(podcastId, since), 2);
      expect(await playback.markUnplayedSince(podcastId, since), 2);

      for (final id in [onDay, later]) {
        final e = await episode(id);
        expect(e.status, EpisodeStatus.newEpisode);
        expect(e.positionMs, 0);
        expect(e.playedAt, isNull, reason: 'no eviction any more');
      }
      expect((await episode(before)).status, EpisodeStatus.played);
      expect((await episode(undated)).status, EpisodeStatus.played);
      final kept = await episode(inProgress);
      expect(kept.status, EpisodeStatus.inProgress);
      expect(kept.positionMs, 5000, reason: 'position is kept');
    });

    test('other podcasts are not touched; nothing to do → 0', () async {
      final other = await db
          .into(db.podcasts)
          .insert(
            PodcastsCompanion.insert(
              feedUrl: 'https://example.com/other',
              title: 'Other',
              subscribedAt: now,
            ),
          );
      final foreign = await addEpisode(
        'foreign',
        pubDate: DateTime(2026, 9, 20),
        status: EpisodeStatus.played,
        playedAt: now,
        podcast: other,
      );
      expect(await playback.markUnplayedSince(podcastId, since), 0);
      expect((await episode(foreign)).status, EpisodeStatus.played);
    });
  });
}
