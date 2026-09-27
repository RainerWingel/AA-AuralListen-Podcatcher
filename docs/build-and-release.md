# Build & Release

## Zielgerät
- Samsung Galaxy S25 (SM-S931B), Android 16 / API 36. Keine SD-Karte.
- Verbindung per **WLAN-Debugging** (Kopplung einmalig mit `adb pair`). Nach Handy-Neustart oder WLAN-Wechsel
  „USB-Debugging über WLAN" wieder einschalten; `adb` findet das Gerät per mDNS. Prüfen: `adb devices`.
- Per USB meldet das S25 kein ADB, solange die Samsung-Funktion „Automatische Blockierung" aktiv ist.
- Samsung-Akkuoptimierung kann Hintergrund-Wiedergabe beenden: App unter
  Einstellungen → Akku → Hintergrundnutzungsgrenzen als „Nie im Standby" eintragen.

## App-Identität
- applicationId / namespace: `io.github.rainerwingel.aapodcastguru` – **nie mehr ändern**
  (sonst ist es für Android eine andere App, Daten weg).
- Dart-Paketname: `aapodcastguru`.

## Signatur
- Release-APKs werden mit einem eigenen Keystore signiert. Updates lassen sich nur mit **demselben** Keystore
  über die bestehende Installation spielen – bei Verlust: Neuinstallation + Datenverlust (Backup vorher!).
- Keystore: `~/keys/aapodcastguru-release.jks` (außerhalb des Repos, Alias `aapodcastguru`), Zugangsdaten in
  `android/key.properties` (gitignored). Ohne diese Datei signiert Gradle mit Debug-Keys (z. B. in der CI).
- Keystore + Passwort zusätzlich sicher sichern (Passwortmanager / externes Medium).

## Secrets
Aktuell keine (Podcast Index entfällt). Falls künftig nötig: `config/secrets.json` (gitignored) + `--dart-define-from-file`.

## Installation
```bash
flutter run                                  # Debug auf dem Gerät
flutter build apk --release --split-per-abi  # nur passende CPU-Architektur → deutlich kleiner
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## CI (GitHub Actions)
Bei jedem Push/PR: `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`
→ Debug-APK bauen (als Artefakt 7 Tage herunterladbar). Keine Secrets in der CI.
- Workflow: `.github/workflows/ci.yml`, Flutter-Version dort fest eingetragen – bei Flutter-Upgrade mit anpassen.

## Bekannte Stolpersteine
- **Immer mit `--split-per-abi` bauen.** Das erhöht den internen `versionCode` (+2000 für arm64). Eine APK ohne
  diesen Schalter hätte einen kleineren `versionCode` und ließe sich nicht mehr über die installierte App spielen (Downgrade).
- `Execution failed for task ':app:compileFlutterBuildRelease' … problem occurred starting process 'flutter'`:
  hängender Gradle-Daemon → `cd android && ./gradlew --stop`, dann erneut bauen.
- Fehlen im Release-Build Benachrichtigungs-Symbole („You must specify an icon resource id to build a CustomAction" im Log):
  `res/raw/keep.xml` prüfen – der Resource-Shrinker entfernt sonst die `audio_service_*`-Drawables.
- Die Internet-Berechtigung steht in `android/app/src/main/AndroidManifest.xml` (Flutter legt sie standardmäßig nur für Debug an).
- WLAN-Debugging reißt ab, wenn das Handy in den Standby geht – Bildschirm beim Installieren anlassen.
