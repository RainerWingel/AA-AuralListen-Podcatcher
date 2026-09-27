import 'package:aapodcastguru/core/widgets/info_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ScaffoldMessengerState messenger;

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              messenger = ScaffoldMessenger.of(context);
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
  }

  // User rule: info messages are visible for at most 7 seconds.
  testWidgets('disappears within 7 s – also with an action button', (
    tester,
  ) async {
    await pumpHost(tester);
    showInfoSnackBar(
      messenger,
      'Aus der Playlist entfernt',
      action: SnackBarAction(label: 'Rückgängig', onPressed: () {}),
    );
    await tester.pump();
    expect(find.text('Aus der Playlist entfernt'), findsOneWidget);

    // The countdown starts after the entrance animation; 7 s in total.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 6700));
    await tester.pump(const Duration(seconds: 1)); // exit animation
    expect(find.text('Aus der Playlist entfernt'), findsNothing);
  });

  testWidgets('a new message replaces the current one immediately', (
    tester,
  ) async {
    await pumpHost(tester);
    showInfoSnackBar(messenger, 'Erste');
    await tester.pump();
    showInfoSnackBar(messenger, 'Zweite');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Erste'), findsNothing);
    expect(find.text('Zweite'), findsOneWidget);
  });

  test('durations respect the 7 s rule', () {
    expect(infoDuration, lessThanOrEqualTo(const Duration(seconds: 7)));
    expect(
      infoWithActionDuration,
      lessThanOrEqualTo(const Duration(seconds: 7)),
    );
  });
}
