import 'package:aapodcastguru/core/widgets/episode_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<double> sizeOf(WidgetTester tester, String title) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            // The test font draws every character as wide as it is high:
            // 20 characters per line here.
            width: 400,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 20),
              child: EpisodeTitle(title),
            ),
          ),
        ),
      ),
    );
    return tester.widget<Text>(find.text(title)).style!.fontSize!;
  }

  testWidgets('a title that fits into two lines keeps its size', (
    tester,
  ) async {
    expect(await sizeOf(tester, 'Kurz'), 20);
    expect(await sizeOf(tester, 'Zwei Zeilen passen hier hin'), 20);
  });

  testWidgets('a title needing a third line is shown at 65 %', (tester) async {
    const long =
        'Ein sehr langer Folgentitel, der in zwei Zeilen dieser Breite '
        'ganz sicher nicht mehr passt';
    expect(await sizeOf(tester, long), 13);
  });
}
