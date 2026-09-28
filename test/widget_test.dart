import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aapodcastguru/app/app.dart';
import 'package:aapodcastguru/audio/audio_providers.dart';
import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/feed/opml.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/playlist_repository.dart';
import 'package:aapodcastguru/data/providers.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:aapodcastguru/features/player/mini_player.dart';
import 'package:aapodcastguru/features/settings/opml_import_flow.dart';
import 'package:aapodcastguru/features/settings/settings_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  setUp(() {
    episodesDir = Directory.systemTemp.createTempSync('widget_episodes_');
    downloadEngine = FakeDownloadEngine(episodesDir);
    battery = FakeBatteryOptimization();
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

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          audioHandlerProvider.overrideWithValue(handler),
          downloadEngineProvider.overrideWithValue(downloadEngine),
          batteryOptimizationProvider.overrideWithValue(battery),
          episodesDirectoryProvider.overrideWithValue(() async => episodesDir),
          httpClientProvider.overrideWithValue(
            MockClient(
              (request) async => switch (request.url.host) {
                // UTF-8 bytes like a real server (the String constructor
                // would send Latin-1 and break umlauts).
                'example.com' => http.Response.bytes(utf8.encode(_feed), 200),
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
    expect(find.text('26. September 2025 · 4 Std. 5 Min.'), findsOneWidget);
    expect(
      find.text('wrint: gespräche zum runterladen – ein sehr langer Name'),
      findsOneWidget,
    );

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

    await tester.tap(find.byTooltip('Download löschen'));
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
    // Only the selected theme was queued.
    expect(downloadEngine.active, hasLength(1));

    await disposeApp(tester);
  });

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
    await tester.tap(find.text('Kapitel (2)'));
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
    await tester.ensureVisible(find.text('Kapitel (2)'));
    await tester.tap(find.text('Kapitel (2)'));
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
    await tester.tap(find.text('Als gehört markieren bis …'));
    await settle(tester);

    // Date picker opens on today; confirm it (the episode is from 2025).
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(find.textContaining('1 Folge bis einschließlich'), findsOneWidget);
    await tester.tap(find.text('Markieren'));
    await settle(tester);

    expect(find.text('1 Folge als gehört markiert'), findsOneWidget);
    final episode = await tester.runAsync(
      () => db.select(db.episodes).getSingle(),
    );
    expect(episode!.status, EpisodeStatus.played);
    expect(find.byTooltip('Gespielt'), findsOneWidget);

    await disposeApp(tester);
  });

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

    await tester.enterText(find.byType(TextField), 'example.com/neu');
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
    'first playback offers "Nicht eingeschränkt" once',
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
      expect(battery.requests, 1);

      // Pause and play again: no second automatic prompt.
      await tester.runAsync(handler.pause);
      await settle(tester);
      await tester.runAsync(handler.play);
      await settle(tester);
      expect(battery.requests, 1);

      // Optionen shows the problem; tapping asks again on purpose.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
      await settle(tester);
      expect(find.textContaining('Akku-Optimierung aktiv'), findsOneWidget);
      await tester.tap(find.text('Hintergrund-Wiedergabe'));
      await settle(tester);
      expect(battery.requests, 2);

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
}

Future<void> handlerSeek(
  WidgetTester tester,
  PodcastAudioHandler handler,
  Duration position,
) async {
  await tester.runAsync(() => handler.seek(position));
  await settle(tester);
}
