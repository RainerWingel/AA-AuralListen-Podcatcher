import 'package:aapodcastguru/data/storage/download_url.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  /// Server answering from [routes] (url → (status, location)); records calls.
  MockClient server(
    Map<String, (int, String?)> routes,
    List<String> calls, {
    bool offline = false,
  }) => MockClient((request) async {
    calls.add(request.url.toString());
    if (offline) throw http.ClientException('no network');
    expect(request.followRedirects, isFalse);
    expect(request.headers['Range'], 'bytes=0-0');
    final (status, location) = routes[request.url.toString()] ?? (206, null);
    return http.Response('', status, headers: {'location': ?location});
  });

  test(
    'http → https is resolved, the https redirect after it is kept',
    () async {
      final calls = <String>[];
      final client = server({
        'http://cre.fm/file/cre195.mp3': (
          301,
          'https://cre.fm/file/cre195.mp3',
        ),
        'https://cre.fm/file/cre195.mp3': (
          301,
          'https://media.example/cre195.mp3?token=1',
        ),
      }, calls);
      expect(
        await resolveProtocolSwitches(client, 'http://cre.fm/file/cre195.mp3'),
        'https://cre.fm/file/cre195.mp3',
      );
      expect(calls, hasLength(2));
    },
  );

  test('https without protocol switch stays unchanged', () async {
    final calls = <String>[];
    final client = server({
      'https://a.example/x.mp3': (302, 'https://cdn.example/x.mp3'),
    }, calls);
    expect(
      await resolveProtocolSwitches(client, 'https://a.example/x.mp3'),
      'https://a.example/x.mp3',
    );
    expect(
      await resolveProtocolSwitches(client, 'https://b.example/y.mp3'),
      'https://b.example/y.mp3',
    );
  });

  test('relative Location and https → http are followed too', () async {
    final client = server({
      'https://a.example/x.mp3': (307, 'http://old.example/x.mp3'),
      'http://old.example/x.mp3': (308, '/moved/x.mp3'),
    }, []);
    expect(
      await resolveProtocolSwitches(client, 'https://a.example/x.mp3'),
      'http://old.example/x.mp3',
    );
  });

  test('offline or endless switching: gives up safely', () async {
    expect(
      await resolveProtocolSwitches(
        server({}, [], offline: true),
        'http://a.example/x.mp3',
      ),
      'http://a.example/x.mp3',
    );
    final calls = <String>[];
    final loop = server({
      'http://a.example/x': (301, 'https://a.example/x'),
      'https://a.example/x': (301, 'http://a.example/x'),
    }, calls);
    await resolveProtocolSwitches(loop, 'http://a.example/x');
    expect(calls, hasLength(5));
  });
}
