# Playlists

Vorbild: Castbox. Mehrere Playlists, manuell befüllt. **Umgesetzt in M5 ✅**

Code: `lib/data/playlist_repository.dart` (Verwaltung, `nextAfter`), `lib/audio/podcast_audio_handler.dart`
(aktive Playlist, Weiterspielen, „Weiter"), `lib/features/playlists/` (UI). Tests: Gruppe „playlists" in
`test/audio/podcast_audio_handler_test.dart`, `test/data/playlist_repository_test.dart`.

## Verwaltung
- Playlists anlegen, umbenennen, löschen, sortieren (Griff ≡ ziehen). Beim ersten Start – und beim Update auf Schema v4 –
  wird die Playlist „Wiedergabeliste" angelegt. Löschen einer Playlist löscht nur die Einträge, nicht die Folgen.
- Folge hinzufügen über Folgen-Menü („Zu Playlist hinzufügen…") – ans Ende der gewählten Playlist. Gibt es nur eine
  Playlist, wird direkt hinzugefügt; sonst Auswahl-Sheet (inkl. „Neue Playlist").
- Reihenfolge per Drag & Drop (Griff ≡), Entfernen per Wischen nach links (mit „Rückgängig" – fügt am Ende wieder ein).
- Eine Folge kann in mehreren Playlists stehen, in einer Playlist aber nur einmal.

## Ganze Podcasts in eine Playlist (Benutzerwunsch 2026-09-28)
Abos-Tab → **langes Drücken** auf eine Kachel → Menü (`play_podcast_episodes.dart`):
1. **„Alle neuen Episoden spielen"** – nur **frische** Folgen.
2. **„Alle ungespielten Episoden spielen"** – alle Folgen mit Status neu oder angefangen.
- **Frisch** ist kein eigener Status (kein Enum/Feld): berechnet aus `episodes.addedAt` (erster Abruf, spätere Refreshes
  ändern es nicht) – jünger als 24 h (`PodcastRepository.freshFor`) **und** nicht beim Abonnieren mitgekommen
  (`addedAt > podcasts.subscribedAt`; sonst wären nach dem Abo alle 200 Altfolgen „neu"). Gespielte zählen nie.
  Ein gespeicherter Zustand müsste nach 24 h von selbst umkippen – dafür gäbe es ohne Hintergrunddienst keinen Auslöser.
- Menü zeigt die Anzahl; Einträge ohne passende Folgen sind ausgegraut.
- Playlist: bei genau einer direkt, sonst Auswahl (`choosePlaylist`, auch „Neue Playlist"). Folgen werden **älteste
  zuerst** angehängt (`PlaylistRepository.addAll`), schon enthaltene übersprungen. Dann startet die **älteste** dieser
  Folgen in der Playlist (angefangene an ihrer Position), danach geht es nach den Regeln unten weiter.
- Infobox: „n Folgen zu „X" hinzugefügt." bzw. „Alle Folgen waren schon in „X" – Wiedergabe startet."

## Abspielverhalten
- Startet der Benutzer eine Folge **aus einer Playlist**, wird diese Playlist zur **aktiven Playlist**.
- Erreicht die Folge ≥ 98 % bzw. ihr Ende:
  1. Folge wird als **gespielt** markiert (`playedAt` gesetzt).
  2. Folge wird **automatisch aus allen Playlists entfernt**, in denen sie steht (nicht nur aus der aktiven).
  3. Die **nächste Folge derselben Playlist startet automatisch**.
- Die „nächste Folge" wird **erst in diesem Moment aus der DB gelesen** – kein Schnappschuss beim Start.
  Dadurch wird eine Folge, die während der Wiedergabe hinzugefügt wurde, automatisch mitgespielt.
- Ist die Playlist leer, stoppt die Wiedergabe.
- Wird eine Folge **außerhalb** einer Playlist gestartet, gibt es keine aktive Playlist; nach dem Ende stoppt die Wiedergabe.
- Überspringt der Benutzer eine Folge manuell („Weiter" ⏭ im Vollbild-Player bzw. in der Benachrichtigung), wird sie
  **nicht** als gespielt markiert und **bleibt** in der Playlist.
- Auch manuelles „Als gespielt markieren" entfernt die Folge aus allen Playlists (Regel sitzt zentral in `markPlayed`).

### Umsetzungsdetails
- Die Folge verschwindet bereits bei **98 %** aus den Playlists (dann wird sie „gespielt"); gestartet wird die nächste
  aber erst am **Ende** der Datei.
- Der Handler merkt sich die **Position** der laufenden Folge in der aktiven Playlist. Die nächste Folge ist der Eintrag
  mit der kleinsten Position **größer** als diese – gelesen im Moment des Wechsels. Vor dem Entfernen (98 %) wird die
  Position neu gelesen, falls der Benutzer inzwischen umsortiert hat.
- Aktive Playlist + Position stehen in `settings['player.activePlaylistId']` (`"<id>:<position>"`) und überleben einen
  App-Neustart. Die Playlist-ID steht auch in `mediaItem.extras['playlistId']` (für den Vollbild-Player).

## Tests
Unit-Tests für: Weiterspielen, Hinzufügen während der Wiedergabe, leere Playlist, Überspringen (bleibt drin, ungespielt),
Folge in mehreren Playlists (wird beim Gespielt-Werden aus allen entfernt).
