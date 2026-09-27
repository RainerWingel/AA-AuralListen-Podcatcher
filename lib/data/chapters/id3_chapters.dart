import 'dart:convert';
import 'dart:typed_data';

import 'parsed_chapter.dart';

/// Size of the whole ID3v2 tag (header + frames) from the first 10 bytes of an
/// MP3, or null if the file does not start with an ID3v2 tag.
int? id3TagLength(Uint8List header) {
  if (header.length < 10 ||
      header[0] != 0x49 || // I
      header[1] != 0x44 || // D
      header[2] != 0x33) {
    return null; // "ID3"
  }
  final footer = (header[5] & 0x10) != 0 ? 10 : 0;
  return 10 + _synchsafe(header, 6) + footer;
}

/// Reads ID3v2.3/2.4 chapter frames (CHAP with TIT2 title, optional WXXX
/// link). Returns an empty list for anything it does not understand – a
/// broken tag must never break playback.
List<ParsedChapter> parseId3Chapters(Uint8List tag) {
  try {
    if (id3TagLength(tag) == null) return const [];
    final major = tag[3];
    if (major != 3 && major != 4) return const []; // v2.2 uses other frames
    final flags = tag[5];
    if ((flags & 0x80) != 0) return const []; // unsynchronised tags: rare, skip
    final end = (10 + _synchsafe(tag, 6)).clamp(0, tag.length);

    var offset = 10;
    if ((flags & 0x40) != 0) {
      // Extended header: v2.4 size is synchsafe and includes itself,
      // v2.3 size excludes its own 4 bytes.
      offset += major == 4 ? _synchsafe(tag, 10) : _uint32(tag, 10) + 4;
    }

    final chapters = <ParsedChapter>[];
    for (final frame in _frames(tag, offset, end, major)) {
      if (frame.id == 'CHAP') {
        final chapter = _parseChap(tag, frame.start, frame.end, major);
        if (chapter != null) chapters.add(chapter);
      }
    }
    return normalizeChapters(chapters);
  } on RangeError {
    return const [];
  }
}

typedef _Frame = ({String id, int start, int end});

Iterable<_Frame> _frames(Uint8List b, int offset, int end, int major) sync* {
  var pos = offset;
  while (pos + 10 <= end) {
    if (b[pos] == 0) return; // padding
    final id = ascii.decode(b.sublist(pos, pos + 4), allowInvalid: true);
    final size = major == 4 ? _synchsafe(b, pos + 4) : _uint32(b, pos + 4);
    final start = pos + 10;
    final frameEnd = start + size;
    if (size <= 0 || frameEnd > end) return;
    yield (id: id, start: start, end: frameEnd);
    pos = frameEnd;
  }
}

ParsedChapter? _parseChap(Uint8List b, int start, int end, int major) {
  // Element ID (null-terminated), then start/end time in ms, start/end offset.
  var pos = start;
  while (pos < end && b[pos] != 0) {
    pos++;
  }
  pos++; // terminator
  if (pos + 16 > end) return null;
  final startMs = _uint32(b, pos);
  pos += 16;

  String? title;
  String? url;
  for (final sub in _frames(b, pos, end, major)) {
    if (sub.id == 'TIT2') {
      title = _text(b, sub.start, sub.end);
    } else if (sub.id == 'WXXX') {
      url = _wxxxUrl(b, sub.start, sub.end);
    }
  }
  if (title == null || title.isEmpty) return null;
  return ParsedChapter(
    start: Duration(milliseconds: startMs),
    title: title,
    url: url,
  );
}

/// Text frame: first byte is the encoding.
String _text(Uint8List b, int start, int end) {
  if (start >= end) return '';
  return _decode(b[start], b.sublist(start + 1, end)).trim();
}

/// WXXX: encoding, description (terminated), then the URL in ISO-8859-1.
String? _wxxxUrl(Uint8List b, int start, int end) {
  if (start >= end) return null;
  final encoding = b[start];
  final wide = encoding == 1 || encoding == 2;
  var pos = start + 1;
  while (pos < end) {
    if (!wide && b[pos] == 0) {
      pos += 1;
      break;
    }
    if (wide && pos + 1 < end && b[pos] == 0 && b[pos + 1] == 0) {
      pos += 2;
      break;
    }
    pos += wide ? 2 : 1;
  }
  final url = latin1.decode(b.sublist(pos.clamp(start, end), end)).trim();
  return url.replaceAll('\u0000', '').isEmpty
      ? null
      : url.replaceAll('\u0000', '');
}

String _decode(int encoding, Uint8List bytes) {
  final String text;
  switch (encoding) {
    case 0:
      text = latin1.decode(bytes);
    case 1:
    case 2:
      text = _utf16(bytes, bigEndianDefault: encoding == 2);
    default:
      text = utf8.decode(bytes, allowMalformed: true);
  }
  return text.replaceAll('\u0000', '');
}

String _utf16(Uint8List bytes, {required bool bigEndianDefault}) {
  var bigEndian = bigEndianDefault;
  var start = 0;
  if (bytes.length >= 2) {
    if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
      bigEndian = false;
      start = 2;
    } else if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
      bigEndian = true;
      start = 2;
    }
  }
  final units = <int>[];
  for (var i = start; i + 1 < bytes.length; i += 2) {
    units.add(
      bigEndian
          ? (bytes[i] << 8) | bytes[i + 1]
          : bytes[i] | (bytes[i + 1] << 8),
    );
  }
  return String.fromCharCodes(units);
}

int _synchsafe(Uint8List b, int o) =>
    ((b[o] & 0x7F) << 21) |
    ((b[o + 1] & 0x7F) << 14) |
    ((b[o + 2] & 0x7F) << 7) |
    (b[o + 3] & 0x7F);

int _uint32(Uint8List b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];
