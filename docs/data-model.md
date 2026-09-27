# Datenmodell (Drift / SQLite)

Code: `lib/data/db/tables.dart` (Tabellen), `lib/data/db/app_database.dart` (DB, `schemaVersion`).
Aktuell **schemaVersion 2** (v1: `podcasts`, `episodes`; v2: `settings`). Die übrigen Tabellen kommen mit ihren Meilensteinen.

### Schema ändern (Pflichtablauf)
1. Tabelle in `tables.dart` ändern/hinzufügen, `schemaVersion` erhöhen, Schritt in `onUpgrade` ergänzen (`if (from < N) …`).
2. `dart run build_runner build --delete-conflicting-outputs`
3. `dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/` (Schnappschuss `drift_schema_vN.json`)
4. `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`
5. Testfall in `test/data/db/migration_test.dart` ergänzen (Upgrade + Daten bleiben erhalten).
Alte Schnappschüsse in `drift_schemas/` **nie** löschen oder ändern.
Nach Änderungen an Tabellen: `dart run build_runner build --delete-conflicting-outputs` (erzeugt `app_database.g.dart`, wird committet).

| Tabelle | Wichtige Spalten |
|---------|------------------|
| `podcasts` ✅ | id, feedUrl (unique), title, author, description, imageUrl, websiteUrl, etag, lastModified, lastRefreshAt, lastError (null = ok), subscribedAt, autoDownloadMode (off/wifiOnly/always), autoDownloadMaxEpisodes (3), autoDeletePlayed (true), boostDb (null = global) |
| `episodes` ✅ | id, podcastId (FK, ON DELETE CASCADE), guid (unique je Podcast), title, description (Klartext, max. 4000 Zeichen), audioUrl, audioMimeType, audioSizeBytes, durationMs, pubDate, imageUrl, chaptersUrl, status, positionMs, playedAt, addedAt |
| `downloads` | episodeId (PK), relativePath, sizeBytes, state (queued/running/done/failed), completedAt |
| `playlists` | id, name, sortOrder |
| `playlist_items` | playlistId, episodeId, position — (playlistId, episodeId) unique |
| `chapters` | episodeId, startMs, title, imageUrl, url |
| `bookmarks` | id, episodeId, positionMs, note, createdAt |
| `settings` ✅ (v2) | key (PK), value (Text). Schlüssel in `lib/data/settings_keys.dart`: `player.lastEpisodeId`, `player.boostDb` |
| ~~`player_state`~~ | entfällt – letzte Folge steht in `settings`; aktive Playlist kommt in M5 ebenfalls dorthin |

## Episoden-Status
- `neu` → `angefangen` (Position > 0) → `gespielt`.
- **Gespielt** = Hörposition ≥ **98 %** der Dauer (oder Ende erreicht). `playedAt` wird dabei gesetzt –
  daran hängt die 96-h-Löschregel (`eviction.md`).
- Manuell „als gespielt / ungespielt markieren" (langes Drücken auf eine Folge). „Ungespielt" → `neu`, Position 0, `playedAt` = null.
- Beim Gespielt-Werden wird `positionMs` auf 0 gesetzt; Details zur Wiedergabe in `playback.md`.
- Enums werden als Text gespeichert (`textEnum`) – Umbenennen eines Enum-Werts braucht eine Migration.
- Beim Refresh werden Feed-Felder bekannter Folgen aktualisiert, **nie** aber Hörzustand (status, positionMs, playedAt).
- Folgen, die aus dem Feed verschwinden, bleiben in der DB (Historie, Hörposition).
- `PRAGMA foreign_keys = ON` wird bei jedem Öffnen gesetzt (sonst ignoriert SQLite die Cascade-Löschung).
- Drift liefert `DateTime` in **lokaler** Zeit zurück – in Tests mit `isAtSameMomentAs` vergleichen.
- Pfade in `downloads` sind **relativ** zum App-Verzeichnis (absolute Pfade können sich bei Android-Updates ändern).
