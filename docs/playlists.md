# Playlists

Vorbild: Castbox. Mehrere Playlists, manuell befüllt.

## Verwaltung
- Playlists anlegen, umbenennen, löschen, sortieren. Beim ersten Start existiert eine Playlist „Wiedergabeliste".
- Folge hinzufügen über Folgen-Menü („Zu Playlist hinzufügen…") – ans Ende der gewählten Playlist.
- Reihenfolge per Drag & Drop, Entfernen per Wischen.
- Eine Folge kann in mehreren Playlists stehen, in einer Playlist aber nur einmal.

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
- Überspringt der Benutzer eine Folge manuell („Weiter"), wird sie **nicht** als gespielt markiert und **bleibt** in der Playlist.

## Tests
Unit-Tests für: Weiterspielen, Hinzufügen während der Wiedergabe, leere Playlist, Überspringen (bleibt drin, ungespielt),
Folge in mehreren Playlists (wird beim Gespielt-Werden aus allen entfernt).
