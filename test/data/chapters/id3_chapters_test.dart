import 'dart:convert';
import 'dart:typed_data';

import 'package:aapodcastguru/data/chapters/id3_chapters.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/id3_builder.dart';

void main() {
  for (final major in [3, 4]) {
    test('ID3v2.$major: chapters with titles, sorted, with link', () {
      final b = Id3Builder(major);
      final tag = b.tag([
        b.frame('TIT2', [3, ...utf8.encode('Folgentitel')]),
        b.chap('ch1', 200000, [b.tit2('Heimweh')]),
        b.chap('ch0', 0, [
          b.tit2('Neueste Geschichte'),
          b.frame('WXXX', [0, 0, ...latin1.encode('https://example.com/x')]),
        ]),
        b.chap('ch2', 399000, [b.tit2('Ostalgie – Größe', encoding: 1)]),
      ]);

      expect(id3TagLength(tag.sublist(0, 10)), tag.length);
      final chapters = parseId3Chapters(tag);
      expect(chapters.map((c) => c.title), [
        'Neueste Geschichte',
        'Heimweh',
        'Ostalgie – Größe',
      ]);
      expect(chapters.map((c) => c.start.inMilliseconds), [0, 200000, 399000]);
      expect(chapters.first.url, 'https://example.com/x');
    });
  }

  test('latin1 titles and chapters without title are skipped', () {
    final b = Id3Builder(3);
    final tag = b.tag([
      b.chap('a', 0, [b.tit2('Kaffee & Kuchen', encoding: 0)]),
      b.chap('b', 5000, []),
    ]);
    expect(parseId3Chapters(tag).single.title, 'Kaffee & Kuchen');
  });

  test('no tag, other version, truncated or garbage → empty, never throws', () {
    expect(id3TagLength(Uint8List.fromList(List.filled(10, 0))), isNull);
    expect(
      parseId3Chapters(Uint8List.fromList(utf8.encode('keine mp3'))),
      isEmpty,
    );

    final b = Id3Builder(3);
    final tag = b.tag([
      b.chap('a', 0, [b.tit2('X')]),
    ]);
    expect(parseId3Chapters(tag.sublist(0, tag.length ~/ 2)), isEmpty);

    final v22 = Uint8List.fromList(tag)..[3] = 2;
    expect(parseId3Chapters(v22), isEmpty);
  });
}
