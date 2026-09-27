# AGENTS.md – Einstieg für KI-Agenten (Claude, ChatGPT/Codex)

Diese Datei ist bewusst **kurz**. Sie enthält nur die Grundregeln und ein Inhaltsverzeichnis.
Alles Fachliche steht in Themen-Dateien unter `docs/`.

## So arbeitest du mit der Doku
1. Lies zu Beginn jeder Aufgabe **nur** die Themen-Dateien aus der Tabelle unten, die für die Aufgabe relevant sind –
   nicht pauschal alle. Im Zweifel `docs/roadmap.md` + das passende Fachthema.
2. Wenn deine Änderung ein Thema betrifft (neues Verhalten, geänderte Regel, neue Tabelle …), **aktualisiere die
   betreffende Themen-Datei im selben Commit**. Doku und Code dürfen nie auseinanderlaufen.
3. Gibt es für etwas noch kein Thema, lege eine neue Datei `docs/<thema>.md` an und trage sie in die Tabelle unten ein.
4. Schreibe fachliche Details **nicht** in diese AGENTS.md. Hier landen nur neue Grundregeln oder Tabellenzeilen.
5. Entscheidungen, die in `docs/decisions.md` stehen, rollst du nicht neu auf. Schlage dem Benutzer Änderungen vor.

## Themen-Index
| Datei | Inhalt | Lesen bei … |
|-------|--------|-------------|
| `docs/roadmap.md` | Meilensteine, Checklisten, offene Punkte | jeder Aufgabe (Was ist dran?) |
| `docs/features.md` | Funktionsumfang: Muss / Soll / bewusst nicht | neuen Funktionen, Umfangsfragen |
| `docs/architecture.md` | Tech-Stack, Pakete, Ordnerstruktur, Schichten | neuem Code, neuen Paketen |
| `docs/data-model.md` | Datenbank-Tabellen, Episoden-Status, Migrationen | DB-Änderungen |
| `docs/eviction.md` | Datenträger- und Arbeitsspeicher-Regeln, Auto-Löschen | Downloads, Dateien, Caches, Streams, `dispose` |
| `docs/playback.md` | Player, Sprünge, Boost, Hörposition, Kapitel, Lesezeichen | Audio-Code |
| `docs/playlists.md` | Playlist-Verhalten, Weiterspielen, „gespielt"-Regel | Playlists, Warteschlange |
| `docs/feeds-and-directories.md` | RSS, OPML, Verzeichnis-Suche, API-Keys | Feeds, Suche, Import/Export |
| `docs/ui-ux.md` | Navigation, Screens, Castbox-Vorbild, Texte | UI-Arbeit |
| `docs/build-and-release.md` | Gerät, Signatur, CI, Secrets, Installation | Build, CI, Release |
| `docs/git-workflow.md` | Branches, Commits, PRs, Übergabe zwischen Agenten | jedem Commit |
| `docs/decisions.md` | Entscheidungslog | vor Architektur-/Umfangsänderungen |

## Grundregeln (immer gültig)
- **Benutzer:** kommt aus C#/.NET, kennt Dart/Flutter nicht, reviewt statt selbst zu coden.
  Mit ihm **Deutsch** sprechen, gern mit C#-Vergleichen erklären.
- **Code:** Bezeichner, Kommentare, Commit-Messages auf **Englisch**. UI-Texte **Deutsch**, nur über `lib/l10n/app_de.arb`.
- **Speicherlecks sind Fehler höchster Priorität** – vor jedem Code, der Dateien, Streams, Timer, Controller oder Caches
  anlegt, `docs/eviction.md` lesen.
- **Neue Pakete** nur nach Rückfrage beim Benutzer; begründen in `docs/decisions.md`.
- **Keine Secrets ins Git** (Repo ist öffentlich!): API-Keys, Keystore, `android/key.properties`.
- **Vor jedem Commit:** `dart format .` · `flutter analyze` (0 Probleme) · `flutter test` (alle grün).
- **Nie mit uncommitteten Änderungen enden** – der andere Agent arbeitet nur mit dem, was gepusht ist
  (Details: `docs/git-workflow.md`).

## Wichtige Befehle
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Codegenerierung (Drift)
flutter analyze
flutter test
flutter run                   # auf dem verbundenen Galaxy S25 (WLAN-Debugging)
flutter build apk --release --split-per-abi   # signiert mit Release-Keystore (android/key.properties)
dart run tool/smoke_feeds.dart "Suchbegriff"  # Parser gegen echte Feeds testen
```
