# Funktionsumfang

Privater, werbefreier Podcatcher, **nur Audio**, im Stil von Castbox. Zielgerät: Samsung Galaxy S25 (Android),
Sideload per APK. Nur Deutsch. Alle Daten nur lokal.

## Muss (MVP, bis M5)
| # | Funktion | Details / Verweis |
|---|----------|-------------------|
| F1 | Podcast suchen | iTunes, fyyd, Podcast Index → `feeds-and-directories.md` |
| F2 | Abo per RSS-URL | Eingabe + Validierung |
| F3 | OPML-Import | Castbox-Export übernehmen |
| F4 | Feed-Aktualisierung | beim App-Start + Pull-to-Refresh, **keine** Hintergrund-Aktualisierung |
| F5 | Folgenliste | pro Podcast und „Neu" über alle Abos |
| F6 | Wiedergabe | Streaming oder lokal, Hintergrund, Benachrichtigung, Sperrbildschirm, Bluetooth → `playback.md` |
| F7 | Sprünge | −15 s / +30 s |
| F8 | Lautstärke-Boost | → `playback.md` |
| F9 | Hörposition merken | → `playback.md` |
| F10 | Downloads | manuell + Auto-Download pro Podcast → `eviction.md` |
| F11 | Eviction | automatisches Löschen, keine Lecks → `eviction.md` |
| F12 | Playlists | mehrere, manuell, Weiterspielen → `playlists.md` |

## Zusatz (nach M5, Wunsch des Benutzers)
| # | Funktion | Details |
|---|----------|---------|
| F19 | Als gehört markieren bis Datum | pro Abo, Kalender + Rückfrage → `data-model.md` |
| F20 | Podcast-Umzug | 301/308, `itunes:new-feed-url`, manuell „Feed-Adresse ändern" → `feeds-and-directories.md` |
| F18 | Auto-Download nach Thema | Netzwerk-Feeds wie WRINT: nur angehakte Themen laden → `feeds-and-directories.md` |

## Soll (M6–M7)
| # | Funktion | Details |
|---|----------|---------|
| F13 | Kapitel | → `playback.md` |
| F14 | Lesezeichen | → `playback.md` |
| F15 | OPML-Export | |
| F16 | Backup / Restore | ZIP mit DB + Einstellungen, ohne Audiodateien |
| F17 | Dark Mode | |

## Bewusst NICHT
Geschwindigkeit, Sleep-Timer, Stille kürzen, CarPlay/Android Auto, Video, Sync/Cloud, Hintergrund-Feed-Update,
Transkripte, KI-Funktionen, Statistiken, andere Sprachen als Deutsch, SD-Karte (Gerät hat keinen Slot).
