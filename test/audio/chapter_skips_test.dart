import 'package:aapodcastguru/audio/chapter_skips.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ChapterSkips skips;
  const ep = 1;
  Duration s(int seconds) => Duration(seconds: seconds);

  setUp(() => skips = ChapterSkips());
  tearDown(() => skips.dispose());

  void skip(int start, int? end, {int episode = ep, bool skipped = true}) =>
      skips.setSkipped(
        episode,
        start * 1000,
        endMs: end == null ? null : end * 1000,
        skipped: skipped,
      );

  test('nothing skipped: no target', () {
    expect(skips.target(ep, s(10)), isNull);
  });

  test('inside a skipped chapter: continue at its end', () {
    skip(60, 120);
    expect(skips.target(ep, s(59)), isNull);
    expect(skips.target(ep, s(60)), (to: s(120)));
    expect(skips.target(ep, s(119)), (to: s(120)));
    expect(skips.target(ep, s(120)), isNull);
    // Other episodes are not affected.
    expect(skips.target(2, s(90)), isNull);
  });

  test('consecutive skipped chapters are left in one jump', () {
    skip(60, 120);
    skip(120, 180);
    expect(skips.target(ep, s(70)), (to: s(180)));
  });

  test('skipping the last chapter means: to the end', () {
    skip(60, 120);
    skip(120, null);
    expect(skips.target(ep, s(70)), (to: null));
  });

  test('un-skipping removes the chapter', () {
    skip(60, 120);
    skip(60, 120, skipped: false);
    expect(skips.target(ep, s(70)), isNull);
    expect(skips.skippedStarts(ep), isEmpty);
  });

  test('keeps at most maxEpisodes episodes, dropping the oldest', () {
    for (var e = 1; e <= ChapterSkips.maxEpisodes + 1; e++) {
      skip(0, 10, episode: e);
    }
    expect(skips.skippedStarts(1), isEmpty);
    expect(skips.skippedStarts(2), {0});
    expect(skips.skippedStarts(ChapterSkips.maxEpisodes + 1), {0});
  });

  test('watch emits the current state and every change', () async {
    final seen = <Set<int>>[];
    final sub = skips.watch(ep).listen(seen.add);
    await pumpEventQueue();
    skip(60, 120);
    skip(0, 10, episode: 2); // other episode: no event
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [
      <int>{},
      {60000},
    ]);
  });
}
