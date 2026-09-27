# Datenmodell (Drift / SQLite)

Erste Fassung, wird in M1 umgesetzt. Jede Schema-Änderung = neue `schemaVersion` + Migration + Test.

| Tabelle | Wichtige Spalten |
|---------|------------------|
| `podcasts` | id, feedUrl (unique), title, author, imageUrl, description, etag, lastModified, lastRefreshAt, autoDownloadMode (off/wifi/always), autoDownloadMaxEpisodes, autoDeletePlayed (bool), boostDb (nullable = global) |
| `episodes` | id, podcastId, guid (unique je Podcast), title, description (gekürzt), audioUrl, durationMs, pubDate, chaptersUrl, status, positionMs, playedAt |
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
- Pfade in `downloads` sind **relativ** zum App-Verzeichnis (absolute Pfade können sich bei Android-Updates ändern).
