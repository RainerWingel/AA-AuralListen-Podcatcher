import 'dart:async';

import 'package:http/http.dart' as http;

import '../../core/app_info.dart';

/// Android's HttpURLConnection, which the downloader uses, never follows a
/// redirect that switches between http and https – the download then fails
/// with the 301 itself (e.g. CRE: `http://cre.fm/…` → `https://cre.fm/…`).
///
/// This follows only such protocol switches (max. [maxHops]) and returns the
/// address from which on the downloader can manage alone. Same-protocol
/// redirects are left to the downloader, so short-lived tracking URLs behind
/// them are not fixed too early. On any network problem the original [url]
/// is returned – the downloader then reports the error as before.
Future<String> resolveProtocolSwitches(
  http.Client client,
  String url, {
  int maxHops = 5,
}) async {
  var uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return url;
  try {
    for (var hop = 0; hop < maxHops; hop++) {
      final request = http.Request('GET', uri!)
        ..followRedirects = false
        ..headers['Range'] = 'bytes=0-0'
        ..headers['User-Agent'] = appUserAgent;
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 10));
      // Close the connection without downloading (servers may ignore Range).
      await response.stream.listen(null).cancel();
      final location = response.headers['location'];
      if (!_isRedirect(response.statusCode) || location == null) {
        return uri.toString();
      }
      final next = uri.resolve(location);
      if (next.scheme == uri.scheme) return uri.toString();
      uri = next;
    }
    return uri.toString();
  } on Exception {
    return url;
  }
}

bool _isRedirect(int code) =>
    code == 301 || code == 302 || code == 303 || code == 307 || code == 308;
