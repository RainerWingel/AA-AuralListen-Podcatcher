import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_info.dart';

/// A podcast found in a directory, before subscribing.
class DirectoryResult {
  const DirectoryResult({
    required this.title,
    required this.feedUrl,
    this.author,
    this.imageUrl,
    this.episodeCount,
  });

  final String title;
  final String feedUrl;
  final String? author;

  /// Small cover for the result list.
  final String? imageUrl;
  final int? episodeCount;
}

/// Result of a search over all directories.
typedef DirectorySearchOutcome = ({
  List<DirectoryResult> results,

  /// Names of directories that failed (the others still deliver results).
  List<String> failedDirectories,
});

abstract interface class PodcastDirectory {
  String get name;
  Future<List<DirectoryResult>> search(String term);
}

/// A directory that knows its most popular podcasts (user wish 2026-10-21).
abstract interface class TopCharts {
  String get name;
  Future<List<DirectoryResult>> top();
}

/// A directory that lists freshly added podcasts (user wish 2026-10-21).
abstract interface class NewPodcasts {
  String get name;
  Future<List<DirectoryResult>> latest();
}

const _userAgent = appUserAgent;
const _searchTimeout = Duration(seconds: 15);
const _maxResultsPerDirectory = 25;

Future<Map<String, Object?>> _getJson(http.Client client, Uri url) async {
  final response = await client
      .get(url, headers: {'User-Agent': _userAgent})
      .timeout(_searchTimeout);
  if (response.statusCode != 200) {
    throw http.ClientException('HTTP ${response.statusCode}', url);
  }
  return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
}

String? _string(Object? value) {
  final text = value is String ? value.trim() : null;
  return text == null || text.isEmpty ? null : text;
}

/// How many podcasts the "popular" and "new" lists show.
const _listLength = 50;

/// Apple Podcasts directory (no API key needed).
class ItunesDirectory implements PodcastDirectory, TopCharts {
  ItunesDirectory(this._client);

  final http.Client _client;

  @override
  String get name => 'Apple Podcasts';

  @override
  Future<List<DirectoryResult>> search(String term) async {
    final json = await _getJson(
      _client,
      Uri.https('itunes.apple.com', '/search', {
        'media': 'podcast',
        'entity': 'podcast',
        'country': 'DE',
        'limit': '$_maxResultsPerDirectory',
        'term': term,
      }),
    );
    final results = json['results'] as List<Object?>? ?? const [];
    return [
      for (final item in results.whereType<Map<String, Object?>>())
        if ((_string(item['collectionName']), _string(item['feedUrl'])) case (
          final title?,
          final feedUrl?,
        ))
          DirectoryResult(
            title: title,
            feedUrl: feedUrl,
            author: _string(item['artistName']),
            imageUrl:
                _string(item['artworkUrl100']) ?? _string(item['artworkUrl60']),
            episodeCount: item['trackCount'] as int?,
          ),
    ];
  }

  /// Apple's chart of the most popular podcasts (Germany): the chart lists
  /// names and ids only, so the feed addresses come from one "lookup" call.
  @override
  Future<List<DirectoryResult>> top() async {
    final chart = await _getJson(
      _client,
      Uri.https(
        'rss.applemarketingtools.com',
        '/api/v2/de/podcasts/top/$_listLength/podcasts.json',
      ),
    );
    final entries = [
      for (final item
          in ((chart['feed'] as Map<String, Object?>?)?['results']
                      as List<Object?>? ??
                  const [])
              .whereType<Map<String, Object?>>())
        if (_string(item['id']) case final id?) (id: id, item: item),
    ];
    if (entries.isEmpty) return const [];
    final lookup = await _getJson(
      _client,
      Uri.https('itunes.apple.com', '/lookup', {
        'id': entries.map((e) => e.id).join(','),
        'entity': 'podcast',
        'country': 'DE',
      }),
    );
    final byId = {
      for (final item
          in (lookup['results'] as List<Object?>? ?? const [])
              .whereType<Map<String, Object?>>())
        '${item['collectionId']}': item,
    };
    return [
      for (final (:id, :item) in entries)
        if (byId[id] case final found?)
          if ((_string(found['feedUrl']) ?? '') case final feedUrl
              when feedUrl.isNotEmpty)
            DirectoryResult(
              title:
                  _string(item['name']) ??
                  _string(found['collectionName']) ??
                  '',
              feedUrl: feedUrl,
              author:
                  _string(item['artistName']) ?? _string(found['artistName']),
              imageUrl:
                  _string(found['artworkUrl100']) ??
                  _string(item['artworkUrl100']),
              episodeCount: found['trackCount'] as int?,
            ),
    ];
  }
}

/// fyyd.de – German podcast directory (no API key needed).
class FyydDirectory implements PodcastDirectory, NewPodcasts {
  FyydDirectory(this._client);

  final http.Client _client;

  @override
  String get name => 'fyyd';

  @override
  Future<List<DirectoryResult>> search(String term) async {
    final json = await _getJson(
      _client,
      Uri.https('api.fyyd.de', '/0.2/search/podcast', {
        'term': term,
        'count': '$_maxResultsPerDirectory',
      }),
    );
    final results = json['data'] as List<Object?>? ?? const [];
    return [
      for (final item in results.whereType<Map<String, Object?>>())
        if ((_string(item['title']), _string(item['xmlURL'])) case (
          final title?,
          final feedUrl?,
        ))
          DirectoryResult(
            title: title,
            feedUrl: feedUrl,
            author: _string(item['author']),
            imageUrl: _string(item['smallImageURL']) ?? _string(item['imgURL']),
            episodeCount: item['episode_count'] as int?,
          ),
    ];
  }

  /// Freshly added podcasts with a language of Germany and at least one
  /// episode, newest first.
  @override
  Future<List<DirectoryResult>> latest() async {
    final json = await _getJson(
      _client,
      Uri.https('api.fyyd.de', '/0.2/podcast/latest', {
        'count': '$_listLength',
        'language': 'de',
      }),
    );
    final results = json['data'] as List<Object?>? ?? const [];
    return [
      for (final item in results.whereType<Map<String, Object?>>())
        if ((_string(item['title']), _string(item['xmlURL'])) case (
          final title?,
          final feedUrl?,
        ))
          if (item['episode_count'] case final int count when count > 0)
            DirectoryResult(
              title: title,
              feedUrl: feedUrl,
              author: _string(item['author']),
              imageUrl:
                  _string(item['smallImageURL']) ?? _string(item['imgURL']),
              episodeCount: count,
            ),
    ];
  }
}

/// Searches all directories in parallel and merges the results.
class DirectorySearch {
  DirectorySearch(this._directories);

  final List<Object> _directories;

  /// The most popular podcasts, most popular first (Apple's chart for
  /// Germany). Failures are reported like in a search.
  Future<DirectorySearchOutcome> top() =>
      _list<TopCharts>((d) => d.top(), (d) => d.name);

  /// Freshly added podcasts, newest first (fyyd).
  Future<DirectorySearchOutcome> latest() =>
      _list<NewPodcasts>((d) => d.latest(), (d) => d.name);

  Future<DirectorySearchOutcome> _list<T>(
    Future<List<DirectoryResult>> Function(T) load,
    String Function(T) name,
  ) async {
    final failed = <String>[];
    final lists = await Future.wait([
      for (final directory in _directories.whereType<T>())
        load(directory).catchError((Object _) {
          failed.add(name(directory));
          return <DirectoryResult>[];
        }),
    ]);
    return (results: mergeDirectoryResults(lists), failedDirectories: failed);
  }

  Future<DirectorySearchOutcome> search(String term) async {
    final query = term.trim();
    if (query.isEmpty) {
      return (results: <DirectoryResult>[], failedDirectories: <String>[]);
    }

    final failed = <String>[];
    final lists = await Future.wait([
      for (final directory in _directories.whereType<PodcastDirectory>())
        directory.search(query).catchError((Object _) {
          failed.add(directory.name);
          return <DirectoryResult>[];
        }),
    ]);
    return (results: mergeDirectoryResults(lists), failedDirectories: failed);
  }
}

/// Interleaves the lists (keeps each directory's ranking) and drops duplicates –
/// same feed URL, or same title and author.
List<DirectoryResult> mergeDirectoryResults(List<List<DirectoryResult>> lists) {
  final merged = <DirectoryResult>[];
  final seen = <String>{};
  final longest = lists.fold(0, (max, l) => l.length > max ? l.length : max);
  for (var i = 0; i < longest; i++) {
    for (final list in lists) {
      if (i >= list.length) continue;
      final result = list[i];
      final urlKey = feedUrlKey(result.feedUrl);
      final nameKey =
          '${result.title.toLowerCase()}|${result.author?.toLowerCase()}';
      if (seen.contains(urlKey) || seen.contains(nameKey)) continue;
      seen
        ..add(urlKey)
        ..add(nameKey);
      merged.add(result);
    }
  }
  return merged;
}

/// Comparison key for feed URLs: ignores scheme, "www.", case and trailing slash.
String feedUrlKey(String url) => url
    .trim()
    .toLowerCase()
    .replaceFirst(RegExp('^[a-z]+://'), '')
    .replaceFirst(RegExp('^www\\.'), '')
    .replaceFirst(RegExp(r'/+$'), '');
