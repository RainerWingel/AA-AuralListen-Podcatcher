# Architektur

## Tech-Stack
| Bereich | Wahl | C#-Analogie |
|---------|------|-------------|
| Framework | Flutter stable 3.47.5, Dart 3.13 | – |
| State / DI | Riverpod | DI-Container + ViewModels |
| Datenbank | Drift (SQLite, typisiert, Migrationen, reaktive Queries) | EF Core |
| HTTP | `http` | HttpClient |
| RSS/OPML | `xml` + eigener Parser (volle Kontrolle über Namespaces) | XDocument |
| Audio | `just_audio` + `audio_service` | – |
| Downloads | `background_downloader` | – |
| Dateien | `path_provider`, `file_picker`, `share_plus`, `archive` | System.IO |
| Bilder | `cached_network_image` mit begrenztem Cache-Manager | – |
| Routing | `go_router` | – |
| Texte | `flutter gen-l10n`, nur `de` | .resx |
| Tests | `flutter_test`, `leak_tracker`, `mocktail` | xUnit + Moq |

Exakte Versionen stehen in `pubspec.lock`. Neue Pakete nur nach Rückfrage (siehe AGENTS.md).

## Ordnerstruktur
```
lib/
  main.dart
  app/            # App-Widget, Routing (router.dart, routes.dart), Theme, AppShell
  core/           # Logging, Fehler, Konstanten, Hilfsfunktionen
  data/
    providers.dart          # Riverpod-Provider der Datenschicht (DB, HTTP, Repository, Streams)
    podcast_repository.dart # Abos, Refresh, Folgen-Abfragen
    db/           # Drift-Datenbank, Tabellen, Migrationen
    feed/         # RSS-/OPML-Parser, Feed-Fetcher
    directory/    # iTunes, fyyd, Podcast Index
    storage/      # cover_cache, download_engine (Paket-Kapsel), download_service (Downloads + Eviction)
  audio/          # PodcastAudioHandler (Logik), PlayerEngine (just_audio-Kapsel), audio_providers.dart
  features/       # je Feature: Screens, Widgets, Provider
    subscriptions/ search/ episodes/ player/ playlists/
    downloads/ bookmarks/ settings/ backup/
  l10n/           # app_de.arb
test/             # spiegelt lib/
```

## Schichten-Regeln
- UI (Widgets) → Riverpod-Provider → Services/Repositories → DB / Netz / Dateisystem.
- Widgets greifen nie direkt auf DB, HTTP oder Dateien zu.
- Die **Datenbank ist die einzige Wahrheit**. Dateien werden mit ihr abgeglichen (`eviction.md`).
- Genau **eine** Player-Instanz für die gesamte Laufzeit (`playback.md`).
- Zeit (`DateTime.now`) über einen injizierbaren `Clock`-Provider, damit Eviction-Regeln (96 h) testbar sind.

## Riverpod-Konventionen
- App-weite Dienste: `Provider` mit `ref.onDispose(...)` zum Schließen (DB, HTTP-Client, Router).
- Bildschirm-Daten: `StreamProvider.autoDispose` (bzw. `.family`) über Drift-`watch()`-Abfragen –
  die UI aktualisiert sich automatisch bei DB-Änderungen, und die Abfrage endet, wenn niemand mehr zuhört.
- Aktionen (abonnieren, refresh) ruft die UI direkt am Repository auf: `ref.read(podcastRepositoryProvider).…`.
- Wiedergabe-Aktionen immer über `ref.read(audioHandlerProvider)` – nie einen eigenen Player anlegen.
- `audioHandlerProvider` wirft ohne Override: in `main()` und in Widget-Tests wird er gesetzt (Tests: `FakePlayerEngine`).

## Navigation & Dialoge (Stolperfalle!)
- Jeder Tab hat einen **eigenen, verschachtelten Navigator** (`StatefulShellRoute`). `showDialog` legt Dialoge dagegen
  auf den **Root-Navigator**.
- Einen Dialog daher nur über seinen eigenen `builder`-Context schließen – oder, wenn man es von außen tut, mit
  `Navigator.of(context, rootNavigator: true).pop()`. Ein `Navigator.of(screenContext).pop()` entfernt sonst die
  Seite des Tabs statt des Dialogs → schwarzer Bildschirm (Fehler beim OPML-Import, siehe Regressionstest in `test/widget_test.dart`).

- Popup-Menüs: In `itemBuilder` den Parameter nicht `context` nennen (`(_) => …`) und in `onTap` den Context des
  Bildschirms benutzen – der Context des Menüs verschwindet beim Schließen.

## Tests
- Unit-Tests mit `NativeDatabase.memory()` und `MockClient` aus `package:http/testing.dart` (kein Netz).
- Widget-Tests mit Drift: **nicht** `pumpAndSettle` (hängt, solange ein Ladekreis auf SQLite wartet), sondern den
  `settle()`-Helfer aus `test/widget_test.dart`; DB im `tearDown` schließen, nicht im Test selbst (hängt sonst).
  Test-Feeds ohne Bilder verwenden (Bild-Cache braucht Plugins, die es im Test nicht gibt).
- Immer ein `timeout` an Widget-Tests setzen.
- Widget-Tests, die Bildschirme mit viel Inhalt bedienen, auf S25-Größe stellen
  (`tester.view.physicalSize = Size(1080, 2340)`, `devicePixelRatio = 3`) – sonst liegen Buttons außerhalb und Taps gehen ins Leere.
- Vor dem Abbau `handler.stop()` aufrufen (beendet den 10-Minuten-Pause-Timer).
- Neue Logik mit Mutationsprobe absichern: absichtlich einen Wert ändern (z. B. 98 % → 99 %) – mindestens ein Test muss rot werden.
