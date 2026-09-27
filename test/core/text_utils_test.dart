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
}
