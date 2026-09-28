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
- Keine Geschwindigkeitsregelung, kein Stille-Kürzen (bewusst weggelassen). Sleep-Timer: seit 2026-09-28 (siehe unten).

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

### Sleep-Timer (Benutzerwunsch 2026-09-28)
Code: `lib/audio/sleep_timer.dart` (Einstellung), `PodcastAudioHandler` (Abschnitt „sleep timer"),
Knopf `SleepTimerButton` rechts neben „Lesezeichen setzen" im Vollbild-Player.
- Auswahl: Aus · 5 · 15 · 30 · 60 Minuten · **Eigene Zeit…** (Zahlenfeld, ganze Minuten 1–3600, „Starten" nur bei
  gültigem Wert; gesetzt steht dort „Eigene Zeit: n Minuten") · Bis Ende der Folge. Nur im Arbeitsspeicher.
- Auch der schon gewählte Eintrag reagiert auf Tippen (`toggleable`): „Eigene Zeit" lässt sich so ändern, eine feste
  Zeit startet neu.
- **Minuten = Spielzeit:** Eine `Stopwatch` läuft nur während der Wiedergabe; in der Pause steht der Countdown.
  Dazu genau ein `Timer` bis zum Ablauf, nur während der Wiedergabe (kein Sekunden-Takt; die Anzeige „noch mm:ss"
  rechnet beim Neuzeichnen, das der Positions-Stream ohnehin auslöst).
- **Ausblenden** (Benutzerwunsch, zuerst 10 s, dann 30 s): die letzten 30 s (`sleepFadeDuration`) senkt ein zweiter
  Timer die Lautstärke in 100 Schritten (alle 0,3 s) auf 0 (`PlayerEngine.setVolume`, unabhängig vom Boost).
  **Kurve kubisch** (`sleepFadeVolume`: Anteil³ ≈ gleiche dB-Schritte: nach der Hälfte −18 dB, bei einem Viertel Restzeit −36 dB). Linear klang
  es wegen des logarithmischen Gehörs, als würde nur in den letzten ~5 s ausgeblendet (Benutzer-Rückmeldung).
  Dieser Timer entsteht erst 30 s vor Ablauf und nur während der Wiedergabe.
- Die Kurve erreicht **1 s vor Ablauf** 0 % (1/30 der Ausblendzeit) – die letzte Sekunde läuft stumm. Dann `pause()`.
  **Die Lautstärke bleibt danach unten** und kommt erst **unmittelbar vor dem nächsten Play** zurück (`_volumeBeforePlay`):
  Android spielt nach „Pause" noch den Audiopuffer aus, ein Hochsetzen direkt danach war als kurzes lautes Aufblitzen
  hörbar (Benutzer-Rückmeldung). Pausieren während des Ausblendens lässt die Lautstärke ebenfalls unten; Play setzt
  direkt auf den passenden Ausblend-Wert und blendet weiter aus. „Aus" während der Wiedergabe → sofort 100 %.
  Der 10-Minuten-Pause-Stopp gilt wie sonst; der Timer steht nach Ablauf auf „Aus"
- **Bis Ende der Folge:** Die Folge endet regulär (gespielt, raus aus Playlists), aber die nächste Playlist-Folge startet
  **nicht**; danach „Aus". Gilt auch, wenn das Ende durch ein übersprungenes letztes Kapitel kommt.
- Folgenwechsel lässt den Timer weiterlaufen. „Aus" bricht ihn ab.

### Hänger-Erkennung (Benutzerwunsch, sparsam)
Code: `PodcastAudioHandler` (Abschnitt „hang detection"), Infobox in `AppShell`.
- **Nur während der Wiedergabe** läuft ein Timer (alle 10 s, `stallCheckInterval`); bei Pause/Stopp gibt es keinen.
  Kosten: ein Vergleich alle 10 s – der Player meldet die Position ohnehin mehrmals pro Sekunde.
- **Hänger** = spielt laut Player, aber die Position steht 3 Prüfungen (≈ 30 s) still (Puffern ohne Ende, Player nach
  Netzfehler stehen geblieben).
- **Korrektur:** Position speichern, Folge an **genau** dieser Stelle neu laden und weiterspielen. Scheitert das Laden
  (kein Netz), neuer Versuch nach 15 s. Höchstens 3 Versuche (`maxRecoveries`), dann sauber anhalten
  (Position bleibt) und Infobox „Die Wiedergabe hing und wurde angehalten …".
- Bewegt sich die Position wieder, beginnt die Zählung neu. Pause, Stopp oder eine andere Folge beenden laufende Versuche.
- **Laden scheitert beim Antippen** (kein Netz, Serverfehler): kein Absturz/keine stille Nicht-Reaktion mehr, sondern
  Infobox „Die Folge konnte nicht geladen werden …" (`PlaybackProblem.loadFailed`).
- **Player-Fehler** (ExoPlayer „Playback error", z. B. kein Netz nach einem Sprung): just_audio schaltet dann seinen
  nativen Player ab und pausiert. Früher hielt die App die Folge weiter für geladen; ein späteres Play weckte den halb
  toten Player – Ton lief, Zeitanzeige blieb stehen (Bug 2026-09-28). Jetzt (`_onEngineError`): Position sichern,
  Player freigeben, **frisch** laden – sofort mit den Wiederholungen oben, wenn gespielt wurde, sonst beim nächsten Play.
- **Die eigentliche Ursache der eingefrorenen Zeitanzeige** war der Schieberegler: Er hielt den Finger-Wert fest, bis der
  Sprung bestätigt war – offline bestätigt just_audio ihn nie. Jetzt wird der Finger-Wert beim Loslassen sofort
  freigegeben; `seek` fängt Player-Fehler ab. (Gefunden mit einer Diagnose-Version auf dem S25: Player und Handler
  meldeten laufende Positionen, nur die Anzeige stand.)
- **Fehlerarten** (`_handleFailure`/`_classify`, Benutzerwunsch 2026-09-28). just_audio meldet nur ExoPlayers Typ
  (0 Quelle, 1 Decoder), keinen HTTP-Code – die App ordnet selbst ein:
  - **Lokale Datei** scheitert → **kaputter Download**: Download löschen (`DownloadService.delete`), sofort streamen,
    Infobox „Der Download war beschädigt …". Kein Netz-Check nötig.
  - Decoder-Fehler → **Format nicht abspielbar**, keine Wiederholung.
  - Sonst fragt `checkStream` (`lib/audio/stream_check.dart`) den Server – **nur im Fehlerfall**, nur 1 Byte (`Range`):
    404/410/403 → **„beim Anbieter nicht mehr verfügbar"**, keine Wiederholung · kein Netz/5xx/408/429 → Netzwerk:
    Wiederholungen wie oben · Server antwortet normal → mitten in der Wiedergabe ein Aussetzer (wiederholen); beim
    Laden noch ein Versuch, scheitert der auch → **Format nicht abspielbar** (z. B. Server liefert Text statt Audio –
    ExoPlayer meldet das als Quellen-, nicht als Decoder-Fehler).
  - Antippen ohne Netz → Infobox „nicht geladen werden …", keine automatischen Wiederholungen.
  - Geprüft im Emulator mit einem lokalen Test-Feed (404-Folge, Text-statt-Audio-Folge).
- Infoboxen: Jede Meldung ist ein eigenes Objekt (`PlaybackProblemNotice`), sonst zeigte ein Provider die gleiche
  Meldung beim zweiten Mal nicht mehr an.
- **Position bei Fehlern = letzte gemeldete Position** (`_knownPosition` aus dem Positions-Strom), nicht
  just_audios `position`: Nach einem Fehler rechnet just_audio vom letzten *Zustandswechsel* – im Hintergrund kann das
  Minuten oder den ganzen Folgenanfang zurückliegen (Bug 2026-09-28: Neustart von vorn). Nachgestellt im Emulator mit
  `cmd connectivity airplane-mode enable` (hartes Trennen; `svc wifi disable` lässt offene Streams weiterlaufen).
- Nie zwei Ladevorgänge gleichzeitig: Play während eines laufenden Neu-Ladens wartet auf dasselbe Laden (`_loadInFlight`).
- **Kein just_audio-Proxy** (`useProxyForRequestHeaders: false`): Der User-Agent geht direkt über ExoPlayer. Mit Proxy lief
  jeder Stream über einen HTTP-Server in der App (Mehraufwand, unbehandelte Fehler offline, Timeouts gegen den Proxy).
- Nachgestellt im Emulator (`Medium_Phone_API_36.0`, `svc wifi/data disable`, Sprünge per
  `cmd media_session dispatch fast-forward`): kurzer Ausfall → spielt von selbst weiter; langer Ausfall → Infobox,
  Position bleibt, Play nach Netzrückkehr läuft mit laufender Anzeige.
- Gegen das Beenden des ganzen Prozesses durch Android hilft kein Wächter (er stürbe mit) – dafür „Nicht eingeschränkt" unten.

### Akku-Optimierung („Nicht eingeschränkt")
Im Dauertest (2026-09-27) hat Samsung die App bei „Optimiert" nach ~40 min Wiedergabe mit ausgeschaltetem Bildschirm
beendet (Signal 9, trotz Vordergrund-Dienst). Mit „Nicht eingeschränkt" darf das nicht passieren.
- Apps dürfen das **nicht selbst umschalten**; erlaubt ist nur der System-Dialog
  (`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, Recht `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) – ein Tipp auf
  „Zulassen" setzt „Nicht eingeschränkt". Samsungs Listen („Nie in Standby" usw.) kann keine App ändern oder anfragen;
  bei „Nicht eingeschränkt" sind sie auch nicht nötig.
- Brücke: `MainActivity.kt` (MethodChannel `aapodcastguru/battery`: `isExempt`, `requestExemption`, `openAppSettings`),
  Dart-Seite `lib/audio/battery_optimization.dart` (Interface, im Test ein Fake). Kein zusätzliches Paket.
- **Automatisch, genau einmal:** beim ersten Wiedergabestart (`AppShell` hört auf `playbackState`), nur wenn die App
  noch optimiert ist. Merker `player.batteryExemptionAsked`; wer ablehnt, wird nicht erneut automatisch gefragt.
- **Optionen → Hören → „Hintergrund-Wiedergabe"** zeigt den Status (wird beim Zurückkehren in die App neu geprüft).
  Optimiert → Tippen öffnet den System-Dialog; nicht eingeschränkt → Tippen öffnet die App-Einstellungen.
- Samsung zeigt Apps in „Grenzen der Hintergrundnutzung" nur, wenn sie kürzlich liefen – dass die App dort zeitweise
  fehlt, ist normal.

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
