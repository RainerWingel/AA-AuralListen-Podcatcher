import 'dart:io';

import 'package:aapodcastguru/data/chapters/chapter_service.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/id3_builder.dart';

void main() {
  late AppDatabase db;
  late int podcastId;
  late List<String> requests;
  late Map<String, http.Response Function(http.Request)> server;
  File? localFile;
  final now = DateTime.utc(2026, 9, 27);

  Uint8List mp3WithChapters() {
    final b = Id3Builder(4);
    final tag = b.tag([
      b.chap('c1', 0, [b.tit2('Anfang')]),
      b.chap('c2', 90000, [b.tit2('Mitte')]),
    ]);
    return Uint8List.fromList([...tag, ...List.filled(5000, 0xFF)]);
  }

  /// Serves [bytes] and honours "Range: bytes=0-N" like a CDN.
  http.Response ranged(Uint8List bytes, http.Request request) {
    final match = RegExp(r'bytes=0-(\d+)')
        .firstMatch(request.headers['Range'] ?? '');
    if (match == null) return http.Response.bytes(bytes, 200);
    final end = int.parse(match[1]!) + 1;
    return http.Response.bytes(
      bytes.sublist(0, end.clamp(0, bytes.length)),
      206,
    );
  }

  ChapterService service() => ChapterService(
    db: db,
    client: MockClient((request) async {
      requests.add('${request.url}|${request.headers['Range'] ?? ''}');
      final handler = server[request.url.toString()];
      return handler == null ? http.Response('', 404) : handler(request);
    }),
    localFile: (id) async => localFile,
  );

  Future<int> addEpisode({String? chaptersUrl}) => db
      .into(db.episodes)
      .insert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'g${DateTime.now().microsecondsSinceEpoch}',
          title: 'Folge',
          audioUrl: 'https://cdn.example.com/folge.mp3',
          chaptersUrl: Value(chaptersUrl),
          addedAt: now,
        ),
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    requests = [];
    server = {};
    localFile = null;
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

  test('JSON chapters file is used first', () async {
    final id = await addEpisode(chaptersUrl: 'https://example.com/c.json');
    server['https://example.com/c.json'] = (_) => http.Response(
      '{"chapters":[{"startTime":0,"title":"Intro"},{"startTime":61,"title":"Thema"}]}',
      200,
    );
    final s = service();
    await s.ensureLoaded(id);
    final chapters = await s.watch(id).first;
    expect(chapters.map((c) => (c.startMs, c.title)), [
      (0, 'Intro'),
      (61000, 'Thema'),
    ]);
  });

  test('broken JSON link (404 page) falls back to the MP3 tag – only the '
      'tag is downloaded', () async {
    final id = await addEpisode(chaptersUrl: 'https://example.com/404.json');
    final mp3 = mp3WithChapters();
    server['https://cdn.example.com/folge.mp3'] = (r) => ranged(mp3, r);

    final s = service();
    await s.ensureLoaded(id);
    expect((await s.watch(id).first).map((c) => c.title), ['Anfang', 'Mitte']);

    final audioRequests = requests.where((r) => r.contains('folge.mp3'));
    expect(audioRequests, hasLength(2)); // header, then exactly the tag
    expect(audioRequests.first, endsWith('bytes=0-9'));
    final tagLength = mp3.length - 5000;
    expect(audioRequests.last, endsWith('bytes=0-${tagLength - 1}'));
  });

  test('server ignoring the range: reading stops after the tag', () async {
    final id = await addEpisode();
    final mp3 = mp3WithChapters();
    server['https://cdn.example.com/folge.mp3'] = (_) =>
        http.Response.bytes(mp3, 200);
    final s = service();
    await s.ensureLoaded(id);
    expect(await s.watch(id).first, hasLength(2));
  });

  test('downloaded file is read locally, no network', () async {
    final id = await addEpisode();
    final dir = Directory.systemTemp.createTempSync('chapters_');
    addTearDown(() => dir.deleteSync(recursive: true));
    localFile = File('${dir.path}/$id.mp3')
      ..writeAsBytesSync(mp3WithChapters());

    final s = service();
    await s.ensureLoaded(id);
    expect(await s.watch(id).first, hasLength(2));
    expect(requests, isEmpty);
  });

  test(
    'stored chapters (from the feed) need no loading; lookups happen once',
    () async {
      final withChapters = await addEpisode(chaptersUrl: 'https://x/c.json');
      await db
          .into(db.chapters)
          .insert(
            ChaptersCompanion.insert(
              episodeId: withChapters,
              startMs: 0,
              title: 'Aus dem Feed',
            ),
          );
      final none = await addEpisode();

      final s = service();
      await s.ensureLoaded(withChapters);
      await s.ensureLoaded(none);
      await s.ensureLoaded(none);
      expect(requests.where((r) => r.contains('c.json')), isEmpty);
      // "none" was tried once (header request), not twice.
      expect(requests.where((r) => r.contains('folge.mp3')), hasLength(1));
    },
  );

  test('currentChapter picks the last chapter that started', () {
    Chapter c(int ms) => Chapter(episodeId: 1, startMs: ms, title: '$ms');
    final chapters = [c(0), c(60000), c(120000)];
    expect(currentChapter(chapters, Duration.zero)!.startMs, 0);
    expect(
      currentChapter(chapters, const Duration(seconds: 90))!.startMs,
      60000,
    );
    expect(currentChapter(chapters, const Duration(hours: 1))!.startMs, 120000);
    expect(currentChapter(const [], Duration.zero), isNull);
  });
}
