# Roadmap

Jeder Meilenstein = eigener Branch + Pull Request, CI muss grün sein. Erledigtes abhaken.

## M0 – Grundgerüst
- [x] Flutter aktualisiert (3.47.5 / Dart 3.13.4)
- [x] Projekt angelegt (`io.github.rainerwingel.aapodcastguru`, Android + iOS-Ordner)
- [x] AGENTS.md, CLAUDE.md (`@AGENTS.md`), Themen-Doku unter `docs/`
- [x] `.gitignore` für Secrets / SSH / Keystore
- [x] GitHub-Repo `RainerWingel/aa-podcast-guru` (öffentlich), erster Push
- [ ] Lints verschärfen (`analysis_options.yaml`)
- [ ] Grundpakete + Ordnerstruktur laut `architecture.md`, Beispiel-Counter entfernen
- [ ] gen-l10n mit `app_de.arb`
- [ ] GitHub Actions: analyze → test → debug-APK
- [ ] Release-Keystore erzeugen und sichern (siehe `build-and-release.md`)
- [ ] App startet auf dem Galaxy S25

## M1 – Abos & Feeds
- [ ] Drift-Schema v1 (`data-model.md`)
- [ ] RSS-Parser inkl. iTunes-/Podcasting-2.0-Namespace, mit Tests
- [ ] Abo per RSS-URL
- [ ] Abo-Übersicht + Folgenliste
- [ ] Refresh bei App-Start + Pull-to-Refresh (ETag/Last-Modified)

## M2 – Suche & Import
- [ ] Suche: iTunes, fyyd (Podcast Index optional, falls Key vorhanden)
- [ ] OPML-Import (Castbox-Export)

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
- [ ] Podcast-Index-API-Key (zurückgestellt: braucht Nicht-Freemail-Adresse mit Postfach)
- [ ] USB-Debugging am Galaxy S25 aktivieren (Benutzer)
