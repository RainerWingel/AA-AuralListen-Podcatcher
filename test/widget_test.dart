import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aapodcastguru/app/app.dart';
import 'package:aapodcastguru/app/router.dart';
import 'package:aapodcastguru/app/routes.dart';
import 'package:aapodcastguru/app/theme.dart';
import 'package:aapodcastguru/audio/audio_providers.dart';
import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/core/app_info.dart';
import 'package:aapodcastguru/core/app_platform.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/opml.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
import 'package:aapodcastguru/data/providers.dart';
import 'package:aapodcastguru/data/settings_keys.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:aapodcastguru/features/episodes/episode_description.dart';
import 'package:aapodcastguru/features/player/mini_player.dart';
import 'package:aapodcastguru/features/player/player_screen.dart';
import 'package:aapodcastguru/features/playlists/playlist_screen.dart';
import 'package:aapodcastguru/features/settings/opml_import_flow.dart';
import 'package:aapodcastguru/features/settings/settings_screen.dart';
import 'package:drift/drift.dart'
    show OrderingTerm, StringExpressionOperators, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/fake_app_platform.dart';
import 'support/fake_battery_optimization.dart';
import 'support/fake_download_engine.dart';
import 'support/fake_player_engine.dart';

// Feed without images, so no network image loading happens in widget tests.
const _feed = '''
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
     xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Widget-Podcast</title>
    <itunes:author>Tester</itunes:author>
    <item>
      <title>Erste Folge</title>
      <guid>1</guid>
      <pubDate>Tue, 10 Jun 2025 04:00:00 +0000</pubDate>
      <enclosure url="https://example.com/1.mp3" type="audio/mpeg"/>
      <itunes:duration>3900</itunes:duration>
      <psc:chapters>
        <psc:chapter title="Begrüßung" start="00:00:00"/>
        <psc:chapter title="Hauptteil" start="00:10:00"/>
      </psc:chapters>
    </item>
  </channel>
</rss>''';

// Serial podcast with two seasons, without images.
const _seasonFeed = '''
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Staffel-Podcast</title>
    <itunes:type>serial</itunes:type>
    <item>
      <title>Neue Staffel Teil 1</title><guid>s2e1</guid>
      <pubDate>Tue, 10 Jun 2025 04:00:00 +0000</pubDate>
      <enclosure url="https://seasons.example.com/s2e1.mp3" type="audio/mpeg"/>
      <itunes:season>2</itunes:season><itunes:episode>1</itunes:episode>
    </item>
    <item>
      <title>Erste Staffel Teil 2</title><guid>s1e2</guid>
      <pubDate>Mon, 09 Jun 2025 04:00:00 +0000</pubDate>
      <enclosure url="https://seasons.example.com/s1e2.mp3" type="audio/mpeg"/>
      <itunes:season>1</itunes:season><itunes:episode>2</itunes:episode>
    </item>
    <item>
      <title>Erste Staffel Teil 1</title><guid>s1e1</guid>
      <pubDate>Sun, 08 Jun 2025 04:00:00 +0000</pubDate>
      <enclosure url="https://seasons.example.com/s1e1.mp3" type="audio/mpeg"/>
      <itunes:season>1</itunes:season><itunes:episode>1</itunes:episode>
    </item>
  </channel>
</rss>''';

// Network feed with two themes (like WRINT), without images.
const _themedFeed = '''
<rss><channel><title>WRINT</title>
  <item><title>Thema A</title><guid>1</guid>
    <pubDate>Thu, 17 Sep 2026 08:00:00 +0000</pubDate>
    <link>https://wrint.network.podigee.io/podcast/85079-zum-thema/1-a</link>
    <enclosure url="https://example.com/a.mp3" type="audio/mpeg"/></item>
  <item><title>Wrintheit A</title><guid>2</guid>
    <pubDate>Wed, 16 Sep 2026 08:00:00 +0000</pubDate>
    <link>https://wrint.network.podigee.io/podcast/85056-die-wrintheit/1-a</link>
    <enclosure url="https://example.com/b.mp3" type="audio/mpeg"/></item>
</channel></rss>''';

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
  late Directory episodesDir;
  late FakeDownloadEngine downloadEngine;
  late FakeBatteryOptimization battery;
  late FakeAppPlatform appPlatform;
  // Wallpaper color of the simulated phone; null = none (Android < 12).
  Color? wallpaperColor;

  setUp(() {
    episodesDir = Directory.systemTemp.createTempSync('widget_episodes_');
    downloadEngine = FakeDownloadEngine(episodesDir);
    battery = FakeBatteryOptimization();
    appPlatform = FakeAppPlatform();
    wallpaperColor = null;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    engine = FakePlayerEngine();
    handler = PodcastAudioHandler(
      engine: engine,
      playback: PlaybackRepository(db, DateTime.now),
      settings: SettingsRepository(db),
      playlists: PlaylistRepository(db, DateTime.now),
    );
  });
  // Closing inside the widget test's fake-async zone never completes.
  tearDown(() async {
    await handler.dispose();
    await db.close();
    if (episodesDir.existsSync()) episodesDir.deleteSync(recursive: true);
  });

  /// [language]: stored UI language; null = first start (language picker).
  Future<void> pumpApp(WidgetTester tester, {String? language = 'de'}) async {
    if (language != null) {
      await tester.runAsync(
        () => SettingsRepository(db).set(SettingsKeys.language, language),
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          audioHandlerProvider.overrideWithValue(handler),
          downloadEngineProvider.overrideWithValue(downloadEngine),
          batteryOptimizationProvider.overrideWithValue(battery),
          appPlatformProvider.overrideWithValue(appPlatform),
          wallpaperColorProvider.overrideWithValue(wallpaperColor),
          episodesDirectoryProvider.overrideWithValue(() async => episodesDir),
          httpClientProvider.overrideWithValue(
            MockClient(
              (request) async => switch (request.url.host) {
                // UTF-8 bytes like a real server (the String constructor
                // would send Latin-1 and break umlauts).
                'example.com' => http.Response.bytes(utf8.encode(_feed), 200),
                'seasons.example.com' => http.Response.bytes(
                  utf8.encode(_seasonFeed),
                  200,
                ),
                'wrint.example.com' => http.Response.bytes(
                  utf8.encode(_themedFeed),
                  200,
                ),
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
        child: const AuralListenApp(),
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
    // Images (e.g. the icon on the info page) stay in Flutter's global,
    // size-limited image cache; empty it so the leak check sees them freed.
    PaintingBinding.instance.imageCache.clear();
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
        'Optionen',
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
    'adds via RSS URL provisionally, then subscribes',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);

      await tester.tap(find.text('Per RSS-URL hinzufügen'));
      await settle(tester);

      // Invalid input shows an error and keeps the dialog open.
      await tester.enterText(find.byType(TextField), 'kein link');
      await tester.tap(find.text('Hinzufügen'));
      await settle(tester);
      expect(find.text('Das ist keine gültige Adresse.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'example.com/feed');
      await tester.tap(find.text('Hinzufügen'));
      await settle(tester);

      // Now on the podcast detail screen – provisional.
      expect(find.text('Widget-Podcast'), findsWidgets);
      expect(find.text('Tester'), findsOneWidget);
      expect(find.text('1 Folge'), findsOneWidget);
      expect(find.text('Erste Folge'), findsOneWidget);
      expect(find.textContaining('1 Std. 5 Min.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Abonnieren'), findsOneWidget);
      final podcast = await tester.runAsync(
        () => db.select(db.podcasts).getSingle(),
      );
      expect(podcast!.provisional, isTrue);

      // ⋮ has only "Entfernen".
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      expect(find.text('Entfernen'), findsOneWidget);
      expect(find.text('Podcast-Einstellungen'), findsNothing);
      expect(find.text('Abo kündigen'), findsNothing);
      Navigator.of(tester.element(find.text('Entfernen'))).pop();
      await settle(tester);

      // Episode menu: only "Abspielen" and "Beschreibung".
      await tester.longPress(find.text('Erste Folge'));
      await settle(tester);
      expect(find.text('Abspielen'), findsOneWidget);
      expect(find.text('Beschreibung'), findsOneWidget);
      expect(find.text('Herunterladen'), findsNothing);
      expect(find.text('Zu Playlist hinzufügen…'), findsNothing);
      expect(find.text('Als gespielt markieren'), findsNothing);
      Navigator.of(tester.element(find.text('Beschreibung'))).pop();
      await settle(tester);

      // Not on Start yet.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Start'));
      await settle(tester);
      expect(find.text('Erste Folge'), findsNothing);

      // Abos: in its own section on top; the menu offers only "Abonnieren".
      ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
          .read(routerProvider)
          .go(Routes.subscriptions);
      await settle(tester);
      expect(find.text('Vorläufig'), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
      // No "unplayed" badge on provisional podcasts.
      expect(find.byType(Badge), findsNothing);
      await tester.longPress(find.text('Widget-Podcast'));
      await settle(tester);
      expect(find.byTooltip('3 Sterne'), findsNothing);
      expect(find.textContaining('in Playlist'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Abonnieren'));
      await settle(tester);
      expect(find.text('„Widget-Podcast“ abonniert'), findsOneWidget);
      expect(find.text('Vorläufig'), findsNothing);
      expect(find.byType(ColorFiltered), findsNothing);
      expect(find.byType(Badge), findsOneWidget);

      // Home shows the episode now.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Start'));
      await settle(tester);
      expect(find.text('Erste Folge'), findsOneWidget);

      // Subscribed: "Deabonnieren" where "Abonnieren" was, not in ⋮.
      ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
          .read(routerProvider)
          .go(Routes.podcast(podcast.id));
      await settle(tester);
      expect(
        find.widgetWithText(OutlinedButton, 'Deabonnieren'),
        findsOneWidget,
      );
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      expect(find.text('Podcast-Einstellungen'), findsOneWidget);
      expect(find.text('Deabonnieren'), findsOneWidget); // only the button
      expect(find.text('Entfernen'), findsNothing);
      Navigator.of(tester.element(find.text('Podcast-Einstellungen'))).pop();
      await settle(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Deabonnieren'));
      await settle(tester);
      expect(find.text('Deabonnieren?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Deabonnieren'));
      await settle(tester);
      expect(
        await tester.runAsync(() => db.select(db.podcasts).get()),
        isEmpty,
      );

      await disposeApp(tester);
    },
  );

  testWidgets(
    'the Abos search finds only subscribed podcasts and their episodes',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.byTooltip('In Abos suchen'));
      await settle(tester);

      // Podcast by its author, case ignored.
      await tester.enterText(find.byType(TextField), 'tESTER');
      await settle(tester);
      expect(find.text('Podcasts'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Widget-Podcast'), findsOneWidget);

      // Episode by title, from the local database.
      await tester.enterText(find.byType(TextField), 'erste');
      await settle(tester);
      expect(find.text('Folgen'), findsOneWidget);
      expect(find.text('Erste Folge'), findsOneWidget);
      expect(find.text('Podcasts'), findsNothing);

      await tester.enterText(find.byType(TextField), 'gibtsnicht');
      await settle(tester);
      expect(find.text('Nichts gefunden in deinen Abos'), findsOneWidget);

      // Back closes the search and shows the grid again.
      await tester.tap(find.byTooltip('Suche schließen'));
      await settle(tester);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Widget-Podcast'), findsOneWidget);

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

      final plusX = tester.getCenter(find.byIcon(Icons.add_circle_outline)).dx;
      await tester.tap(find.byTooltip('Hinzufügen'));
      await settle(tester);
      // ✓ in the same column as the ⊕ was (user report 2026-10-06).
      expect(tester.getCenter(find.byIcon(Icons.check_circle)).dx, plusX);
      expect(
        find.text('„Widget-Podcast“ vorläufig hinzugefügt'),
        findsOneWidget,
      );
      expect(find.byTooltip('Schon in deinen Abos'), findsOneWidget);

      final podcasts = await tester.runAsync(
        () => db.select(db.podcasts).get(),
      );
      expect(podcasts!.single.title, 'Widget-Podcast');
      expect(podcasts.single.provisional, isTrue);

      await disposeApp(tester);
    },
  );

  // Regression: closing the progress dialog popped the tab's nested navigator
  // instead of the dialog → black screen after the import.
  testWidgets('OPML import returns to the settings screen', timeout: timeout, (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
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
    // Further down the list in the small test window.
    await tester.scrollUntilVisible(find.text('OPML-Datei importieren'), 200);
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

  // Regression (screenshot from the S25): "Einstellungen" wrapped in the tab
  // bar, and long podcast names pushed date/duration out of the episode row.
  testWidgets('layout fits a Galaxy S25 with enlarged font', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.runAsync(() async {
      final podcastId = await db
          .into(db.podcasts)
          .insert(
            PodcastsCompanion.insert(
              feedUrl: 'https://example.com/lang',
              title: 'wrint: gespräche zum runterladen – ein sehr langer Name',
              subscribedAt: DateTime(2026),
            ),
          );
      await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: 'x',
              title: 'Stadt Land Ost West',
              audioUrl: 'https://example.com/x.mp3',
              pubDate: Value(DateTime(2025, 9, 26)),
              durationMs: const Value(4 * 3600 * 1000 + 5 * 60 * 1000),
              addedAt: DateTime(2026),
            ),
          );
    });
    await pumpApp(tester);

    // Widget tests use a font whose glyphs are 1 em wide squares, so real line
    // breaks cannot be measured here (the real look is checked on the S25).
    // Rule instead: no tab label longer than "Downloads", which fits on the S25.
    final labels = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((d) => d.label);
    expect(labels, hasLength(5));
    for (final label in labels) {
      expect(
        label.length,
        lessThanOrEqualTo('Downloads'.length),
        reason: label,
      );
    }

    // Date and duration have their own line, separate from the podcast name.
    expect(find.text('26. Sept. 2025 · 4 Std. 5 Min.'), findsOneWidget);
    expect(
      find.text('wrint: gespräche zum runterladen – ein sehr langer Name'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets(
    'rating a podcast with stars in the Abos menu',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final podcastId = await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      Future<int> rating() async => (await tester.runAsync(
        () => (db.select(
          db.podcasts,
        )..where((p) => p.id.equals(podcastId!))).getSingle(),
      ))!.rating;

      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.longPress(find.text('Widget-Podcast'));
      await settle(tester);
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));

      await tester.tap(find.byTooltip('3 Sterne'));
      await settle(tester);
      expect(await rating(), 3);
      // Three in the menu plus the "★3" badge on the cover behind it.
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      // The menu stays open; the same star again removes the rating.
      await tester.tap(find.byTooltip('Bewertung entfernen'));
      await settle(tester);
      expect(await rating(), 0);
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'setting: when finished episodes leave the playlist',
    timeout: timeout,
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      final tile = find.text('Fertige Folgen aus Playlist entfernen');
      await tester.ensureVisible(tile);
      await settle(tester);
      expect(
        find.descendant(
          of: find.ancestor(of: tile, matching: find.byType(ListTile)),
          matching: find.text('Nach 10 Minuten'),
        ),
        findsOneWidget,
      );
      await tester.tap(tile);
      await settle(tester);
      await tester.tap(find.text('Nie'));
      await settle(tester);
      expect(
        await tester.runAsync(
          () => SettingsRepository(db).get(SettingsKeys.removeFinished),
        ),
        'never',
      );
      expect(find.text('Nie'), findsOneWidget); // subtitle

      await disposeApp(tester);
    },
  );

  testWidgets('a playlist name can only exist once', timeout: timeout, (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Playlists'));
    await settle(tester);

    // Same name as the default playlist (case and spaces ignored) → error,
    // the dialog stays open.
    await tester.tap(find.byTooltip('Neue Playlist'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), ' wiedergabeliste ');
    await tester.tap(find.widgetWithText(FilledButton, 'Anlegen'));
    await settle(tester);
    const taken = 'Eine Playlist mit diesem Namen gibt es schon.';
    expect(find.text(taken), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);

    // Typing removes the message; a new name is accepted.
    await tester.enterText(find.byType(TextField), 'Arbeit');
    await settle(tester);
    expect(find.text(taken), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Anlegen'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Arbeit'), findsOneWidget);

    // Renaming: another playlist's name is refused, its own name is fine.
    await tester.tap(find.text('Arbeit'));
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>).last);
    await settle(tester);
    await tester.tap(find.text('Umbenennen'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Wiedergabeliste');
    await tester.tap(find.widgetWithText(FilledButton, 'Speichern'));
    await settle(tester);
    expect(find.text(taken), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'arbeit');
    await tester.tap(find.widgetWithText(FilledButton, 'Speichern'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('arbeit'), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('downloads an episode and deletes it again', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await settle(tester);

    // Long press → "Herunterladen".
    await tester.longPress(find.text('Erste Folge'));
    await settle(tester);
    await tester.tap(find.text('Herunterladen'));
    await settle(tester);
    expect(downloadEngine.active, hasLength(1));

    final episodeId = downloadEngine.active.keys.single;
    await tester.runAsync(() => downloadEngine.finish(episodeId, bytes: 2048));
    await settle(tester);
    expect(find.byTooltip('Heruntergeladen'), findsOneWidget);

    // Downloads tab lists it with its size.
    await tester.tap(find.widgetWithText(NavigationDestination, 'Downloads'));
    await settle(tester);
    expect(find.text('Erste Folge'), findsOneWidget);
    expect(find.text('1 MB'), findsOneWidget);

    // Long press → details: full title, author, dates, size, state.
    await tester.longPress(find.text('Erste Folge'));
    await settle(tester);
    expect(find.textContaining('Widget-Podcast'), findsWidgets);
    for (final (label, value) in [
      ('Autor', 'Tester'),
      ('Erschienen', '10. Juni 2025'),
      ('Länge', '1 Std. 5 Min.'),
      ('Download', 'Heruntergeladen'),
      ('Größe', '1 MB'),
      ('Hörstand', 'Neu'),
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
      expect(find.text(value), findsWidgets, reason: value);
    }
    expect(find.text('Heruntergeladen'), findsWidgets);
    // "Beschreibung" swaps the details for the show notes.
    await tester.tap(find.text('Beschreibung'));
    await settle(tester);
    expect(find.text('Hörstand'), findsNothing);
    final notes = find.byWidgetPredicate(
      (w) =>
          w is NotesText ||
          (w is Text &&
              w.data == 'Für diese Folge gibt es keine Beschreibung.'),
    );
    expect(notes, findsOneWidget);
    Navigator.of(tester.element(notes)).pop();
    await settle(tester);

    // The trash asks first; "Abbrechen" keeps the file.
    await tester.tap(find.byTooltip('Download löschen'));
    await settle(tester);
    expect(find.textContaining('vom Gerät löschen?'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await settle(tester);
    expect(episodesDir.listSync(), hasLength(1));

    await tester.tap(find.byTooltip('Download löschen'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Löschen'));
    await settle(tester);
    expect(find.text('Keine Downloads'), findsOneWidget);
    expect(episodesDir.listSync(), isEmpty);

    await disposeApp(tester);
  });

  testWidgets(
    'adds to a playlist, plays from it, swipes it away',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);

      // Only the default playlist exists → added directly.
      await tester.longPress(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.text('Zu Playlist hinzufügen…'));
      await settle(tester);
      expect(find.text('Zu „Wiedergabeliste“ hinzugefügt'), findsOneWidget);

      await tester.tap(find.widgetWithText(NavigationDestination, 'Playlists'));
      await settle(tester);
      expect(find.text('1 Folge · 1 Std. 5 Min.'), findsOneWidget);

      await tester.tap(find.text('Wiedergabeliste'));
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      expect(handler.activePlaylistId, isNotNull);

      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);
      expect(find.text('Aus Playlist „Wiedergabeliste“'), findsOneWidget);
      expect(find.byTooltip('Nächste Folge'), findsOneWidget);
      await tester.tap(find.byTooltip('Player schließen'));
      await settle(tester);

      // The mini player shows the title too – swipe the playlist row.
      await tester.drag(
        find.descendant(
          of: find.byType(Dismissible),
          matching: find.text('Erste Folge'),
        ),
        const Offset(-600, 0),
      );
      await settle(tester);
      expect(find.text('Aus der Playlist entfernt'), findsOneWidget);
      expect(find.text('Diese Playlist ist leer'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets('theme checkboxes limit auto-download', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    final podcastId = await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://wrint.example.com/feed'),
    );
    await settle(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('WRINT'));
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Podcast-Einstellungen'));
    await settle(tester);

    expect(find.text('Themen für automatische Downloads'), findsOneWidget);
    expect(find.text('Zum Thema'), findsOneWidget);
    expect(find.text('Die Wrintheit'), findsOneWidget);

    // First choose the themes (below the fold – scroll like a user would),
    // then switch auto-download on.
    await tester.ensureVisible(find.text('Die Wrintheit'));
    await settle(tester);
    await tester.tap(find.text('Die Wrintheit'));
    await settle(tester);
    await tester.ensureVisible(find.text('Immer'));
    await settle(tester);
    await tester.tap(find.text('Immer'));
    await settle(tester);

    final podcast = await tester.runAsync(
      () => (db.select(
        db.podcasts,
      )..where((p) => p.id.equals(podcastId!))).getSingle(),
    );
    expect(podcast!.autoDownloadThemes, '["zum-thema"]');
    expect(podcast.autoDownloadMode, AutoDownloadMode.always);
    // Nothing starts while the settings are still being chosen …
    expect(downloadEngine.active, isEmpty);

    // Long press on a topic: 5th entry "Neue automatisch als gespielt
    // markieren", checkable, stored at once (user wish 2026-10-06).
    // (Scrolled out of view by the mode choice above.)
    await tester.ensureVisible(find.text('Die Wrintheit'));
    await settle(tester);
    await tester.longPress(find.text('Die Wrintheit'));
    await settle(tester);
    final autoPlayed = find.widgetWithText(
      CheckboxListTile,
      'Neue automatisch als gespielt markieren',
    );
    expect(autoPlayed, findsOneWidget);
    expect(tester.widget<CheckboxListTile>(autoPlayed).value, isFalse);
    await tester.tap(autoPlayed);
    await settle(tester);
    expect(tester.widget<CheckboxListTile>(autoPlayed).value, isTrue);
    final marked = await tester.runAsync(
      () => (db.select(
        db.podcasts,
      )..where((p) => p.id.equals(podcastId!))).getSingle(),
    );
    expect(marked!.autoPlayedThemes, '["die-wrintheit"]');
    Navigator.of(tester.element(autoPlayed)).pop();
    await settle(tester);

    // … the number is choosable, and closing the sheet applies it all.
    await tester.tap(find.widgetWithText(SegmentedButton<int>, '1'));
    await settle(tester);
    // Close with Android's back button.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Themen für automatische Downloads'), findsNothing);
    // Only the selected theme was queued.
    expect(downloadEngine.active, hasLength(1));

    await disposeApp(tester);
  });

  testWidgets(
    'numbered feed: feed numbers or own count with offset',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      // The feed numbers its (only) episode 42.
      await tester.runAsync(
        () => db
            .update(db.episodes)
            .write(const EpisodesCompanion(episodeNumber: Value(42))),
      );
      await settle(tester);
      Finder coverNumber(String n) =>
          find.descendant(of: find.byType(RotatedBox), matching: find.text(n));
      expect(coverNumber('42'), findsOneWidget);

      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      await tester.tap(find.text('Podcast-Einstellungen'));
      await settle(tester);
      await tester.ensureVisible(find.text('Versatz der Zählung'));
      await settle(tester);
      // Feed numbers: the offset is not available.
      expect(
        find.text('Der Versatz gilt nur für die eigene Zählung.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Eigene Zählung'));
      await settle(tester);
      await tester.tap(find.byTooltip('Erhöhen'));
      await settle(tester);
      await tester.binding.handlePopRoute();
      await settle(tester);
      // Own count (1) + offset 1.
      expect(coverNumber('2'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets('episode number on the cover, with an offset', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await settle(tester);
    Finder coverNumber(String n) =>
        find.descendant(of: find.byType(RotatedBox), matching: find.text(n));
    // On by default: the only (oldest) episode is number 1.
    expect(coverNumber('1'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('Widget-Podcast'));
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Podcast-Einstellungen'));
    await settle(tester);
    await tester.ensureVisible(find.text('Versatz der Zählung'));
    await settle(tester);
    await tester.tap(find.byTooltip('Erhöhen'));
    await settle(tester);
    await tester.tap(find.byTooltip('Erhöhen'));
    await settle(tester);
    // Typing works too: −1 makes the first episode 0.
    await tester.enterText(
      find
          .descendant(of: find.byType(Row), matching: find.byType(TextField))
          .last,
      '-1',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    await tester.binding.handlePopRoute(); // close the settings
    await settle(tester);
    expect(coverNumber('0'), findsOneWidget);

    // Switched off: no number.
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Podcast-Einstellungen'));
    await settle(tester);
    await tester.ensureVisible(find.text('Folgennummer am Cover'));
    await settle(tester);
    await tester.tap(find.text('Folgennummer am Cover'));
    await settle(tester);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.byType(RotatedBox), findsNothing);

    await disposeApp(tester);
  });

  testWidgets(
    'a target playlist for auto-downloads can be chosen',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final podcastId = await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      await tester.tap(find.text('Podcast-Einstellungen'));
      await settle(tester);

      final row = find.widgetWithText(
        ListTile,
        'Neue Downloads zur Playlist hinzufügen',
      );
      await tester.ensureVisible(row);
      await settle(tester);
      expect(
        find.descendant(of: row, matching: find.text('Keine')),
        findsOneWidget,
      );
      await tester.tap(row);
      await settle(tester);
      await tester.tap(find.text('Wiedergabeliste'));
      await settle(tester);
      expect(
        find.descendant(of: row, matching: find.text('Wiedergabeliste')),
        findsOneWidget,
      );
      final podcast = await tester.runAsync(
        () => (db.select(
          db.podcasts,
        )..where((p) => p.id.equals(podcastId!))).getSingle(),
      );
      expect(podcast!.autoPlaylistName, 'Wiedergabeliste');
      expect(podcast.autoPlaylistId, isNotNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'long press on a topic fills a playlist with that topic',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://wrint.example.com/feed'),
      );
      final playlistId = (await tester.runAsync(
        () => db.select(db.playlists).getSingle(),
      ))!.id;
      await settle(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('WRINT'));
      await settle(tester);
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      await tester.tap(find.text('Podcast-Einstellungen'));
      await settle(tester);
      Future<void> playTopicAll() async {
        await tester.ensureVisible(find.text('Die Wrintheit'));
        await settle(tester);
        await tester.longPress(find.text('Die Wrintheit'));
        await settle(tester);
        // The menu is limited to the topic: 1 of the 2 unplayed episodes.
        expect(find.text('WRINT · Die Wrintheit'), findsOneWidget);
        expect(
          find.descendant(
            of: find.widgetWithText(
              ListTile,
              'Alle ungespielten Episoden in Playlist',
            ),
            matching: find.text('1 Folge'),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Alle ungespielten Episoden in Playlist'));
        await settle(tester);
      }

      await playTopicAll();
      final entries = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).entries(playlistId),
      );
      expect(entries!.map((e) => e.episode.title), ['Wrintheit A']);
      expect(
        find.text('1 Folge zu „Wiedergabeliste“ hinzugefügt.'),
        findsOneWidget,
      );
      // Only added, nothing plays (user wish 2026-10-04).
      expect(handler.currentEpisodeId, isNull);

      // Again: nothing is added twice.
      await playTopicAll();
      expect(
        find.textContaining('Alle Folgen waren schon in „Wiedergabeliste“'),
        findsOneWidget,
      );
      final again = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).entries(playlistId),
      );
      expect(again, hasLength(1));

      // "Mark all as played" for the topic, then it offers the opposite.
      Future<void> openTopicMenu() async {
        await tester.ensureVisible(find.text('Die Wrintheit'));
        await settle(tester);
        await tester.longPress(find.text('Die Wrintheit'));
        await settle(tester);
      }

      await openTopicMenu();
      await tester.tap(find.text('Alle als gespielt markieren'));
      await settle(tester);
      expect(
        find.textContaining('1 Folge als gespielt markieren?'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Markieren'));
      await settle(tester);
      expect(find.text('1 Folge als gespielt markiert'), findsOneWidget);
      await openTopicMenu();
      expect(find.text('Alle als ungespielt markieren'), findsOneWidget);
      expect(find.text('Alle als gespielt markieren'), findsNothing);
      // The other topic is untouched.
      await tester.tapAt(const Offset(10, 10)); // close the menu
      await settle(tester);
      await tester.ensureVisible(find.text('Zum Thema'));
      await settle(tester);
      await tester.longPress(find.text('Zum Thema'));
      await settle(tester);
      expect(find.text('Alle als gespielt markieren'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets('chapters and bookmarks in the player', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await settle(tester);
    await tester.tap(find.text('Erste Folge'));
    await settle(tester);
    await tester.tap(find.byType(MiniPlayer));
    await settle(tester);

    // Chapters from the feed.
    expect(find.text('Kapitel 1/2: Begrüßung'), findsOneWidget);
    await tester.tap(find.text('Kapitel 1/2: Begrüßung'));
    await settle(tester);
    await tester.tap(find.text('Hauptteil'));
    await settle(tester);
    expect(handler.position, const Duration(minutes: 10));

    // Bookmark with a note.
    await tester.ensureVisible(find.text('Lesezeichen setzen'));
    await tester.tap(find.text('Lesezeichen setzen'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Gute Stelle');
    await tester.tap(find.text('Speichern'));
    await settle(tester);
    expect(find.text('Lesezeichen bei 10:00 gesetzt'), findsOneWidget);
    expect(find.text('Lesezeichen (1)'), findsOneWidget);

    // "Skip" marks a chapter in memory; choosing it later un-skips it.
    await tester.ensureVisible(find.text('Kapitel 2/2: Hauptteil'));
    await tester.tap(find.text('Kapitel 2/2: Hauptteil'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Skip').first);
    await settle(tester);
    expect(handler.chapterSkips.skippedStarts(handler.currentEpisodeId!), {0});
    await tester.tap(find.text('Begrüßung'));
    await settle(tester);
    expect(
      handler.chapterSkips.skippedStarts(handler.currentEpisodeId!),
      isEmpty,
    );
    expect(handler.position, Duration.zero);

    // Global list in Optionen → tap plays from the bookmark.
    await tester.tap(find.byTooltip('Player schließen'));
    await settle(tester);
    await handlerSeek(tester, handler, Duration.zero);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await settle(tester);
    await tester.tap(find.text('Lesezeichen'));
    await settle(tester);
    expect(find.text('Gute Stelle'), findsOneWidget);
    await tester.tap(find.text('Gute Stelle'));
    await settle(tester);
    expect(handler.position, const Duration(minutes: 10));

    await disposeApp(tester);
  });

  testWidgets('marks all episodes up to a date as played', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await settle(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('Widget-Podcast'));
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Als gespielt markieren bis …'));
    await settle(tester);

    // Date picker opens on today; confirm it (the episode is from 2025).
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(find.textContaining('1 Folge bis einschließlich'), findsOneWidget);
    await tester.tap(find.text('Markieren'));
    await settle(tester);

    expect(find.text('1 Folge als gespielt markiert'), findsOneWidget);
    final episode = await tester.runAsync(
      () => db.select(db.episodes).getSingle(),
    );
    expect(episode!.status, EpisodeStatus.played);
    expect(find.byTooltip('Gespielt'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets(
    'screen titles use the title font, tabs do not',
    timeout: timeout,
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Playlists'));
      await settle(tester);
      String? fontOf(Finder text) =>
          tester.renderObject<RenderParagraph>(text).text.style?.fontFamily;
      expect(
        fontOf(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Playlists'),
          ),
        ),
        AppTheme.titleFontFamily,
      );
      expect(
        fontOf(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Playlists'),
          ),
        ),
        isNot(AppTheme.titleFontFamily),
      );

      await disposeApp(tester);
    },
  );

  testWidgets(
    'status bar icons fit the theme on screens with a background',
    timeout: timeout,
    (tester) async {
      await pumpApp(tester);
      Brightness? icons() => tester
          .widget<AppBar>(find.byType(AppBar).last)
          .systemOverlayStyle
          ?.statusBarIconBrightness;
      // Light mode (default in tests): dark icons on Home and Downloads.
      expect(icons(), Brightness.dark);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Downloads'));
      await settle(tester);
      expect(icons(), Brightness.dark);

      await tester.runAsync(
        () => SettingsRepository(db).set(SettingsKeys.themeMode, 'dark'),
      );
      await settle(tester);
      expect(icons(), Brightness.light);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'without a choice the app uses the wallpaper color, else orange',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      wallpaperColor = const Color(0xFF1565C0); // blue wallpaper
      await pumpApp(tester);
      final primary = Theme.of(tester.element(find.byType(NavigationBar)))
          .colorScheme
          .primary;
      expect(primary.b, greaterThan(primary.r));
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      expect(
        find.widgetWithText(ListTile, 'Wie Hintergrundbild'),
        findsOneWidget,
      );
      await disposeApp(tester);

      // Same (unset) choice on a phone without wallpaper colors.
      wallpaperColor = null;
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      expect(find.widgetWithText(ListTile, 'Orange'), findsOneWidget);
      await disposeApp(tester);
    },
  );

  testWidgets(
    'the app color can be chosen, also from the wallpaper',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      Color primary() =>
          Theme.of(tester.element(find.byType(NavigationBar)))
              .colorScheme
              .primary;
      Future<void> choose(String name) async {
        await tester.tap(find.text('App-Farbe'));
        await settle(tester);
        await tester.tap(find.byTooltip(name));
        await settle(tester);
      }

      // No wallpaper colors (Android < 12): only the 8 presets.
      await pumpApp(tester);
      final orange = primary();
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      await tester.tap(find.text('App-Farbe'));
      await settle(tester);
      for (final name in [
        'Orange',
        'Rot',
        'Pink',
        'Lila',
        'Blau',
        'Petrol',
        'Grün',
        'Braun',
      ]) {
        expect(find.byTooltip(name), findsOneWidget, reason: name);
      }
      expect(find.byTooltip('Wie Hintergrundbild'), findsNothing);
      // The default "wallpaper" shows as what it is here: orange.
      expect(
        find.descendant(
          of: find.byTooltip('Orange'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Blau'));
      await settle(tester);
      final blue = primary();
      expect(blue, isNot(orange));
      expect(blue.b, greaterThan(blue.r));
      expect(
        await tester.runAsync(
          () => SettingsRepository(db).get(SettingsKeys.appColor),
        ),
        'blue',
      );
      await disposeApp(tester);

      // Android 12+ with a green wallpaper: the extra option uses it.
      wallpaperColor = const Color(0xFF2E7D32);
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      await choose('Wie Hintergrundbild');
      expect(find.text('Wie Hintergrundbild'), findsOneWidget);
      final fromWallpaper = primary();
      expect(fromWallpaper.g, greaterThan(fromWallpaper.r));
      expect(fromWallpaper.g, greaterThan(fromWallpaper.b));

      await disposeApp(tester);
    },
  );

  testWidgets('dark mode can be chosen in Optionen', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    ThemeMode mode() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
    expect(mode(), ThemeMode.system);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await settle(tester);
    await tester.tap(find.text('Dunkel'));
    await settle(tester);
    expect(mode(), ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(NavigationBar))).brightness,
      Brightness.dark,
    );

    // The backup section is further down – scroll there like a user.
    await tester.scrollUntilVisible(find.text('Backup erstellen'), 300);
    await settle(tester);
    expect(find.text('Backup erstellen'), findsOneWidget);
    expect(find.text('Abos als OPML exportieren'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets(
    'first start asks for the language; Optionen can change it',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      Future<String?> stored() => tester.runAsync<String?>(
        () => SettingsRepository(db).get(SettingsKeys.language),
      );

      // Nothing chosen yet: the picker comes first, in the device language
      // (English in tests), and the app behind it is not shown.
      await pumpApp(tester, language: null);
      expect(find.text('Choose language'), findsOneWidget);
      expect(
        find.text('Welcome to the Podcatcher “AA-AuralListen”'),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('Deutsch'));
      await settle(tester);
      expect(await stored(), 'de');
      expect(find.text('Choose language'), findsNothing);
      expect(
        find.widgetWithText(NavigationDestination, 'Optionen'),
        findsOneWidget,
      );

      // Optionen → Sprache → English switches the whole app at once.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      await tester.tap(find.text('Sprache'));
      await settle(tester);
      await tester.tap(find.text('English'));
      await settle(tester);
      expect(await stored(), 'en');
      expect(find.text('Language'), findsOneWidget);
      expect(
        find.widgetWithText(NavigationDestination, 'Settings'),
        findsOneWidget,
      );
      expect(find.text('Dark'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'the language picker speaks German on a German device',
    timeout: timeout,
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester, language: null);
      expect(find.text('Sprache wählen'), findsOneWidget);
      expect(
        find.text('Willkommen beim Podcatcher „AA-AuralListen“'),
        findsOneWidget,
      );
      expect(find.text('Choose language'), findsNothing);

      await disposeApp(tester);
    },
  );

  testWidgets('feed address can be changed after a move', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await settle(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('Widget-Podcast'));
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Podcast-Einstellungen'));
    await settle(tester);
    await tester.ensureVisible(find.text('Feed-Adresse ändern'));
    await settle(tester);
    await tester.tap(find.text('Feed-Adresse ändern'));
    await settle(tester);

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'example.com/neu',
    );
    await tester.tap(find.text('Übernehmen'));
    await settle(tester);

    expect(find.text('Feed-Adresse geändert.'), findsOneWidget);
    final podcast = await tester.runAsync(
      () => db.select(db.podcasts).getSingle(),
    );
    expect(podcast!.feedUrl, 'https://example.com/neu');

    await disposeApp(tester);
  });

  testWidgets(
    'battery: status in Optionen, button opens the app settings',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);

      // Playing never asks for the exemption by itself.
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      expect(battery.settingsOpened, 0);

      // Optionen shows the status; tapping opens the app's system settings.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      expect(find.textContaining('Akku-Optimierung aktiv'), findsOneWidget);
      // Further down since the playlist setting sits above it.
      await tester.ensureVisible(find.text('Hintergrund-Wiedergabe'));
      await settle(tester);
      await tester.tap(find.text('Hintergrund-Wiedergabe'));
      await settle(tester);
      expect(battery.settingsOpened, 1);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'subscription tiles show unplayed episodes, 99+ above 99',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final podcastId = await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      final episodes = await tester.runAsync(
        () => db.select(db.episodes).get(),
      );
      expect(find.widgetWithText(Badge, '${episodes!.length}'), findsOneWidget);

      await tester.runAsync(
        () => db.batch(
          (b) => b.insertAll(db.episodes, [
            for (var i = 0; i < 120; i++)
              EpisodesCompanion.insert(
                podcastId: podcastId!,
                guid: 'extra-$i',
                title: 'Extra $i',
                audioUrl: 'https://example.com/extra-$i.mp3',
                addedAt: DateTime.utc(2026, 9, 28),
              ),
          ]),
        ),
      );
      await settle(tester);
      expect(find.widgetWithText(Badge, '99+'), findsOneWidget);

      // All played: the badge disappears.
      await tester.runAsync(
        () => db
            .update(db.episodes)
            .write(
              const EpisodesCompanion(status: Value(EpisodeStatus.played)),
            ),
      );
      await settle(tester);
      expect(find.byType(Badge), findsNothing);

      await disposeApp(tester);
    },
  );

  testWidgets('played episodes are shown half transparent', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('Widget-Podcast'));
    await settle(tester);

    double? opacityOf(Finder finder) {
      final opacity = find.ancestor(of: finder, matching: find.byType(Opacity));
      return opacity.evaluate().isEmpty
          ? null
          : tester.widget<Opacity>(opacity.first).opacity;
    }

    expect(opacityOf(find.text('Erste Folge')), isNull);

    await tester.runAsync(
      () => db
          .update(db.episodes)
          .write(const EpisodesCompanion(status: Value(EpisodeStatus.played))),
    );
    await settle(tester);
    expect(opacityOf(find.text('Erste Folge')), 0.5);
    // The check mark itself stays fully visible.
    expect(opacityOf(find.byTooltip('Gespielt')), isNull);

    await disposeApp(tester);
  });

  testWidgets(
    'an episode that cannot be loaded shows an info box',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);

      engine.failLoads = true;
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      expect(
        find.text(
          'Die Folge konnte nicht geladen werden. '
          'Bitte Internetverbindung prüfen.',
        ),
        findsOneWidget,
      );
      expect(handler.playbackState.value.playing, isFalse);

      // The same problem again (second tap): the info box shows again.
      await tester.pump(const Duration(seconds: 8)); // first box is gone
      await settle(tester);
      expect(find.textContaining('nicht geladen werden'), findsNothing);
      await tester.tap(find.text('Erste Folge').first); // the list entry
      await settle(tester);
      expect(find.textContaining('nicht geladen werden'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'the player shows a "downloaded" mark for downloaded episodes',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.runAsync(handler.pause);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);
      final inPlayer = find.descendant(
        of: find.byType(PlayerScreen),
        matching: find.byTooltip('Heruntergeladen'),
      );
      expect(inPlayer, findsNothing, reason: 'streamed');

      // Download it while the player is open: the mark appears once done.
      await tester.runAsync(
        () =>
            ProviderScope.containerOf(tester.element(find.byType(PlayerScreen)))
                .read(downloadServiceProvider)
                .download(handler.currentEpisodeId!),
      );
      await settle(tester);
      expect(inPlayer, findsNothing, reason: 'still running');
      final id = downloadEngine.active.keys.single;
      await tester.runAsync(() => downloadEngine.finish(id, bytes: 2048));
      await settle(tester);
      expect(inPlayer, findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'sleep timer is chosen next to "Lesezeichen setzen"',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.runAsync(handler.pause);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);

      await tester.ensureVisible(find.text('Sleep-Timer'));
      await tester.tap(find.text('Sleep-Timer'));
      await settle(tester);
      for (final option in [
        'Aus',
        '5 Minuten',
        '15 Minuten',
        '30 Minuten',
        '60 Minuten',
        'Bis Ende der Folge',
      ]) {
        expect(find.text(option), findsOneWidget);
      }
      await tester.tap(find.text('15 Minuten'));
      await settle(tester);
      // Paused: the countdown waits.
      expect(find.text('noch 15:00'), findsOneWidget);

      await tester.tap(find.text('noch 15:00'));
      await settle(tester);
      await tester.tap(find.text('Bis Ende der Folge'));
      await settle(tester);
      expect(find.text('Bis Folgenende'), findsOneWidget);

      // Own number of minutes: 1 to 3600.
      await tester.tap(find.text('Bis Folgenende'));
      await settle(tester);
      await tester.tap(find.text('Eigene Zeit…'));
      await settle(tester);
      FilledButton start() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Starten'),
      );
      for (final invalid in ['0', '3601']) {
        await tester.enterText(find.byType(TextField), invalid);
        await settle(tester);
        expect(start().onPressed, isNull, reason: invalid);
        expect(find.text('1 bis 3600 Minuten'), findsNWidgets(1));
      }
      await tester.enterText(find.byType(TextField), '45');
      await settle(tester);
      await tester.tap(find.text('Starten'));
      await settle(tester);
      expect(find.text('noch 45:00'), findsOneWidget);

      await tester.tap(find.text('noch 45:00'));
      await settle(tester);
      expect(find.text('Eigene Zeit: 45 Minuten'), findsOneWidget);
      await tester.tap(find.text('Eigene Zeit: 45 Minuten'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), '3600');
      await settle(tester);
      await tester.tap(find.text('Starten'));
      await settle(tester);
      expect(find.text('noch 60:00:00'), findsOneWidget);

      await tester.tap(find.text('noch 60:00:00'));
      await settle(tester);
      await tester.tap(find.text('Aus'));
      await settle(tester);
      expect(find.text('Sleep-Timer'), findsOneWidget);
      expect(handler.sleepTimerState.isActive, isFalse);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'time display keeps running when a seek never completes',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);

      // Offline after a player error: just_audio never confirms the seek.
      engine.hangSeeks = true;
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await settle(tester);

      // Playback goes on (network back): the display must follow.
      engine.emitPosition(const Duration(minutes: 7, seconds: 5));
      await settle(tester);
      expect(find.text('7:05'), findsOneWidget);
      engine.emitPosition(const Duration(minutes: 7, seconds: 9));
      await settle(tester);
      expect(find.text('7:09'), findsOneWidget);

      engine.hangSeeks = false;
      await disposeApp(tester);
    },
  );

  testWidgets(
    'playlist mark follows adding to and removing from playlists',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      final playlists = container.read(playlistRepositoryProvider);
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      final first = await tester.runAsync(() => playlists.create('Eins'));
      final second = await tester.runAsync(() => playlists.create('Zwei'));
      final episode = await tester.runAsync(
        () => (db.select(
          db.episodes,
        )..where((e) => e.title.equals('Erste Folge'))).getSingle(),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);

      final mark = find.byTooltip('In einer Playlist');
      expect(mark, findsNothing);

      await tester.runAsync(() => playlists.add(first!, episode!.id));
      await tester.runAsync(() => playlists.add(second!, episode!.id));
      await settle(tester);
      // One mark for the episode, however many playlists contain it.
      expect(mark, findsOneWidget);

      await tester.runAsync(() => playlists.remove(first!, episode!.id));
      await settle(tester);
      expect(mark, findsOneWidget);

      await tester.runAsync(() => playlists.remove(second!, episode!.id));
      await settle(tester);
      expect(mark, findsNothing);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'show notes in the episode menu and in the player',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await tester.runAsync(() async {
        final episode = await db.select(db.episodes).getSingle();
        await db
            .into(db.episodeNotes)
            .insert(
              EpisodeNotesCompanion.insert(
                episodeId: Value(episode.id),
                notes: 'Darin: Testthemen \uE000Mehr\uE001https://example.com/x\uE002',
              ),
            );
      });
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);

      await tester.longPress(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.text('Beschreibung'));
      await settle(tester);
      final notes = find.textContaining(
        'Darin: Testthemen',
        findRichText: true,
      );
      expect(notes, findsOneWidget);
      // The link shows only its text, not the address.
      expect(
        find.textContaining('example.com', findRichText: true),
        findsNothing,
      );
      Navigator.of(tester.element(notes)).pop();
      await settle(tester);

      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);
      // Collapsed at first; the text appears when opened.
      expect(notes, findsNothing);
      await tester.ensureVisible(find.text('Beschreibung'));
      await tester.tap(find.text('Beschreibung'));
      await settle(tester);
      expect(notes, findsOneWidget);
      // On top: number as on the cover (own count: 1) and the date.
      expect(find.text('Folge 1 · 10. Juni 2025'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'started elsewhere: the playlist is only offered until tapped',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      final playlists = container.read(playlistRepositoryProvider);
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      final list = await tester.runAsync(() => playlists.create('Unterwegs'));
      final first = await tester.runAsync(
        () => db.select(db.episodes).getSingle(),
      );
      // Older episodes first in the playlist, so the jump has to scroll.
      // One batch each: many single awaits in runAsync hang the test.
      await tester.runAsync(
        () => db.batch(
          (b) => b.insertAll(db.episodes, [
            for (var i = 0; i < 25; i++)
              EpisodesCompanion.insert(
                podcastId: first!.podcastId,
                guid: 'alt-$i',
                title: 'Alte Folge $i',
                audioUrl: 'https://example.com/alt-$i.mp3',
                pubDate: Value(DateTime.utc(2020, 1, 1 + i)),
                addedAt: DateTime.utc(2026),
              ),
          ]),
        ),
      );
      final older = await tester.runAsync(
        () =>
            (db.select(db.episodes)
                  ..where((e) => e.guid.like('alt-%'))
                  ..orderBy([(e) => OrderingTerm.asc(e.pubDate)]))
                .get(),
      );
      await tester.runAsync(
        () => db.batch(
          (b) => b.insertAll(db.playlistItems, [
            for (final (i, e) in [...older!, first!].indexed)
              PlaylistItemsCompanion.insert(
                playlistId: list!,
                episodeId: e.id,
                position: i,
                addedAt: DateTime.utc(2026),
              ),
          ]),
        ),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);

      final row = find.text('Aus Playlist „Unterwegs“');
      Finder dimmed() => find.ancestor(
        of: row,
        matching: find.byWidgetPredicate(
          (w) => w is Opacity && w.opacity == 0.5,
        ),
      );
      expect(row, findsOneWidget);
      expect(dimmed(), findsOneWidget);
      expect(handler.activePlaylistId, isNull);

      await tester.tap(row);
      await settle(tester);
      expect(dimmed(), findsNothing);
      expect(handler.activePlaylistId, list);
      expect(find.text('Playlist „Unterwegs“ ist aktiviert'), findsOneWidget);

      // ⏮ ⏭ follow the active playlist: last entry → only ⏮ (2026-10-06).
      IconButton button(String tooltip) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );
      expect(button('Vorherige Folge').onPressed, isNotNull);
      expect(button('Nächste Folge').onPressed, isNull);

      // Active: the playlist symbol closes the player and shows the
      // playlist, scrolled to this episode (user wish 2026-10-06).
      await tester.tap(find.byTooltip('Playlist öffnen'));
      await settle(tester);
      expect(find.byType(PlayerScreen), findsNothing);
      expect(find.text('Unterwegs'), findsOneWidget); // app bar
      // (The mini player shows the title too.)
      final target = find.descendant(
        of: find.byType(PlaylistScreen),
        matching: find.text('Erste Folge'),
      );
      expect(target, findsOneWidget);
      // Fully visible above the mini player (as the last entry it cannot
      // move further up than the end of the list allows).
      final rect = tester.getRect(target);
      expect(rect.top, greaterThan(0));
      expect(
        rect.bottom,
        lessThan(tester.getRect(find.byType(MiniPlayer)).top),
      );
      expect(find.text('Alte Folge 0'), findsNothing); // scrolled away

      await disposeApp(tester);
    },
  );

  testWidgets(
    'tapping the remaining time shows the total length, remembered',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);

      Future<String?> stored() async => tester.runAsync<String?>(
        () => SettingsRepository(db).get(SettingsKeys.showTotalTime),
      );
      final remaining = find.textContaining(RegExp(r'^-\d'));
      expect(remaining, findsOneWidget);
      expect(await stored(), isNull);

      await tester.tap(remaining);
      await settle(tester);
      // Feed length (the fake player's 10 min count as a wrong estimate).
      expect(remaining, findsNothing);
      expect(find.text('1:05:00'), findsOneWidget);
      expect(await stored(), 'true');

      await tester.tap(find.text('1:05:00'));
      await settle(tester);
      expect(remaining, findsOneWidget);
      expect(await stored(), isNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'speed button: choice is shown, remaining time gets the real time',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.byType(MiniPlayer));
      await settle(tester);

      expect(find.text('-1:05:00'), findsOneWidget);
      await tester.ensureVisible(find.text('Tempo: Aus'));
      await tester.tap(find.text('Tempo: Aus'));
      await settle(tester);
      expect(find.text('Aus (1,0x)'), findsOneWidget);
      await tester.tap(find.text('1,5x'));
      await settle(tester);
      Navigator.of(tester.element(find.text('Abspielgeschwindigkeit'))).pop();
      await settle(tester);

      expect(find.text('Tempo: 1,5x'), findsOneWidget);
      expect(handler.speed, 1.5);
      // 65 min at 1.5x take 43:20.
      expect(find.text('-1:05:00 (-43:20)'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'podcast page links to the website and the support page',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      await tester.runAsync(
        () => db
            .update(db.podcasts)
            .write(
              const PodcastsCompanion(
                websiteUrl: Value('https://www.example.com/podcast'),
                fundingUrl: Value('https://steadyhq.com/de/p'),
                fundingLabel: Value('Unterstütze uns auf Steady'),
              ),
            ),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);

      await tester.tap(find.text('example.com'));
      await settle(tester);
      await tester.tap(find.text('Unterstütze uns auf Steady'));
      await settle(tester);
      expect(appPlatform.opened, [
        'https://www.example.com/podcast',
        'https://steadyhq.com/de/p',
      ]);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'seasons: chips filter, listening order, labels on the cover',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://seasons.example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Staffel-Podcast'));
      await settle(tester);

      // Serial: listening order, not newest first.
      double top(String title) => tester.getTopLeft(find.text(title)).dy;
      expect(
        top('Erste Staffel Teil 1'),
        lessThan(top('Erste Staffel Teil 2')),
      );
      expect(top('Erste Staffel Teil 2'), lessThan(top('Neue Staffel Teil 1')));
      expect(find.text('S1·1'), findsOneWidget);
      expect(find.text('S2·1'), findsOneWidget);

      // The chip row scrolls sideways (wide test font).
      final season2 = find.widgetWithText(ChoiceChip, 'Staffel 2');
      await tester.ensureVisible(season2);
      await tester.tap(season2);
      await settle(tester);
      expect(find.text('Neue Staffel Teil 1'), findsOneWidget);
      expect(find.text('Erste Staffel Teil 1'), findsNothing);

      final all = find.widgetWithText(ChoiceChip, 'Alle');
      await tester.ensureVisible(all);
      await tester.tap(all);
      await settle(tester);
      expect(find.text('Erste Staffel Teil 1'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'while a playlist plays: "play next" and "add to the end" in the menu',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      final playlists = container.read(playlistRepositoryProvider);
      final podcastId = await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      final first = (await tester.runAsync(
        () => db.select(db.episodes).getSingle(),
      ))!.id;
      Future<int> add(String guid, int day) async => (await tester.runAsync(
        () => db
            .into(db.episodes)
            .insert(
              EpisodesCompanion.insert(
                podcastId: podcastId!,
                guid: guid,
                title: 'Folge $guid',
                audioUrl: 'https://example.com/$guid.mp3',
                pubDate: Value(DateTime.utc(2025, 6, day)),
                addedAt: DateTime.now(),
              ),
            ),
      ))!;
      final later = await add('später', 11);
      final extra = await add('extra', 12);
      final list = (await tester.runAsync(
        () => db.select(db.playlists).getSingle(),
      ))!.id;
      await tester.runAsync(() => playlists.addAll(list, [first, later]));
      final ids = (first: first, later: later, extra: extra, list: list);
      // Start the first episode from the playlist, like a user.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Playlists'));
      await settle(tester);
      await tester.tap(find.text('Wiedergabeliste'));
      await settle(tester);
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      expect(handler.activePlaylistId, ids.list);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      // The mini player shows the podcast name too.
      await tester.tap(find.text('Widget-Podcast').first);
      await settle(tester);

      // Not in the playlist yet: both entries, "end" enabled.
      await tester.longPress(find.text('Folge extra'));
      await settle(tester);
      expect(find.text('Als Nächstes spielen'), findsOneWidget);
      await tester.tap(find.text('Als Nächstes spielen'));
      await settle(tester);
      Future<List<int>> order() async => [
        for (final e in (await tester.runAsync(
          () => playlists.entries(ids.list),
        ))!)
          e.item.episodeId,
      ];
      expect(await order(), [ids.first, ids.extra, ids.later]);

      // Now in it: "add to the end" is disabled.
      await tester.longPress(find.text('Folge extra'));
      await settle(tester);
      final append = tester.widget<ListTile>(
        find.widgetWithText(
          ListTile,
          'Ans Ende der Playlist „Wiedergabeliste“ anfügen',
        ),
      );
      expect(append.enabled, isFalse);
      Navigator.of(tester.element(find.text('Als Nächstes spielen'))).pop();
      await settle(tester);

      // The currently playing episode gets no queue entries.
      await tester.longPress(find.text('Erste Folge').first);
      await settle(tester);
      expect(find.text('Als Nächstes spielen'), findsNothing);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'Optionen → Abspielverlauf lists played episodes, tap plays again',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      await tester.ensureVisible(find.text('Abspielverlauf'));
      await tester.tap(find.text('Abspielverlauf'));
      await settle(tester);
      expect(find.text('Noch keine Folge zu Ende gehört'), findsOneWidget);

      final episode = await tester.runAsync(
        () => db.select(db.episodes).getSingle(),
      );
      await tester.runAsync(
        () =>
            container.read(historyRepositoryProvider).addFinished(episode!.id),
      );
      await settle(tester);
      expect(find.text('Erste Folge'), findsOneWidget);

      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      expect(handler.currentEpisodeId, episode!.id);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'the progress bar keeps its width with or without a status symbol',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      // In progress (bar visible), no symbol on the right.
      await tester.runAsync(
        () => db
            .update(db.episodes)
            .write(
              const EpisodesCompanion(
                status: Value(EpisodeStatus.inProgress),
                positionMs: Value(600000),
              ),
            ),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      final bar = find.byType(LinearProgressIndicator);
      final without = tester.getSize(bar).width;

      // Now playing: the "now playing" symbol appears on the right.
      await tester.tap(find.text('Erste Folge'));
      await settle(tester);
      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
      expect(tester.getSize(bar.first).width, without);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'podcast page menu: play all unplayed episodes',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      expect(find.text('Alle neuen Episoden abspielen'), findsOneWidget);
      expect(
        find.text('Ungespielte Episoden seit … abspielen'),
        findsOneWidget,
      );
      await tester.tap(find.text('Alle ungespielten Episoden abspielen'));
      await settle(tester);

      // Only one playlist: no chooser, it plays right away.
      final episode = await tester.runAsync(
        () => db.select(db.episodes).getSingle(),
      );
      expect(handler.currentEpisodeId, episode!.id);
      expect(handler.playbackState.value.playing, isTrue);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'long press on a subscription: unplayed episodes into a playlist',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      final second = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).create('Unterwegs'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);

      await tester.longPress(find.text('Widget-Podcast'));
      await settle(tester);
      expect(find.text('Alle neuen Episoden in Playlist'), findsOneWidget);
      // Only the initial import so far: nothing is "new".
      expect(
        find.text('Keine neuen Folgen in den letzten 96 Stunden'),
        findsOneWidget,
      );

      await tester.tap(find.text('Alle ungespielten Episoden in Playlist'));
      await settle(tester);
      // Two playlists: the user chooses.
      await tester.tap(find.text('Unterwegs'));
      await settle(tester);

      final entries = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).entries(second!),
      );
      final episodes = await tester.runAsync(
        () => db.select(db.episodes).get(),
      );
      expect(entries, hasLength(episodes!.length));
      expect(entries!.first.item.playlistId, second);
      // Only added: nothing starts playing (user wish 2026-10-03).
      expect(handler.currentEpisodeId, isNull);
      expect(handler.playbackState.value.playing, isFalse);
      expect(find.textContaining('zu „Unterwegs“ hinzugefügt'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'long press → unplayed episodes since a chosen date',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      final podcastId = await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      // Two more episodes: the day before this month began, and today.
      final today = DateTime.now();
      final monthStart = DateTime(today.year, today.month);
      await tester.runAsync(
        () => db.batch(
          (b) => b.insertAll(db.episodes, [
            for (final (guid, date) in [
              ('alt', monthStart.subtract(const Duration(days: 1))),
              ('neu', DateTime(today.year, today.month, today.day)),
            ])
              EpisodesCompanion.insert(
                podcastId: podcastId!,
                guid: guid,
                title: 'Folge $guid',
                audioUrl: 'https://example.com/$guid.mp3',
                pubDate: Value(date),
                addedAt: today,
              ),
          ]),
        ),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);

      await tester.longPress(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.text('Ungespielte Episoden seit … in Playlist'));
      await settle(tester);

      // The calendar opens on this month: pick its first day.
      await tester.tap(find.text('1').last);
      await settle(tester);
      await tester.tap(find.text('OK'));
      await settle(tester);

      // Only one playlist exists: no chooser, straight into it.
      final playlist = await tester.runAsync(
        () => db.select(db.playlists).getSingle(),
      );
      final entries = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).entries(playlist!.id),
      );
      expect(entries!.map((e) => e.episode.guid), ['neu']);
      expect(handler.playbackState.value.playing, isFalse);
      expect(find.textContaining('1 Folge zu'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'typing a date offers a keyboard with "." (Samsung)',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 2; // the text-input dialog needs some height
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.longPress(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.text('Ungespielte Episoden seit … in Playlist'));
      await settle(tester);
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await settle(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.text);

      await tester.tap(find.text('Abbrechen'));
      await settle(tester);
      await disposeApp(tester);
    },
  );

  testWidgets('the "Neu" dot marks only fresh episodes', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    final podcastId = await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('Widget-Podcast'));
    await settle(tester);
    // Only the initial import: unplayed, but not fresh → no dot.
    expect(find.text('Erste Folge'), findsOneWidget);
    expect(find.byTooltip('Neu'), findsNothing);

    // A later refresh brings a new episode → dot.
    final podcast = await tester.runAsync(
      () => db.select(db.podcasts).getSingle(),
    );
    await tester.runAsync(
      () => db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId!,
              guid: 'frisch',
              title: 'Frische Folge',
              audioUrl: 'https://example.com/frisch.mp3',
              pubDate: Value(DateTime.now()),
              addedAt: podcast!.subscribedAt.add(const Duration(minutes: 1)),
            ),
          ),
    );
    await settle(tester);
    expect(find.text('Frische Folge'), findsOneWidget);
    expect(find.byTooltip('Neu'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('the progress bar appears only from 15 s on', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
              .read(podcastRepositoryProvider)
              .subscribe('https://example.com/feed'),
    );
    await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
    await settle(tester);
    await tester.tap(find.text('Widget-Podcast'));
    await settle(tester);
    Future<void> setEpisode(int positionMs) async {
      await tester.runAsync(
        () => db
            .update(db.episodes)
            .write(
              EpisodesCompanion(
                status: const Value(EpisodeStatus.inProgress),
                positionMs: Value(positionMs),
                durationMs: const Value(600000),
              ),
            ),
      );
      await settle(tester);
    }

    // "In progress" but rewound to the start: no empty bar.
    await setEpisode(0);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await setEpisode(14999);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await setEpisode(15000);
    expect(find.byType(LinearProgressIndicator), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets(
    'a finished episode shows as played, not as playing',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.text('Erste Folge').first);
      await settle(tester);
      expect(find.byTooltip('Läuft gerade'), findsOneWidget);

      // Streamed to the end, nothing follows.
      await tester.runAsync(() async {
        engine.complete();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await settle(tester);

      expect(
        handler.currentEpisodeId,
        isNotNull,
        reason: 'still in the mini player',
      );
      expect(find.byTooltip('Läuft gerade'), findsNothing);
      expect(find.byTooltip('Gespielt'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'marks played episodes as unplayed since a date',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final podcastId = await tester.runAsync(
        () => ProviderScope.containerOf(
          tester.element(find.byType(NavigationBar)),
        ).read(podcastRepositoryProvider).subscribe('https://example.com/feed'),
      );
      final today = DateTime.now();
      await tester.runAsync(
        () => db
            .into(db.episodes)
            .insert(
              EpisodesCompanion.insert(
                podcastId: podcastId!,
                guid: 'heute',
                title: 'Heutige Folge',
                audioUrl: 'https://example.com/heute.mp3',
                pubDate: Value(DateTime(today.year, today.month, today.day, 6)),
                status: const Value(EpisodeStatus.played),
                playedAt: Value(today),
                addedAt: today,
              ),
            ),
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Abos'));
      await settle(tester);
      await tester.tap(find.text('Widget-Podcast'));
      await settle(tester);
      await tester.tap(find.byType(PopupMenuButton<void>));
      await settle(tester);
      // Right below "Als gespielt markieren bis …".
      expect(find.text('Als gespielt markieren bis …'), findsOneWidget);
      await tester.tap(find.text('Als ungespielt markieren seit …'));
      await settle(tester);

      // Calendar opens on today: confirm.
      await tester.tap(find.text('OK'));
      await settle(tester);
      expect(
        find.textContaining('1 gespielte Folge seit einschließlich'),
        findsOneWidget,
      );
      await tester.tap(find.text('Markieren'));
      await settle(tester);

      expect(find.text('1 Folge als ungespielt markiert'), findsOneWidget);
      final episode = await tester.runAsync(
        () => (db.select(
          db.episodes,
        )..where((e) => e.guid.equals('heute'))).getSingle(),
      );
      expect(episode!.status, EpisodeStatus.newEpisode);

      await disposeApp(tester);
    },
  );

  testWidgets('playlist menu: sort and download everything', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
    );
    final podcastId = await tester.runAsync(
      () => container
          .read(podcastRepositoryProvider)
          .subscribe('https://example.com/feed'),
    );
    final playlistId = (await tester.runAsync(
      () => db.select(db.playlists).getSingle(),
    ))!.id;
    // One write only: a second statement inside runAsync would wait for the
    // database lock held by the app's live queries in the paused fake time.
    await tester.runAsync(
      () => db.batch((b) {
        for (final (i, (guid, year)) in [
          ('Alt', 2020),
          ('Neu', 2026),
        ].indexed) {
          b
            ..insert(
              db.episodes,
              EpisodesCompanion.insert(
                id: Value(1000 + i),
                podcastId: podcastId!,
                guid: guid,
                title: 'Folge $guid',
                audioUrl: 'https://example.com/$guid.mp3',
                pubDate: Value(DateTime.utc(year)),
                addedAt: DateTime.now(),
              ),
            )
            ..insert(
              db.playlistItems,
              PlaylistItemsCompanion.insert(
                playlistId: playlistId,
                episodeId: 1000 + i,
                position: i,
                addedAt: DateTime.now(),
              ),
            );
        }
      }),
    );
    Future<List<String>> order() async => [
      for (final e in (await tester.runAsync(
        () => container.read(playlistRepositoryProvider).entries(playlistId),
      ))!)
        e.episode.title,
    ];

    await tester.tap(find.widgetWithText(NavigationDestination, 'Playlists'));
    await settle(tester);
    await tester.tap(find.text('Wiedergabeliste'));
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>).last);
    await settle(tester);
    for (final entry in [
      'Aufsteigend nach Datum sortieren',
      'Absteigend nach Datum sortieren',
      'Aufsteigend nach Namen sortieren',
      'Alles downloaden',
      'Umbenennen',
      'Playlist löschen',
    ]) {
      expect(find.text(entry), findsOneWidget, reason: entry);
    }
    await tester.tap(find.text('Absteigend nach Datum sortieren'));
    await settle(tester);
    expect(await order(), ['Folge Neu', 'Folge Alt']);
    expect(find.textContaining('neueste zuerst'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<void>).last);
    await settle(tester);
    await tester.tap(find.text('Alles downloaden'));
    await settle(tester);
    expect(
      find.textContaining('2 Folgen aus „Wiedergabeliste“'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Herunterladen'));
    await settle(tester);
    expect(downloadEngine.active, hasLength(2));
    expect(find.text('2 Downloads gestartet.'), findsOneWidget);

    // Overview menu: no sort options, "Fortsetzen" instead.
    container.read(routerProvider).go(Routes.playlists);
    await settle(tester);
    await tester.runAsync(
      () => container
          .read(playlistRepositoryProvider)
          .setLastEpisode(playlistId, 1000),
    );
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    expect(find.text('Aufsteigend nach Datum sortieren'), findsNothing);
    expect(find.text('Alles downloaden'), findsOneWidget);
    await tester.tap(find.text('Fortsetzen'));
    await settle(tester);
    // 1000 ("Folge Alt") is second after the sort, but it was played last.
    expect(handler.currentEpisodeId, 1000);
    expect(handler.activePlaylistId, playlistId);

    await disposeApp(tester);
  });

  testWidgets('a playlist gets a category color', timeout: timeout, (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Playlists'));
    await settle(tester);
    // The tile's gradient (null = no color).
    Gradient? tileGradient() =>
        (tester
                    .widget<Ink>(
                      find.ancestor(
                        of: find.widgetWithText(ListTile, 'Wiedergabeliste'),
                        matching: find.byType(Ink),
                      ),
                    )
                    .decoration!
                as BoxDecoration)
            .gradient;
    expect(tileGradient(), isNull);

    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Farbe…'));
    await settle(tester);
    for (final name in [
      'Rot',
      'Orange',
      'Gelb',
      'Grün',
      'Blau',
      'Indigo',
      'Violett',
      'Keine Farbe',
    ]) {
      expect(find.byTooltip(name), findsOneWidget, reason: name);
    }
    await tester.tap(find.byTooltip('Grün'));
    await settle(tester);
    final playlist = await tester.runAsync(
      () => db.select(db.playlists).getSingle(),
    );
    expect(playlist!.color, PlaylistColor.green);
    // Green, fading to transparent.
    final colors = (tileGradient()! as LinearGradient).colors;
    expect(colors.first.a, greaterThan(0));
    expect(colors.last.a, 0);
    expect(colors.first.g, greaterThan(colors.first.r));

    // The playlist's own screen: tinted app bar, gradient below.
    await tester.tap(find.text('Wiedergabeliste'));
    await settle(tester);
    expect(
      tester.widget<AppBar>(find.byType(AppBar).last).backgroundColor,
      isNotNull,
    );
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Ink &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).gradient is LinearGradient,
      ),
      findsOneWidget,
    );

    // "Keine Farbe" removes it again.
    ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
        .read(routerProvider)
        .go(Routes.playlists);
    await settle(tester);
    await tester.tap(find.byType(PopupMenuButton<void>));
    await settle(tester);
    await tester.tap(find.text('Farbe…'));
    await settle(tester);
    await tester.tap(find.byTooltip('Keine Farbe'));
    await settle(tester);
    expect(tileGradient(), isNull);

    await disposeApp(tester);
  });

  testWidgets(
    'a download can be added to a chosen playlist',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await tester.runAsync(
        () => container
            .read(podcastRepositoryProvider)
            .subscribe('https://example.com/feed'),
      );
      final second = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).create('Unterwegs'),
      );
      await tester.runAsync(
        () => container
            .read(playlistRepositoryProvider)
            .setColor(second!, PlaylistColor.blue),
      );
      await settle(tester);

      await tester.longPress(find.text('Erste Folge'));
      await settle(tester);
      await tester.tap(find.text('Herunterladen'));
      await settle(tester);
      final episodeId = downloadEngine.active.keys.single;
      await tester.runAsync(
        () => downloadEngine.finish(episodeId, bytes: 2048),
      );
      await settle(tester);

      await tester.tap(find.widgetWithText(NavigationDestination, 'Downloads'));
      await settle(tester);
      await tester.tap(find.byTooltip('Zu Playlist hinzufügen…'));
      await settle(tester);
      // Two playlists: the known chooser, colored playlists tinted there too.
      Gradient? gradientOf(String name) =>
          (tester
                      .widget<Ink>(
                        find.ancestor(
                          of: find.widgetWithText(ListTile, name),
                          matching: find.byType(Ink),
                        ),
                      )
                      .decoration!
                  as BoxDecoration)
              .gradient;
      expect(gradientOf('Unterwegs'), isA<LinearGradient>());
      expect(gradientOf('Wiedergabeliste'), isNull);
      await tester.tap(find.text('Unterwegs'));
      await settle(tester);

      expect(find.text('Zu „Unterwegs“ hinzugefügt'), findsOneWidget);
      final entries = await tester.runAsync(
        () => container.read(playlistRepositoryProvider).entries(second!),
      );
      expect(entries!.map((e) => e.episode.id), [episodeId]);

      // Opening the chooser again: ✅ marks the playlist that has it.
      await tester.tap(find.byTooltip('Zu Playlist hinzufügen…'));
      await settle(tester);
      expect(find.text('Unterwegs ✅', findRichText: true), findsOneWidget);
      expect(find.text('Wiedergabeliste', findRichText: true), findsOneWidget);
      expect(find.text('Wiedergabeliste ✅', findRichText: true), findsNothing);

      // Choosing it again asks to remove it; "Abbrechen" keeps it.
      Future<List<int>> inSecond() async => [
        for (final e in (await tester.runAsync(
          () => container.read(playlistRepositoryProvider).entries(second!),
        ))!)
          e.episode.id,
      ];
      await tester.tap(find.text('Unterwegs ✅', findRichText: true));
      await settle(tester);
      expect(find.text('Aus Playlist entfernen?'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await settle(tester);
      expect(await inSecond(), [episodeId]);

      await tester.tap(find.byTooltip('Zu Playlist hinzufügen…'));
      await settle(tester);
      await tester.tap(find.text('Unterwegs ✅', findRichText: true));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Entfernen'));
      await settle(tester);
      expect(find.text('Aus „Unterwegs“ entfernt'), findsOneWidget);
      expect(await inSecond(), isEmpty);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'Optionen → Info: version, developer and links',
    timeout: timeout,
    (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      await tester.scrollUntilVisible(find.text('Über die App'), 300);
      await settle(tester);
      await tester.tap(find.text('Über die App'));
      await settle(tester);

      // Version comes from Android (here: the fake), not from a constant.
      expect(find.text('Version 1.2.0 (Build 3)'), findsOneWidget);
      expect(find.text('Entwickelt von Artem A.'), findsOneWidget);
      // No payment link in the app – support is offered on GitHub.
      expect(find.textContaining('PayPal'), findsNothing);
      expect(find.textContaining('Trinkgeld'), findsNothing);

      await tester.tap(find.text('Quellcode auf GitHub'));
      await settle(tester);
      await tester.tap(find.text('Datenschutzerklärung'));
      await settle(tester);
      expect(appPlatform.opened, [sourceCodeUrl, privacyPolicyUrl]);

      await disposeApp(tester);
    },
  );
}

Future<void> handlerSeek(
  WidgetTester tester,
  PodcastAudioHandler handler,
  Duration position,
) async {
  await tester.runAsync(() => handler.seek(position));
  await settle(tester);
}
