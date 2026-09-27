import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Outcome of downloading a feed.
sealed class FeedFetchResult {
  const FeedFetchResult();
}

/// HTTP 304: the feed did not change since the last refresh.
class FeedNotModified extends FeedFetchResult {
  const FeedNotModified();
}

class FeedFetched extends FeedFetchResult {
  const FeedFetched({
    required this.body,
    required this.finalUrl,
    required this.movedPermanently,
    this.etag,
    this.lastModified,
  });

  final String body;
  final String? etag;
  final String? lastModified;

  /// URL after following redirects.
  final Uri finalUrl;

  /// True if every redirect was permanent (301/308) → the stored feed URL should be updated.
  final bool movedPermanently;
}

/// Network or HTTP error while fetching a feed.
class FeedFetchException implements Exception {
  const FeedFetchException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'FeedFetchException: $message';
}

/// Downloads feeds with conditional GET and manual redirect handling.
class FeedFetcher {
  FeedFetcher(this._client);

  final http.Client _client;

  static const _maxRedirects = 5;
  static const _timeout = Duration(seconds: 30);

  /// Protects the RAM from absurdly large or endless responses.
  static const maxFeedBytes = 30 * 1024 * 1024;

  static const _userAgent =
      'AA-PodcastGuru/0.1 (+https://github.com/RainerWingel/AA-Podcast-Guru)';

  Future<FeedFetchResult> fetch(
    Uri url, {
    String? etag,
    String? lastModified,
  }) async {
    var current = url;
    var allPermanent = true;

    for (var hop = 0; hop <= _maxRedirects; hop++) {
      final request = http.Request('GET', current)
        ..followRedirects = false
        ..headers['User-Agent'] = _userAgent
        ..headers['Accept'] =
            'application/rss+xml, application/xml;q=0.9, text/xml;q=0.8, */*;q=0.5';
      // Only send cache validators for the URL they belong to.
      if (hop == 0) {
        if (etag != null) request.headers['If-None-Match'] = etag;
        if (lastModified != null) {
          request.headers['If-Modified-Since'] = lastModified;
        }
      }

      final http.StreamedResponse response;
      try {
        response = await _client.send(request).timeout(_timeout);
      } on TimeoutException {
        throw const FeedFetchException('Timeout');
      } on Exception catch (e) {
        throw FeedFetchException('Network error: $e');
      }

      final status = response.statusCode;
      if (status >= 300 && status < 400 && status != 304) {
        // Drain the redirect body so the connection can be reused.
        await response.stream.drain<void>();
        final location = response.headers['location'];
        if (location == null) {
          throw FeedFetchException(
            'Redirect without Location',
            statusCode: status,
          );
        }
        allPermanent &= status == 301 || status == 308;
        current = current.resolve(location);
        continue;
      }

      if (status == 304) {
        await response.stream.drain<void>();
        return const FeedNotModified();
      }
      if (status != 200) {
        await response.stream.drain<void>();
        throw FeedFetchException('HTTP $status', statusCode: status);
      }

      final bytes = await _readLimited(response.stream);
      return FeedFetched(
        body: _decode(bytes, response.headers['content-type']),
        etag: response.headers['etag'],
        lastModified: response.headers['last-modified'],
        finalUrl: current,
        movedPermanently: hop > 0 && allPermanent,
      );
    }
    throw const FeedFetchException('Too many redirects');
  }

  Future<List<int>> _readLimited(Stream<List<int>> stream) async {
    final builder = BytesBuilder(copy: false);
    try {
      await for (final chunk in stream.timeout(_timeout)) {
        builder.add(chunk);
        if (builder.length > maxFeedBytes) {
          throw const FeedFetchException('Feed too large');
        }
      }
    } on TimeoutException {
      throw const FeedFetchException('Timeout');
    }
    return builder.takeBytes();
  }

  static final RegExp _xmlEncoding = RegExp(
    r'''<\?xml[^>]*encoding=["']([^"']+)["']''',
    caseSensitive: false,
  );

  String _decode(List<int> bytes, String? contentType) {
    final head = latin1.decode(bytes.take(200).toList());
    final declared =
        _charsetOf(contentType) ?? _xmlEncoding.firstMatch(head)?[1];
    final isLatin1 =
        declared != null &&
        {
          'iso-8859-1',
          'latin1',
          'windows-1252',
        }.contains(declared.toLowerCase());
    final text = isLatin1
        ? latin1.decode(bytes)
        : utf8.decode(bytes, allowMalformed: true);
    // Strip a UTF-8 byte order mark; the XML parser rejects it.
    return text.startsWith('﻿') ? text.substring(1) : text;
  }

  String? _charsetOf(String? contentType) {
    if (contentType == null) return null;
    for (final part in contentType.split(';')) {
      final kv = part.trim().split('=');
      if (kv.length == 2 && kv[0].toLowerCase() == 'charset') {
        return kv[1].replaceAll('"', '').trim();
      }
    }
    return null;
  }
}
