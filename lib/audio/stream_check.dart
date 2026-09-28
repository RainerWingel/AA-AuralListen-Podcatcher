import 'dart:async';

import 'package:http/http.dart' as http;

/// What a failed stream's server says (docs/playback.md → Fehlerarten).
enum StreamCheck {
  /// Server answers normally – the network and the file are fine.
  reachable,

  /// 404/410/403 …: the episode is no longer offered.
  gone,

  /// 5xx, 408, 429: the server has a problem right now.
  serverError,

  /// No connection at all (no network, DNS, timeout).
  offline,
}

/// Asks for the first byte of [uri] only when playback failed; costs nothing
/// in normal operation. The body is never read.
Future<StreamCheck> checkStream(http.Client client, Uri uri) async {
  try {
    final request = http.Request('GET', uri)..headers['Range'] = 'bytes=0-0';
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 10));
    // Close the connection without downloading (servers may ignore Range).
    await response.stream.listen(null).cancel();
    final code = response.statusCode;
    if (code >= 200 && code < 400) return StreamCheck.reachable;
    if (code == 408 || code == 429 || code >= 500) {
      return StreamCheck.serverError;
    }
    return StreamCheck.gone;
  } on Exception {
    return StreamCheck.offline;
  }
}
