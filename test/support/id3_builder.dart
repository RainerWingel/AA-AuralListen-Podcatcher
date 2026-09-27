import 'dart:convert';
import 'dart:typed_data';

/// Builds ID3v2 tags in memory (no copyrighted MP3s in the repo).
class Id3Builder {
  Id3Builder(this.major);

  final int major;

  List<int> _size(int n) => major == 4
      ? [(n >> 21) & 0x7F, (n >> 14) & 0x7F, (n >> 7) & 0x7F, n & 0x7F]
      : [(n >> 24) & 0xFF, (n >> 16) & 0xFF, (n >> 8) & 0xFF, n & 0xFF];

  List<int> frame(String id, List<int> body) => [
    ...ascii.encode(id),
    ..._size(body.length),
    0,
    0,
    ...body,
  ];

  List<int> tit2(String text, {int encoding = 3}) => frame('TIT2', [
    encoding,
    ...switch (encoding) {
      0 => latin1.encode(text),
      1 => [
        0xFF,
        0xFE,
        for (final c in text.codeUnits) ...[c & 0xFF, c >> 8],
      ],
      _ => utf8.encode(text),
    },
  ]);

  List<int> chap(String id, int startMs, List<List<int>> subFrames) =>
      frame('CHAP', [
        ...ascii.encode(id),
        0,
        ..._u32(startMs),
        ..._u32(startMs + 1000),
        ..._u32(0xFFFFFFFF),
        ..._u32(0xFFFFFFFF),
        for (final f in subFrames) ...f,
      ]);

  static List<int> _u32(int n) => [
    (n >> 24) & 0xFF,
    (n >> 16) & 0xFF,
    (n >> 8) & 0xFF,
    n & 0xFF,
  ];

  Uint8List tag(List<List<int>> frames, {int padding = 20}) {
    final body = [for (final f in frames) ...f, ...List.filled(padding, 0)];
    final n = body.length; // header size is always synchsafe
    return Uint8List.fromList([
      ...ascii.encode('ID3'),
      major,
      0,
      0,
      (n >> 21) & 0x7F,
      (n >> 14) & 0x7F,
      (n >> 7) & 0x7F,
      n & 0x7F,
      ...body,
    ]);
  }
}
