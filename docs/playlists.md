# Playlists

Vorbild: Castbox. Mehrere Playlists, manuell befüllt. **Umgesetzt in M5 ✅**

Code: `lib/data/playlist_repository.dart` (Verwaltung, `nextAfter`), `lib/audio/podcast_audio_handler.dart`
(aktive Playlist, Weiterspielen, „Weiter"), `lib/features/playlists/` (UI). Tests: Gruppe „playlists" in
`test/audio/podcast_audio_handler_test.dart`, `test/data/playlist_repository_test.dart`.

## Verwaltung
- Playlists anlegen, umbenennen, löschen, sortieren (Griff ≡ ziehen). Beim ersten Start – und beim Update auf Schema v4 –
  wird die Playlist „Wiedergabeliste" angelegt. Löschen einer Playlist löscht nur die Einträge, nicht die Folgen.
- Folge hinzufügen über Folgen-Menü („Zu Playlist hinzufügen…") oder den Playlist-Knopf in der Downloads-Liste – ans
  Ende der gewählten Playlist. Gibt es nur eine
  Playlist, wird direkt hinzugefügt; sonst Auswahl-Sheet (inkl. „Neue Playlist").
  Im Sheet steht rechts neben dem Namen ein ✅, wenn die Folge schon in dieser Playlist ist (`playlistIdsWith`;
  Screenreader liest „Schon in „X““). Wählt man eine solche Playlist (oder ist sie die einzige), fragt die App
  „Aus Playlist entfernen?" → „Entfernen" nimmt die Folge heraus (Infobox „Aus „X“ entfernt"), „Abbrechen" lässt alles.
- Reihenfolge per Drag & Drop (Griff ≡), Entfernen per Wischen nach links (mit „Rückgängig" – fügt am Ende wieder ein).
- Eine Folge kann in mehreren Playlists stehen, in einer Playlist aber nur einmal.
- **Fortsetzen** (▶ im Kreis; Benutzerwunsch 2026-09-29): Knopf oben rechts in der geöffneten Playlist und Eintrag im
  ⋮-Menü der Übersicht, beide `resumePlaylist`. Spielt die Folge, die zuletzt **aus dieser Playlist** lief
  (`playlists.lastEpisodeId`, Schema v7) an ihrer gemerkten Position weiter; steht sie nicht mehr in der Playlist
  (gespielt, entfernt), die oberste. Jede Playlist merkt sich ihre eigene Folge.
  - Gemerkt wird, sobald eine Folge aus der Playlist startet (auch automatisches Weiterspielen) und nochmal bei Pause.
    Woanders gestartet zählt nur, wenn die Folge in genau einer Playlist steht (siehe unten).
- **Farbe** (Benutzerwunsch 2026-09-29): ⋮ → „Farbe…" → Dialog mit 7 Regenbogenfarben (Rot, Orange, Gelb, Grün, Blau,
  Indigo, Violett) und „Keine Farbe" (`playlist_colors.dart`, gespeichert in `playlists.color`). Die Playlist bekommt
  einen sanften **Farbverlauf** (Farbe mit 22 % hell / 30 % dunkel, auslaufend bis transparent), damit der Text
  lesbar bleibt: in der Übersicht und im Auswahl-Sheet „Zu Playlist hinzufügen…" je Zeile von links nach rechts
  (`playlistTintedRow`), im eigenen Fenster AppBar im vollen Farbton und darunter von oben nach unten auslaufend.
  Als `Ink` gemalt, damit der Tipp-Effekt sichtbar bleibt.
- **Playlist-Menü ⋮** (Übersicht und geöffnete Playlist, gemeinsam: `playlistMenuItems`), Benutzerwunsch 2026-09-29:
  - **Übersicht:** Fortsetzen (ausgegraut bei leerer Playlist), Alles downloaden, Umbenennen, Löschen.
  - **Geöffnete Playlist:** die drei Sortierungen, Alles downloaden, Umbenennen, Löschen (Sortieren nur hier).
  - **Aufsteigend / Absteigend nach Datum sortieren** (Pfeil ↑/↓): Veröffentlichungsdatum; Folgen ohne Datum stehen in
    beiden Richtungen am Ende.
  - **Aufsteigend nach Namen sortieren** (↑): Folgentitel, ohne Groß/Klein, Umlaute wie Grundbuchstabe, Zahlen nach
    Wert („Folge 2" vor „Folge 10", `compareTitles`).
  - Sortieren schreibt die Reihenfolge einmal neu (`PlaylistRepository.sort`), danach ist sie wie gewohnt per Drag &
    Drop änderbar; Infobox bestätigt. Eine laufende Playlist spielt nach der neuen Reihenfolge weiter.
  - **Alles downloaden**: Rückfrage mit Anzahl der fehlenden Folgen und ungefährer Größe; lädt sofort (auch mobil),
    überspringt fertige/laufende Downloads, wiederholt fehlgeschlagene. Ungespielte Downloads zählen nicht zum
    automatischen Aufräumen (siehe `eviction.md`).
  - Umbenennen, Farbe…, Playlist löschen.

## Ganze Podcasts in eine Playlist (Benutzerwunsch 2026-09-28)
Abos-Tab → **langes Drücken** auf eine Kachel → Menü (`play_podcast_episodes.dart`); dasselbe Menü gibt es für ein einzelnes **Thema**
(Netzwerk-Feeds wie WRINT): Podcast-Einstellungen → „Themen für automatische Downloads" → langes Drücken auf ein Thema
(Benutzerwunsch 2026-09-30). Dann zählen nur Folgen dieses Themas (`unplayedEpisodes(theme: …)`), Titel „Podcast · Thema";
schon enthaltene Folgen werden wie immer übersprungen:
1. **„Alle neuen Episoden spielen"** – nur **frische** Folgen.
2. **„Ungespielte Episoden seit … spielen"** – Kalender (öffnet auf heute, frühestes Datum = älteste ungespielte
   Folge): ungespielte Folgen mit Veröffentlichungsdatum **ab Beginn des gewählten Tags**; Folgen ohne Datum zählen
   nicht. Keine passenden → Infobox „Keine ungespielten Folgen seit dem …".
3. **„Alle ungespielten Episoden spielen"** – alle Folgen mit Status neu oder angefangen.
- **Frisch** ist kein eigener Status (kein Enum/Feld): berechnet aus `episodes.addedAt` (erster Abruf, spätere Refreshes
  ändern es nicht) – jünger als 96 h (`PodcastRepository.freshFor`; zuerst 24 h, auf Wunsch 96 h) **und** nicht beim Abonnieren mitgekommen
  (`addedAt > podcasts.subscribedAt`; sonst wären nach dem Abo alle 200 Altfolgen „neu"). Gespielte zählen nie.
  Dieselbe Regel steuert den Punkt „Neu" in den Folgenlisten (`isFreshEpisode`).
  Ein gespeicherter Zustand müsste nach 96 h von selbst umkippen – dafür gäbe es ohne Hintergrunddienst keinen Auslöser.
- Menü zeigt die Anzahl; Einträge ohne passende Folgen sind ausgegraut. Das Menü scrollt (große Schrift).
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
- Wird eine Folge **außerhalb** einer Playlist gestartet (Start, Podcast-Seite, Downloads, Lesezeichen) und steht sie in
  **genau einer** Playlist, gilt sie als aus dieser Playlist gespielt (Benutzerwunsch 2026-09-30): „Aus Playlist „X““
  im Player, danach geht es dort weiter, „Fortsetzen" merkt sie sich. Steht sie in keiner oder in mehreren Playlists,
  gibt es keine aktive Playlist; nach dem Ende stoppt die Wiedergabe.
- **Während der Wiedergabe** beobachtet der Player, in welchen Playlists die laufende Folge steht
  (`watchPlaylistIdsWith`, nur echte Änderungen): Die aktive Playlist bleibt, solange die Folge darin steht; wird sie
  dort entfernt, übernimmt die einzige verbliebene Playlist, sonst keine; kommt sie in genau eine Playlist, wird diese
  aktiv. Ausnahme: Beim Gespielt-Markieren (98 % / Ende) verlässt sie alle Playlists absichtlich – das wird ignoriert,
  damit es mit der nächsten Folge weitergeht. Der Beobachter wird beim Folgenwechsel sofort beendet (sonst Wettlauf) und
  in `dispose` freigegeben.
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
