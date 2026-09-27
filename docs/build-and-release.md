# Build & Release

## Zielgerät
- Samsung Galaxy S25, per USB am Mac mini M4. Keine SD-Karte.
- Einmalig: Entwickleroptionen (Einstellungen → Telefoninfo → Softwareinformationen → 7× „Buildnummer")
  → USB-Debugging an → Mac beim Verbinden erlauben. Prüfen: `adb devices`.
- Samsung-Akkuoptimierung kann Hintergrund-Wiedergabe beenden: App unter
  Einstellungen → Akku → Hintergrundnutzungsgrenzen als „Nie im Standby" eintragen.

## App-Identität
- applicationId / namespace: `io.github.rainerwingel.aapodcastguru` – **nie mehr ändern**
  (sonst ist es für Android eine andere App, Daten weg).
- Dart-Paketname: `aapodcastguru`.

## Signatur
- Release-APKs werden mit einem eigenen Keystore signiert. Updates lassen sich nur mit **demselben** Keystore
  über die bestehende Installation spielen – bei Verlust: Neuinstallation + Datenverlust (Backup vorher!).
- Keystore: `~/keys/aapodcastguru-release.jks` (außerhalb des Repos), Zugangsdaten in `android/key.properties` (gitignored).
- Keystore + Passwort zusätzlich sicher sichern (Passwortmanager / externes Medium).

## Secrets
- `config/secrets.json` (gitignored), Vorlage `config/secrets.example.json`.
- Einbinden: `--dart-define-from-file=config/secrets.json`.

## Installation
```bash
flutter run --dart-define-from-file=config/secrets.json            # Debug auf dem Gerät
flutter build apk --release --dart-define-from-file=config/secrets.json
flutter install --release                                          # installiert Release-APK aufs Gerät
```

## CI (GitHub Actions)
Bei jedem Push/PR: `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`
→ Debug-APK bauen. Keine Secrets in der CI nötig (Podcast Index ist dort einfach deaktiviert).
