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

  /// Picture frame: [mime] "-->" makes [data] a link to the picture.
  List<int> apic(
    List<int> data, {
    String mime = 'image/jpeg',
    int encoding = 0,
    String description = '',
  }) => frame('APIC', [
    encoding,
    ...latin1.encode(mime),
    0,
    3, // picture type: front cover
    ...switch (encoding) {
      1 => [
        0xFF,
        0xFE,
        for (final c in description.codeUnits) ...[c & 0xFF, c >> 8],
        0,
        0,
      ],
      _ => [...latin1.encode(description), 0],
    },
    ...data,
  ]);

  /// The first bytes of a real JPEG (enough for type detection).
  static const jpegBytes = [
    0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x02, 0x01, 0x01, 0x01, 0x01, //
    0x01, 0x02, 0x01, 0x01,
  ];

  /// A valid 1×1 PNG.
  static const pngBytes = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
    0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00,
    0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ];

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
