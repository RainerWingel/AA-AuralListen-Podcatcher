# Eviction & Speicherlecks (Kernanforderung)

Speicherlecks – im Arbeitsspeicher wie auf dem Datenträger – gelten als **Fehler höchster Priorität**.

## Datenträger

### Ablage
- Nur im **app-spezifischen internen Speicher** (`getApplicationSupportDirectory()/episodes/`).
  Keine Speicher-Berechtigung nötig; wird bei Deinstallation automatisch entfernt. Keine SD-Karte (Gerät hat keine).
- Dateiname = `<episodeId>.<ext>`, damit Zuordnung eindeutig ist.

### Invarianten
1. Jede Audiodatei hat genau einen `downloads`-Eintrag mit `state=done` – und umgekehrt.
2. Downloads schreiben in `<name>.part`; erst nach Erfolg umbenennen, dann DB auf `done` setzen.
   Bei Fehler/Abbruch: `.part` löschen, Eintrag `failed` bzw. entfernen.
3. Jeder Code, der eine Datei anlegt, hat auch den Löschpfad (inkl. Fehlerfall).

### Automatisches Löschen (Regel des Benutzers)
- Eine Folge gilt als **gespielt**, sobald ≥ 98 % gehört wurden (`data-model.md`).
- Heruntergeladene, **gespielte** Folgen werden **96 Stunden nach `playedAt`** automatisch gelöscht
  (sofern `autoDeletePlayed` für den Podcast aktiv ist – Standard: an).
- Folgen **unter 98 %** werden **nie** automatisch gelöscht.
- Die gerade aktive Folge wird nie gelöscht.
- Wird eine Folge wieder „ungespielt" markiert, entfällt die Löschung.
- Ausgeführt: bei jedem App-Start und nach jedem Refresh (kein Hintergrund-Job).

### Auto-Download
- Pro Podcast einstellbar: aus / nur WLAN / immer, max. N ungespielte Downloads.
- Wird N überschritten, lädt die App keine weiteren herunter (sie löscht keine ungespielten Folgen selbstständig).

### Reconciliation bei jedem App-Start
- Dateien ohne DB-Eintrag → löschen.
- `.part`-Reste → löschen.
- DB-Einträge ohne Datei → Eintrag entfernen, Folge wird wieder „streambar".
- Abo kündigen → alle Dateien, Downloads-Einträge und Cover-Cache-Einträge des Podcasts löschen.

### Caches
- Cover-Bilder: `CoverCacheManager` (`lib/data/storage/cover_cache.dart`) mit fester Obergrenze: 300 Objekte, 30 Tage. ✅
  Dekodiert wird nur in Anzeigegröße (`CoverImage`, `memCacheWidth`). ✅
  Beim Abo-Kündigen werden Podcast- und Folgen-Cover aus dem Cache entfernt. ✅
- HTTP-Antworten werden mit Größenlimit gelesen (30 MB), Feed-XML nach dem Parsen verworfen. ✅
- Temporäre Dateien (Backup-ZIP, OPML-Export) nach dem Teilen löschen.
- Kopien des Datei-Pickers (OPML-Import) werden direkt nach dem Einlesen gelöscht. ✅

### Sichtbarkeit
Einstellungen → „Speicher": Belegung gesamt und pro Podcast, Knopf „Jetzt aufräumen".

## Arbeitsspeicher
- Jede `StreamSubscription`, jeder `Timer`, `AnimationController`, `TextEditingController`, `ScrollController`
  wird in `dispose()` bzw. `ref.onDispose` freigegeben.
- Genau eine Player-Instanz. Keine Player-Objekte in Widgets anlegen.
- Positions-Updates des Players gedrosselt in die DB schreiben (z. B. alle 5 s + bei Pause/Stopp), nicht bei jedem Tick.
- Lange Listen nur mit `ListView.builder`; Bilder mit `memCacheWidth`/`cacheWidth` dekodieren.
- Feed-XML nach dem Parsen verwerfen; Beschreibungen gekürzt speichern.
- Keine unbegrenzt wachsenden Listen/Maps in Services.

## Tests
- Unit-Tests für alle Regeln oben (mit fake `Clock` und temporärem Verzeichnis).
- `leak_tracker` in Widget-Tests aktiv.
- Vor Release (M8): DevTools-Speicherprofil, Soak-Test 2 h Wiedergabe + 50 Refreshes, Speicher darf nicht wachsen.
