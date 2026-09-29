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
}
