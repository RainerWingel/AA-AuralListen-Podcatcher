# UI / UX

Vorbild: **Castbox**. Material 3, nur Deutsch, Hell/Dunkel (Dunkel ab M7).

## Navigation (untere Leiste)
1. **Start** – neueste Folgen aller Abos, Pull-to-Refresh
2. **Abos** – Raster mit Covern; Tippen → Podcast-Detail mit Folgenliste und Podcast-Einstellungen
3. **Playlists** – Liste der Playlists → Inhalt mit Drag & Drop
4. **Downloads** – laufende und fertige Downloads
5. **Optionen** (Bildschirmtitel „Einstellungen") – Sprünge, Boost-Standard, Speicher, OPML, Backup, Info

Tab-Beschriftungen höchstens 9 Zeichen (Länge von „Downloads"): Bei 5 Tabs und großer Systemschrift brechen längere
Wörter auf dem S25 um (Test: „layout fits a Galaxy S25 with enlarged font").

Suche: Lupe oben rechts auf Start und Abos → Suchbildschirm (`/abos/suche`) mit Eingabefeld in der AppBar.
Treffer: Cover, Titel, „Autor · N Folgen", rechts ⊕ (abonnieren) bzw. ✓ (abonniert). Nach dem Abonnieren
Snackbar „„X" abonniert" mit Aktion „Öffnen".
Abos-Tab: Lupe + „+" (RSS-URL). Leerer Abos-Tab bietet: Suchen · Per RSS-URL hinzufügen · OPML-Datei importieren.
Einstellungen: Abschnitt „Abos" → „OPML-Datei importieren".

## Player
- **Mini-Player** (`lib/features/player/mini_player.dart`) über der Navigationsleiste, sobald etwas gespielt wurde:
  dünner Fortschrittsbalken, Cover, Titel, Podcast, Play/Pause (Kreisel beim Puffern). Tippen → Vollbild-Player.
- **Vollbild-Player** (`/player`, fährt von unten ein, verdeckt die Navigation): großes Cover, Titel, Podcast,
  Slider mit „verstrichen" / „-verbleibend", −15 s / Play / +30 s, „Boost: …" (öffnet Auswahl). Pfeil nach unten schließt.
  Später: Kapitel, Lesezeichen-Knopf, „Zu Playlist".
- **Boost-Auswahl** (Bottom-Sheet): Aus / +3 / +6 / +9 / +12 dB, Schalter „Nur für diesen Podcast".

## Folgen-Elemente
Cover, Titel (max. 2 Zeilen), auf der Startseite der Podcast-Name in eigener Zeile, darunter **Datum · Dauer**
(eigene Zeile, damit lange Podcast-Namen sie nie verdrängen), Fortschritt (Balken), Status-Icon (Punkt = neu, Haken = gespielt, Equalizer = läuft gerade;
laufende Folge hervorgehoben). **Tippen = abspielen.** **Langes Drücken** = Menü: Abspielen, Als gespielt / ungespielt markieren.
Menü außerdem: Herunterladen / Download abbrechen / Download löschen / Erneut herunterladen (je nach Zustand).
Vor dem Datum ein kleines Download-Symbol: ✓ heruntergeladen, Fortschrittskreis, ⚠ fehlgeschlagen. Später: Zu Playlist (M5).

## Downloads-Tab
Oben „x von y belegt" mit Balken, darunter alle Downloads (neueste zuerst): Cover, Titel, Podcast, Größe bzw. „42 %" /
„Wartet auf WLAN …" / „Download fehlgeschlagen"; rechts Löschen / Abbrechen / Erneut. Tippen spielt ab. AppBar: 🧹 Jetzt aufräumen.

## Podcast-Einstellungen
Podcast-Detail → ⋮ → „Podcast-Einstellungen" (Bottom-Sheet): Automatisch herunterladen (Aus / Nur WLAN / Immer),
„Neueste ungespielte Folgen behalten" (1/2/3/5/10), Schalter „Gespielte Folgen löschen" (96 h nach 98 %).

## Optionen
Abschnitt „Abos": OPML-Import. Abschnitt „Downloads": Speicherlimit (1–20 GB), „Jetzt aufräumen".

## Texte
- Alle Texte in `lib/l10n/app_de.arb`, Du-Form, kurz.
- Fehlermeldungen verständlich, ohne Stacktraces („Feed konnte nicht geladen werden").
