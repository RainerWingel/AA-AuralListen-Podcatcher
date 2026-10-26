import 'package:aapodcastguru/core/panel_design.dart';
import 'package:aapodcastguru/features/player/panel_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget panel) => MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
  home: Scaffold(body: SizedBox(width: 300, height: 200, child: panel)),
);

/// The seeds of all sky painters currently in the tree (two while fading).
List<int> seeds(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .whereType<PanelDesignPainter>()
    .map((p) => p.seed)
    .toList();

void main() {
  const minute = PanelBackground.reshuffleInterval;

  testWidgets('the stars are scattered anew every minute', (tester) async {
    await tester.pumpWidget(
      app(
        const PanelBackground(
          design: PanelDesign.stars,
          reshuffle: true,
          child: SizedBox.expand(),
        ),
      ),
    );
    expect(seeds(tester), [0]);

    await tester.pump(minute - const Duration(seconds: 1));
    expect(seeds(tester), [0], reason: 'not yet');

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2)); // the cross-fade ends
    final first = seeds(tester);
    expect(first, hasLength(1));
    expect(first.single, isNot(0));

    await tester.pump(minute);
    await tester.pump(const Duration(seconds: 2));
    final second = seeds(tester);
    expect(second, hasLength(1));
    expect(second.single, isNot(first.single));
  });

  testWidgets('previews and other designs stay still', (tester) async {
    for (final design in [PanelDesign.stars, PanelDesign.waves]) {
      await tester.pumpWidget(
        app(
          PanelBackground(
            design: design,
            reshuffle: design == PanelDesign.waves,
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump(minute * 3);
      expect(seeds(tester), [0], reason: design.name);
    }
    // No timer is left over (the test fails on a pending timer).
  });

  testWidgets('no timer in the background, and none after dispose', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const PanelBackground(
          design: PanelDesign.stars,
          reshuffle: true,
          child: SizedBox.expand(),
        ),
      ),
    );
    // App goes to the background: nothing is scattered while nobody looks.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(minute * 3);
    expect(seeds(tester), [0]);

    // Back in the foreground: the minute starts again.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(minute + const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2)); // the cross-fade ends
    expect(seeds(tester).single, isNot(0));

    // Leaving the player screen: the timer is gone (no pending timer left).
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(minute * 2);
  });

  testWidgets('switching the design off stops the timer', (tester) async {
    Widget panel(PanelDesign design) => app(
      PanelBackground(
        design: design,
        reshuffle: true,
        child: const SizedBox.expand(),
      ),
    );
    await tester.pumpWidget(panel(PanelDesign.stars));
    await tester.pumpWidget(panel(PanelDesign.waves));
    await tester.pump(minute * 2);
    expect(seeds(tester), [0]);
  });
}
