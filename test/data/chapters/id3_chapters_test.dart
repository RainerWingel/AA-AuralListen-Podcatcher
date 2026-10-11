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

  group('chapter pictures (APIC)', () {
    test('embedded JPEG and PNG, also with a UTF-16 description', () {
      final b = Id3Builder(3);
      final tag = b.tag([
        b.chap('a', 0, [
          b.tit2('Eruption'),
          b.apic(Id3Builder.jpegBytes, description: 'Sonne'),
        ]),
        b.chap('b', 5000, [
          b.tit2('SoFi'),
          // The MIME type in the tag may be wrong: the bytes decide.
          b.apic(
            Id3Builder.pngBytes,
            mime: 'image/jpeg',
            encoding: 1,
            description: 'Über',
          ),
        ]),
        b.chap('c', 9000, [b.tit2('Ohne Bild')]),
      ]);
      final chapters = parseId3Chapters(tag);
      expect(chapters[0].imageBytes, Id3Builder.jpegBytes);
      expect(chapters[0].imageExtension, 'jpg');
      expect(chapters[1].imageBytes, Id3Builder.pngBytes);
      expect(chapters[1].imageExtension, 'png');
      expect(chapters[2].imageBytes, isNull);
      expect(chapters[2].imageUrl, isNull);
    });

    test('MIME "-->" links to the picture; junk is ignored', () {
      final b = Id3Builder(4);
      final tag = b.tag([
        b.chap('a', 0, [
          b.tit2('Link'),
          b.apic(latin1.encode('https://example.com/a.jpg'), mime: '-->'),
        ]),
        b.chap('b', 5000, [b.tit2('Müll'), b.apic(List.filled(30, 7))]),
      ]);
      final chapters = parseId3Chapters(tag);
      expect(chapters[0].imageUrl, 'https://example.com/a.jpg');
      expect(chapters[0].imageBytes, isNull);
      expect(chapters[1].imageBytes, isNull);
      expect(chapters[1].imageUrl, isNull);
    });
  });
}
