<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="128" alt="App-Symbol von AA-AuralListen Podcatcher">
</p>

# AA-AuralListen Podcatcher

Privater, werbefreier Podcatcher für Android – nur Audio, ohne Konto, ohne Tracking. Alle Daten bleiben auf dem
Gerät. Geschrieben in Flutter.

> **Sprachen:** Die App gibt es auf **Deutsch und Englisch**. Beim ersten Start fragt sie nach der Sprache; ändern
> lässt sie sich jederzeit unter Optionen → Sprache. Weitere Sprachen können folgen – alle Texte liegen zentral in
> Übersetzungsdateien (`lib/l10n/app_de.arb`, `lib/l10n/app_en.arb`).
>
> *The app is available in **German and English**. It asks for the language on first start; you can change it any
> time under Settings → Language.*

## Funktionen

**Podcasts finden und abonnieren**
- Suche über Apple Podcasts und fyyd.de, Abo per RSS-Adresse, OPML-Import und -Export (z. B. aus anderen Apps)
- Aktualisierung beim Start und per Herunterziehen; Umzüge von Podcasts (neue Feed-Adresse) werden übernommen
- Rote Zahl mit ungespielten Folgen an jedem Abo; Punkt bei frischen Folgen (letzte 96 Stunden)
- Podcast-Seite mit Beschreibung, Links zur Website und zum Unterstützen (falls im Feed), Suche in den Abos
- Folgennummer am Cover (aus dem Feed oder eigene Zählung mit Versatz)
- Staffeln: „S2·5" am Cover, Filter nach Staffel; Serien-Podcasts (Hörspiele, Doku-Reihen) in Hörreihenfolge

**Hören**
- Wiedergabe im Hintergrund mit Benachrichtigung, Sperrbildschirm- und Bluetooth-Tasten
- Sprünge −15 s / +30 s, Abspielgeschwindigkeit 1,0× / 1,2× / 1,5× / 2,0×, Lautstärke-Boost (global oder pro Podcast)
- Restzeit (bei höherem Tempo zusätzlich die tatsächliche Restzeit) oder Gesamtlänge – per Antippen umschaltbar
- Shownotes mit antippbaren Links, Folgennummer und Erscheinungsdatum
- Kapitel (Podlove, JSON, ID3) mit „Skip" je Kapitel, Lesezeichen mit Notiz
- Sleep-Timer: 5 / 15 / 30 / 60 Minuten, eigene Zeit oder bis Ende der Folge – mit sanftem Ausblenden
- Hörposition wird gemerkt; erst bis zum Ende gehört gilt eine Folge als gespielt
- Abspielverlauf der letzten 100 zu Ende gehörten Folgen (bleibt auch nach dem Kündigen eines Abos)
- Robust bei Netzproblemen: Hänger-Erkennung, Fortsetzen an der richtigen Stelle (auch bei MP3s mit wechselnder
  Bitrate), Hinweis bei Podcasts mit wechselnder Werbung, klare Meldungen

**Playlists**
- Mehrere Playlists mit automatischem Weiterspielen; eine zu Ende gehörte Folge verlässt die Playlist, aus der sie
  lief (manuell als gespielt markiert: alle Playlists)
- Folge woanders gestartet: ihre Playlist wird nur angeboten und erst nach Antippen fortgesetzt
- „Als Nächstes spielen" und „Ans Ende der Playlist anfügen" für die laufende Playlist
- „Fortsetzen" mit der zuletzt gespielten Folge jeder Playlist, Sortieren nach Datum oder Namen, „Alles downloaden"
- Aus dem Abo-Menü: alle neuen, alle ungespielten oder alle ungespielten seit einem Datum in eine Playlist; über die
  Podcast-Seite gleich abspielen
- Symbol an jeder Folge, die in einer Playlist steht

**Downloads und Speicher**
- Downloads manuell oder automatisch pro Podcast (auch nur bestimmte Themen, z. B. bei Netzwerk-Feeds wie WRINT)
- Automatisches Löschen gespielter Folgen nach 96 Stunden (nicht, solange sie noch in einer Playlist stehen),
  einstellbares Speicherlimit

**Sonstiges**
- „Als gespielt markieren bis …" / „Als ungespielt markieren seit …"
- Backup und Wiederherstellung (ZIP), Dark Mode, wählbare App-Farbe, Deutsch oder Englisch

## Installation

Die App ist (noch) nicht im Play Store. Die signierte APK gibt es unter
[Releases](https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases):

1. Beim neuesten Release die Datei `…-arm64-v8a.apk` herunterladen (64-Bit-ARM, praktisch alle aktuellen
   Android-Handys).
2. Öffnen und installieren – Android fragt einmalig nach der Erlaubnis, Apps aus dieser Quelle zu installieren.
3. Empfehlung: In den App-Einstellungen unter **Akku → „Nicht eingeschränkt"** wählen (in der App: Optionen →
   Hören → „Hintergrund-Wiedergabe"), damit Android lange Wiedergaben mit ausgeschaltetem Bildschirm nicht beendet.

## Unterstützen

Wenn dir der AA-AuralListen Podcatcher gefällt und du die Entwicklung freiwillig unterstützen möchtest, kannst du mir
ein Trinkgeld über PayPal senden: **[paypal.me/Yama83](https://paypal.me/Yama83)**

## Datenschutz

Keine Konten, keine Werbung, kein Tracking, kein eigener Server. Details:
[Datenschutzerklärung](https://rainerwingel.github.io/AA-AuralListen-Podcatcher/datenschutz/).

## Selbst bauen

Voraussetzungen: Flutter 3.47.5 (Dart 3.13), Android SDK, Java 21.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

Die Release-Signatur kommt aus `android/key.properties` (nicht im Repo). Fehlt die Datei, bleibt die Release-APK
**unsigniert** – so erwartet es F-Droid, das aus dem Quellcode baut und selbst signiert. Zum Installieren einer eigenen
Version ohne Schlüssel `flutter build apk --debug` verwenden.

## Lizenz

AA-AuralListen Podcatcher ist freie Software: **GNU General Public License v3.0** (siehe [LICENSE](LICENSE)).
Du darfst die App verwenden, untersuchen, verändern und weitergeben – veränderte Versionen müssen ebenfalls unter der
GPL-3.0 mit Quellcode weitergegeben werden. Die Titelschrift Fredoka steht unter der SIL Open Font License 1.1
(`assets/fonts/OFL-Fredoka.txt`).

## Projekt

- Plan und Fortschritt: [docs/roadmap.md](docs/roadmap.md)
- Funktionsumfang: [docs/features.md](docs/features.md)
- Architektur: [docs/architecture.md](docs/architecture.md)
- Hinweise für KI-Agenten (Claude, ChatGPT/Codex), die am Code arbeiten: [AGENTS.md](AGENTS.md)
