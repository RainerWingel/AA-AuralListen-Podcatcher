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
}
