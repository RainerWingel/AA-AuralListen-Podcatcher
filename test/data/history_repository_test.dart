import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/history_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late HistoryRepository repo;
  late int podcastId;
  var now = DateTime.utc(2026, 10, 3, 12);

  Future<int> addEpisode(String guid) => db
      .into(db.episodes)
      .insert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: guid,
          title: 'Folge $guid',
          audioUrl: 'https://example.com/$guid.mp3',
          durationMs: const Value(60000),
          addedAt: now,
        ),
      );

  Future<List<String>> titles() async => [
    for (final e in await repo.watchAll().first) e.episodeTitle,
  ];

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = HistoryRepository(db, () => now);
    podcastId = await db
        .into(db.podcasts)
        .insert(
          PodcastsCompanion.insert(
            feedUrl: 'https://example.com/feed',
            title: 'Podcast',
            imageUrl: const Value('https://example.com/cover.jpg'),
            subscribedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  test('newest first; a replay moves the entry up', () async {
    final a = await addEpisode('a');
    final b = await addEpisode('b');
    await repo.addFinished(a);
    now = now.add(const Duration(minutes: 1));
    await repo.addFinished(b);
    expect(await titles(), ['Folge b', 'Folge a']);

    now = now.add(const Duration(minutes: 1));
    await repo.addFinished(a);
    expect(await titles(), ['Folge a', 'Folge b']);
    final entry = (await repo.watchAll().first).first;
    expect(entry.podcastTitle, 'Podcast');
    expect(entry.imageUrl, 'https://example.com/cover.jpg');
    expect(entry.durationMs, 60000);
  });

  test('keeps at most the newest 100 entries', () async {
    for (var i = 0; i < HistoryRepository.maxEntries + 5; i++) {
      now = now.add(const Duration(minutes: 1));
      await repo.addFinished(await addEpisode('e$i'));
    }
    final all = await titles();
    expect(all, hasLength(HistoryRepository.maxEntries));
    expect(all.first, 'Folge e104');
    expect(all.last, 'Folge e5');
  });

  test('entries survive the end of the subscription', () async {
    final a = await addEpisode('a');
    await repo.addFinished(a);
    final entry = (await repo.watchAll().first).single;
    expect(await repo.episodeIdOf(entry), a);

    await (db.delete(db.podcasts)..where((p) => p.id.equals(podcastId))).go();
    expect(await titles(), ['Folge a']);
    expect(await repo.episodeIdOf(entry), isNull);

    await repo.clear();
    expect(await titles(), isEmpty);
  });
}
