import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PlaylistRepository repo;
  late int podcastId;
  final now = DateTime.utc(2026, 9, 27);

  Future<int> addEpisode(String guid, {int? durationMs, DateTime? pubDate}) =>
      db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: guid,
              title: guid,
              audioUrl: 'https://example.com/$guid.mp3',
              durationMs: Value(durationMs),
              pubDate: Value(pubDate),
              addedAt: now,
            ),
          );

  Future<List<String>> titles(int playlistId) async =>
      (await repo.entries(playlistId)).map((e) => e.episode.title).toList();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PlaylistRepository(db, () => now);
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

  test('a fresh database has the default playlist', () async {
    final all = await repo.playlists();
    expect(all.single.name, 'Wiedergabeliste');
  });

  test('add appends, no duplicates, remove and move', () async {
    final list = await repo.create('  Unterwegs ');
    final a = await addEpisode('A');
    final b = await addEpisode('B');
    final c = await addEpisode('C');

    expect(await repo.add(list, a), isTrue);
    await repo.add(list, b);
    await repo.add(list, c);
    expect(await repo.add(list, a), isFalse);
    expect(await titles(list), ['A', 'B', 'C']);

    await repo.move(list, 0, 2); // A to the end
    expect(await titles(list), ['B', 'C', 'A']);
    await repo.move(list, 2, 0); // A back to the top
    expect(await titles(list), ['A', 'B', 'C']);

    await repo.remove(list, b);
    expect(await titles(list), ['A', 'C']);
    expect((await repo.playlists()).last.name, 'Unterwegs');
  });

  test('insertAfter: "play next" adds or moves behind an episode', () async {
    final list = await repo.create('Q');
    final a = await addEpisode('A');
    final b = await addEpisode('B');
    final c = await addEpisode('C');
    final d = await addEpisode('D');
    await repo.addAll(list, [a, b, c]);

    await repo.insertAfter(list, d, afterEpisodeId: a); // new one
    expect(await titles(list), ['A', 'D', 'B', 'C']);
    await repo.insertAfter(list, c, afterEpisodeId: a); // moved forward
    expect(await titles(list), ['A', 'C', 'D', 'B']);
    await repo.insertAfter(list, a, afterEpisodeId: b); // moved back
    expect(await titles(list), ['C', 'D', 'B', 'A']);
    final e = await addEpisode('E');
    await repo.insertAfter(list, e, afterEpisodeId: 9999); // unknown: end
    expect(await titles(list), ['C', 'D', 'B', 'A', 'E']);
  });

  test('addAll appends in order and skips episodes already there', () async {
    final playlistId = (await db.select(db.playlists).getSingle()).id;
    final a = await addEpisode('a');
    final b = await addEpisode('b');
    final c = await addEpisode('c');
    await repo.add(playlistId, b);

    expect(await repo.addAll(playlistId, [a, b, c]), [a, c]);
    expect((await repo.entries(playlistId)).map((e) => e.episode.id), [
      b,
      a,
      c,
    ]);
  });

  test('compareTitles: case, umlauts, numbers by value', () {
    final titles = ['Folge 10', 'über alles', 'Folge 2', 'Apfel', 'Ärger'];
    titles.sort(compareTitles);
    expect(titles, ['Apfel', 'Ärger', 'Folge 2', 'Folge 10', 'über alles']);
  });

  test('sort by date both ways (undated last) and by name', () async {
    final playlistId = (await db.select(db.playlists).getSingle()).id;
    for (final (guid, date) in [
      ('Zebra', DateTime.utc(2026, 5)),
      ('ohne Datum', null),
      ('Mango', DateTime.utc(2025)),
      ('Apfel', DateTime.utc(2026, 9)),
    ]) {
      await repo.add(playlistId, await addEpisode(guid, pubDate: date));
    }

    await repo.sort(playlistId, PlaylistSort.dateAscending);
    expect(await titles(playlistId), ['Mango', 'Zebra', 'Apfel', 'ohne Datum']);
    await repo.sort(playlistId, PlaylistSort.dateDescending);
    expect(await titles(playlistId), ['Apfel', 'Zebra', 'Mango', 'ohne Datum']);
    await repo.sort(playlistId, PlaylistSort.nameAscending);
    expect(await titles(playlistId), ['Apfel', 'Mango', 'ohne Datum', 'Zebra']);
  });

  test('summary counts episodes and sums durations', () async {
    final list = (await repo.playlists()).single.id;
    await repo.add(list, await addEpisode('A', durationMs: 60000));
    await repo.add(list, await addEpisode('B', durationMs: 120000));
    final summary = (await repo.watchPlaylists().first).single;
    expect(summary.count, 2);
    expect(summary.duration, const Duration(minutes: 3));
  });

  test('rename, reorder and delete playlists; episodes stay', () async {
    final first = (await repo.playlists()).single.id;
    final second = await repo.create('Zweite');
    final a = await addEpisode('A');
    await repo.add(second, a);

    await repo.rename(first, 'Erste');
    await repo.reorderPlaylists([second, first]);
    expect((await repo.playlists()).map((p) => p.name), ['Zweite', 'Erste']);

    await repo.delete(second);
    expect((await repo.playlists()).map((p) => p.name), ['Erste']);
    expect(await db.select(db.playlistItems).get(), isEmpty);
    expect(await db.select(db.episodes).get(), hasLength(1));
  });

  test('marking as played removes the episode from all playlists', () async {
    final first = (await repo.playlists()).single.id;
    final second = await repo.create('Zweite');
    final a = await addEpisode('A');
    await repo.add(first, a);
    await repo.add(second, a);

    await PlaybackRepository(db, () => now).markPlayed(a);
    expect(await db.select(db.playlistItems).get(), isEmpty);
  });

  test(
    'resumeEpisode: remembered one while in the list, else the top',
    () async {
      final list = await repo.create('Unterwegs');
      expect(await repo.resumeEpisode(list), isNull, reason: 'empty');
      final a = await addEpisode('A');
      final b = await addEpisode('B');
      await repo.addAll(list, [a, b]);
      expect(await repo.resumeEpisode(list), a);

      await repo.setLastEpisode(list, b);
      expect(await repo.resumeEpisode(list), b);
      // Another playlist remembers its own episode.
      final other = await repo.create('Abends');
      await repo.add(other, a);
      expect(await repo.resumeEpisode(other), a);

      await repo.remove(list, b);
      expect(await repo.resumeEpisode(list), a);
    },
  );

  test('setColor stores and clears the category color', () async {
    final list = await repo.create('Bunt');
    Future<PlaylistColor?> color() async =>
        (await repo.playlists()).firstWhere((p) => p.id == list).color;
    expect(await color(), isNull);
    await repo.setColor(list, PlaylistColor.green);
    expect(await color(), PlaylistColor.green);
    await repo.setColor(list, null);
    expect(await color(), isNull);
  });

  test('playlistIdsWith lists the playlists containing an episode', () async {
    final a = await addEpisode('A');
    final first = (await repo.playlists()).single.id;
    final second = await repo.create('Zweite');
    expect(await repo.playlistIdsWith(a), isEmpty);
    await repo.add(second, a);
    expect(await repo.playlistIdsWith(a), {second});
    await repo.add(first, a);
    expect(await repo.playlistIdsWith(a), {first, second});
  });

  test('nextAfter reads the current state', () async {
    final list = (await repo.playlists()).single.id;
    final a = await addEpisode('A');
    final b = await addEpisode('B');
    await repo.add(list, a);
    expect(await repo.nextAfter(list, 0), isNull);
    await repo.add(list, b);
    expect((await repo.nextAfter(list, 0))!.episodeId, b);
  });
}
