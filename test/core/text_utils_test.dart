import 'package:aapodcastguru/core/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts HTML to plain text', () {
    expect(
      htmlToPlainText(
        '<p>Hallo&nbsp;<b>Welt</b></p><p>Gr&uuml;&szlig;e &amp; &#8211; &#x263A;</p>',
      ),
      'Hallo Welt\nGrüße & – ☺',
    );
  });

  test('collapses whitespace and blank lines', () {
    expect(htmlToPlainText('a   b<br><br><br><br>c'), 'a b\n\nc');
  });

  test('caps the length', () {
    final text = htmlToPlainText('x' * 50, maxLength: 10);
    expect(text, '${'x' * 10}…');
  });

  test('titles: entities decoded, spaces collapsed, tags kept', () {
    expect(cleanTitle('A&nbsp;B'), 'A B');
    expect(cleanTitle('Folge 12 &#8211; Titel'), 'Folge 12 – Titel');
    expect(cleanTitle('K&auml;se &amp; Brot'), 'Käse & Brot');
    expect(cleanTitle('  C<3   Liebe '), 'C<3 Liebe');
    // Double-escaped stays one level: the feed meant the text "&nbsp;".
    expect(cleanTitle('a &amp;nbsp; b'), 'a &nbsp; b');
    // Unknown or impossible entities stay as they are (no crash).
    expect(cleanTitle('x &foo; &#99999999; y'), 'x &foo; &#99999999; y');
  });

  group('show notes', () {
    test('keeps web links, drops other markup', () {
      final notes = htmlToNotes(
        '<p>Intro <b>fett</b></p>'
        '<ul><li><a href="https://a.example/x?y=1&amp;z=2">Link A</a></li>'
        '<li><a href="javascript:alert(1)">Böse</a></li>'
        '<li><a href="https://b.example">https://b.example</a></li></ul>',
      );
      expect(
        notes,
        'Intro fett\n• \uE000Link A\uE001https://a.example/x?y=1&z=2\uE002\n'
        '• Böse\n• https://b.example',
      );
      expect(parseNotes(notes), [
        (text: 'Intro fett\n• ', url: null),
        (text: 'Link A', url: 'https://a.example/x?y=1&z=2'),
        (text: '\n• Böse\n• ', url: null),
        (text: 'https://b.example', url: 'https://b.example'),
      ]);
    });

    test('list items stay compact, bullet on the same line', () {
      expect(
        htmlToNotes(
          '<p>Gäste</p>\n<ul>\n<li>\n<p>Linus</p>\n</li>\n'
          '<li>\n<p><a href="https://l.example">l.example</a></p>\n</li>\n</ul>',
        ),
        'Gäste\n• Linus\n• \uE000l.example\uE001https://l.example\uE002',
      );
    });

    test('bare addresses in plain text become links', () {
      expect(parseNotes('Siehe https://x.example/a. Danke'), [
        (text: 'Siehe ', url: null),
        (text: 'https://x.example/a', url: 'https://x.example/a'),
        (text: '. Danke', url: null),
      ]);
    });

    test('cutting never splits a link', () {
      final notes = htmlToNotes(
        'abc <a href="https://x.example/long">Linktext</a>',
        maxLength: 10,
      );
      expect(notes, 'abc…');
      // Marker characters from the feed itself are removed.
      expect(htmlToNotes('a\uE000b\uE002c'), 'abc');
    });
  });
}
