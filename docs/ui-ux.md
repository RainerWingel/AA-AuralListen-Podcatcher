# UI / UX

Vorbild: **Castbox**. Material 3, nur Deutsch, Hell/Dunkel (Dunkel ab M7).

## Navigation (untere Leiste)
1. **Start** – neueste Folgen aller Abos, Pull-to-Refresh
2. **Abos** – Raster mit Covern; Tippen → Podcast-Detail mit Folgenliste und Podcast-Einstellungen.
   Rotes Zahlen-Abzeichen oben rechts = ungespielte Folgen (neu + angefangen), ab 100 „99+", bei 0 keins
   (`watchUnplayedCounts`: eine gruppierte Abfrage für alle Abos). Feed-Fehler: rotes Symbol oben links.
3. **Playlists** – Liste der Playlists → Inhalt mit Drag & Drop
4. **Downloads** – laufende und fertige Downloads
5. **Optionen** (Bildschirmtitel „Einstellungen") – Sprünge, Boost-Standard, Speicher, OPML, Backup, Info

Tab-Beschriftungen höchstens 9 Zeichen (Länge von „Downloads"): Bei 5 Tabs und großer Systemschrift brechen längere
Wörter auf dem S25 um (Test: „layout fits a Galaxy S25 with enlarged font").

Suche: Lupe oben rechts auf Start und Abos → Suchbildschirm (`/abos/suche`) mit Eingabefeld in der AppBar.
Treffer: Cover, Titel, „Autor · N Folgen", rechts ⊕ (abonnieren) bzw. ✓ (abonniert). Nach dem Abonnieren
Snackbar „„X" abonniert" mit Aktion „Öffnen".
Abos-Tab: Lupe + „+" (RSS-URL). Langes Drücken auf eine Kachel → „Alle neuen / seit … / alle ungespielten Episoden spielen" (→ `playlists.md`). Leerer Abos-Tab bietet: Suchen · Per RSS-URL hinzufügen · OPML-Datei importieren.
Einstellungen: Abschnitt „Abos" → „OPML-Datei importieren".

## Player
- **Mini-Player** (`lib/features/player/mini_player.dart`) über der Navigationsleiste, sobald etwas gespielt wurde:
  dünner Fortschrittsbalken, Cover, Titel, Podcast, Play/Pause (Kreisel beim Puffern). Tippen → Vollbild-Player.
- **Vollbild-Player** (`/player`, fährt von unten ein, verdeckt die Navigation): großes Cover, Titel, Podcast,
  Slider mit „verstrichen" / „-verbleibend", −15 s / Play / +30 s, „Boost: …" (öffnet Auswahl). Pfeil nach unten schließt.
  Darunter „Kapitel x/n: Titel" (falls vorhanden) und Knöpfe „Kapitel (n)", „Lesezeichen setzen", Sleep-Timer (Stoppuhr;
  aktiv: „noch mm:ss" bzw. „Bis Folgenende"), „Lesezeichen (n)".
  Kapitel-Liste: Titel, darunter Startzeit, rechts Chip „Skip" (übersprungen = durchgestrichen) → `playback.md`.
- **Boost-Auswahl** (Bottom-Sheet): Aus / +3 / +6 / +9 / +12 dB, Schalter „Nur für diesen Podcast".

## Folgen-Elemente
Cover, Titel (max. 2 Zeilen), auf der Startseite der Podcast-Name in eigener Zeile, darunter **Datum · Dauer**
(eigene Zeile, damit lange Podcast-Namen sie nie verdrängen), Fortschritt (Balken), Status-Icon (Punkt = **frisch** – ungespielt und von einem Refresh vor < 96 h geholt, gleiche Regel wie
„Alle neuen Episoden spielen" (`isFreshEpisode`); ältere ungespielte Folgen ohne Punkt · Haken = gespielt · Equalizer = läuft gerade;
laufende Folge hervorgehoben; eine **gespielte** Folge gilt nur als laufend, solange sie wirklich noch spielt –
nach dem Ende zeigt sie den Haken, auch wenn der Mini-Player sie noch anzeigt). Gespielte Folgen: Bild, Titel und Untertitel mit 50 % Deckkraft wie bei Castbox
(`EpisodeTile.playedOpacity`), Haken bleibt voll sichtbar, die gerade laufende Folge wird nie abgeblendet. **Tippen = abspielen.** **Langes Drücken** = Menü: Abspielen, Als gespielt / ungespielt markieren.
Menü außerdem: Herunterladen / Download abbrechen / Download löschen / Erneut herunterladen (je nach Zustand).
Vor dem Datum ein kleines Download-Symbol: ✓ heruntergeladen, Fortschrittskreis, ⚠ fehlgeschlagen. Außerdem „Zu Playlist hinzufügen…".

## Playlists
- **Playlists-Tab:** Liste mit Name und „N Folgen · Dauer", Griff ≡ zum Sortieren, ⋮ (Umbenennen, Löschen),
  AppBar „Neue Playlist". Tippen öffnet die Playlist.
- **Playlist:** Folgen in Reihenfolge (mit Podcast-Name), Griff ≡ zum Verschieben, nach links wischen = entfernen
  (Snackbar mit „Rückgängig"). Tippen spielt ab und macht die Playlist aktiv. AppBar: ▶ „Playlist abspielen" (ab oben), ⋮.
- **Vollbild-Player:** Bei aktiver Playlist Zeile „Aus Playlist „X"" mit ⏭ „Nächste Folge".

## Downloads-Tab
Oben „x von y belegt" mit Balken, darunter alle Downloads (neueste zuerst): Cover, Titel, Podcast, Größe bzw. „42 %" /
„Wartet auf WLAN …" / „Download fehlgeschlagen"; rechts „Zu Playlist hinzufügen…" (bei mehreren Playlists die bekannte
Auswahl) und Löschen / Abbrechen / Erneut. Tippen spielt ab. AppBar: 🧹 Jetzt aufräumen.

## Podcast-Menü (⋮ im Podcast-Detail)
Podcast-Einstellungen · Als gespielt markieren bis … · Als ungespielt markieren seit … (je Kalender → Rückfrage mit Anzahl →
Infobox) · Abo kündigen.

## Podcast-Einstellungen
Podcast-Detail → ⋮ → „Podcast-Einstellungen" (Bottom-Sheet): Automatisch herunterladen (Aus / Nur WLAN / Immer),
„Neueste ungespielte Folgen behalten" (1/2/3/5/10), Schalter „Gespielte Folgen löschen" (96 h nach 98 %).
Bei Netzwerk-Feeds mit ≥ 2 Themen darunter „Themen für automatische Downloads": je Thema Checkbox, Bild der neuesten Folge,
Name, „N Folgen · zuletzt …"; Knöpfe „Alle" / „Keine". Die Liste ist auch bei ausgeschaltetem Auto-Download bedienbar
(erst Themen wählen, dann einschalten – sonst startet sofort alles). Das Blatt scrollt.
Ganz unten „Feed-Adresse ändern" mit der aktuellen Adresse → Dialog (Hinweis, Textfeld mit alter Adresse, „Übernehmen");
Fehler erscheinen im Textfeld, Erfolg als Infobox „Feed-Adresse geändert.".
Hat ein Pull-to-Refresh Umzüge erkannt, meldet eine Infobox „N Podcast(s) umgezogen – die Adresse wurde aktualisiert."

## Optionen
Abschnitt „Darstellung": System / Hell / Dunkel (`settings['ui.themeMode']`, Dark Mode aus derselben Grundfarbe).
Abschnitt „Info" (ganz unten): „Über die App" → Info-Seite (`info_screen.dart`): App-Symbol, Name, **Version + Build
automatisch von Android** (Kanal `aurallisten/app`, kommt beim Bauen aus `pubspec.yaml`), „Entwickelt von Artem A.",
Links Datenschutzerklärung und „Quellcode auf GitHub" (öffnen den Browser). **Kein Zahlungslink in der App** –
freiwillige Unterstützung (PayPal) steht auf GitHub (README „Unterstützen", Sponsor-Knopf via `.github/FUNDING.yml`). Abschnitt „Hören": Lesezeichen (alle), „Hintergrund-Wiedergabe" (Akku-Status, → `playback.md`). Abschnitt „Abos": OPML-Import. Abschnitt „Downloads": Speicherlimit (1–20 GB), „Jetzt aufräumen".
Abschnitt „Sicherung": Abos als OPML exportieren, Backup erstellen, Backup wiederherstellen (`backup.md`).

## Infoboxen (SnackBars)
- **Nur** über `showInfoSnackBar` (`lib/core/widgets/info_snack_bar.dart`) – nie `showSnackBar` direkt.
- Regel des Benutzers: **höchstens 7 Sekunden** sichtbar. Ohne Knopf 4 s, mit Knopf (z. B. „Rückgängig") 6 s.
- Eine neue Meldung ersetzt die aktuelle sofort (keine Warteschlange).
- Hintergrund: Flutter lässt SnackBars **mit** Knopf standardmäßig stehen, bis man sie wegwischt (`persist`); der Helfer
  setzt `persist: false`. Test: `test/core/info_snack_bar_test.dart`.

## Texte
- Alle Texte in `lib/l10n/app_de.arb`, Du-Form, kurz.
- Fehlermeldungen verständlich, ohne Stacktraces („Feed konnte nicht geladen werden").

## Datumsauswahl
Kalender („Als gespielt markieren bis …", „Als ungespielt markieren seit …", „Ungespielte Episoden seit …"): Im Texteingabe-Modus (Stift) wird die
**normale Tastatur** angefordert (`keyboardType: TextInputType.text`) – Samsungs Datums-Tastatur hat keinen Punkt,
„tt.mm.jjjj" ließ sich sonst nicht eintippen.
