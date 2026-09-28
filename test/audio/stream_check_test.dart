import 'dart:io';

import 'package:aapodcastguru/audio/stream_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final uri = Uri.parse('https://example.com/folge.mp3');

  Future<StreamCheck> checkWith(int status) {
    String? range;
    final client = MockClient((request) async {
      range = request.headers['Range'];
      return http.Response('x', status);
    });
    return checkStream(client, uri).then((result) {
      expect(range, 'bytes=0-0', reason: 'asks for one byte only');
      return result;
    });
  }

  test('answers are sorted by what they mean for playback', () async {
    expect(await checkWith(206), StreamCheck.reachable);
    expect(await checkWith(200), StreamCheck.reachable);
    expect(await checkWith(404), StreamCheck.gone);
    expect(await checkWith(410), StreamCheck.gone);
    expect(await checkWith(403), StreamCheck.gone);
    expect(await checkWith(503), StreamCheck.serverError);
    expect(await checkWith(429), StreamCheck.serverError);
  });

  test('no connection counts as offline', () async {
    final client = MockClient(
      (_) async => throw const SocketException('Failed host lookup'),
    );
    expect(await checkStream(client, uri), StreamCheck.offline);
  });
}
