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
  app/            # App-Widget, Routing, Theme
  core/           # Logging, Fehler, Konstanten, Hilfsfunktionen
  data/
    db/           # Drift-Datenbank, Tabellen, DAOs, Migrationen
    feed/         # RSS-/OPML-Parser, Feed-Fetcher
    directory/    # iTunes, fyyd, Podcast Index
    storage/      # Dateiverwaltung, Download-Service, Eviction
  audio/          # AudioHandler, Player-Service, Boost
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
