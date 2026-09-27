import 'dart:async';
import 'dart:convert';

import 'package:aapodcastguru/app/app.dart';
import 'package:aapodcastguru/audio/audio_providers.dart';
import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/opml.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/providers.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:aapodcastguru/features/player/mini_player.dart';
import 'package:aapodcastguru/features/settings/opml_import_flow.dart';
import 'package:aapodcastguru/features/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/fake_player_engine.dart';

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

// Search result without artwork (no image loading in widget tests).
final _itunesJson = jsonEncode({
  'results': [
    {
      'collectionName': 'Widget-Podcast',
      'artistName': 'Tester',
      'feedUrl': 'https://example.com/feed',
      'trackCount': 1,
    },
  ],
});

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
  late FakePlayerEngine engine;
  late PodcastAudioHandler handler;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    engine = FakePlayerEngine();
    handler = PodcastAudioHandler(
      engine: engine,
      playback: PlaybackRepository(db, DateTime.now),
      settings: SettingsRepository(db),
    );
  });
  // Closing inside the widget test's fake-async zone never completes.
  tearDown(() async {
    await handler.dispose();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          audioHandlerProvider.overrideWithValue(handler),
          httpClientProvider.overrideWithValue(
            MockClient(
              (request) async => switch (request.url.host) {
                'example.com' => http.Response(_feed, 200),
                'itunes.apple.com' => http.Response.bytes(
                  utf8.encode(_itunesJson),
                  200,
                ),
                'api.fyyd.de' => http.Response('', 500),
                _ => http.Response('', 404),
              },
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
    // Stop the player first: its 10-minute pause timer must not outlive the test.
    await tester.runAsync(handler.stop);
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

  testWidgets(
    'searches directories and subscribes from the results',
    timeout: timeout,
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Suchen'));
      await settle(tester);
      expect(find.text('Suche nach Titel, Thema oder Autor'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'widget');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);

      // fyyd is down (HTTP 500), Apple still delivers.
      expect(find.textContaining('fyyd nicht erreichbar'), findsOneWidget);
      expect(find.text('Widget-Podcast'), findsOneWidget);
      expect(find.text('Tester · 1 Folge'), findsOneWidget);

      await tester.tap(find.byTooltip('Abonnieren'));
      await settle(tester);
      expect(find.text('„Widget-Podcast“ abonniert'), findsOneWidget);
      expect(find.byTooltip('Abonniert'), findsOneWidget);

      final podcasts = await tester.runAsync(
        () => db.select(db.podcasts).get(),
      );
      expect(podcasts!.single.title, 'Widget-Podcast');

      await disposeApp(tester);
    },
  );

  // Regression: closing the progress dialog popped the tab's nested navigator
  // instead of the dialog → black screen after the import.
  testWidgets('OPML import returns to the settings screen', timeout: timeout, (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(
      find.widgetWithText(NavigationDestination, 'Einstellungen'),
    );
    await settle(tester);

    // The file picker is a platform plugin; start the flow after picking.
    // The widget's element doubles as its WidgetRef.
    final element = tester.element(find.byType(SettingsScreen));
    final ref = element as WidgetRef;
    unawaited(
      confirmAndImportOpml(element, ref, const [
        OpmlFeed(url: 'https://example.com/feed', title: 'Widget-Podcast'),
        OpmlFeed(url: 'https://kaputt.test/feed', title: 'Kaputt'),
      ]),
    );
    await settle(tester);
    expect(find.text('Abos importieren?'), findsOneWidget);

    await tester.tap(find.text('Importieren'));
    await settle(tester);
    expect(find.text('Import abgeschlossen'), findsOneWidget);
    expect(find.textContaining('Neu: 1'), findsOneWidget);
    expect(find.text('• Kaputt'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.widgetWithText(AppBar, 'Einstellungen'), findsOneWidget);
    expect(find.text('OPML-Datei importieren'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets(
    'plays an episode via mini player and full player',
    timeout: timeout,
    (tester) async {
      // Galaxy S25 screen, so the full player fits without scrolling.
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      // The mini player is always in the tree but empty until something plays.
      final miniPlayerContent = find.descendant(
        of: find.byType(MiniPlayer),
        matching: find.byType(InkWell),
      );
      expect(miniPlayerContent, findsNothing);

      // Subscribe (see test above) to get an episode.
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);

      await tester.tap(find.text('Erste Folge'));
      await settle(tester);

      // Mini player shows the episode and a pause button.
      expect(engine.loadedUri, Uri.parse('https://example.com/1.mp3'));
      expect(
        find.descendant(
          of: find.byType(MiniPlayer),
          matching: find.text('Erste Folge'),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Läuft gerade'), findsOneWidget);
      expect(find.byTooltip('Pause'), findsOneWidget);

      // Open the full player.
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Boost: Aus'), findsOneWidget);

      await tester.tap(find.byTooltip('30 Sekunden vor'));
      await settle(tester);
      expect(handler.position, const Duration(seconds: 30));

      await tester.tap(find.byTooltip('Pause').first);
      await settle(tester);
      expect(engine.calls.last, 'pause');
      expect(find.byTooltip('Abspielen'), findsWidgets);

      await tester.tap(find.byTooltip('Player schließen'));
      await settle(tester);
      expect(find.byType(Slider), findsNothing);

      await disposeApp(tester);
    },
  );
}
