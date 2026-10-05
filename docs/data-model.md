# Datenmodell (Drift / SQLite)

Code: `lib/data/db/tables.dart` (Tabellen), `lib/data/db/app_database.dart` (DB, `schemaVersion`).
Aktuell **schemaVersion 21** (v1: `podcasts`, `episodes`; v2: `settings`; v3: `downloads`; v4: `playlists`, `playlist_items`;
v5: `episodes.theme`, `podcasts.autoDownloadThemes`; v6: `chapters`, `bookmarks`; v7: `playlists.lastEpisodeId`; v8: nur Daten – `angefangen` unter 15 s → `neu`, Position 0; v9: `playlists.color`; v10: `podcasts.autoPlaylistId`, `autoPlaylistName`; v11: `episodes.episodeNumber`, `podcasts.episodeCounter`, `episodeNumberOffset`, einmaliges Neulesen aller Feeds; v12: `podcasts.episodeOwnCount`; v13: `episode_notes`, Shownotes aus `episodes.description` dorthin verschoben,
einmaliges Neulesen aller Feeds für die Links; v14: nur Daten – Shownotes-Grenze 6000 → 18000 Zeichen, einmaliges
Neulesen aller Feeds; v15: nur Daten – einmaliges Neulesen aller Feeds, stellt Feed-Dauern wieder her, die der Player
mit einer falschen VBR-Schätzung überschrieben hatte, `playback.md`; v16: `podcasts.streamVaries`; v17: `podcasts.fundingUrl`, `fundingLabel`, einmaliges Neulesen aller Feeds; v18: `episodes.season`, `podcasts.serial`,
einmaliges Neulesen aller Feeds; v19: `play_history`; v20: nur Daten – einmaliges Neulesen aller Feeds
für die vollständige Entity-Dekodierung; v21: `downloads.failedAttempts`). Die übrigen Tabellen kommen mit ihren Meilensteinen.

### Schema ändern (Pflichtablauf)
0. Neue Tabelle? → auch in `BackupService._restoredTables` eintragen (`backup.md`).
1. Tabelle in `tables.dart` ändern/hinzufügen, `schemaVersion` erhöhen, Schritt in `onUpgrade` ergänzen (`if (from < N) …`).
2. `dart run build_runner build --delete-conflicting-outputs`
3. `dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/` (Schnappschuss `drift_schema_vN.json`)
4. `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`
5. Testfall in `test/data/db/migration_test.dart` ergänzen (Upgrade + Daten bleiben erhalten).
Alte Schnappschüsse in `drift_schemas/` **nie** löschen oder ändern.
Nach Änderungen an Tabellen: `dart run build_runner build --delete-conflicting-outputs` (erzeugt `app_database.g.dart`, wird committet).

| Tabelle | Wichtige Spalten |
|---------|------------------|
| `podcasts` ✅ | id, feedUrl (unique), title, author, description, imageUrl, websiteUrl (nur http/https), fundingUrl + fundingLabel (v17, `podcast:funding`), serial (v18, `itunes:type` = serial → Hörreihenfolge), etag, lastModified, lastRefreshAt, lastError (null = ok), subscribedAt, autoDownloadMode (off/wifiOnly/always), autoDownloadMaxEpisodes (3), autoDownloadThemes (v5, JSON-Liste, null = alle Themen), autoDeletePlayed (true), boostDb (null = global), autoPlaylistId + autoPlaylistName (v10, Ziel-Playlist für Auto-Downloads, ohne FK – gelöschte wird unter dem Namen neu angelegt), episodeCounter (v11, true) + episodeNumberOffset (v11, 0, −9999…9999), episodeOwnCount (v12, false = Feed-Nummern), streamVaries (v16, false; Server liefert Streams je Anfrage anders → Download-Tipp, `playback.md`) |
| `episodes` ✅ | id, podcastId (FK, ON DELETE CASCADE), guid (unique je Podcast), title, description (**seit v13 unbenutzt, immer NULL** – Spalte bleibt, weil Löschen die Tabelle samt
Fremdschlüsseln neu aufbauen würde), audioUrl, audioMimeType, audioSizeBytes, durationMs, pubDate, imageUrl, chaptersUrl, theme (v5, z. B. `zum-thema`), episodeNumber (v11, `itunes:episode`), season (v18, `itunes:season` ≥ 1), status, positionMs, playedAt, addedAt |
| `downloads` ✅ (v3) | episodeId (PK, FK → episodes, CASCADE), relativePath (`<id>.<ext>`), state (queued/running/done/failed), sizeBytes, wifiOnly, failedAttempts (v21, Zahl der Fehlschläge – Auto-Download gibt nach 3 auf), createdAt, completedAt. Regeln: `eviction.md` |
| `playlists` ✅ (v4) | id, name, sortOrder, createdAt, lastEpisodeId (v7, zuletzt aus der Playlist gespielte Folge für „Fortsetzen", ohne FK), color (v9, `PlaylistColor` als Name, null = keine). Standard-Playlist „Wiedergabeliste" (`AppDatabase.defaultPlaylistName`) |
| `playlist_items` ✅ (v4) | PK (playlistId, episodeId), beide FK mit CASCADE, position (aufsteigend, neu = max + 1), addedAt |
| `chapters` ✅ (v6) | PK (episodeId, startMs), FK CASCADE, title, url, imageUrl. Quellen: `playback.md` |
| `episode_notes` ✅ (v13) | episodeId (PK, FK → episodes, CASCADE), notes. Shownotes **getrennt von `episodes`**, damit Folgenlisten sie nicht in den Arbeitsspeicher laden; gelesen nur beim Anzeigen (`episodeNotesProvider`, autoDispose). Format: Text mit Zeilenumbrüchen und „• " für Aufzählungen, Links als `\uE000Text\uE001URL\uE002` (nur http/https), max. **18000** Zeichen inkl. URLs (Benutzerwunsch 2026-10-03, vorher 6000; nur beim Anzeigen im Speicher), Links werden beim Kürzen nie zerteilt (`htmlToNotes`/`parseNotes` in `lib/core/text_utils.dart`). Beim Feed-Refresh neu geschrieben; Folge ohne Shownotes → Zeile gelöscht. Die Abos-Suche sucht auch hier. |
| `play_history` ✅ (v19) | id, feedUrl, guid, episodeTitle, podcastTitle, imageUrl, durationMs, playedAt. Abspielverlauf, max. 100 neueste; **ohne FK**, damit Einträge das Abo-Kündigen überleben; eindeutig über feedUrl + guid (`playback.md`) |
| `bookmarks` ✅ (v6) | id, episodeId (FK CASCADE), positionMs, note (null = keine), createdAt |
| `settings` ✅ (v2) | key (PK), value (Text). Schlüssel in `lib/data/settings_keys.dart`: `player.lastEpisodeId`, `player.boostDb`, `player.activePlaylistId`, `player.showTotalTime` (`true` = Gesamtlänge statt Restzeit, fehlt = Restzeit), `player.speed` (Abspieltempo, fehlt = 1,0), `downloads.limitBytes`, `ui.themeMode`, `ui.language` (`de`/`en`, fehlt = noch nicht gewählt), `ui.appColor` (`AppColor`-Name, fehlt = wallpaper, ohne Wallpaper-Farben orange) |
| ~~`player_state`~~ | entfällt – letzte Folge und aktive Playlist stehen in `settings` |

## Episoden-Status
- `neu` → `angefangen` (Position ≥ **15 s**, `PlaybackRepository.inProgressFrom`, Benutzerwunsch 2026-09-29) →
  `gespielt`. Darunter wird nur die Position gespeichert, die Folge bleibt „neu". Der Status geht beim Speichern der
  Position nur vorwärts (Zurückspulen auf 0 macht eine angefangene Folge nicht wieder neu).
- Gilt genauso beim **erneuten Abspielen** einer gespielten Folge: unter 15 s bleibt sie `gespielt` (Position und
  `playedAt` unverändert), ab 15 s wird sie `angefangen` (`playedAt` gelöscht).
- Migration v8 (einmalig): Folgen, die nach der alten Regel schon nach wenigen Sekunden `angefangen` wurden
  (Position < 15 s), sind wieder `neu` mit Position 0. Gilt auch für ältere Backups beim Wiederherstellen.
- **Gespielt** = die Datei ist **bis zum Ende** abgelaufen (Benutzerwunsch 2026-10-03; vorher ab 98 %), oder manuell
  markiert, oder letztes Kapitel übersprungen. `playedAt` wird dabei gesetzt –
  daran hängt die 96-h-Löschregel (`eviction.md`).
- Manuell „als gespielt / ungespielt markieren" (langes Drücken auf eine Folge). „Ungespielt" → `neu`, Position 0, `playedAt` = null.
- Podcast → ⋮ → „Als gespielt markieren bis …": alle **ungespielten** Folgen mit `pubDate` bis einschließlich des gewählten
  Tages (lokale Zeit) werden `gespielt` – gleiche Regeln wie `markPlayed` (aus allen Playlists, `playedAt` = jetzt →
  Downloads nach 96 h weg). Folgen ohne Datum und bereits gespielte (ihr `playedAt` bleibt) sind nicht betroffen.
  Code: `PlaybackRepository.markPlayedUntil`, Tests: `test/data/playback_repository_test.dart`.
- Podcast → ⋮ → „Als ungespielt markieren seit …" (Benutzerwunsch 2026-09-28): alle **gespielten** Folgen mit `pubDate` ab
  Beginn des gewählten Tags werden `newEpisode` (Position 0, `playedAt` = null → keine Eviction). Angefangene Folgen
  bleiben unverändert (Hörposition), Folgen ohne Datum werden übersprungen. Kalender → Rückfrage mit Anzahl → Infobox.
  Sie kommen **nicht** automatisch zurück in Playlists.
- Beim Gespielt-Werden wird `positionMs` auf 0 gesetzt; Details zur Wiedergabe in `playback.md`.
- Enums werden als Text gespeichert (`textEnum`) – Umbenennen eines Enum-Werts braucht eine Migration.
- Beim Refresh werden Feed-Felder bekannter Folgen aktualisiert, **nie** aber Hörzustand (status, positionMs, playedAt).
- Folgen, die aus dem Feed verschwinden, bleiben in der DB (Historie, Hörposition).
- `PRAGMA foreign_keys = ON` wird bei jedem Öffnen gesetzt (sonst ignoriert SQLite die Cascade-Löschung).
- Drift liefert `DateTime` in **lokaler** Zeit zurück – in Tests mit `isAtSameMomentAs` vergleichen.
- Pfade in `downloads` sind **relativ** zum App-Verzeichnis (absolute Pfade können sich bei Android-Updates ändern).
