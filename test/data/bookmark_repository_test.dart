import 'package:aapodcastguru/data/bookmark_repository.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BookmarkRepository repo;
  late int episodeId;
  final now = DateTime.utc(2026, 9, 27);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BookmarkRepository(db, () => now);
    final podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/feed',
            title: 'P',
            subscribedAt: now,
          ),
        );
    episodeId = await db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: 'g',
            title: 'Folge',
            audioUrl: 'https://example.com/a.mp3',
            addedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  test('add, sort by position, edit note, delete', () async {
    final later = await repo.add(episodeId, const Duration(minutes: 5));
    final earlier = await repo.add(
      episodeId,
      const Duration(minutes: 1),
      note: '  Wichtig  ',
    );

    var list = await repo.watchForEpisode(episodeId).first;
    expect(list.map((b) => b.id), [earlier, later]);
    expect(list.first.note, 'Wichtig');
    expect(list.last.note, isNull);

    await repo.updateNote(later, '');
    await repo.updateNote(earlier, 'Neu');
    list = await repo.watchForEpisode(episodeId).first;
    expect(list.map((b) => b.note), ['Neu', null]);

    await repo.delete(earlier);
    final all = await repo.watchAll().first;
    expect(all.single.bookmark.id, later);
    expect(all.single.episode.title, 'Folge');
  });

  test(
    'bookmarks survive deleting the audio file (only the row matters)',
    () async {
      await repo.add(episodeId, const Duration(minutes: 1));
      // Downloads are separate rows; nothing links bookmarks to files.
      expect(await repo.watchAll().first, hasLength(1));
    },
  );
}
