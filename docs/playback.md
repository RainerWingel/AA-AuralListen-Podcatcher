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

## Kapitel (M6)
- Quellen in dieser Reihenfolge: Podcasting 2.0 `<podcast:chapters>` (JSON-URL) → Podlove Simple Chapters
  `<psc:chapters>` im Feed → ID3-CHAP-Frames in heruntergeladenen MP3s (später).
- Anzeige im Vollbild-Player als Liste, Tippen springt zum Kapitel; aktuelles Kapitel hervorgehoben.

## Lesezeichen (M6)
- Knopf im Player speichert aktuelle Position, optional mit Notiz.
- Liste pro Folge und global; Tippen spielt Folge ab dieser Stelle.
- Lesezeichen bleiben erhalten, auch wenn die Audiodatei per Eviction gelöscht wurde (dann wird gestreamt).
