# Roadmap

Jeder Meilenstein = eigener Branch + Pull Request, CI muss grün sein. Erledigtes abhaken.

## M0 – Grundgerüst
- [x] Flutter aktualisiert (3.47.5 / Dart 3.13.4)
- [x] Projekt angelegt (`io.github.rainerwingel.aapodcastguru`, Android + iOS-Ordner)
- [x] AGENTS.md, CLAUDE.md (`@AGENTS.md`), Themen-Doku unter `docs/`
- [x] `.gitignore` für Secrets / SSH / Keystore
- [x] GitHub-Repo `RainerWingel/aa-podcast-guru` (öffentlich), erster Push
- [x] Lints verschärfen (`analysis_options.yaml`)
- [x] Grundpakete (Riverpod, go_router, intl) + App-Gerüst mit 5 Tabs, Beispiel-Counter entfernt
- [x] gen-l10n mit `app_de.arb`
- [x] GitHub Actions: analyze → test → debug-APK
- [x] Release-Keystore erzeugt
- [x] Keystore + `key.properties` extern gesichert (Benutzer, 2026-09-27)
- [x] App startet auf dem Galaxy S25 (Release-APK)

## M1 – Abos & Feeds
- [x] Drift-Schema v1 (`data-model.md`)
- [x] RSS-Parser inkl. iTunes-/Podcasting-2.0-Namespace, mit Tests (+ Smoke-Test gegen echte Feeds)
- [x] Abo per RSS-URL
- [x] Abo-Übersicht (Raster) + Podcast-Detail mit Folgenliste + Startseite „neueste Folgen"
- [x] Refresh bei App-Start + Pull-to-Refresh (ETag/Last-Modified, Redirects)
- [x] Abo kündigen (inkl. Cover-Cache)
- [x] Begrenzter Cover-Cache (300 Bilder / 30 Tage)

## M2 – Suche & Import
- [x] Suche: Apple Podcasts (iTunes) + fyyd, parallel, zusammengeführt, ohne Dubletten
- [x] Abonnieren direkt aus den Suchergebnissen
- [x] OPML-Import (Castbox-Export) mit Fortschritt und Ergebnis-Übersicht
- [x] Castbox-Export auf dem Handy importiert (Benutzer, 2026-09-27)

## M3 – Player → erste produktiv nutzbare Version
- [x] `audio_service`-Handler, Benachrichtigung, Sperrbildschirm, Bluetooth
- [x] Streaming, −15 s / +30 s, Hörposition, 98 %-Regel
- [x] Lautstärke-Boost (global + pro Podcast)
- [x] Mini-Player + Vollbild-Player
- [x] Folge antippen = abspielen; langes Drücken: Menü (als gespielt / ungespielt markieren)
- [x] DB-Schema v2 (`settings`) inkl. Migrationstest
- [x] Praxistest auf dem S25: Sperrbildschirm, Bluetooth, Anruf (Benutzer, 2026-09-28)
- [ ] Praxistest: 10 Minuten Pause → Benachrichtigung verschwindet, Play setzt an gleicher Stelle fort (Benutzer)

## M4 – Downloads & Eviction
- [x] Manueller Download (langes Drücken), Abbrechen, Löschen, erneut versuchen
- [x] Auto-Download pro Podcast (Aus / Nur WLAN / Immer, N Folgen) – Podcast-Einstellungen
- [x] Eviction komplett nach `eviction.md`: 96-h-Regel, Speicherlimit, Abgleich beim Start, Abo kündigen
- [x] Downloads-Tab mit Belegung, Optionen: Speicherlimit + „Jetzt aufräumen"
- [x] Player spielt heruntergeladene Datei statt Stream
- [x] DB-Schema v3 (`downloads`) inkl. Migrationstests
- [ ] Praxistest auf dem S25: Download im Hintergrund, Offline-Wiedergabe, Auto-Download (Benutzer)

## M5 – Playlists (Castbox-Ersatz komplett)
- [x] Mehrere Playlists (anlegen, umbenennen, löschen, sortieren), Standard „Wiedergabeliste"
- [x] Folgen hinzufügen (Folgen-Menü), sortieren (Drag & Drop), entfernen (Wischen, Rückgängig)
- [x] Weiterspielen nach `playlists.md`: gespielt → aus allen Playlists, nächste startet, dynamisch aus der DB
- [x] „Nächste Folge" (überspringen, bleibt ungespielt), aktive Playlist übersteht Neustart
- [x] DB-Schema v4 inkl. Migrationstests
- [ ] Praxistest auf dem S25 (Benutzer)

## Zusatz – Auto-Download nach Thema (WRINT)
- [x] Thema aus dem Folgen-Link, Schema v5, Migration mit erzwungenem Voll-Refresh
- [x] Checkbox-Liste in den Podcast-Einstellungen, Filter im Auto-Download
- [ ] Praxistest mit dem WRINT-Feed (Benutzer)

## Zusatz – Als gespielt markieren bis Datum / als ungespielt seit Datum
- [x] „Als ungespielt markieren seit …" (gespielte Folgen ab Datum → neu; angefangene bleiben)
- [x] Podcast-Menü → Kalender → Rückfrage mit Anzahl; Regeln wie „gespielt"

## M6 – Kapitel & Lesezeichen
- [x] Kapitel aus Feed (Podlove), JSON (url/href) und ID3-CHAP (lokal oder nur Tag per HTTP-Range)
- [x] Kapitelanzeige und -liste im Vollbild-Player, Sprung per Tippen
- [x] Lesezeichen mit Notiz, Liste pro Folge und global, Abspielen ab Lesezeichen
- [x] DB-Schema v6 inkl. Migrationstests
- [x] Praxistest Kapitel auf dem S25 (Benutzer, 2026-09-28)
## M7 – OPML-Export, Backup/Restore, Dark Mode, Feinschliff
- [x] OPML-Export über den Speichern-Dialog
- [x] Backup (ZIP: Manifest + SQLite-Schnappschuss) und Wiederherstellung ohne Neustart, alte Backups werden migriert
- [x] Dark Mode (System / Hell / Dunkel)
- [x] Praxistest Backup/Restore auf dem S25 (Benutzer, 2026-09-28)
## Zusatz – Kapitel überspringen
- [x] Chip „Skip" in der Kapitel-Liste, Sprung im Player-Handler, nur im Arbeitsspeicher
- [x] Praxistest auf dem S25 (Benutzer, 2026-09-28)

## M8 – Härtung: Leak-Tests, Soak-Test, Release-APK 1.0
- [x] Podcast-Umzug: `itunes:new-feed-url` beim Refresh/Abonnieren, Umzüge per Infobox, „Feed-Adresse ändern" (Benutzerwunsch)
- [x] Leak-Tests: leak_tracker in allen Widget-Tests, `dispose()`-Tests für Handler und Downloads
- [x] Fix: Downloads von `http://`-Links (CRE) scheiterten an Androids Klartext-Sperre
- [x] Soak-Test Refresh: 50 Refreshes, Speicher flach (`test/soak`)
- [x] Soak-Test auf dem S25: 2 h Wiedergabe mit `tool/soak_memory.sh`, kein Speicherwachstum
- [x] Eigenes App-Symbol (adaptiv, Designsymbol, Statusleiste)
- [x] Version 1.0.0: GitHub-Release `v1.0.0` mit signierter arm64-APK

## Zusatz – Akku-Optimierung
- [x] Ursache Abbruch im Dauertest: App war „Optimiert" (Samsung beendete sie nach ~40 min, Bildschirm aus)
- [x] System-Dialog „Nicht eingeschränkt" einmal beim ersten Abspielen, Status + Knopf unter Optionen → Hören
- [x] Praxistest auf dem S25 (Benutzer, 2026-09-28)

## Zusatz – Ungespielt-Zähler
- [x] Rotes Abzeichen mit Anzahl ungespielter Folgen an jeder Abo-Kachel, „99+" ab 100

## Zusatz – Hänger-Erkennung
- [x] Watchdog nur während der Wiedergabe, Neu-Laden an gleicher Stelle, Infobox bei Aufgabe / Ladefehler
- [x] Praxistest: Streamen, dann WLAN/Mobilfunk kurz aus (Benutzer, 2026-09-28)

## Zusatz – Sleep-Timer
- [x] Stoppuhr-Knopf neben „Lesezeichen setzen": Aus / 5 / 15 / 30 / 60 min (Spielzeit) / Bis Ende der Folge
- [x] Eigene Zeit 1–3600 Minuten
- [x] Ausblenden in den letzten 30 Sekunden (kubisch, letzte Sekunde stumm, volle Lautstärke erst beim nächsten Play)
- [x] Praxistest Ausblenden (Benutzer, 2026-09-28)
- [x] Praxistest auf dem S25 inkl. eigener Zeit (Benutzer, 2026-09-28)

## Bugfix – Zeitanzeige eingefroren nach Netzausfall
- [x] Player-Fehler → Player freigeben und frisch laden; keine parallelen Ladevorgänge; kein just_audio-Proxy
- [x] Praxistest auf dem S25 (Benutzer, 2026-09-28)

## Zusatz – Fehlerarten beim Abspielen
- [x] Kaputter Download → löschen + streamen; 404/410 → „nicht mehr verfügbar"; Format → Meldung; keine sinnlosen Wiederholungen
- [x] Gleiche Infobox auch beim zweiten Mal

## Bugfix – Neustart von vorn nach Netzausfall im Hintergrund
- [x] Wiederherstellung nutzt die zuletzt gemeldete Position statt just_audios veralteter
- [x] Praxistest auf dem S25 (Benutzer, 2026-09-28)

## Zusatz – Alle neuen / ungespielten Episoden spielen
- [x] Langes Drücken auf Abo-Kachel, „frisch" = Refresh < 96 h (ohne Abo-Import), Playlist-Wahl, älteste zuerst
- [ ] Praxistest auf dem S25 (Benutzer)

## Zusatz – Ungespielte Episoden seit … spielen
- [x] Abo-Menü: Kalender, ungespielte Folgen ab dem gewählten Tag in eine Playlist
- [ ] Praxistest auf dem S25 (Benutzer)

## Zusatz – Playlist-Menü
- [x] Sortieren nach Datum ↑/↓ und Namen ↑, Alles downloaden mit Rückfrage
- [x] Downloads-Liste: jede Folge „Zu Playlist hinzufügen…"
- [ ] Praxistest auf dem S25 (Benutzer)

## Umbenennung „AA-AuralListen Podcatcher" (2026-09-29)
- [x] Anzeigename voll / Launcher „AuralListen", applicationId `io.github.rainerwingel.aurallisten`, User-Agent, Backup-/OPML-Namen
- [x] Akku: kein Ausnahme-Dialog mehr, nur Knopf zu den App-Einstellungen
- [ ] Alte App deinstallieren, neue einrichten (Benutzer; keine Datenübernahme)
- [x] Datenschutzerklärung (`docs/datenschutz.md`, GitHub Pages)
- [x] GitHub-Repo umbenannt in `AA-AuralListen-Podcatcher`, Remote + Links angepasst

## Offene Punkte
- keine
