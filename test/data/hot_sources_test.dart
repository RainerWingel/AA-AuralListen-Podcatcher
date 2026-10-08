import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/hot_sources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 8);

  /// Episode [daysAgo] days old; [heard]: to the end, [started]: in
  /// progress, [marked]: only marked as played (skipped).
  HotEpisodeFacts ep(
    int daysAgo, {
    bool heard = false,
    bool started = false,
    bool marked = false,
    int podcast = 1,
    String? theme,
  }) => (
    podcastId: podcast,
    theme: theme,
    pubDate: now.subtract(Duration(days: daysAgo)),
    status: started
        ? EpisodeStatus.inProgress
        : (heard || marked)
        ? EpisodeStatus.played
        : EpisodeStatus.newEpisode,
    finishedListening: heard,
  );

  /// Weekly episodes, newest 8 days ago; the first [skipped] (newest) not
  /// heard, the rest heard.
  List<HotEpisodeFacts> weekly(int count, {int skipped = 0, String? theme}) => [
    for (var i = 0; i < count; i++)
      ep(8 + 7 * i, heard: i >= skipped, theme: theme),
  ];

  bool hot(List<HotEpisodeFacts> facts) =>
      HotSources.compute(facts, now).podcasts.contains(1);

  test('8 of the 10 newest judged episodes heard: 🔥, 7: no', () {
    expect(hot(weekly(12, skipped: 2)), isTrue);
    expect(hot(weekly(12, skipped: 3)), isFalse);
  });

  test('started counts as heard, "marked as played" as skipped', () {
    final facts = weekly(10, skipped: 3); // 7 of 10 heard
    expect(hot(facts), isFalse);
    facts[0] = ep(8, started: true); // 8 of 10
    expect(hot(facts), isTrue);
    facts[0] = ep(8, marked: true); // only marked: skipped, 7 of 10
    expect(hot(facts), isFalse);
  });

  test('episodes of the last 7 days are not judged yet', () {
    final facts = [
      ...weekly(10),
      for (var d = 0; d < 7; d++) ep(d), // not heard yet, too new
    ];
    expect(hot(facts), isTrue);
  });

  test('at least 5 judged episodes, counted from the first one heard', () {
    expect(hot(weekly(4)), isFalse);
    expect(hot(weekly(5)), isTrue);
    // A backlog from before ever listening does not count as skipped.
    final facts = [...weekly(6), for (var i = 0; i < 20; i++) ep(100 + i)];
    expect(hot(facts), isTrue);
    expect(hot([ep(30), ep(40)]), isFalse); // never heard anything
  });

  test('topics are judged on their own', () {
    final facts = [
      ...weekly(10, theme: 'zum-thema'),
      for (var i = 0; i < 10; i++) ep(9 + 7 * i, theme: 'wrintheit'),
      ep(300, heard: true, theme: 'wrintheit'),
    ];
    final sources = HotSources.compute(facts, now);
    expect(sources.podcasts, isEmpty); // half of all skipped
    expect(sources.themes, {(1, 'zum-thema')});
  });
}
