import 'package:aapodcastguru/app/app.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Feed without images, so no network image loading happens in widget tests.
const _feed = '''
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Widget-Podcast</title>
    <itunes:author>Tester</itunes:author>
    <item>
      <title>Erste Folge</title>
      <guid>1</guid>
      <pubDate>Tue, 10 Jun 2025 04:00:00 +0000</pubDate>
      <enclosure url="https://example.com/1.mp3" type="audio/mpeg"/>
      <itunes:duration>3900</itunes:duration>
    </item>
  </channel>
</rss>''';

/// Like pumpAndSettle, but also lets real async work (SQLite, mocked HTTP) run.
/// pumpAndSettle alone never settles while a loading spinner waits for drift.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  // Closing inside the widget test's fake-async zone never completes.
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          httpClientProvider.overrideWithValue(
            MockClient(
              (request) async => request.url.host == 'example.com'
                  ? http.Response(_feed, 200)
                  : http.Response('', 404),
            ),
          ),
        ],
        child: const PodcastGuruApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> disposeApp(WidgetTester tester) async {
    // Unmount so drift stream subscriptions are cancelled (DB is closed in tearDown).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  const timeout = Timeout(Duration(seconds: 60));

  testWidgets(
    'shows German bottom navigation and empty states',
    timeout: timeout,
    (tester) async {
      await pumpApp(tester);

      for (final label in [
        'Start',
        'Abos',
        'Playlists',
        'Downloads',
        'Einstellungen',
      ]) {
        expect(
          find.widgetWithText(NavigationDestination, label),
          findsOneWidget,
        );
      }
      expect(find.text('Noch keine Folgen'), findsOneWidget);

      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      expect(find.text('Noch keine Abos'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'subscribes via RSS URL and shows the episodes',
    timeout: timeout,
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);

      await tester.tap(find.text('Per RSS-URL hinzufügen'));
      await settle(tester);

      // Invalid input shows an error and keeps the dialog open.
      await tester.enterText(find.byType(TextField), 'kein link');
      await tester.tap(find.text('Abonnieren'));
      await settle(tester);
      expect(find.text('Das ist keine gültige Adresse.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'example.com/feed');
      await tester.tap(find.text('Abonnieren'));
      await settle(tester);

      // Now on the podcast detail screen.
      expect(find.text('Widget-Podcast'), findsWidgets);
      expect(find.text('Tester'), findsOneWidget);
      expect(find.text('1 Folge'), findsOneWidget);
      expect(find.text('Erste Folge'), findsOneWidget);
      expect(find.textContaining('1 Std. 5 Min.'), findsOneWidget);

      // Home shows the episode too.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Start'));
      await settle(tester);
      expect(find.text('Erste Folge'), findsOneWidget);

      await disposeApp(tester);
    },
  );
}
