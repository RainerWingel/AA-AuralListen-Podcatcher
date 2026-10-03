# Entscheidungslog

Format: Datum · Entscheidung · Begründung. Neue Einträge unten anhängen.

- 2026-09-27 · **Flutter statt Lynx** · ausgereifte Pakete für Hintergrund-Audio und Downloads; Lynx-Ökosystem dafür noch dünn.
- 2026-09-27 · **Android-first, Sideload per APK, kein Store** · iOS-Sideload ohne bezahlten Developer-Account nur 7 Tage gültig. Code bleibt plattformneutral, iOS-Ordner existiert.
- 2026-09-27 · **Nur lokale Daten, kein Sync** · Anforderung des Benutzers.
- 2026-09-27 · **Kein Hintergrund-Feed-Update** · Refresh nur beim App-Start und per Pull-to-Refresh.
- 2026-09-27 · **Nur Deutsch** · UI-Texte trotzdem über gen-l10n (ARB), damit sie zentral liegen.
- 2026-09-27 · **AGENTS.md + Themen-Doku unter docs/** · Claude und ChatGPT arbeiten abwechselnd; AGENTS.md bleibt kurz, Agenten lesen/schreiben nur relevante Themen. CLAUDE.md enthält nur `@AGENTS.md`.
- 2026-09-27 · **applicationId `io.github.rainerwingel.aapodcastguru`** · Vorgabe des Benutzers; unveränderlich.
- 2026-09-27 · **„Gespielt" = ≥ 98 %; Auto-Löschen 96 h nach Gespielt** · Vorgabe des Benutzers. Unter 98 % wird nie automatisch gelöscht.
- 2026-09-27 · **Playlists: gespielte Folge verschwindet, nächste startet, dynamisch aus DB** · Vorgabe des Benutzers (Castbox-Verhalten).
- 2026-09-27 · **Nur interner app-spezifischer Speicher** · Galaxy S25 hat keinen SD-Slot; keine Speicher-Berechtigung nötig.
- 2026-09-27 · **Eigener RSS-Parser auf `xml`** · volle Kontrolle über Podcasting-2.0-/Podlove-Namespaces.
- 2026-09-27 · **Überspringen ≠ gespielt; gespielte Folge verlässt alle Playlists** · Vorgabe des Benutzers.
- 2026-09-27 · **Anonyme Commit-Identität (GitHub-noreply)** · öffentliches Repo; keine Verknüpfung mit echtem Namen.
- 2026-09-27 · **Kein Podcast Index** · Registrierung verlangt Nicht-Freemail-Adresse; Arbeitsadresse soll nicht genutzt werden. iTunes + fyyd reichen.
- 2026-09-27 · **Generierte l10n-Dateien werden committet** · Agenten ohne Flutter-SDK sehen so die fertigen Getter.
- 2026-09-27 · **CI pinnt die Flutter-Version** · reproduzierbare Builds; bei Upgrade Workflow anpassen.
- 2026-09-27 · **Generierter Code (`*.g.dart`) wird committet** · wie bei l10n: Agenten ohne Flutter-SDK sehen alle Typen; CI prüft trotzdem.
- 2026-09-27 · **Show-Notes als Klartext, max. 4000 Zeichen** · hält die DB klein (Eviction); formatierte Show-Notes ggf. später.
- 2026-09-27 · **Folgen, die aus dem Feed verschwinden, bleiben erhalten** · Hörposition/Lesezeichen gehen nicht verloren.
- 2026-09-27 · **Pakete M1: drift, drift_flutter, http, xml, path_provider, cached_network_image, flutter_cache_manager** · wie in `architecture.md` geplant.
- 2026-09-27 · **Paket `file_picker` für OPML-Import** · Systemdialog zur Dateiauswahl, keine Speicher-Berechtigung nötig.
- 2026-09-27 · **Suchergebnisse abwechselnd zusammenführen** · beide Rankings bleiben erhalten; Dubletten per URL-Schlüssel oder Titel+Autor.
- 2026-09-27 · **PRs merged der Agent selbst, sobald CI grün** · Vorgabe des Benutzers. GitHub-Auto-Merge ist im Repo deaktiviert → `gh pr merge <n> --merge --delete-branch`.
- 2026-09-27 · **Pakete M3: just_audio, audio_service, audio_session** · wie geplant; Boost über `AndroidLoudnessEnhancer`.
- 2026-09-27 · **`PlayerEngine`-Interface um just_audio** · Wiedergabe-Logik ohne echtes Audio testbar (Fake-Engine).
- 2026-09-27 · **Dienst bleibt in der Pause im Vordergrund, Selbst-Stopp nach 10 Min.** · Android 12+ verbietet sonst ggf. den Neustart aus dem Hintergrund (Samsung).
- 2026-09-27 · **Nach kurzer Unterbrechung (Anruf) automatisch weiterspielen** · Standardverhalten von just_audio; ersetzt die ursprüngliche Notiz „nicht automatisch weiterspielen".
- 2026-09-27 · **Gespielte Folge erneut abspielen = wieder „angefangen" ab 0** · verhindert, dass eine Folge während des erneuten Hörens nach 96 h gelöscht wird.
- 2026-09-27 · **`player_state`-Tabelle entfällt, stattdessen `settings`** · ein Key/Value-Speicher reicht für letzte Folge, Boost und später aktive Playlist.
- 2026-09-27 · **Drift-Schema-Schnappschüsse + generierte Migrationstests** · jede künftige Migration (auch von ChatGPT) wird gegen die alten Schemata geprüft.
- 2026-09-27 · **Paket background_downloader ohne dessen Task-Datenbank** · Downloads laufen im Hintergrund weiter (WorkManager); unsere `downloads`-Tabelle bleibt die einzige Buchführung.
- 2026-09-27 · **Speicherlimit löscht nur gespielte Downloads** · Benutzerregel „unter 98 % nie automatisch löschen" hat Vorrang; bei vollem Speicher stoppt nur der Auto-Download (ersetzt die frühere Notiz „dann älteste ungespielte löschen").
- 2026-09-27 · **Tab „Optionen" statt „Einstellungen"** · 5 Tabs + große Systemschrift auf dem S25 → Umbruch.
- 2026-09-27 · **Gespielt-Regel „aus allen Playlists" zentral in `markPlayed`** · gilt für 98 %, Dateiende und manuelles Markieren gleich.
- 2026-09-27 · **Nächste Folge = kleinste Position größer als die der laufenden** · dynamisch gelesen; Position wird vor dem Entfernen aktualisiert (Umsortieren während der Wiedergabe).
- 2026-09-27 · **„Rückgängig" beim Entfernen fügt am Ende ein** · alte Position wiederherzustellen lohnt den Aufwand nicht.
- 2026-09-27 · **Infoboxen max. 7 s, zentraler Helfer** · Vorgabe des Benutzers; Flutter-Standard ließ Boxen mit Knopf unbegrenzt stehen.
- 2026-09-27 · **Merge nur mit expliziter CI-Prüfung** · PR #9 wurde versehentlich bei laufender CI gemergt (die CI war danach grün bzw. wird geprüft).
- 2026-09-27 · **Themen über den Folgen-Link statt über das Bild** · im WRINT-Feed hat jede Folge eine eigene Bild-URL; der Link enthält die Sendereihe zuverlässig.
- 2026-09-27 · **Themen-Filter als Positivliste; alle angehakt = null** · neue Themen kommen nicht ungefragt dazu; „alle" bleibt offen für Folgen ohne erkanntes Thema.
- 2026-09-27 · **ID3-Kapitel per HTTP-Range statt ganzer Datei** · WRINT hat nur so Kapitel (JSON-Links liefern 404); der Tag ist 0,1–1 MB, die Folge oft 50+ MB.
- 2026-09-27 · **Kapitel-Reihenfolge Feed → JSON → ID3, Ergebnis in der DB** · schnellste/zuverlässigste Quelle zuerst, Netzwerk nur einmal pro Folge.
- 2026-09-27 · **Migration v6 erzwingt erneut einen Voll-Refresh** · damit Podlove-Kapitel vorhandener Folgen gespeichert werden.
- 2026-09-27 · **Paket `archive` für Backup-ZIPs** · wie geplant.
- 2026-09-27 · **Speichern über den Android-Speichern-Dialog (file_picker.saveFile)** · Benutzer wählt Ort (Downloads, Drive); kein Teilen-Paket nötig, keine Temp-Dateien.
- 2026-09-27 · **Wiederherstellung per ATTACH + Tabellenkopie statt Datei-Austausch** · kein App-Neustart nötig (audio_service hält den Prozess am Leben, ein Neustart wäre unzuverlässig); alte Backups werden vorher migriert.
- 2026-09-27 · **Downloads gehören nicht ins Backup** · Audiodateien sind groß und jederzeit neu ladbar.
- 2026-09-27 · **App-Symbol per eigenem Python-Skript statt `flutter_launcher_icons`** · kein zusätzliches Paket; Freistellen des Motivs und Statusleisten-Silhouette braucht das Paket ohnehin nicht zu können.
- 2026-09-27 · **Klartext-HTTP erlaubt (network_security_config)** · Podcast-Audio ist öffentlich; ohne das scheitern Downloads/Streams von Feeds mit `http://`-Links (CRE). Wie AntennaPod.
- 2026-09-27 · **Dev-Paket `leak_tracker_flutter_testing`** (Benutzer zugestimmt) · automatische Erkennung nicht freigegebener Controller in Widget-Tests; kommt nicht in die App.
- 2026-09-28 · **Akku-Ausnahme per eigenem MethodChannel statt `permission_handler`** · zwei Android-Aufrufe rechtfertigen kein Paket; System-Dialog nur einmal automatisch, danach nur auf Wunsch.
- 2026-09-28 · **Sleep-Timer doch umgesetzt** (Benutzerwunsch, hebt „bewusst nicht" auf) · Minuten zählen nur Spielzeit; „Bis Ende der Folge" stoppt ohne Playlist-Weiterspielen; nur im Arbeitsspeicher.
- 2026-09-28 · **just_audio ohne lokalen Proxy** (`useProxyForRequestHeaders: false`) · User-Agent nativ über ExoPlayer; Proxy verursachte Timeouts/unbehandelte Fehler offline und kostet Ressourcen.
- 2026-09-28 · **Nur noch direkt auf `main` committen** (Benutzerwunsch) · keine Feature-Branches/PRs mehr; lokale Prüfungen (format, analyze, test) vor jedem Push, CI auf `main` als Nachkontrolle.
- 2026-09-28 · **Pushen nur auf Ansage des Benutzers** · committen jederzeit auf `main`; CI läuft beim Push.
- 2026-09-29 · **Umbenennung in „AA-AuralListen Podcatcher"** (markenrechtlich, Benutzer) · Launcher „AuralListen", applicationId `io.github.rainerwingel.aurallisten` (neue App, Neustart ohne Datenübernahme – alte Backups werden nicht angenommen); Keystore, Dart-Paket- und DB-Dateiname bleiben.
- 2026-09-29 · **Kein Akku-Ausnahme-Dialog mehr** · nur Status + Knopf zu den App-Einstellungen; das Recht `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` ist für den Play Store heikel.
- 2026-09-29 · **Play Store geplant** (hebt „nur Sideload" auf) · Datenschutzerklärung nötig, Klartext-HTTP im Datensicherheits-Formular angeben.
- 2026-09-29 · **Weitere Sprachen geplant** (hebt „Nur Deutsch" auf, Benutzer) · vorerst weiter nur `app_de.arb`; die gen-l10n-Struktur ist dafür schon vorbereitet. README weist darauf hin.
- 2026-10-01 · **F-Droid-Vorbereitung** (Benutzer) · Lizenz **GPL-3.0-only**. SQLite wird aus der offiziellen Quelle
  (`third_party/sqlite`, 3.53.4) kompiliert statt vom `sqlite3`-Hook heruntergeladen – F-Droid verlangt Bau komplett aus
  Quellcode; eigene Builds sind damit identisch. Release-APK ohne `key.properties` ist unsigniert (F-Droid signiert
  selbst; Play Store später mit eigenem Upload-Schlüssel unberührt). Erste F-Droid-Version: 1.3.0 (Build 5). Screenshots
  macht der Benutzer. Details: `f-droid.md`.
- 2026-09-30 · **Wählbare App-Farbe + Paket `dynamic_color`** (Benutzer) · 8 feste Farben (Orange, Rot, Pink, Lila, Blau,
  Petrol, Grün, Braun) + „Wie Hintergrundbild" (Material You, Android 12+) – **Standard** (Benutzer); ohne Wallpaper-Farben
  (Android ≤ 11) Orange. Feste Auswahl statt Farbrad,
  damit Kontraste in Hell/Dunkel immer stimmen. `dynamic_color` (Google Material, Apache-2.0, F-Droid-tauglich) liefert
  nur die Hintergrundbild-Farbe; die Palette baut immer `ColorScheme.fromSeed` (vollständige M3-Rollen).
- 2026-09-30 · **Titelschrift Fredoka** (Benutzer, aus 6 Vorschlägen; ersetzt das kurz genutzte Playfair Display) ·
  nur AppBar-Titel; als Asset gebündelt
  statt Paket `google_fonts` (kein neues Paket, kein Nachladen aus dem Netz → Datenschutz). Lizenz SIL OFL 1.1,
  mit GPL-3.0 verträglich.
- 2026-09-29 · **Englisch als zweite Sprache** (Benutzer) · `app_en.arb`; Abfrage beim ersten Start, gespeichert in
  `settings['ui.language']`, änderbar unter Optionen. Vor der Wahl: Gerätesprache Deutsch → Deutsch, sonst Englisch.
  Datumsformate und Dezimaltrenner folgen der gewählten Sprache. Sprachnamen stehen in jeder ARB-Datei in der
  eigenen Sprache („Deutsch", „English").
- 2026-09-29 · **Kein Trinkgeld in der App** (Benutzer) · weder Google Play Billing noch externer Zahlungslink; die Info-Seite verlinkt nur GitHub, dort steht der PayPal-Link (README, `.github/FUNDING.yml`). Keine Play-Richtlinienprobleme, keine Händler-Pflichtangaben.
- 2026-10-01 · **Shownotes ohne HTML-Paket, eigene Tabelle** (Benutzer, Eviction wichtig) · Statt `flutter_html` o. Ä.
  (Folgepakete, Bilder aus dem Netz → Datenschutz, ~3× Speicher) behält der Parser nur Absätze, Aufzählungen und
  http/https-Links in einem schlanken Eigenformat; Links öffnet der vorhandene `openUrl`-Kanal. Shownotes liegen in
  `episode_notes` statt in `episodes`, damit Listen sie nicht laden (`data-model.md`).
- 2026-10-03 · **Anderswo gestartete Folge: Playlist nur anbieten** (Benutzer) · Ersetzt die Regel vom 2026-09-30
  (Folge in genau einer Playlist galt automatisch als aus ihr gespielt → am Ende startete ungewollt die nächste).
  Jetzt halbtransparente Zeile „Aus Playlist …", aktiv erst nach Antippen; sonst stoppt die Wiedergabe am Ende.
- 2026-10-03 · **„Gespielt" erst am Dateiende, 98-%-Regel abgeschafft** (Benutzer) · Ersetzt „Gespielt = ≥ 98 %"
  (2026-09-27). Die Sonderfälle der 98-%-Regel (Folge verließ die Playlists vor dem Ende, Beobachter-Ausnahme,
  Positions-Nachlesen) entfallen; am Ende: nächste lesen → markieren → stoppen → weiter. Auto-Löschen bleibt 96 h nach
  „gespielt"; nicht gespielte Folgen werden nie automatisch gelöscht.
