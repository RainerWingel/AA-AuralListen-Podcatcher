import 'package:aapodcastguru/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows German bottom navigation and switches tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PodcastGuruApp()));
    await tester.pumpAndSettle();

    for (final label in [
      'Start',
      'Abos',
      'Playlists',
      'Downloads',
      'Einstellungen',
    ]) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }

    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Abos'), findsOneWidget);
  });
}
