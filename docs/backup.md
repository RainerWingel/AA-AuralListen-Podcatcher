# Backup, Wiederherstellung, OPML-Export

Code: `lib/data/backup/backup_service.dart`, `lib/data/feed/opml.dart` (`buildOpml`),
UI: `lib/features/settings/backup_flow.dart`. Tests: `test/data/backup/backup_service_test.dart`, `test/data/feed/opml_test.dart`.

## OPML-Export
Optionen → Sicherung → „Abos als OPML exportieren": OPML 2.0 mit allen Abos (`title`, `xmlUrl`, `htmlUrl`), gespeichert
über den Android-Speichern-Dialog (Datei `AA-AuralListen-Abos-JJJJ-MM-TT.opml`). Nur Abos, kein Hörstand – für andere Apps.

## Backup
Optionen → Sicherung → „Backup erstellen" → Speichern-Dialog (`AA-AuralListen-Backup-JJJJ-MM-TT.zip`).
- ZIP mit `manifest.json` (`app` = `AA-AuralListen`, `format` = 1, `schemaVersion`, `createdAt`) und
  `aapodcastguru.sqlite` (Dateiname bewusst unverändert). Backups der alten App (`app` = `AA-PodcastGuru`) werden
  **nicht** angenommen – Benutzerentscheidung 2026-09-29, keine Datenübernahme aus der alten App.
- Die Datenbank wird mit `VACUUM INTO` als konsistenter, kompakter Schnappschuss kopiert (temporäre Datei im
  App-Cache, wird sofort gelöscht).
- Enthalten: Abos inkl. Einstellungen, Folgen mit Hörstand, Shownotes (`episode_notes`), Kapitel, Lesezeichen, Playlists, App-Einstellungen.
- **Nicht** enthalten: Audiodateien (Downloads).
- Sprache: Enthält das Backup `ui.language`, wird sie übernommen; ältere Backups ohne Sprache behalten die aktuelle
  (sonst käme die Sprachabfrage des ersten Starts zurück).

## Wiederherstellen
Optionen → Sicherung → „Backup wiederherstellen" → Datei wählen → Vorschau (Datum, Anzahl Abos/Folgen/Playlists/
Lesezeichen) → Bestätigen. **Ersetzt alle aktuellen Daten.**
1. Prüfen: ZIP, Manifest von dieser App, `schemaVersion` ≤ aktuelle (sonst „aus neuerer App-Version"), SQLite-Kennung.
2. Die Sicherungs-DB wird in eine Temp-Datei entpackt und mit `AppDatabase` geöffnet → **Migration auf das aktuelle
   Schema** (alte Backups funktionieren also).
3. Wiedergabe stoppen, alle Downloads abbrechen.
4. `ATTACH` der Sicherung, in **einer Transaktion**: alle Tabellen leeren (Kinder zuerst) und aus der Sicherung
   füllen (Eltern zuerst) – mit **expliziten Spaltenlisten**, weil migrierte DBs Spalten in anderer Reihenfolge haben.
   Die Tabelle `downloads` wird geleert, nicht übernommen.
5. `DETACH`, Temp-Datei löschen, Drift-Streams benachrichtigen (`markTablesUpdated`) → die Oberfläche aktualisiert sich
   ohne Neustart.
6. Download-Wartung löscht die jetzt verwaisten Audiodateien; der Player zeigt die „letzte Folge" aus der Sicherung.

Grenzen: max. 200 MB Backup. Jede neue Tabelle muss in `BackupService._restoredTables` (Eltern vor Kindern) eingetragen
werden – sonst fehlt sie nach einer Wiederherstellung (Test „backup → restore" erweitern).
