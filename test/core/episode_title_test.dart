import 'package:aapodcastguru/core/widgets/episode_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final short = 'x' * 59;
  final long = 'x' * 60;

  test('60 characters or more count as long', () {
    expect(isLongEpisodeTitle(short), isFalse);
    expect(isLongEpisodeTitle(long), isTrue);
    // Characters, not bytes: umlauts count once.
    expect(isLongEpisodeTitle('ä' * 59), isFalse);
  });

  testWidgets('a long title is shown at 65 % of the size', (tester) async {
    double sizeOf(String title) =>
        tester.widget<Text>(find.text(title)).style!.fontSize!;
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTextStyle(
          style: const TextStyle(fontSize: 20),
          child: Column(
            children: [
              EpisodeTitle(short),
              EpisodeTitle(long),
              EpisodeTitle('y' * 70, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
    expect(sizeOf(short), 20);
    expect(sizeOf(long), 13);
    expect(sizeOf('y' * 70), closeTo(6.5, 0.001));
  });
}
