import 'dart:convert';

import 'package:aapodcastguru/data/directory/directory_search.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _itunesJson = jsonEncode({
  'resultCount': 3,
  'results': [
    {
      'collectionName': 'Logbuch:Netzpolitik',
      'artistName': 'Metaebene',
      'feedUrl': 'https://feeds.metaebene.me/lnp/mp3',
      'artworkUrl100': 'https://img.example.com/lnp100.jpg',
      'trackCount': 563,
    },
    {
      'collectionName': 'Off/On',
      'artistName': 'netzpolitik.org',
      'feedUrl': 'https://netzpolitik.org/feed/podcast/off-on/',
    },
    // Without feed URL (e.g. Apple-exclusive) → skipped.
    {'collectionName': 'Exklusiv', 'artistName': 'Apple'},
  ],
});

final _fyydJson = jsonEncode({
  'status': 1,
  'data': [
    // Same feed as iTunes result (other scheme, trailing slash) → duplicate.
    {
      'title': 'Off/On – anderer Titel',
      'xmlURL': 'http://www.netzpolitik.org/feed/podcast/off-on',
      'author': 'netzpolitik.org',
    },
    {
      'title': 'Systemeinstellungen',
      'xmlURL': 'https://netzpolitik.org/feed/podcast/systemeinstellungen/',
      'author': 'netzpolitik.org',
      'smallImageURL': 'https://img.example.com/sys.jpg',
      'episode_count': 12,
    },
  ],
});

http.Client _client({bool itunesDown = false, bool fyydDown = false}) =>
    MockClient((request) async {
      if (request.url.host == 'itunes.apple.com') {
        expect(request.url.queryParameters['term'], 'netzpolitik');
        return itunesDown
            ? http.Response('', 503)
            : http.Response.bytes(utf8.encode(_itunesJson), 200);
      }
      if (request.url.host == 'api.fyyd.de') {
        return fyydDown
            ? http.Response('', 500)
            : http.Response.bytes(utf8.encode(_fyydJson), 200);
      }
      return http.Response('', 404);
    });

DirectorySearch _search(http.Client client) =>
    DirectorySearch([ItunesDirectory(client), FyydDirectory(client)]);

void main() {
  test('merges both directories, interleaved and without duplicates', () async {
    final outcome = await _search(_client()).search('  netzpolitik ');

    expect(outcome.failedDirectories, isEmpty);
    expect(outcome.results.map((r) => r.title), [
      'Logbuch:Netzpolitik',
      // Rank 1 at fyyd comes before rank 2 at iTunes; the iTunes duplicate is dropped.
      'Off/On – anderer Titel',
      'Systemeinstellungen',
    ]);
    final lnp = outcome.results.first;
    expect(lnp.author, 'Metaebene');
    expect(lnp.imageUrl, 'https://img.example.com/lnp100.jpg');
    expect(lnp.episodeCount, 563);
    expect(outcome.results[2].episodeCount, 12);
  });

  test('one failing directory still delivers the other results', () async {
    final outcome = await _search(_client(itunesDown: true))
        .search('netzpolitik');
    expect(outcome.failedDirectories, ['Apple Podcasts']);
    expect(outcome.results, hasLength(2));
  });

  test('empty term does not hit the network', () async {
    final outcome = await _search(
      MockClient((_) async => fail('no request expected')),
    ).search('   ');
    expect(outcome.results, isEmpty);
  });

  test('feedUrlKey ignores scheme, www, case and trailing slash', () {
    expect(
      feedUrlKey('HTTPS://www.Example.com/Feed/'),
      feedUrlKey('http://example.com/feed'),
    );
    expect(
      feedUrlKey('https://example.com/a'),
      isNot(feedUrlKey('https://example.com/b')),
    );
  });

  group('popular and new podcasts', () {
    final chart = jsonEncode({
      'feed': {
        'results': [
          {'id': '111', 'name': 'Platz Eins', 'artistName': 'A. Autor'},
          {'id': '222', 'name': 'Ohne Feed', 'artistName': 'B'},
          {'id': '333', 'name': 'Platz Drei', 'artistName': 'C'},
        ],
      },
    });
    final lookup = jsonEncode({
      'results': [
        // Not in chart order on purpose: the chart's order counts.
        {
          'collectionId': 333,
          'feedUrl': 'https://example.com/drei',
          'artworkUrl100': 'https://img.example.com/3.jpg',
          'trackCount': 30,
        },
        {
          'collectionId': 111,
          'feedUrl': 'https://example.com/eins',
          'trackCount': 100,
        },
        // Apple-exclusive: no feed → left out.
        {'collectionId': 222},
      ],
    });
    final latest = jsonEncode({
      'status': 1,
      'data': [
        {
          'title': 'Frisch',
          'xmlURL': 'https://example.com/frisch',
          'author': 'Neu',
          'episode_count': 3,
        },
        // No episode yet: nothing to listen to.
        {
          'title': 'Leer',
          'xmlURL': 'https://example.com/leer',
          'episode_count': 0,
        },
      ],
    });

    DirectorySearch search(List<Uri> requests) => DirectorySearch([
      ItunesDirectory(
        MockClient((request) async {
          requests.add(request.url);
          if (request.url.host == 'rss.applemarketingtools.com') {
            return http.Response.bytes(utf8.encode(chart), 200);
          }
          if (request.url.path == '/lookup') {
            return http.Response.bytes(utf8.encode(lookup), 200);
          }
          return http.Response('', 404);
        }),
      ),
      FyydDirectory(
        MockClient((request) async {
          requests.add(request.url);
          return http.Response.bytes(utf8.encode(latest), 200);
        }),
      ),
    ]);

    test('popular: Apple chart of Germany, feeds from one lookup', () async {
      final requests = <Uri>[];
      final outcome = await search(requests).top();

      expect(outcome.failedDirectories, isEmpty);
      expect(outcome.results.map((r) => r.title), ['Platz Eins', 'Platz Drei']);
      expect(outcome.results.first.feedUrl, 'https://example.com/eins');
      expect(outcome.results.first.author, 'A. Autor');
      expect(outcome.results.last.imageUrl, 'https://img.example.com/3.jpg');
      expect(outcome.results.last.episodeCount, 30);
      expect(requests.first.path, '/api/v2/de/podcasts/top/50/podcasts.json');
      expect(requests.last.queryParameters['id'], '111,222,333');
    });

    test('new: freshly added podcasts of fyyd with episodes', () async {
      final requests = <Uri>[];
      final outcome = await search(requests).latest();

      expect(outcome.results.map((r) => r.title), ['Frisch']);
      expect(requests.single.path, '/0.2/podcast/latest');
      expect(requests.single.queryParameters['language'], 'de');
    });

    test('a failed first request is tried once more', () async {
      var calls = 0;
      final flaky = DirectorySearch([
        FyydDirectory(
          MockClient((request) async {
            calls++;
            return calls == 1
                ? http.Response('', 503)
                : http.Response.bytes(utf8.encode(latest), 200);
          }),
        ),
      ]);
      final outcome = await flaky.latest();
      expect(calls, 2);
      expect(outcome.failedDirectories, isEmpty);
      expect(outcome.results.map((r) => r.title), ['Frisch']);
    });

    test('a failing source is reported, not thrown', () async {
      final down = DirectorySearch([
        ItunesDirectory(MockClient((_) async => http.Response('', 503))),
        FyydDirectory(MockClient((_) async => http.Response('', 500))),
      ]);
      final top = await down.top();
      expect(top.results, isEmpty);
      expect(top.failedDirectories, ['Apple Podcasts']);
      final latest = await down.latest();
      expect(latest.failedDirectories, ['fyyd']);
    });
  });
}
