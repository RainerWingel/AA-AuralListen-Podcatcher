import 'dart:convert';

import 'package:aapodcastguru/data/feed/feed_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final feedUrl = Uri.parse('https://example.com/feed');

  test('returns body and cache validators', () async {
    final fetcher = FeedFetcher(
      MockClient(
        (request) async => http.Response(
          '<rss/>',
          200,
          headers: {'etag': '"abc"', 'last-modified': 'Mon, 01 Jan 2024'},
        ),
      ),
    );
    final result = await fetcher.fetch(feedUrl) as FeedFetched;
    expect(result.body, '<rss/>');
    expect(result.etag, '"abc"');
    expect(result.lastModified, 'Mon, 01 Jan 2024');
    expect(result.movedPermanently, isFalse);
  });

  test('sends validators and understands 304', () async {
    late http.BaseRequest seen;
    final fetcher = FeedFetcher(
      MockClient((request) async {
        seen = request;
        return http.Response('', 304);
      }),
    );
    final result = await fetcher.fetch(
      feedUrl,
      etag: '"abc"',
      lastModified: 'X',
    );
    expect(result, isA<FeedNotModified>());
    expect(seen.headers['If-None-Match'], '"abc"');
    expect(seen.headers['If-Modified-Since'], 'X');
  });

  test('follows redirects and reports permanent moves', () async {
    final fetcher = FeedFetcher(
      MockClient((request) async {
        return switch (request.url.path) {
          '/feed' => http.Response('', 301, headers: {'location': '/neu'}),
          '/neu' => http.Response('<rss/>', 200),
          _ => http.Response('', 404),
        };
      }),
    );
    final result = await fetcher.fetch(feedUrl) as FeedFetched;
    expect(result.finalUrl, Uri.parse('https://example.com/neu'));
    expect(result.movedPermanently, isTrue);
  });

  test('temporary redirect is not a permanent move', () async {
    final fetcher = FeedFetcher(
      MockClient((request) async {
        return request.url.path == '/feed'
            ? http.Response('', 302, headers: {'location': '/tmp'})
            : http.Response('<rss/>', 200);
      }),
    );
    final result = await fetcher.fetch(feedUrl) as FeedFetched;
    expect(result.movedPermanently, isFalse);
  });

  test('throws on HTTP errors and redirect loops', () async {
    final notFound = FeedFetcher(
      MockClient((_) async => http.Response('', 404)),
    );
    await expectLater(
      notFound.fetch(feedUrl),
      throwsA(
        isA<FeedFetchException>().having((e) => e.statusCode, 'status', 404),
      ),
    );

    final loop = FeedFetcher(
      MockClient(
        (_) async => http.Response('', 302, headers: {'location': '/feed'}),
      ),
    );
    await expectLater(loop.fetch(feedUrl), throwsA(isA<FeedFetchException>()));
  });

  test('decodes ISO-8859-1 feeds and strips the UTF-8 BOM', () async {
    final latin = FeedFetcher(
      MockClient(
        (_) async => http.Response.bytes(
          latin1.encode(
            '<?xml version="1.0" encoding="ISO-8859-1"?><t>Käse</t>',
          ),
          200,
        ),
      ),
    );
    expect(
      ((await latin.fetch(feedUrl)) as FeedFetched).body,
      contains('Käse'),
    );

    final bom = FeedFetcher(
      MockClient(
        (_) async => http.Response.bytes([
          0xEF,
          0xBB,
          0xBF,
          ...utf8.encode('<rss>Grüße</rss>'),
        ], 200),
      ),
    );
    expect(
      ((await bom.fetch(feedUrl)) as FeedFetched).body,
      '<rss>Grüße</rss>',
    );
  });
}
