import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'id3_chapters.dart';

/// Tags larger than this (huge embedded cover art) are not downloaded.
const maxId3TagBytes = 4 * 1024 * 1024;

const _timeout = Duration(seconds: 20);

/// Downloads only the ID3v2 tag at the start of a remote MP3: first the
/// 10-byte header, then exactly the tag – never the audio itself.
/// Returns null if there is no tag, it is too large, or anything fails.
Future<Uint8List?> fetchId3Tag(http.Client client, Uri url) async {
  try {
    final header = await _readPrefix(client, url, 10);
    final length = header == null ? null : id3TagLength(header);
    if (length == null || length > maxId3TagBytes) return null;
    final tag = await _readPrefix(client, url, length);
    return tag != null && tag.length == length ? tag : null;
  } on Exception {
    return null;
  }
}

/// Reads the first [count] bytes. Asks for a byte range; if the server
/// ignores it and sends the whole file, stops reading after [count] bytes.
Future<Uint8List?> _readPrefix(http.Client client, Uri url, int count) async {
  final request = http.Request('GET', url)
    ..headers['Range'] = 'bytes=0-${count - 1}';
  final response = await client.send(request).timeout(_timeout);
  if (response.statusCode != 200 && response.statusCode != 206) {
    await response.stream.listen(null).cancel();
    return null;
  }

  final builder = BytesBuilder(copy: false);
  final done = Completer<void>();
  late final StreamSubscription<List<int>> subscription;
  subscription = response.stream.listen(
    (chunk) {
      builder.add(chunk);
      if (builder.length >= count && !done.isCompleted) done.complete();
    },
    onError: (Object e) {
      if (!done.isCompleted) done.completeError(e);
    },
    onDone: () {
      if (!done.isCompleted) done.complete();
    },
    cancelOnError: true,
  );
  try {
    await done.future.timeout(_timeout);
  } finally {
    // Cancelling closes the connection when the server sent the whole file.
    await subscription.cancel();
  }
  final bytes = builder.takeBytes();
  return bytes.length > count ? Uint8List.sublistView(bytes, 0, count) : bytes;
}
