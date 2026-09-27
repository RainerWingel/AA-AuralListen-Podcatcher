import 'package:aapodcastguru/data/chapters/json_chapters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads Podcasting 2.0 chapters, skips toc:false, sorts', () {
    final chapters = parseJsonChapters('''
{"version": "1.2.0", "chapters": [
  {"startTime": 125.5, "title": "Zweites", "img": "https://img/2.jpg"},
  {"startTime": 0, "title": "Intro", "url": "https://example.com"},
  {"startTime": 60, "title": "Versteckt", "toc": false},
  {"startTime": 90}
]}''');
    expect(chapters.map((c) => c.title), ['Intro', 'Zweites']);
    expect(chapters[1].start, const Duration(milliseconds: 125500));
    expect(chapters[1].imageUrl, 'https://img/2.jpg');
    expect(chapters[0].url, 'https://example.com');
  });

  test('rejects HTML error pages (Podigee returns 404 pages)', () {
    expect(
      () => parseJsonChapters('<!DOCTYPE html><html></html>'),
      throwsFormatException,
    );
    expect(() => parseJsonChapters('{"foo": 1}'), throwsFormatException);
  });
}
