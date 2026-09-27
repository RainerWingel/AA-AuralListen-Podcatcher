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
- [ ] Keystore + `key.properties` extern sichern (Benutzer)
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
- [ ] Castbox-Export auf dem Handy importieren (Benutzer)

## M3 – Player → erste produktiv nutzbare Version
- [x] `audio_service`-Handler, Benachrichtigung, Sperrbildschirm, Bluetooth
- [x] Streaming, −15 s / +30 s, Hörposition, 98 %-Regel
- [x] Lautstärke-Boost (global + pro Podcast)
- [x] Mini-Player + Vollbild-Player
- [x] Folge antippen = abspielen; langes Drücken: Menü (als gespielt / ungespielt markieren)
- [x] DB-Schema v2 (`settings`) inkl. Migrationstest
- [ ] Praxistest auf dem S25: Sperrbildschirm, Bluetooth, Anruf, 10-Min-Pause (Benutzer)

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

## Zusatz – Als gehört markieren bis Datum
- [x] Podcast-Menü → Kalender → Rückfrage mit Anzahl; Regeln wie „gespielt"

## M6 – Kapitel & Lesezeichen
- [x] Kapitel aus Feed (Podlove), JSON (url/href) und ID3-CHAP (lokal oder nur Tag per HTTP-Range)
- [x] Kapitelanzeige und -liste im Vollbild-Player, Sprung per Tippen
- [x] Lesezeichen mit Notiz, Liste pro Folge und global, Abspielen ab Lesezeichen
- [x] DB-Schema v6 inkl. Migrationstests
- [ ] Praxistest auf dem S25 mit WRINT und Freak Show (Benutzer)
## M7 – OPML-Export, Backup/Restore, Dark Mode, Feinschliff
- [x] OPML-Export über den Speichern-Dialog
- [x] Backup (ZIP: Manifest + SQLite-Schnappschuss) und Wiederherstellung ohne Neustart, alte Backups werden migriert
- [x] Dark Mode (System / Hell / Dunkel)
- [ ] Praxistest auf dem S25: Backup erstellen → in Drive/Downloads speichern → wiederherstellen (Benutzer)
## M8 – Härtung: Leak-Tests, Soak-Test, Release-APK 1.0
- [x] Podcast-Umzug: `itunes:new-feed-url` beim Refresh/Abonnieren, Umzüge per Infobox, „Feed-Adresse ändern" (Benutzerwunsch)
- [ ] Leak-Tests (Streams, Timer, Controller, Caches)
- [ ] Soak-Test auf dem S25 (2 h Wiedergabe, Speicher beobachten)
- [x] Eigenes App-Symbol (adaptiv, Designsymbol, Statusleiste)
- [ ] Version 1.0.0, Release-APK

## Offene Punkte
- keine
