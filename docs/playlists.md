# Playlists

Vorbild: Castbox. Mehrere Playlists, manuell befüllt. **Umgesetzt in M5 ✅**

Code: `lib/data/playlist_repository.dart` (Verwaltung, `nextAfter`), `lib/audio/podcast_audio_handler.dart`
(aktive Playlist, Weiterspielen, „Weiter"), `lib/features/playlists/` (UI). Tests: Gruppe „playlists" in
`test/audio/podcast_audio_handler_test.dart`, `test/data/playlist_repository_test.dart`.

## Verwaltung
- Playlists anlegen, umbenennen, löschen, sortieren (Griff ≡ ziehen). Beim ersten Start – und beim Update auf Schema v4 –
  wird die Playlist „Wiedergabeliste" angelegt. Löschen einer Playlist löscht nur die Einträge, nicht die Folgen.
- **Namen sind eindeutig** (Benutzerwunsch 2026-10-05): Anlegen oder Umbenennen auf einen schon vorhandenen Namen
  (Groß-/Kleinschreibung und Leerzeichen außen egal) zeigt im Dialog „Eine Playlist mit diesem Namen gibt es schon."
  und lässt ihn offen; der eigene Name beim Umbenennen ist erlaubt (`playlist_actions.dart`, `_uniqueName`). Nur eine
  Dialog-Prüfung, keine DB-Bedingung (die automatische Ziel-Playlist von Auto-Download legt Namen selbst an).
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
Ein Menü (`showPodcastPlayMenu` in `play_podcast_episodes.dart`) an drei Stellen:
- **Abos-Tab → langes Drücken auf eine Kachel/Zeile:** die drei Folgen-Einträge **packen nur in eine Playlist**, ohne
  abzuspielen (Benutzerwunsch 2026-10-03, `PodcastEpisodesAction.addToPlaylist`): „Alle neuen Episoden in Playlist",
  „Ungespielte Episoden seit … in Playlist", „Alle ungespielten Episoden in Playlist"; Infobox „n Folgen zu „X"
  hinzugefügt." bzw. „Alle Folgen waren schon in „X".".
- **Thema** (Netzwerk-Feeds wie WRINT): Podcast-Einstellungen → „Themen für automatische Downloads" → langes Drücken
  (Benutzerwunsch 2026-09-30) – nur Folgen dieses Themas (`unplayedEpisodes(theme: …)`), Titel „Podcast · Thema";
  packt wie die Abos-Übersicht **nur in eine Playlist** (Benutzerwunsch 2026-10-04).
- **Staffel**: langes Drücken auf einen Staffel-Chip im Podcast-Detail – nur diese Staffel.
Nur die Staffel **spielt** wie unten beschrieben. Zusätzlich hat das ⋮-Menü im Podcast-Detail direkt (ohne Menü
dazwischen) „Alle neuen Episoden abspielen", „Ungespielte Episoden seit … abspielen", „Alle ungespielten Episoden
abspielen" (`playFromPodcastMenu`; nichts Passendes → Infobox). Schon enthaltene Folgen werden immer übersprungen:
1. **„Alle neuen Episoden spielen"** – nur **frische** Folgen.
2. **„Ungespielte Episoden seit … spielen"** – Kalender (öffnet auf heute, frühestes Datum = älteste ungespielte
   Folge): ungespielte Folgen mit Veröffentlichungsdatum **ab Beginn des gewählten Tags**; Folgen ohne Datum zählen
   nicht. Keine passenden → Infobox „Keine ungespielten Folgen seit dem …".
3. **„Alle ungespielten Episoden spielen"** – alle Folgen mit Status neu oder angefangen (älteste zuerst, bei
   Serien-Podcasts in Hörreihenfolge nach Staffel und Folge; mit Staffel-Chip nur diese Staffel).
4. **„Alle als gespielt markieren"** (unter einem Trennstrich; Benutzerwunsch 2026-09-30): alle Folgen des Podcasts bzw.
   des Themas, auch ohne Datum – Regeln wie „Als gespielt markieren bis …" (verlassen alle Playlists, Downloads nach
   96 h weg). Sind **alle** betroffenen Folgen schon gespielt, heißt der Eintrag **„Alle als ungespielt markieren"**
   (werden wieder neu). Beides mit Rückfrage samt Anzahl (`PlaybackRepository.markAllPlayed` / `markAllUnplayed`).
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

## „Als Nächstes spielen" / „Ans Ende anfügen" (Benutzerwunsch 2026-10-03)
Läuft gerade eine Folge aus einer **aktiven** Playlist X (Zeile „Aus Playlist „X"" voll sichtbar; eine nur angebotene,
halbtransparente zählt nicht), hat das Menü beim langen Drücken auf eine **andere** Folge außerhalb der Playlist-Ansicht
(Start, Podcast-Seite, Suche …) zwei weitere Einträge (`episode_tile.dart`):
- **„Als Nächstes spielen"** (Untertitel „Direkt nach der laufenden Folge in „X""): fügt sie direkt hinter der laufenden
  Folge in X ein; steht sie schon woanders in X, wird sie dorthin verschoben (`PlaylistRepository.insertAfter`).
- **„Ans Ende der Playlist „X" anfügen"**: hängt sie hinten an – nur aktiv, wenn sie noch nicht in X steht.
Für die laufende Folge selbst gibt es beide Einträge nicht. Die nächste Folge wird am Ende ohnehin frisch aus der DB
gelesen, die neue Reihenfolge gilt also sofort.

## Abspielverhalten
- Startet der Benutzer eine Folge **aus einer Playlist**, wird diese Playlist zur **aktiven Playlist**.
- Erreicht die Folge ihr **Ende** (Dateiende; keine 98-%-Regel mehr, Benutzerwunsch 2026-10-03):
  1. Folge wird als **gespielt** markiert (`playedAt` gesetzt).
  2. Folge wird **nur aus der aktiven Playlist entfernt** (der mit ⏭; Benutzerwunsch 2026-10-03, vorher aus allen) und
     bleibt in allen anderen. Ohne aktive Playlist (auch wenn eine nur angeboten war) bleibt sie überall.
  3. Die **nächste Folge derselben Playlist startet automatisch**.
- Die „nächste Folge" wird **erst in diesem Moment aus der DB gelesen** – kein Schnappschuss beim Start.
  Dadurch wird eine Folge, die während der Wiedergabe hinzugefügt wurde, automatisch mitgespielt.
- Ist die Playlist leer, stoppt die Wiedergabe.
- Wird eine Folge **außerhalb** einer Playlist gestartet (Start, Podcast-Seite, Downloads, Lesezeichen) und steht sie in
  **genau einer** Playlist, wird diese Playlist nur **angeboten** (Benutzerwunsch 2026-10-03, ersetzt die Regel vom
  2026-09-30 „gilt automatisch als aus der Playlist gespielt"): Zeile „Aus Playlist „X““ im Player **halbtransparent
  (50 %)**, kein ⏭ in der Benachrichtigung, „Fortsetzen" merkt sie sich nicht, **am Ende stoppt die Wiedergabe**.
  Tippt der Benutzer auf die Zeile (oder ihr ⏭), wird die Playlist aktiv (`continueWithSuggestedPlaylist`): Zeile voll
  sichtbar, am Ende startet die nächste Folge der Playlist, Infobox **„Playlist „X“ ist aktiviert"** (2026-10-06).
  Steht sie in keiner oder in mehreren Playlists, gibt es weder Angebot noch aktive Playlist. Tippt man die gerade
  laufende Folge erneut an, bleibt ihr Playlist-Zustand.
- **Aktive Zeile, Playlist-Symbol links** („Playlist öffnen", Benutzerwunsch 2026-10-06): schließt den Player und zeigt
  die Playlist im Playlists-Tab, gescrollt zur laufenden Folge (`Routes.playlistAt` → `?folge=ID&r=…`; `r` macht einen
  erneuten Sprung zur selben Folge zu einer neuen Adresse). `PlaylistScreen` springt erst grob (geschätzte Zeilenhöhe,
  die Liste baut nur Sichtbares) und richtet die Folge dann mit `Scrollable.ensureVisible` auf ein Drittel der Höhe aus.
- **Während der Wiedergabe** beobachtet der Player, in welchen Playlists die laufende Folge steht
  (`watchPlaylistIdsWith`, nur echte Änderungen): Die aktive Playlist bleibt, solange die Folge darin steht; wird sie
  dort entfernt, wird die einzige verbliebene Playlist nur **angeboten**, sonst keine; kommt sie in genau eine Playlist,
  wird diese angeboten (aktiv erst nach Antippen). Der Beobachter wird beim Folgenwechsel und am Ende der Folge (vor dem
  Gespielt-Markieren, das sie absichtlich aus allen Playlists nimmt) sofort beendet und in `dispose` freigegeben.
- Überspringt der Benutzer eine Folge manuell („Weiter" ⏭ im Vollbild-Player bzw. in der Benachrichtigung), wird sie
  **nicht** als gespielt markiert und **bleibt** in der Playlist.
- Manuelles „Als gespielt markieren" (auch „bis …") entfernt die Folge dagegen aus **allen** Playlists
  (`PlaybackRepository.markPlayed`); das Ende der Wiedergabe nutzt `markFinished(id, playlistId: aktive)`.

### Umsetzungsdetails
- Am Ende (`PodcastAudioHandler._complete`) in dieser Reihenfolge: nächste Folge lesen (die laufende steht noch in der
  Playlist, ihre Position wird frisch gelesen – Umsortieren während der Wiedergabe zählt), Playlist-Beobachter beenden,
  als gespielt markieren (entfernt sie nur aus der aktiven Playlist), stoppen, nächste starten.
- Der Handler merkt sich die **Position** der laufenden Folge in der aktiven Playlist. Die nächste Folge ist der Eintrag
  mit der kleinsten Position **größer** als diese – gelesen im Moment des Wechsels.
- Aktive Playlist + Position stehen in `settings['player.activePlaylistId']` (`"<id>:<position>"`) und überleben einen
  App-Neustart. Die Playlist-ID steht auch in `mediaItem.extras['playlistId']` (für den Vollbild-Player), die angebotene
  in `extras['suggestedPlaylistId']` (nur im Speicher; nach Neustart ergibt sie der Playlist-Beobachter neu).
- `MediaItem` vergleicht nur die ID – der UI-Provider `mediaItemProvider` liefert deshalb eine Hülle `PlayerItem` ohne
  `==`, sonst kämen Änderungen derselben Folge (Dauer, Playlist) nicht in der Oberfläche an.

## Tests
Unit-Tests für: Weiterspielen, Hinzufügen während der Wiedergabe, leere Playlist, Überspringen (bleibt drin, ungespielt),
Folge in mehreren Playlists (wird beim Gespielt-Werden aus allen entfernt).
