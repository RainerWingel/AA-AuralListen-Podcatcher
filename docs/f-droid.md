# F-Droid

F-Droid baut die App **selbst aus dem Quellcode** (Git-Tag) und signiert sie mit eigenem Schlüssel. Die Store-Texte
kommen aus diesem Repo. Stand 2026-10-05: eingereicht (MR !51179); Prüfer verlangt ABI-Split-Versionsschema → v1.3.2.

## Was im Repo dafür vorbereitet ist
| Was | Wo |
|-----|----|
| Lizenz GPL-3.0 (offizieller Text) | `LICENSE`, README „Lizenz" |
| Build-Rezept für F-Droid (Entwurf, wird in *fdroiddata* eingereicht) | `fdroid/io.github.rainerwingel.aurallisten.yml` |
| Store-Texte, Icon, Changelog – de-DE und en-US | `fastlane/metadata/android/<Sprache>/` |
| Screenshots (macht der Benutzer selbst) | `fastlane/metadata/android/<Sprache>/images/phoneScreenshots/` |
| SQLite aus Quellcode statt heruntergeladener Binärdatei | `third_party/sqlite/`, `hooks:` in `pubspec.yaml` |
| Ohne `key.properties` bleibt die Release-APK unsigniert | `android/app/build.gradle.kts` |
| Versionsschema Build-Nummer × 10 + ABI (F-Droid-Vorgabe) | `android/app/build.gradle.kts` (`abiCodes`) |

Geprüft: keine Google-Play-Dienste/Firebase/Tracker (voller Gradle-Abhängigkeitsbaum: nur Material + Guava, beide
Apache-2.0), keine Binärdateien im Repo, Build ohne Schlüssel ergibt eine unsignierte APK, SQLite im APK ist die Version
aus `third_party/sqlite` (3.53.4).

## Regeln für Agenten
- **Keine Pakete mit Google-Play-Diensten, Firebase, Crashlytics, Analytics** – sonst lehnt F-Droid die App ab.
- Keine Build-Schritte, die Binärdateien herunterladen (Beispiel: `sqlite3` lädt sonst vorkompilierte Bibliotheken).
- Neue Version = `version:` in `pubspec.yaml` erhöhen (Build-Nummer!), Git-Tag `vX.Y.Z` auf GitHub. F-Droid erkennt
  Tags automatisch (`UpdateCheckMode: Tags`). Changelog je Sprache als `changelogs/<versionCode>.txt` für alle drei
  Codes (max. 500 Zeichen).
- **Versionsschema (seit 1.3.2, Vorgabe der F-Droid-Prüfer):** `versionCode` = Build-Nummer × 10 + ABI
  (armeabi-v7a 1, arm64-v8a 2, x86_64 3), gesetzt in `android/app/build.gradle.kts`; im Rezept
  `VercodeOperation: '%c * 10 + 1/2/3'`. Bis 1.3.1 galt Flutters Schema 1000/2000/4000 + Build-Nummer (1006/2006/4006).
  Damit die neuen Codes darüber liegen (sonst kein Update über GitHub-APKs), sprang die Build-Nummer von 6 auf **500**
  (Codes 5001/5002/5003). Build-Nummer ab jetzt nur noch erhöhen.
- `short_description.txt` max. 80 Zeichen, `full_description.txt` max. 4000 (einfaches HTML erlaubt).
- Flutter-Version: Das Rezept (srclib `flutter@stable`) liest sie beim Bauen aus `flutter-version: '…'` in
  `.github/workflows/ci.yml` – diese Zeile im Format nicht ändern. `pubspec.lock` muss eingecheckt und aktuell sein
  (`pub get --enforce-lockfile`).

## Schritte für den Benutzer
Stand 2026-10-04: **v1.3.1 veröffentlicht** (+6, Codes 1006/2006/4006; Tag auf
`7906fd482c82f34068059258548309675b580b95`), Rezept, Changelogs, Store-Texte und Screenshots fertig. 1.3.0 wurde nie
eingereicht – eingereicht wird direkt 1.3.1.
**Eingereicht 2026-10-04:** Merge Request https://gitlab.com/fdroid/fdroiddata/-/merge_requests/51179 – F-Droid-Pipeline
grün. Im MR erklärt bzw. nicht angehakt: Flutter als srclib, keine Reproducible Builds (F-Droid signiert selbst).
**2026-10-05, Rückmeldung der Prüfer:** erst Frage nach Alleinstellungsmerkmalen (beantwortet: Kapitel-Skip, Hinweis
bei wechselnder Werbung, VBR-Fix, Playlist-Verhalten, Themen-Filter, Android Auto geplant), dann Auftrag: Rezept nach
`templates/build-flutter.yml` und ABI-Split-Versionsschema (s. o.) → v1.3.2 mit `flutter pub get --enforce-lockfile`.
**v1.3.2 veröffentlicht 2026-10-05** (Tag auf `05f780f6d6d52982d402a35a08c75d536afe18b1`).
Rezept im Fork ersetzt (2026-10-05, Inhalt mit dieser Datei identisch geprüft), neue MR-Pipeline #2914723501 grün (alle drei ABIs gebaut, 24 min).
**v1.3.3 veröffentlicht 2026-10-07** (Tag auf `72294e4bf67caed7f43ac633f31b3c4c5ff7a9b4`) – der MR bleibt bewusst auf
v1.3.2; nach dem Merge findet der Bot v1.3.3 selbst (`UpdateCheckMode: Tags`). Rezept im MR nicht anfassen.
**Offen: Prüfung durch F-Droid (Schritt 7).**
1. **Screenshots** machen (siehe unten), in die beiden `phoneScreenshots`-Ordner legen (alte `3.jpg`/`4.jpg` sind
   gelöscht) – Claude committet und pusht sie auf Ansage. **Vor dem Tag**: F-Droid liest Texte und Bilder aus dem
   getaggten Stand.
2. **Release v1.3.1 freigeben** – Claude setzt den Tag `v1.3.1`, baut den GitHub-Release (`build-and-release.md`) und
   trägt danach im Rezept statt `commit: v1.3.1` den **vollen Commit-Hash** des Tags ein (fdroiddata-Checkliste).
3. **Konto auf gitlab.com** anlegen (Pseudonym möglich – der Name ist öffentlich). Claude legt keine Konten an.
4. Auf gitlab.com das Projekt **fdroid/fdroiddata forken** („Fork"-Knopf).
5. Im eigenen Fork eine Datei `metadata/io.github.rainerwingel.aurallisten.yml` anlegen (Weboberfläche: „+" → „New
   file") und den Inhalt aus `fdroid/io.github.rainerwingel.aurallisten.yml` dieses Repos einfügen.
6. **Merge Request** an fdroid/fdroiddata stellen, Titel z. B. „New app: AA-AuralListen Podcatcher". Die Vorlage fragt
   Punkte ab (Lizenz, keine proprietären Teile, Tracker …) – alles erfüllt. F-Droid-CI baut die App testweise.
7. Rückfragen der Prüfer beantworten (Claude hilft). Nach dem Merge erscheint die App meist nach wenigen Tagen.
   Spätere Versionen erkennt F-Droid selbst am Tag (`UpdateCheckMode: Tags`) – dann nur noch Version erhöhen,
   Changelogs schreiben, taggen.

## Ablauf der Prüfung (Erfahrungen MR !51179)
- **Codequalitäts-Scan** im MR („32 neue Funde"): listet nur die Berechtigungen je Build-Block (3 ABIs × Berechtigungen),
  INTERNET als „Minor", der Rest „Info". Harmlos, kein Handlungsbedarf. Herkunft: eigenes Manifest (INTERNET, WAKE_LOCK,
  FOREGROUND_SERVICE[_MEDIA_PLAYBACK]); ACCESS_NETWORK_STATE und RECEIVE_BOOT_COMPLETED kommen von WorkManager
  (über `background_downloader`). Neue Berechtigungen → auch `datenschutz.md`/`privacy.md` („Berechtigungen").
- **„Gibt es schon viele ähnliche Apps"** ist die Standardfrage bei neuen Podcatchern, keine Ablehnung. Antwort kurz und
  persönlich (nicht KI-artig) mit Alleinstellungsmerkmalen: Kapitel einzeln überspringen, Hinweis bei wechselnder Werbung,
  VBR-MP3-Fix, Playlist-Verhalten, Themen-Filter beim Auto-Download, geplant Android Auto.
- **Rezept muss `templates/build-flutter.yml` folgen** (fdroiddata) und das ABI-Versionsschema nutzen (oben).
- **Kategorie** aus `config/categories.yml` (fdroiddata) wählen – passend ist **`Podcast`** (nicht `Multimedia`,
  Prüfer 2026-10-06).
- **Netzdienste** (Prüferfrage 2026-10-06): Feeds/Cover/Audio direkt von den Podcast-Servern, Suche über Apple iTunes
  Search API und fyyd.de, kein eigener Server, kein Konto. Wegen Apple steht im Rezept das Anti-Feature
  **`NonFreeNet`** (RSS-Adresse und OPML gehen ohne).
- **Format exakt wie `fdroid rewritemeta`**, sonst wird der Pipeline-Job „fdroid rewritemeta" rot (2026-10-06: nur
  ein anderer Zeilenumbruch im Anti-Feature-Text). Lange Texte bricht rewritemeta nach etwa 80 Zeichen um; im Zweifel
  den Diff aus dem Job-Log übernehmen.
- Änderungen am Rezept: Benutzer ersetzt die Datei im Fork `ArtemArb/fdroiddata` (Branch `master`) über die
  Weboberfläche; der MR aktualisiert sich selbst, die Pipeline läuft neu. Nachrichten im MR schreibt nur der Benutzer.

## Reproduzierbare Builds (in Arbeit, Prüferwunsch 2026-10-07)
Ziel: F-Droid veröffentlicht **unsere** signierten APKs (`binary:` je Build + `AllowedAPKSigningKeys`), nachdem es
selbst gebaut und verglichen hat. Dafür müssen unsere Release-APKs bitgleich mit F-Droids Build sein.
- Mac-Builds sind es **nicht** (v1.3.2: 6–8 von 359 Dateien anders – u. a. `libdartjni.so` vom macOS-Compiler,
  `libapp.so`/`classes.dex` durch andere Pfade/Toolchain; außerdem baut F-Droid jede ABI einzeln mit
  `--target-platform`, was die eingebettete Native-Assets-Liste ändert).
- **`tool/fdroid_release_build.sh <out> [--sign] [versionCode …]`** baut im F-Droid-Image
  `fdroidserver:buildserver-trixie` (OrbStack/Docker, linux/amd64) genau wie der CI-Job „fdroid build"
  (`fetchsrclibs` + `build --on-server`, Pfade `/home/vagrant/build/…`), aus `fdroid/<appid>.yml`. Test 2026-10-07:
  v1.3.2 arm64 **SHA-256-gleich** mit F-Droids CI-Build (~13 min unter Emulation).
- Signieren mit `apksigner sign --alignment-preserved` (ohne die Option richtet apksigner neu aus → F-Droids
  `apksigcopier compare` schlägt fehl); das Skript prüft danach selbst mit `apksigcopier compare`.

## Fragen & Antworten für den Benutzer

### Muss ich warten, bis die App bei F-Droid gelistet ist, bevor ich neue Versionen veröffentliche?
Nein. GitHub-Releases gehen jederzeit. Der Merge Request ist auf v1.3.2 festgelegt und wird nur damit geprüft – eine
neuere Version während der Prüfung braucht **keine** Änderung am MR. Nach dem Merge findet F-Droid die neueste
Version selbst (nächste Frage).

### Wird automatisch bei F-Droid veröffentlicht, wenn ich ein GitHub-Release erzeuge? Und beim bloßen Pushen?
- **Release (genauer: der Git-Tag `vX.Y.Z`) → ja**, sobald die App aufgenommen ist. Ein F-Droid-Bot schaut etwa täglich
  nach neuen Tags (`UpdateCheckMode: Tags ^v[0-9.]+$`), liest die Version aus `pubspec.yaml` am Tag und trägt den neuen
  Build selbst in fdroiddata ein (`AutoUpdateMode: Version`). Danach baut und signiert der Buildserver. Bis die Version
  bei den Nutzern ist: meist einige Tage bis etwa eine Woche.
- **Nur pushen → nein.** Ohne neuen Tag passiert bei F-Droid nichts; Pushen ist also gefahrlos.
- Vor jedem Tag muss stimmen (erledigt Claude beim „Release freigeben"): Versionsname **und** Build-Nummer in
  `pubspec.yaml` erhöht (Build-Nummer nur nach oben), Changelogs für alle drei Codes im Repo, `flutter-version:` in
  `ci.yml` im gewohnten Format, `pubspec.lock` aktuell.

### Wo trage ich den Changelog ein – und auf Deutsch oder Englisch?
- **Beide Sprachen**, je eine Datei pro Versionscode:
  `fastlane/metadata/android/de-DE/changelogs/<Code>.txt` und `fastlane/metadata/android/en-US/changelogs/<Code>.txt`.
- Code = Build-Nummer × 10 + 1/2/3, also bei Build-Nummer 501 die Dateien `5011.txt`, `5012.txt`, `5013.txt` (gleicher
  Inhalt, weil F-Droid jedem Handy die APK seiner CPU-Art zeigt). Max. 500 Zeichen, einfacher Text, Aufzählung mit „•".
- Die F-Droid-App zeigt den Text in der Sprache des Handys; gibt es die nicht, Englisch (en-US). Englisch also nie
  weglassen.
- Die Changelog-Dateien müssen **vor** dem Tag im Repo sein – F-Droid liest sie aus dem getaggten Stand.
- Die Release-Notizen auf GitHub sind davon unabhängig (schreibt Claude beim Release, Deutsch mit englischer Kurzfassung).

### Wie ergänze oder tausche ich Screenshots?
1. Neue Bilder machen (Format und Tipps im Abschnitt „Screenshots" unten).
2. In `fastlane/metadata/android/de-DE/images/phoneScreenshots/` bzw. `…/en-US/…` legen. Reihenfolge = Dateiname
   (`1.jpg`, `2.jpg` …). Austauschen = Datei mit gleichem Namen ersetzen; Bild entfernen = Datei löschen und die übrigen
   lückenlos durchnummerieren. Fehlt eine Sprache, zeigt F-Droid die englischen Bilder.
3. Claude wandelt PNGs in kleine JPGs um, committet und pusht (auf Ansage).
4. **Sichtbar werden sie erst mit dem nächsten Release (Tag)** – F-Droid liest Bilder und Texte aus dem Stand der
   neuesten gebauten Version, nicht aus dem aktuellen `main`.

### Wie ändere ich die App-Beschreibung auf F-Droid?
Genauso wie die Screenshots – alles kommt aus diesem Repo, nicht aus fdroiddata:
- `title.txt` – App-Name (Stand: „AA-AuralListen Podcatcher")
- `short_description.txt` – Kurzbeschreibung, **max. 80 Zeichen**
- `full_description.txt` – lange Beschreibung, **max. 4000 Zeichen**, einfaches HTML erlaubt (`<b>`, `<i>`, `<ul><li>`)
- `images/icon.png` – Symbol (512 × 512)

jeweils unter `fastlane/metadata/android/de-DE/` und `…/en-US/`. Ändern lassen (oder selbst ändern), committen,
pushen – sichtbar mit dem **nächsten Release**. Dinge im Rezept (Kategorie, Lizenz, Spenden-Link, Autor) ändern sich
dagegen nur per Merge Request in fdroiddata (Datei im Fork bearbeiten → MR).

### Wie gehe ich im Notfall auf ein älteres Release zurück?
Echtes „Zurückdrehen" gibt es bei Android nicht: Ein Update mit **kleinerem** Versionscode lehnt Android ab (außer man
deinstalliert vorher – dann sind die Daten weg, also erst Backup!). Darum:
1. **Vorwärts reparieren (empfohlen):** Den kaputten Stand im Code rückgängig machen (Claude: `git revert` der
   schuldigen Commits oder den Code eines älteren Tags wiederherstellen), dann **neue** Version mit **höherer**
   Build-Nummer veröffentlichen, z. B. v1.3.4+503 mit dem Inhalt von 1.3.2. Für Nutzer ist das ein normales Update –
   F-Droid und GitHub-Nutzer bekommen es automatisch bzw. als Update.
2. **GitHub:** Ein kaputtes Release kann man als „Pre-release" markieren oder löschen – betrifft nur neue Downloads.
   Den Tag dabei **nicht** auf einen anderen Commit verschieben (F-Droid hat ihn evtl. schon gebaut).
3. **F-Droid:** Eine schon veröffentlichte Version kann nur das F-Droid-Team zurückziehen (MR in fdroiddata, der den
   Build-Eintrag mit `disable: <Grund>` markiert, oder Issue). Das dauert ebenfalls Tage – Weg 1 ist fast immer
   schneller. In der F-Droid-App können Nutzer ältere Versionen sehen; installieren geht wegen des kleineren Codes nur
   nach Deinstallation.
4. Vorbeugend: Vor jedem Release Backup-Funktion und Datenbank-Migration testen (Testhandy A05s) – eine Migration
   lässt sich auch mit Weg 1 nicht rückgängig machen; die neue Version muss mit der schon migrierten Datenbank klarkommen.

### Welche Android-Version braucht die App?
Android 7.0 (API 24, Flutter-Standard), Ziel-API 36. F-Droid zeigt das automatisch an („Benötigt Android 7.0").
Auf Android 7–9 ungetestet.

### Was sind „Pipelines" bei GitLab? Sind fehlgeschlagene Einträge schlimm?
- GitLab-Pipeline = das, was bei GitHub „Actions" heißt (bei Azure DevOps „Azure Pipelines"): automatischer Build und
  Prüfung bei jedem Push/MR, gesteuert über eine YAML-Datei. Bei fdroiddata zwei Phasen: Rezept prüfen, App bauen.
- Die Pipeline-Liste von fdroiddata zeigt **alle** MRs aller Leute – rote Einträge dort betreffen fremde Apps.
  Die eigene Pipeline steht im MR !51179 unter dem Reiter „Pipelines". Nur die muss grün sein.

## Screenshots
- Format **JPG, 720 × 1600, Qualität 80** (`sips -Z 1600 -s format jpeg -s formatOptions 80`), Hochformat, Dateinamen
  sortieren die Reihenfolge (`1.jpg`, `2.jpg` …), 2–8 Stück je Sprache. **Keine PNGs einchecken** (3–4× größer, bläht
  die Git-Historie auf; `.gitignore` blockt sie). Kein Git-LFS: F-Droid lädt LFS-Dateien beim Bauen nicht.
- Stand 2026-10-04: je 5 Bilder (en-US: Start, Abos, Player, Downloads, Optionen; de-DE: Downloads, Start, Podcast-Menü,
  Playlists, Optionen – teils dunkel), PNG-Originale beim Benutzer unter `~/Pictures/AA-AuralListen-Screenshots-2026-10-04/`.
- Vorschlag: Start (mit Hintergrund), Abos, Podcast-Seite, Player, Playlists (mit Farben), Downloads, Optionen.
- Auf dem Handy: App-Sprache umstellen (Optionen → Sprache) für die englischen Bilder; Seitentaste + Leiser.
- Achtung, öffentlich: nichts Privates im Bild (Benachrichtigungen, Namen in Playlists …).

## Bekannte Punkte für die Prüfung
- **NonFreeNet** (Anti-Feature, Hinweis – keine Ablehnung): Die Suche nutzt Apples iTunes Search API. Möglich, dass
  F-Droid das markiert; fyyd.de und RSS-Adressen funktionieren ohne Apple.
- Unterschiedliche Signatur: Wer die GitHub-APK hat, kann nicht auf die F-Droid-Version aktualisieren (vorher Backup,
  deinstallieren, F-Droid-Version installieren, Backup einspielen).
