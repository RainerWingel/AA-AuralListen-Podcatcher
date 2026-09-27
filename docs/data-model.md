# Datenmodell (Drift / SQLite)

Code: `lib/data/db/tables.dart` (Tabellen), `lib/data/db/app_database.dart` (DB, `schemaVersion`).
Aktuell **schemaVersion 1** (M1: `podcasts`, `episodes`). Die übrigen Tabellen kommen mit ihren Meilensteinen.
Jede Schema-Änderung = `schemaVersion` erhöhen + Migration in `migration` + Test.
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
| `settings` | key, value |
| `player_state` | aktive Folge, aktive Playlist (für Wiederaufnahme nach App-Neustart) |

## Episoden-Status
- `neu` → `angefangen` (Position > 0) → `gespielt`.
- **Gespielt** = Hörposition ≥ **98 %** der Dauer (oder Ende erreicht). `playedAt` wird dabei gesetzt –
  daran hängt die 96-h-Löschregel (`eviction.md`).
- Manuell „als gespielt / ungespielt markieren" ist möglich. „Ungespielt" setzt `playedAt` zurück.
- Enums werden als Text gespeichert (`textEnum`) – Umbenennen eines Enum-Werts braucht eine Migration.
- Beim Refresh werden Feed-Felder bekannter Folgen aktualisiert, **nie** aber Hörzustand (status, positionMs, playedAt).
- Folgen, die aus dem Feed verschwinden, bleiben in der DB (Historie, Hörposition).
- `PRAGMA foreign_keys = ON` wird bei jedem Öffnen gesetzt (sonst ignoriert SQLite die Cascade-Löschung).
- Drift liefert `DateTime` in **lokaler** Zeit zurück – in Tests mit `isAtSameMomentAs` vergleichen.
- Pfade in `downloads` sind **relativ** zum App-Verzeichnis (absolute Pfade können sich bei Android-Updates ändern).
