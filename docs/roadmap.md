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
- [ ] `audio_service`-Handler, Benachrichtigung, Sperrbildschirm, Bluetooth
- [ ] Streaming, −15 s / +30 s, Hörposition, 98 %-Regel
- [ ] Lautstärke-Boost
- [ ] Mini-Player + Vollbild-Player

## M4 – Downloads & Eviction
- [ ] Manueller Download, Auto-Download pro Podcast
- [ ] Eviction komplett nach `eviction.md` inkl. Reconciliation beim Start
- [ ] Speicher-Seite in den Einstellungen

## M5 – Playlists (Castbox-Ersatz komplett)
- [ ] Mehrere Playlists, Drag & Drop, Weiterspielen nach `playlists.md`

## M6 – Kapitel & Lesezeichen
## M7 – OPML-Export, Backup/Restore, Dark Mode, Feinschliff
## M8 – Härtung: Leak-Tests, Soak-Test, Release-APK 1.0

## Offene Punkte
- keine
