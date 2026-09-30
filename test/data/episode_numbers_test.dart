import 'package:aapodcastguru/data/episode_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  NumberedEpisode ep(int id, int? day, {int? feed}) => (
    id: id,
    pubDate: day == null ? null : DateTime.utc(2026, 1, day),
    feedNumber: feed,
  );

  test('own count by date over the whole feed, oldest = 1', () {
    expect(episodeNumbers([ep(3, 20), ep(1, 5), ep(2, 10)]), {
      1: 1,
      2: 2,
      3: 3,
    });
  });

  test('offset shifts the own count; undated episodes get no number', () {
    expect(episodeNumbers([ep(1, 5), ep(2, null), ep(3, 7)], offset: -1), {
      1: 0,
      3: 1,
    });
    expect(episodeNumbers([ep(1, 5)], offset: 9999), {1: 10000});
  });

  test('same date: the older database entry comes first', () {
    expect(episodeNumbers([ep(8, 5), ep(4, 5)]), {4: 1, 8: 2});
  });

  test('feed numbers win, without offset; unnumbered get none', () {
    expect(
      episodeNumbers([
        ep(1, 5, feed: 195),
        ep(2, 6), // bonus episode without a number
        ep(3, 7, feed: 196),
      ], offset: 100),
      {1: 195, 3: 196},
    );
  });
}
