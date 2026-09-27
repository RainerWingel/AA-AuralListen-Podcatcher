# Wiedergabe

## Player
- `just_audio` für die Wiedergabe, `audio_service` für Hintergrund, Medien-Benachrichtigung, Sperrbildschirm,
  Bluetooth-/Kopfhörer-Tasten. Eine einzige `AudioHandler`-Instanz, gestartet in `main()`.
- Android: Foreground-Service-Typ `mediaPlayback` im Manifest (Pflicht ab Android 14).
- Quelle: lokale Datei, falls heruntergeladen, sonst Streaming der `audioUrl`.
- Audio-Fokus: bei Anruf/anderer App pausieren, danach **nicht** automatisch laut weiterspielen.
- Kopfhörer abgezogen → Pause.
- Keine Geschwindigkeitsregelung, kein Sleep-Timer, kein Stille-Kürzen (bewusst weggelassen).

## Sprünge
−15 s / +30 s, in Benachrichtigung und Player.

## Hörposition
- Wird gedrosselt gespeichert (alle 5 s, bei Pause, Stopp, Folgenwechsel, App-Hintergrund).
- Beim Fortsetzen 3 s zurückspringen (Kontext).
- ≥ 98 % → Status `gespielt` (siehe `data-model.md`, `playlists.md`).
- Letzte aktive Folge + Playlist werden in `player_state` gemerkt und nach App-Neustart im Mini-Player angezeigt.

## Lautstärke-Boost
- Android `LoudnessEnhancer` über `just_audio` (`AndroidLoudnessEnhancer`), Zielverstärkung in dB.
- Stufen z. B. 0 / +3 / +6 / +9 / +12 dB. Globaler Standard + optional pro Podcast.
- iOS: nicht verfügbar (Regler ausblenden).

## Kapitel (M6)
- Quellen in dieser Reihenfolge: Podcasting 2.0 `<podcast:chapters>` (JSON-URL) → Podlove Simple Chapters
  `<psc:chapters>` im Feed → ID3-CHAP-Frames in heruntergeladenen MP3s (später).
- Anzeige im Vollbild-Player als Liste, Tippen springt zum Kapitel; aktuelles Kapitel hervorgehoben.

## Lesezeichen (M6)
- Knopf im Player speichert aktuelle Position, optional mit Notiz.
- Liste pro Folge und global; Tippen spielt Folge ab dieser Stelle.
- Lesezeichen bleiben erhalten, auch wenn die Audiodatei per Eviction gelöscht wurde (dann wird gestreamt).
