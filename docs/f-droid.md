# F-Droid

F-Droid baut die App **selbst aus dem Quellcode** (Git-Tag) und signiert sie mit eigenem Schlüssel. Die Store-Texte
kommen aus diesem Repo. Stand 2026-10-01: vorbereitet, noch nicht eingereicht.

## Was im Repo dafür vorbereitet ist
| Was | Wo |
|-----|----|
| Lizenz GPL-3.0 (offizieller Text) | `LICENSE`, README „Lizenz" |
| Build-Rezept für F-Droid (Entwurf, wird in *fdroiddata* eingereicht) | `fdroid/io.github.rainerwingel.aurallisten.yml` |
| Store-Texte, Icon, Changelog – de-DE und en-US | `fastlane/metadata/android/<Sprache>/` |
| Screenshots (macht der Benutzer selbst) | `fastlane/metadata/android/<Sprache>/images/phoneScreenshots/` |
| SQLite aus Quellcode statt heruntergeladener Binärdatei | `third_party/sqlite/`, `hooks:` in `pubspec.yaml` |
| Ohne `key.properties` bleibt die Release-APK unsigniert | `android/app/build.gradle.kts` |

Geprüft: keine Google-Play-Dienste/Firebase/Tracker (voller Gradle-Abhängigkeitsbaum: nur Material + Guava, beide
Apache-2.0), keine Binärdateien im Repo, Build ohne Schlüssel ergibt eine unsignierte APK, SQLite im APK ist die Version
aus `third_party/sqlite` (3.53.4).

## Regeln für Agenten
- **Keine Pakete mit Google-Play-Diensten, Firebase, Crashlytics, Analytics** – sonst lehnt F-Droid die App ab.
- Keine Build-Schritte, die Binärdateien herunterladen (Beispiel: `sqlite3` lädt sonst vorkompilierte Bibliotheken).
- Neue Version = `version:` in `pubspec.yaml` erhöhen (Build-Nummer!), Git-Tag `vX.Y.Z` auf GitHub. F-Droid erkennt
  Tags automatisch (`UpdateCheckMode: Tags`). Changelog je Sprache als `changelogs/<versionCode>.txt` für alle drei
  Codes (1000/2000/4000 + Build-Nummer, max. 500 Zeichen).
- `short_description.txt` max. 80 Zeichen, `full_description.txt` max. 4000 (einfaches HTML erlaubt).
- Flutter-Version im Rezept (`flutter@…`) = Version in `.github/workflows/ci.yml`.

## Schritte für den Benutzer
1. **Screenshots** machen (siehe unten) und in die beiden `phoneScreenshots`-Ordner legen.
2. **Release v1.3.0** freigeben – Claude erhöht nichts mehr, setzt nur den Tag und baut den GitHub-Release.
   Erst danach kann F-Droid bauen (das Rezept zeigt auf `commit: v1.3.0`).
3. **Konto auf gitlab.com** anlegen (Pseudonym möglich – der Name ist öffentlich). Claude legt keine Konten an.
4. Auf gitlab.com das Projekt **fdroid/fdroiddata forken** („Fork"-Knopf).
5. Im eigenen Fork eine Datei `metadata/io.github.rainerwingel.aurallisten.yml` anlegen (Weboberfläche: „+" → „New
   file") und den Inhalt aus `fdroid/io.github.rainerwingel.aurallisten.yml` dieses Repos einfügen.
6. **Merge Request** an fdroid/fdroiddata stellen, Titel z. B. „New app: AA-AuralListen Podcatcher". Die Vorlage fragt
   Punkte ab (Lizenz, keine proprietären Teile, Tracker …) – alles erfüllt. F-Droid-CI baut die App testweise.
7. Rückfragen der Prüfer beantworten (Claude hilft). Nach dem Merge erscheint die App meist nach wenigen Tagen.

## Screenshots
- Format PNG oder JPG, Hochformat, Dateinamen sortieren die Reihenfolge (`1.png`, `2.png` …), 2–8 Stück je Sprache.
- Vorschlag: Start (mit Hintergrund), Abos, Podcast-Seite, Player, Playlists (mit Farben), Downloads, Optionen.
- Auf dem Handy: App-Sprache umstellen (Optionen → Sprache) für die englischen Bilder; Seitentaste + Leiser.
- Achtung, öffentlich: nichts Privates im Bild (Benachrichtigungen, Namen in Playlists …).

## Bekannte Punkte für die Prüfung
- **NonFreeNet** (Anti-Feature, Hinweis – keine Ablehnung): Die Suche nutzt Apples iTunes Search API. Möglich, dass
  F-Droid das markiert; fyyd.de und RSS-Adressen funktionieren ohne Apple.
- Unterschiedliche Signatur: Wer die GitHub-APK hat, kann nicht auf die F-Droid-Version aktualisieren (vorher Backup,
  deinstallieren, F-Droid-Version installieren, Backup einspielen).
