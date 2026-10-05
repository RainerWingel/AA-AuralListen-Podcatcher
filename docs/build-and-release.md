# Build & Release

## Zielgerät
- **Testhandy: Samsung Galaxy A05s** – frei nutzbar zum Installieren, Durchtippen, Test-Feeds, Screenshots.
  WLAN-Debugging per `adb connect <IP>:<Port>` (Port wechselt; steht unter „Wireless Debugging" auf dem Handy).
- **Samsung Galaxy S25 (SM-S931B) = Produktiv-Handy des Benutzers**, Android 16 / API 36, keine SD-Karte. **Nie zum
  Testen benutzen**; nur auf ausdrückliche Ansage installieren (ein Neustart beim Installieren beendet laufende Aktionen,
  z. B. ein Backup).
- Verbindung per **WLAN-Debugging** (Kopplung einmalig mit `adb pair`). Nach Handy-Neustart oder WLAN-Wechsel
  „USB-Debugging über WLAN" wieder einschalten; `adb` findet das Gerät per mDNS. Prüfen: `adb devices`.
  Fehlt ein Gerät trotz eingeschaltetem WLAN-Debugging: `adb kill-server && adb start-server`, dann `adb connect`.
- Per USB meldet das S25 kein ADB, solange die Samsung-Funktion „Automatische Blockierung" aktiv ist.
- Samsung-Akkuoptimierung kann Hintergrund-Wiedergabe beenden: App unter
  Einstellungen → Akku → Hintergrundnutzungsgrenzen als „Nie im Standby" eintragen.

## App-Identität
- Name (2026-09-29, markenrechtlich umbenannt): **„AA-AuralListen Podcatcher"** (App-Info, Einstellungen, Store,
  `appName` in `lib/core/app_info.dart`); unter dem Launcher-Symbol kurz **„AuralListen"** (Activity-Label, sonst
  abgeschnitten). Früher „AA-PodcastGuru".
- applicationId / namespace: `io.github.rainerwingel.aurallisten` (Doppel-L) – **nie mehr ändern**, spätestens ab
  Play-Store-Veröffentlichung unveränderlich. Bis 2026-09-29 `io.github.rainerwingel.aapodcastguru`: für Android eine
  andere App, Neustart mit leeren Daten (Backups der alten App werden bewusst nicht angenommen, `backup.md`).
- Bewusst unverändert (unsichtbar): Dart-Paketname `aapodcastguru`, DB-Datei `aapodcastguru.sqlite`, Keystore
  (Alias `aapodcastguru`, Zertifikat `CN=AA-PodcastGuru`) – ein neuer Schlüssel würde Updates verhindern.

## App-Symbol
Vorlage vom Benutzer: `tool/icon/source.webp` (Kopfhörer + „AA" + Mikrofon auf Navy). Erzeugt mit
`tool/icon/make_icons.py` (Aufruf steht im Skript; braucht Pillow + numpy in einem Wegwerf-venv, **kein** App-Paket):
- **Adaptives Symbol** (Android 8+, `mipmap-anydpi-v26/ic_launcher.xml`): Hintergrund = Verlauf
  `drawable/ic_launcher_background.xml`, Vordergrund = Motiv freigestellt (transparent, über den Blau-Kanal),
  innerhalb der 66-dp-Schutzzone, damit Kreis-, Squircle- und Samsung-Masken nichts abschneiden.
- **Monochrom-Ebene** für Android-13-„Designsymbole".
- **Legacy** `mipmap-*/ic_launcher.png`: Originalbild mit transparenten Ecken.
- **Statusleiste** `drawable-*/ic_stat_podcast.png`: weiße Silhouette, in `main.dart` als
  `androidNotificationIcon` gesetzt und in `res/raw/keep.xml` vor dem Ressourcen-Schrumpfen geschützt.
Neues Motiv: `source.webp` ersetzen, Skript laufen lassen, Vorschau-PNG prüfen, Farben im Hintergrund-XML anpassen.

## Signatur
- Release-APKs werden mit einem eigenen Keystore signiert. Updates lassen sich nur mit **demselben** Keystore
  über die bestehende Installation spielen – bei Verlust: Neuinstallation + Datenverlust (Backup vorher!).
- Keystore: `~/keys/aapodcastguru-release.jks` (außerhalb des Repos, Alias `aapodcastguru`), Zugangsdaten in
  `android/key.properties` (gitignored). Ohne diese Datei bleibt die Release-APK unsigniert (für F-Droid, `f-droid.md`); Debug-Builds (CI) sind nicht betroffen.
- Keystore + Passwort zusätzlich sicher sichern (Passwortmanager / externes Medium).

## Secrets
Aktuell keine (Podcast Index entfällt). Falls künftig nötig: `config/secrets.json` (gitignored) + `--dart-define-from-file`.

## Installation
```bash
flutter run                                  # Debug auf dem Gerät
flutter build apk --release --split-per-abi  # nur passende CPU-Architektur → deutlich kleiner
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## GitHub Pages (Datenschutzerklärung)
- Quelle: `main`, Ordner `/docs`. `docs/_config.yml` veröffentlicht **nur** `index.md` und `datenschutz.md`
  (interne Doku bleibt draußen).
- Adresse: https://rainerwingel.github.io/AA-AuralListen-Podcatcher/datenschutz/ – verlinkt in README und Store-Texten.
- Ändert sich, welche Server die App abruft, welche Berechtigungen sie hat oder was sie speichert: `datenschutz.md`
  im selben Commit anpassen (Stand-Datum!).
- Kontakt ist bewusst pseudonym (GitHub-Issues). Falls der Play Store doch noch kommt (derzeit verworfen, siehe
  `decisions.md` 2026-10-05): Entwicklername muss zur Play Console passen.

## GitHub-Release
Nur auf ausdrücklichen Wunsch des Benutzers (Repo ist öffentlich → APK für jeden herunterladbar).
1. `version:` in `pubspec.yaml` erhöhen (Name + Build-Nummer) **und** `appVersion` in `lib/core/app_info.dart`
   (User-Agent; ein Test vergleicht beide), committen, pushen, von `main` bauen.
2. Prüfen: `apksigner verify --print-certs` (Release-Zertifikat), keine DB/Key-Dateien in der APK (`unzip -l`).
3. APK als `AA-AuralListen-<version>-arm64-v8a.apk` hochladen (bis v1.1.0: `AA-PodcastGuru-…`):
   `gh release create v<version> <apk> --target <volle SHA von origin/main> --title … --notes-file …`
   (kurze SHA lehnt GitHub ab). Notizen auf Deutsch, mit SHA-256 der APK.
- v1.0.0 (2026-09-27): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.0.0
- v1.1.0 (2026-09-29): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.1.0
- v1.2.0 (2026-09-29): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.2.0 – erster
  Release unter dem neuen Namen und Paketnamen (`io.github.rainerwingel.aurallisten`)
- v1.3.0 (2026-10-01): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.3.0 – erste Version
  für F-Droid (`f-droid.md`); App-Farbe, Hintergründe, Playlist-Funktionen, Folgennummern, SQLite aus Quellcode
- v1.3.1 (2026-10-04): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.3.1 – Shownotes,
  Tempo, Staffeln/Serien, Abspielverlauf, „Als Nächstes spielen", „gespielt" erst am Ende, VBR-MP3-Fix, Sonderzeichen;
  Version für die F-Droid-Einreichung (Tag auf `7906fd48…`, neue Screenshots)
- v1.3.2 (2026-10-05): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.3.2 – nur neues
  Versionscode-Schema für F-Droid (+500, Codes 5001/5002/5003; Tag auf `05f780f6…`)
- v1.2.1 (2026-09-30): https://github.com/RainerWingel/AA-AuralListen-Podcatcher/releases/tag/v1.2.1 – Englisch,
  Playlist-Fortsetzen und -Farben, Abos-Suche, 15-s-Regel, Download-Fix (http → https)

## CI (GitHub Actions)
Bei jedem Push/PR: `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`
→ Debug-APK bauen (als Artefakt 7 Tage herunterladbar). Keine Secrets in der CI.
- Workflow: `.github/workflows/ci.yml`, Flutter-Version dort fest eingetragen – bei Flutter-Upgrade mit anpassen.

## Bekannte Stolpersteine
- **Immer mit `--split-per-abi` bauen.** Erst dann wird der `versionCode` zu Build-Nummer × 10 + ABI (arm64 = 2, seit
  1.3.2, siehe `f-droid.md`). Eine APK ohne diesen Schalter hätte nur die Build-Nummer als `versionCode` und ließe sich
  nicht mehr über die installierte App spielen (Downgrade).
- `Execution failed for task ':app:compileFlutterBuildRelease' … problem occurred starting process 'flutter'`:
  hängender Gradle-Daemon → `cd android && ./gradlew --stop`, dann erneut bauen.
- Fehlen im Release-Build Benachrichtigungs-Symbole („You must specify an icon resource id to build a CustomAction" im Log):
  `res/raw/keep.xml` prüfen – der Resource-Shrinker entfernt sonst die `audio_service_*`-Drawables.
- Die Internet-Berechtigung steht in `android/app/src/main/AndroidManifest.xml` (Flutter legt sie standardmäßig nur für Debug an).
- WLAN-Debugging reißt ab, wenn das Handy in den Standby geht – Bildschirm beim Installieren anlassen.
