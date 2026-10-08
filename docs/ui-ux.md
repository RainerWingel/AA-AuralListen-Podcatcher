# UI / UX

Vorbild: **Castbox**. Material 3, Deutsch und Englisch, Hell/Dunkel (Dunkel ab M7).
Schrift: **Bildschirmtitel (AppBar) in Fredoka** halbfett (600) (Benutzerwahl 2026-09-30, zuerst Playfair Display,
dann gewechselt; `AppTheme.titleFontFamily`, über `appBarTheme.titleTextStyle`); alles andere inkl. Tab-Beschriftungen
in der Systemschrift. Die Schrift liegt als variable TTF in `assets/fonts/` (Gewicht über die `wght`-Achse), Lizenz
SIL OFL 1.1 (`OFL-Fredoka.txt`).
**Start-Bildschirm-Hintergrund** (Benutzerwunsch 2026-09-30): drei ineinanderliegende Bögen oben, außen am kräftigsten,
nach innen in die normale Fläche auslaufend (`lib/core/widgets/arch_background.dart`, `CustomPainter`, Vektor).
Geometrie exakt symmetrisch: drei konzentrische Halbellipsen um einen gemeinsamen Mittelpunkt auf der senkrechten
Bildschirmmitte (Maße in Bildschirmbreiten, Schrittweite je Bogen gleich).
Töne = Primärfarbe mit 7–19 % über der Oberfläche (hell/dunkel automatisch), feine helle Kante zwischen den Bögen.
Liegt hinter dem ganzen Bildschirm inkl. transparenter AppBar; die Liste bleibt unter der AppBar.
**Downloads-Hintergrund** (Benutzerwunsch 2026-09-30, `lib/core/widgets/squares_background.dart`): Raster aus Quadraten,
das ein Dreieck in der oberen linken Ecke füllt. „Schritt" = Spalte + Zeile (0 in der Ecke, max. 11): pro Schritt
Quadrat × 0,92 kleiner, Farbe × 0,88 schwächer; Spalten-/Zeilenbreite pro Index × 1,07 → Abstände wachsen. Keine
Zufallswerte, Maße in Bildschirmbreiten. Beide Hintergründe über `BackgroundScaffold` (transparente AppBar). Weil Flutter eine
transparente AppBar als „dunkel" wertet, setzt `BackgroundScaffold` die Statusleisten-Symbole selbst (hell: dunkle
Symbole, dunkel: helle) – sonst waren sie im hellen Modus weiß (Bug 2026-09-30).

## Navigation (untere Leiste)
1. **Start** – neueste Folgen aller Abos, Pull-to-Refresh. **🔥 „Beliebt"** (Benutzerwunsch 2026-10-08, nur hier):
   rechts bei noch nicht angefangenen Folgen eines Podcasts **oder Themas**, das du fast nie auslässt – knapp über dem
   96-h-Punkt bzw. allein (`_NewMarks`, `Icons.local_fire_department`). Regel (`HotSources`): von den **10 neuesten**
   Folgen, die **älter als 7 Tage** sind und nicht älter als die älteste je gehörte, sind **≥ 80 %** gehört
   (`episodes.finishedListening` – gesetzt ab **90 % der Länge**, viele überspringen das Outro, Benutzerwunsch
   2026-10-09; ändert „gespielt" nicht – oder angefangen); mindestens 5 solcher Folgen. „Als gespielt markieren" zählt
   als ausgelassen. Eine kleine beobachtete Abfrage (5 Spalten) wird im Speicher ausgewertet; die Oberfläche hört nur
   von geändertem Ergebnis (`distinct`). Kein nachgeschobenes `asyncMap`-Query – das hing in Widget-Tests.
2. **Abos** – Raster mit Covern; Tippen → Podcast-Detail mit Folgenliste und Podcast-Einstellungen. Im Kopf des
   Podcast-Details unter der Beschreibung (falls im Feed) antippbare Links: 🌐 Website (angezeigt als Host ohne „www.",
   z. B. „freakshow.fm") und ♡ Unterstützen (Text aus `podcast:funding`, sonst „Unterstützen"); öffnen im Browser
   (Benutzerwunsch 2026-10-03). **Langes Drücken auf „XY Folgen"** zeigt als Tooltip die durchschnittliche Folgenlänge
   („Ø 1 Std. 5 Min. pro Folge"; Benutzerwunsch 2026-10-08) – aus den gespeicherten Feed-Daten, ohne Netzzugriff,
   aus den **70 neuesten** Folgen (nach Erscheinungsdatum, `averageOf`), davon nur die mit bekannter Länge
   (`averageEpisodeLength`); sonst „Durchschnittliche Länge unbekannt".
   Rotes Zahlen-Abzeichen oben rechts = ungespielte Folgen (neu + angefangen), ab 100 „99+", bei 0 keins
   (`watchUnplayedCounts`: eine gruppierte Abfrage für alle Abos). Feed-Fehler: rotes Symbol oben links.
   **Bewertung & Reihenfolge** (Benutzerwunsch 2026-10-05): Im Menü beim langen Drücken auf eine Kachel stehen unter dem
   Titel fünf antippbare Sterne (`_RatingStars`, gespeichert in `podcasts.rating`, sofort; denselben Stern nochmal
   tippen = Bewertung entfernen). Die Abos sind **nach Sternen absteigend, dann nach Name** sortiert
   (`PodcastRepository.watchPodcasts`; unbewertet = 0 Sterne, also am Ende). Auf dem Cover unten links ein kleines
   „★4" auf dunkler Pille (`_RatingBadge`), bei unbewerteten nichts. Das Menü ist dafür kompakter (dichte
   Einträge, `ListTileTheme.merge`) – gilt auch für die gleichen Menüs auf Podcast-Seite, Staffeln und Themen; Sterne
   gibt es nur im Abos-Tab.
3. **Playlists** – Liste der Playlists → Inhalt mit Drag & Drop
4. **Downloads** – laufende und fertige Downloads
5. **Optionen** (Bildschirmtitel „Einstellungen") – Sprünge, Boost-Standard, Speicher, OPML, Backup, Info

Tab-Beschriftungen höchstens 9 Zeichen (Länge von „Downloads"): Bei 5 Tabs und großer Systemschrift brechen längere
Wörter auf dem S25 um (Test: „layout fits a Galaxy S25 with enlarged font").

Suche (Verzeichnisse, neue Podcasts): Lupe oben rechts auf **Start** → Suchbildschirm (`/abos/suche`) mit Eingabefeld
in der AppBar.
Treffer: Cover, Titel, „Autor · N Folgen", rechts ⊕ (abonnieren) bzw. ✓ (abonniert). Nach dem Abonnieren
Snackbar „„X" abonniert" mit Aktion „Öffnen".
Abos-Tab: Lupe + „+" (RSS-URL). Die **Lupe im Abos-Tab sucht nur in den Abos** (Benutzerwunsch 2026-09-30, lokal,
ohne Internet): AppBar wird zum Eingabefeld „In Abos suchen" (← bzw. Android-Zurück schließt, ✕ leert). Treffer
während des Tippens: Abschnitt „Podcasts" (Name oder Autor, ohne Groß/Klein und Umlaute, `foldForSearch`), darunter
„Folgen" (Titel oder Show-Notes, `PodcastRepository.searchEpisodes`: Titel-Treffer zuerst, dann neueste, max. 50;
SQLite-LIKE ignoriert Groß/Klein nur bei ASCII). Nichts gefunden → Hinweis auf die Suche auf „Start". Langes Drücken auf eine Kachel → „Alle neuen / seit … / alle ungespielten Episoden spielen" (→ `playlists.md`). Leerer Abos-Tab bietet: Suchen · Per RSS-URL hinzufügen · OPML-Datei importieren.
Einstellungen: Abschnitt „Abos" → „OPML-Datei importieren".

## Player
- **Mini-Player** (`lib/features/player/mini_player.dart`) über der Navigationsleiste, sobald etwas gespielt wurde:
  dünner Fortschrittsbalken, Cover, Titel, Podcast, Play/Pause (Kreisel beim Puffern). Tippen → Vollbild-Player.
- **Vollbild-Player im Dunkel-Modus: Knöpfe auf hellerem Grund** (Benutzerwunsch 2026-10-09,
  `lib/core/perceived_brightness.dart`): Text- und Symbolknöpfe (−15/+30, Lesezeichen, Sleep-Timer, Boost, Tempo,
  Playlist-Zeile, Schließen) und der Beschreibungs-Bereich (abgerundete Fläche) bekommen einen Hintergrund mit der
  **3-fachen Leuchtdichte** des Seitenhintergrunds. Nach Weber–Fechner wird Helligkeit logarithmisch empfunden – vor fast
  Schwarz ist dieser kleine absolute Schritt deutlich sichtbar. Symbole/Texte behalten ihre Farbe; der Play-Knopf setzt
  seine Farben explizit (sonst überstimmte ihn das Theme). Heller Modus unverändert. (Ein erster Versuch hellte den
  Vordergrund auf – verworfen.) **Abstände:** Play-Zeile → Knopfreihe 1 → Knopfreihe 2 → Beschreibung jeweils **16**
  sichtbar (`_controlGap` = 12 + 4 unsichtbarer Tipp-Rand der Textknöpfe; zwischen den Reihen 8 + 4 + 4), ein
  Widget-Test misst es nach.
- **Vollbild-Player** (`/player`, fährt von unten ein, verdeckt die Navigation): großes Cover, Titel, Podcast (davor ✓-Download-Symbol „Heruntergeladen", wenn die Datei komplett auf dem Gerät ist),
  Slider mit „verstrichen" / „-verbleibend" (Tippen auf die rechte Zeit wechselt zur Gesamtlänge und zurück, gemerkt in
  `settings['player.showTotalTime']`, Benutzerwunsch 2026-10-03; bei Tempo ≠ 1 zusätzlich „(-tatsächliche Restzeit)"),
  −15 s / Play / +30 s, „Boost: …" und daneben „Tempo: …" (öffnen je eine Auswahl, `playback.md`). Pfeil nach unten schließt.
  Darunter „Kapitel x/n: Titel" (falls vorhanden; tippen → Kapitel-Liste) und Knöpfe „Lesezeichen setzen", Sleep-Timer (Stoppuhr;
  aktiv: „noch mm:ss" bzw. „Bis Folgenende"), „Lesezeichen (n)". Ganz unten aufklappbarer Bereich „Beschreibung"
  (Shownotes mit Links, zugeklappt; Benutzerwunsch 2026-10-01). Aufgeklappt steht oben „Folge 105 · 26. September
  2025" – Nummer wie am Cover (eigene Zählung/Versatz/Staffel „S2·5" beachtet), Erscheinungsdatum aus
  `mediaItem.extras['pubDateMs']` (Benutzerwunsch 2026-10-04); der Bereich erscheint auch ohne Shownotes, wenn es
  Nummer oder Datum gibt.
  Kapitel-Liste: Titel, darunter Startzeit, rechts Chip „Skip" (übersprungen = durchgestrichen) → `playback.md`.
- **Boost-Auswahl** (Bottom-Sheet): Aus / +3 / +6 / +9 / +12 dB, Schalter „Nur für diesen Podcast".

## Folgen-Elemente
Cover, Titel (max. 2 Zeilen), auf der Startseite der Podcast-Name in eigener Zeile, darunter **Datum · Dauer**
(eigene Zeile, damit lange Podcast-Namen sie nie verdrängen), Fortschritt (Balken, nur bei `angefangen` und ab 15 s Position; immer gleich breit – rechts steht stets ein 24 pt breiter Platz, auch ohne Symbol, Benutzerwunsch 2026-10-04), Status-Icon (Punkt = **frisch** – ungespielt und von einem Refresh vor < 96 h geholt, gleiche Regel wie
„Alle neuen Episoden spielen" (`isFreshEpisode`); ältere ungespielte Folgen ohne Punkt · Haken = gespielt · Equalizer = läuft gerade;
laufende Folge hervorgehoben; eine **gespielte** Folge gilt nur als laufend, solange sie wirklich noch spielt –
nach dem Ende zeigt sie den Haken, auch wenn der Mini-Player sie noch anzeigt). Gespielte Folgen: Bild, Titel und Untertitel mit 50 % Deckkraft wie bei Castbox
(`EpisodeTile.playedOpacity`), Haken bleibt voll sichtbar, die gerade laufende Folge wird nie abgeblendet. **Tippen = abspielen.** **Langes Drücken** = Menü: Abspielen, Als gespielt / ungespielt markieren.
Menü außerdem: Herunterladen / Download abbrechen / Download löschen / Erneut herunterladen (je nach Zustand); wartet
der Download auf WLAN, zusätzlich „Jetzt über Mobilfunk laden" (`eviction.md`).
**Folgennummer am Cover** (Benutzerwunsch 2026-09-30, `lib/data/episode_numbers.dart`, `_NumberedCover` in
`episode_tile.dart`): schmaler schwarzer Streifen am linken Cover-Rand, zu 75 % transparent (Benutzerwunsch 2026-10-01), Zahl weiß mit
leichtem Schatten, von unten nach oben
gelesen, in allen Folgenlisten (nicht im Player). Regeln: Hat der Feed eigene Nummern (`itunes:episode`), werden die
gezeigt – Folgen ohne Nummer bekommen dann keine (keine Kollision mit Bonusfolgen). Sonst zählt die App über den ganzen
Feed nach Veröffentlichungsdatum (älteste = 1, bei gleichem Datum der ältere DB-Eintrag zuerst) plus Versatz; Folgen
ohne Datum bekommen keine Nummer. Podcast-Einstellungen: Schalter „Folgennummer am Cover" (Standard an); bei Feeds
mit eigenen Nummern Auswahl **„Nummerierung: Feed-Nummern | Eigene Zählung"** (Standard Feed-Nummern; fast alle
Podcasts liefern `itunes:episode`, Benutzerwunsch 2026-10-01); „Versatz der Zählung" als − [Feld] + (−9999…9999,
Eingabe mit „Fertig" oder beim Verlassen übernommen) gilt **nur für die eigene Zählung** – bei Feed-Nummern
ausgegraut mit Hinweis. „Eigene Zählung" nummeriert auch Folgen ohne Feed-Nummer. Themen-Feeds zählen über den ganzen Feed.

**Staffeln und Serien** (Benutzerwunsch 2026-10-03, `itunes:season`, `itunes:type`):
- Als Staffel-Podcast gilt er erst ab **zwei verschiedenen Staffeln** (`PodcastRepository.minSeasons`): manche Feeds
  markieren nur vereinzelte Folgen mit Staffel 1 („Hi Freaks": 2 von 105 Folgen, Fehler des Podcasters, 2026-10-03) –
  bei nur einer Staffel werden die Angaben ignoriert (keine Chips, kein „S1·", eigene Zählung möglich).
- Hat ein Podcast Staffeln, zeigt der Cover-Streifen **„S2·5"** (Staffel·Feed-Nummer), „S2" für ungezählte Folgen
  einer Staffel (Trailer, Bonus), nur die Nummer für Folgen ohne Staffel. **Eigene Zählung und Versatz sind dann aus**
  (Podcast-Einstellungen: Hinweis statt Auswahl) – sie würden die Staffeln durcheinanderbringen.
- Podcast-Detail: unter dem Kopf Chips **„Alle · Staffel 1 · Staffel 2 …"** (seitlich scrollbar); Tippen filtert die
  Liste, **langes Drücken** öffnet das Abspielmenü nur für diese Staffel (neue / seit … / alle ungespielten spielen,
  alle als (un)gespielt markieren) – wie die Themen in den Podcast-Einstellungen. Die Auswahl gilt nur, solange die
  Seite offen ist.
- **Serien-Podcasts** (`itunes:type` = `serial`, z. B. Hörspiele, Doku-Reihen) erscheinen in **Hörreihenfolge**:
  Staffel, dann Folgennummer, dann Datum (ohne Staffel/Nummer jeweils dahinter) – in der Podcast-Liste, bei „Alle
  ungespielten spielen" und beim Auto-Download (die nächsten statt der neuesten, `eviction.md`). Normale Podcasts
  (`episodic`, Standard) bleiben neueste zuerst. Code: `PodcastRepository.serialOrder`.
**Lange Folgentitel** – solche, die **nicht in zwei Zeilen passen** (gemessen mit `TextPainter` bei aktueller Breite und
Schriftgröße; zuerst galt „ab 60 Zeichen") – stehen in **Listen** bei 65 % der normalen Schriftgröße (Benutzerwunsch
2026-10-09, `EpisodeTitle`/`textOverflows` in `lib/core/widgets/episode_title.dart`): Folgenzeilen (Start, Podcast-Seite,
Playlists, Abos-Suche), Downloads-Tab, Abspielverlauf, Lesezeichen-Liste. **Nicht** im Player, Mini-Player oder in
Menüs/Detail-Fenstern.
Vor dem Datum ein kleines Download-Symbol: ✓ heruntergeladen, 🕓 wartet (`Icons.schedule`, Tooltip „Wartet auf WLAN …"
bzw. „Wartet …" – Benutzerwunsch 2026-10-05, vorher leere Lücke), Fortschrittskreis (mit blasser Spur, damit er auch bei
0 % sichtbar ist; ohne Wert dreht er), ⚠ fehlgeschlagen. Daneben
Playlist-Symbol (`playlist_add_check`, Tooltip „In einer Playlist"), solange die Folge in mindestens einer Playlist
steht – live aus der DB (`episodesInPlaylistsProvider`), verschwindet beim Entfernen aus der letzten Playlist; in der
Playlist-Ansicht selbst nicht angezeigt (Benutzerwunsch 2026-10-01).
Langes Drücken → Menü mit „Beschreibung" (Sheet mit Titel und Shownotes, markierbar, Links antippbar → Browser;
ohne Shownotes „Für diese Folge gibt es keine Beschreibung."; `lib/features/episodes/episode_description.dart`).
Shownotes = Text mit Absätzen, Aufzählungen (•) und Links, kein HTML (`data-model.md` → `episode_notes`); auch nackte
Adressen im Text werden zu Links. Außerdem „Zu Playlist hinzufügen…".

## Playlists
- **Playlists-Tab:** Liste mit Name und „N Folgen · Dauer", Griff ≡ zum Sortieren, ⋮ (Fortsetzen, Alles downloaden,
  Umbenennen, Farbe…, Löschen – `playlists.md`), farbige Playlists mit Farbverlauf im Hintergrund,
  AppBar „Neue Playlist". Tippen öffnet die Playlist.
- **Playlist:** Folgen in Reihenfolge (mit Podcast-Name), Griff ≡ zum Verschieben, nach links wischen = entfernen
  (Snackbar mit „Rückgängig"). Tippen spielt ab und macht die Playlist aktiv. AppBar: ▶ „Fortsetzen" (zuletzt gespielte Folge, sonst oben), ⋮ mit
  Sortieren.
- **Vollbild-Player:** Bei aktiver Playlist Zeile „Aus Playlist „X"" mit ⏭ „Nächste Folge"; nur angeboten (Folge
  anderswo gestartet) halbtransparent, Antippen aktiviert sie (`playlists.md`) – unter dem
  Podcast-Namen, über dem Positionsregler.

## Downloads-Tab
Oben „x von y belegt" mit Balken, darunter alle Downloads (neueste zuerst): Cover, Titel, Podcast, Größe bzw. „42 %"
mit Balken (nur solange wirklich übertragen wird) / „Wartet auf WLAN …" bzw. „Wartet …" / „Download fehlgeschlagen"; rechts „Zu Playlist hinzufügen…" (bei mehreren Playlists die bekannte
Auswahl) und Löschen / Abbrechen / Erneut; bei „Wartet auf WLAN …" zusätzlich 📶 „Jetzt über Mobilfunk laden".
**Löschen fragt nach** („„Titel" vom Gerät löschen? Die Folge bleibt …", Benutzerwunsch 2026-10-05).
**Langes Drücken** = Details-Sheet (`download_details_sheet.dart`, Benutzerwunsch 2026-10-05): Cover, voller Titel und
Podcast (markierbar), dann Autor, Folge (Nummer wie am Cover), Erschienen, Länge, Download-Zustand (live), Größe und
„Heruntergeladen" (Datum + Uhrzeit, nur fertige), Hörstand (Neu / Angefangen bei 12:34 / Gespielt am …); Knopf
„Beschreibung" öffnet die Shownotes. Tippen spielt ab. AppBar: 🧹 Jetzt aufräumen.

## Vorläufige Podcasts (Benutzerwunsch 2026-10-05)
- Per **„+"** (RSS-URL, Knopf „Hinzufügen") oder aus dem **Katalog** (Suche, ⊕ „Hinzufügen", Infobox „… vorläufig
  hinzugefügt") geladene Podcasts sind erst **vorläufig** (`podcasts.provisional`). OPML-Import und Backup abonnieren
  direkt bzw. übernehmen den Zustand.
- **Abos-Tab:** vorläufige oben unter „Vorläufig", darunter ein Balken und „Abonniert" mit den übrigen (ohne vorläufige
  nur das Raster wie bisher). Cover vorläufiger **schwarz-weiß und blasser** (`ColorFiltered` + `Opacity` 0,55), ohne
  rotes „ungespielt"-Abzeichen (dort ist ja alles ungespielt).
- **Abonnieren** an zwei gleichwertigen Stellen: Menü beim langen Drücken (Knopf rechts neben dem Namen; sonst nichts im
  Menü – keine Sterne, keine Playlists) und Podcast-Seite (Knopf unter „XY Folgen"). → `confirmSubscription`, Infobox
  „… abonniert".
- Vorläufig heißt: **nur streamen**. Kein Download (auch `DownloadService.download` lehnt ab, kein Auto-Download, kein
  „Herunterladen" im Streaming-Hinweis), keine Playlists, keine Podcast-Einstellungen, nicht auf „Start", nicht im
  OPML-Export. ⋮ auf der Podcast-Seite hat nur **„Entfernen"** (löscht wie „Abo kündigen"), Folgen-Menü nur
  „Abspielen" und „Beschreibung", Staffel-Chips ohne Abspielmenü.
- **Beim Abspielen wird nichts gespeichert** (Benutzerwunsch 2026-10-05): keine Hörposition, kein Status (neu/
  angefangen/gespielt), keine Dauer-Korrektur, kein Abspielverlauf, nicht „zuletzt gespielt" (`player.lastEpisodeId`),
  kein „wechselnde Werbung"-Merker. Im Player fehlen Lesezeichen- und Boost-Knopf (Boost gilt nur, wie er gerade ist).
  Der Handler prüft das bei jedem Schreiben (`PlaybackRepository.isProvisional`), „Abonnieren" während der Wiedergabe
  wirkt also sofort.
- **Abonnierte Podcasts:** „Abo kündigen" steht nicht mehr im ⋮, sondern als Knopf **„Deabonnieren"** an derselben
  Stelle wie „Abonnieren" (unter „XY Folgen"); löscht nach Rückfrage „Deabonnieren?" Podcast und Folgen.

## Podcast-Menü (⋮ im Podcast-Detail)
Podcast-Einstellungen · Alle neuen Episoden abspielen · Ungespielte Episoden seit … abspielen · Alle ungespielten
Episoden abspielen (Benutzerwunsch 2026-10-03, `playlists.md`) · Als gespielt markieren bis … · Als ungespielt markieren
seit … (je Kalender → Rückfrage mit Anzahl → Infobox). Kündigen über den Knopf „Deabonnieren" im Kopf (2026-10-05).
Langes Drücken auf einen Podcast im Abos-Tab packt
dagegen nur in eine Playlist (ohne Abspielen).

## Podcast-Einstellungen
Podcast-Detail → ⋮ → „Podcast-Einstellungen" (Bottom-Sheet): Automatisch herunterladen (Aus / Nur WLAN / Immer),
„Anzahl ungespielter Folgen auf dem Gerät" (1/2/3/5/10, auch bei „Aus" wählbar; Hinweis: lädt nach, löscht nichts;
wirksam erst beim Schließen des Blatts), darunter „Neue Downloads zur Playlist hinzufügen" → Dialog Keine / Playlists
(mit Farbverlauf) und Hinweis zur Neuanlage (`eviction.md`), Schalter „Gespielte Folgen löschen" (96 h nach „gespielt" = bis zum Ende gehört).
Bei Netzwerk-Feeds mit ≥ 2 Themen darunter „Themen für automatische Downloads": je Thema Checkbox, Bild der neuesten Folge,
Name, „N Folgen · zuletzt …"; Knöpfe „Alle" / „Keine". Die Liste ist auch bei ausgeschaltetem Auto-Download bedienbar
(erst Themen wählen, dann einschalten – sonst startet sofort alles). Das Blatt scrollt.
Ganz unten „Feed-Adresse ändern" mit der aktuellen Adresse → Dialog (Hinweis, Textfeld mit alter Adresse, „Übernehmen");
Fehler erscheinen im Textfeld, Erfolg als Infobox „Feed-Adresse geändert.".
Hat ein Pull-to-Refresh Umzüge erkannt, meldet eine Infobox „N Podcast(s) umgezogen – die Adresse wurde aktualisiert."

## Optionen
Abschnitt „Darstellung": System / Hell / Dunkel (`settings['ui.themeMode']`, Dark Mode aus derselben Grundfarbe),
darunter „Sprache" → Dialog Deutsch / English (`settings['ui.language']`, die App wechselt sofort), dann
„App-Farbe" → Dialog mit 8 Farbkreisen + „Wie Hintergrundbild" (nur wenn das Handy Wallpaper-Farben liefert,
Android 12+; `settings['ui.appColor']`, `AppColor`, `lib/features/settings/app_color_picker.dart`). Alles – Knöpfe,
Balken, Tabs, Punkte und die Hintergründe von Start und Downloads – folgt der Farbe; Cover, rotes Ungespielt-Abzeichen,
Playlist-Farben und Fehlerrot nicht. **Standard = „Wie Hintergrundbild"**; ohne Wallpaper-Farben Orange (die Zeile
zeigt dann „Orange"). Die Hintergrundbild-Farbe wird in `main.dart` vor dem ersten Bild gelesen (kein Orange-Aufblitzen).
Abschnitt „Info" (ganz unten): „Über die App" → Info-Seite (`info_screen.dart`): App-Symbol, Name, **Version + Build
automatisch von Android** (Kanal `aurallisten/app`, kommt beim Bauen aus `pubspec.yaml`), „Entwickelt von Artem A.",
Links Datenschutzerklärung und „Quellcode auf GitHub" (öffnen den Browser). **Kein Zahlungslink in der App** –
freiwillige Unterstützung (PayPal) steht auf GitHub (README „Unterstützen", Sponsor-Knopf via `.github/FUNDING.yml`). Abschnitt „Hören": Lesezeichen (alle), **„Abspielverlauf"** (`playback.md`), „Hintergrund-Wiedergabe" (Akku-Status, → `playback.md`). Abschnitt „Abos": OPML-Import. Abschnitt „Downloads": Speicherlimit (1–20 GB), „Jetzt aufräumen".
Abschnitt „Sicherung": Abos als OPML exportieren, Backup erstellen, Backup wiederherstellen (`backup.md`).

## Infoboxen (SnackBars)
- **Nur** über `showInfoSnackBar` (`lib/core/widgets/info_snack_bar.dart`) – nie `showSnackBar` direkt.
- Regel des Benutzers: **höchstens 7 Sekunden** sichtbar. Ohne Knopf 4 s, mit Knopf (z. B. „Rückgängig") 6 s.
- Eine neue Meldung ersetzt die aktuelle sofort (keine Warteschlange).
- Hintergrund: Flutter lässt SnackBars **mit** Knopf standardmäßig stehen, bis man sie wegwischt (`persist`); der Helfer
  setzt `persist: false`. Test: `test/core/info_snack_bar_test.dart`.

## Sprache und Texte
- Alle Texte in `lib/l10n/app_de.arb` (Vorlage) und `lib/l10n/app_en.arb` – **jeder neue Schlüssel in beide**
  (Test `test/l10n_test.dart` prüft das). Deutsch in Du-Form, Englisch im gleichen lockeren Ton; kurz.
- **Erster Start:** Ist `ui.language` nicht gesetzt, zeigt `AuralListenApp` (über `MaterialApp.builder`) statt der App
  den Sprachwähler (`lib/features/settings/language_picker.dart`: oben „Willkommen beim Podcatcher
  „AA-AuralListen“" / „Welcome to the Podcatcher …", App-Symbol, „Sprache wählen", Knöpfe Deutsch /
  English). Er erscheint in der Gerätesprache (Deutsch bei deutschem Gerät, sonst Englisch). Ein Tipp speichert die
  Wahl, danach erscheint die App.
- Datum und Größen formatieren mit `AppLocalizations.localeName` (nie fest `'de'`). In **Listen** kurzer Monat
  (`formatEpisodeDate`, Benutzerwunsch 2026-09-29): „27. Feb." / „Feb 27", mit Jahr „15. März 2025" / „Mar 15, 2025";
  in Dialogen und Meldungen ausgeschrieben („10. Juni 2025"),
  „1,2 GB" / „1.2 GB".
- Der Name des Benachrichtigungskanals (Android-Einstellungen) wird in `main.dart` beim Start aus der gespeicherten
  Sprache gesetzt.
- Fehlermeldungen verständlich, ohne Stacktraces („Feed konnte nicht geladen werden").

## Datumsauswahl
Kalender („Als gespielt markieren bis …", „Als ungespielt markieren seit …", „Ungespielte Episoden seit …"): Im Texteingabe-Modus (Stift) wird die
**normale Tastatur** angefordert (`keyboardType: TextInputType.text`) – Samsungs Datums-Tastatur hat keinen Punkt,
„tt.mm.jjjj" ließ sich sonst nicht eintippen.
