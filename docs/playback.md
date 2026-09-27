# Wiedergabe

## Aufbau (M3 ✅)
```
UI (Mini-/Vollbild-Player, EpisodeTile)      Benachrichtigung / Sperrbildschirm / Bluetooth
                 \                                   /
                  PodcastAudioHandler  (lib/audio/podcast_audio_handler.dart)
                  – eine Instanz, erstellt in main() via AudioService.init
                  – Regeln: Position, 98 %, Fortsetzen, Boost, Pause-Timeout
                 /                                   \
   PlayerEngine (Interface)                   PlaybackRepository / SettingsRepository (DB)
   └─ JustAudioEngine (just_audio/ExoPlayer)
   └─ FakePlayerEngine (Tests, test/support/)
```
- `audio_service` stellt Hintergrund-Dienst, Medien-Benachrichtigung, Sperrbildschirm und Kopfhörer-/Bluetooth-Tasten bereit
  und ruft dieselben Methoden auf wie die UI (`play`, `pause`, `seek`, `rewind`, `fastForward`, `stop`).
- `PlayerEngine` kapselt `just_audio`, damit die Logik ohne echtes Audio testbar ist (`test/audio/podcast_audio_handler_test.dart`).
- In `main()` wird die Datenbank **vor** dem Handler erzeugt und per Override in Riverpod eingespeist
  (`databaseProvider`, `audioHandlerProvider`). UI-Streams: `mediaItemProvider`, `playbackStateProvider`, `positionProvider`.
- Quelle: Streaming der `audioUrl`. Ab M4: lokale Datei, falls heruntergeladen.
- Keine Geschwindigkeitsregelung, kein Sleep-Timer, kein Stille-Kürzen (bewusst weggelassen).

### Zustandsmeldungen (Stolperfalle)
`just_audio` meldet **keinen** neuen Zustand, wenn es beim Folgenwechsel schon spielte (`playing` bleibt `true`, `play()`
ändert nichts). Der Handler ruft deshalb nach dem Laden sowie nach `play()`/`pause()` selbst `_broadcastState()` auf –
sonst bleibt der Play-Button auf „Play" stehen. Die `FakePlayerEngine` bildet dieses Verhalten bewusst nach;
Regressionstest: „switching episodes while playing reports "playing"".

## Android-Besonderheiten
- Manifest: Service `AudioService` (Typ `mediaPlayback`), `MediaButtonReceiver`, Rechte `WAKE_LOCK`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MEDIA_PLAYBACK`. `MainActivity` erbt von `AudioServiceActivity`.
- `androidStopForegroundOnPause: false`: Der Dienst bleibt in der Pause im Vordergrund, weil Android 12+ (Samsung besonders)
  einen Neustart aus dem Hintergrund verbieten kann. Dafür beendet der Handler nach **10 Minuten Pause** selbst
  (`stop()`): Player wird freigegeben, Benachrichtigung verschwindet, Position ist gespeichert.
- App im Task-Switcher weggewischt: läuft weiter, wenn gerade gespielt wird, sonst `stop()`.
- Benachrichtigungs-Symbole: `android/app/src/main/res/raw/keep.xml` verhindert, dass der Release-Build sie entfernt.
- Cover in der Benachrichtigung kommen aus dem begrenzten `CoverCacheManager` und werden auf 512 px verkleinert.

## Audio-Fokus & Kopfhörer
Übernimmt `just_audio` (Standard `handleInterruptions: true`):
- Anruf / andere App mit Audio → Pause; nach einer **kurzen** Unterbrechung (z. B. Anruf) geht es automatisch weiter.
- Navigationsansage → leiser (Ducking).
- Kopfhörer abgezogen / Bluetooth getrennt → Pause.

## Sprünge
−15 s / +30 s im Vollbild-Player und in der Benachrichtigung (Grenzen: 0 und Dauer).

## Hörposition
- Gespeichert: alle **5 s** während der Wiedergabe, bei Pause, Seek, Stopp und Folgenwechsel.
- Fortsetzen: **3 s** vor der gespeicherten Position.
- Folge ≥ **98 %** der (vom Player gemeldeten) Dauer → `gespielt`, `playedAt` = jetzt, Position = 0.
  Danach wird die Position dieser Folge nicht mehr überschrieben.
- Ende der Datei → `gespielt` (falls noch nicht), Player wird gestoppt. (Ab M5: nächste Playlist-Folge.)
- Eine gespielte Folge erneut abspielen → startet bei 0 und ist wieder `angefangen` (`playedAt` gelöscht → keine Löschung nach 96 h).
- Die vom Player gemeldete Dauer wird in `episodes.durationMs` übernommen (genauer als die Feed-Angabe).
- Letzte Folge: `settings['player.lastEpisodeId']`; nach App-Start zeigt der Mini-Player sie an, **ohne** Audio zu laden
  (kein Netzverkehr, bis Play gedrückt wird).
- **Ruheposition:** Solange kein Audio geladen ist (nach App-Start, nach Stopp/Pause-Timeout), zeigen Mini-/Vollbild-Player
  die gespeicherte Position (`handler.position` / `positionStream` liefern sie). Slider und −15/+30 s verschieben dann nur die
  gespeicherte Position (sofort in der DB); Play startet danach **exakt** dort (ohne 3-s-Rückblick).
  Regressionstests: Gruppe „before audio is loaded" in `test/audio/podcast_audio_handler_test.dart`.

## Lautstärke-Boost
- Android `LoudnessEnhancer` über `just_audio` (`AndroidLoudnessEnhancer`), Zielverstärkung in dB; 0 = aus.
- Stufen: Aus / +3 / +6 / +9 / +12 dB (Auswahl im Vollbild-Player → „Boost: …").
- Globaler Standard `settings['player.boostDb']`; pro Podcast optional `podcasts.boostDb` (Schalter „Nur für diesen Podcast").
  Eigener Podcast-Wert gewinnt. Ändert man den globalen Wert, wird der Podcast-Wert des aktuellen Podcasts entfernt.
- iOS: nicht verfügbar (die Engine ignoriert den Wert).

## Kapitel (M6 ✅)
Code: `lib/data/chapters/` (Parser, `ChapterService`, `remote_id3.dart`), UI: `lib/features/player/chapters_and_bookmarks.dart`.
Quellen in dieser Reihenfolge – die erste, die Kapitel liefert, gewinnt; Ergebnis wird in `chapters` gespeichert:
1. **Podlove Simple Chapters** (`<psc:chapters>`) im Feed – beim Refresh gespeichert (nur wenn die Folge noch keine
   Kapitel hat, damit Refreshes nichts umschreiben). Zeitformat `HH:MM:SS.mmm`, `MM:SS` oder Sekunden.
2. **Podcasting 2.0 JSON** (`<podcast:chapters url=…>`; Podigee schreibt `href=…`, beides wird gelesen).
   `"toc": false`-Einträge werden übersprungen. Bei WRINT liefern diese Links **404** (HTML-Seite) → nächste Quelle.
3. **ID3-CHAP im MP3** (v2.3/v2.4, Titel aus `TIT2`, Link aus `WXXX`): heruntergeladene Datei lokal lesen, sonst per
   HTTP-Range nur den Tag holen (erst 10 Byte Header, dann genau die Tag-Länge, max. 4 MB) – nie die Audiodaten.
   Ignoriert der Server die Range, wird nach der Tag-Länge abgebrochen. Kaputte Tags → keine Kapitel, nie ein Fehler.
   (M4A/AAC-Kapitel werden nicht gelesen.)
- Geladen wird erst, wenn der Vollbild-Player die Folge zeigt (`chaptersProvider` → `ensureLoaded`), pro App-Sitzung
  höchstens ein Versuch pro Folge (auch ohne Ergebnis).
- Anzeige: unter dem Slider „Kapitel 3/7: Titel" (tippen → Liste); Knopf „Kapitel (n)" → Liste mit Startzeit,
  aktuelles Kapitel hervorgehoben, Tippen springt dorthin.
- Werkzeug: `dart run tool/smoke_chapters.dart <Feed-URL>` prüft ID3-Kapitel echter Folgen.

### Kapitel überspringen („Skip", Benutzerwunsch)
- In der Kapitel-Liste hat jedes Kapitel einen Umschalt-Chip **„Skip"**; übersprungene Kapitel sind durchgestrichen.
- Nur im Arbeitsspeicher (`lib/audio/chapter_skips.dart`, gehört dem `PodcastAudioHandler`), **nicht** in der DB,
  nicht im Backup; nach einem App-Neustart ist alles wieder normal. Höchstens 20 Folgen werden gemerkt (älteste fliegt).
- Die Logik steckt im Handler (nicht in der UI), damit sie auch bei ausgeschaltetem Bildschirm greift:
  Landet eine Positionsmeldung in einem übersprungenen Kapitel `[Start, nächster Start)`, springt der Player ans Ende;
  mehrere übersprungene Kapitel hintereinander in einem Sprung.
- Wird das **aktuelle** Kapitel auf Skip gesetzt, springt der Player sofort weiter.
- Ist das **letzte** Kapitel übersprungen, endet die Folge dort wie regulär: „gespielt", raus aus allen Playlists,
  nächste Playlist-Folge startet.
- Tippen auf ein übersprungenes Kapitel in der Liste hebt Skip auf und springt dorthin („doch hören").
- Auch −15 s aus dem Folgekapitel in ein übersprungenes Kapitel hinein wird wieder nach vorn gesprungen (gewollt).

## Lesezeichen (M6 ✅)
- Vollbild-Player → „Lesezeichen setzen": merkt die Position **beim Tippen** (Wiedergabe läuft weiter), optional Notiz.
- „Lesezeichen (n)" im Player: Liste der Folge, Tippen springt. Optionen → „Lesezeichen": alle, neueste zuerst;
  Tippen spielt die Folge **genau** ab dieser Stelle (`playEpisode(startAt:)`, auch wenn sie schon gespielt war).
- Langes Drücken bearbeitet die Notiz, Papierkorb löscht (Infobox).
- Lesezeichen bleiben erhalten, wenn die Audiodatei per Eviction gelöscht wurde (dann wird gestreamt); beim Abo-Kündigen
  werden sie mit den Folgen gelöscht.
