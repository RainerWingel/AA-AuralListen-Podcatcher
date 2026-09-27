# Eviction & Speicherlecks (Kernanforderung)

Speicherlecks – im Arbeitsspeicher wie auf dem Datenträger – gelten als **Fehler höchster Priorität**.

## Datenträger (M4 ✅)

Code: `lib/data/storage/download_service.dart` (alle Regeln), `download_engine.dart` (Download-Paket-Kapsel),
Tests: `test/data/storage/download_service_test.dart` (inkl. Mutationsprobe der 96-h-Regel).

### Ablage
- Nur im **app-spezifischen internen Speicher** (`getApplicationSupportDirectory()/episodes/`).
  Keine Speicher-Berechtigung nötig; wird bei Deinstallation automatisch entfernt. Keine SD-Karte (Gerät hat keine).
- Dateiname = `<episodeId>.<ext>` (Endung aus MIME-Typ, sonst URL, sonst `mp3`), damit Zuordnung eindeutig ist.

### Invarianten
1. Jede Audiodatei im Ordner hat einen `downloads`-Eintrag (nicht `failed`) – und jeder `done`-Eintrag eine Datei.
2. `background_downloader` lädt in eine **temporäre Datei** (App-Cache) und verschiebt sie erst nach Erfolg in den
   Episoden-Ordner. Halbfertige Dateien landen also nie dort; Abbruch/Fehler räumt das Paket selbst auf.
3. Unsere Tabelle `downloads` ist die einzige Buchführung: Das Paket-eigene Tracking (`trackTasks`) wird **nicht** genutzt,
   damit keine zweite, wachsende Datenbank entsteht.
4. Jeder Code, der eine Datei anlegt, hat auch den Löschpfad (inkl. Fehlerfall).
5. Der `DownloadService` hört ab seiner Erzeugung auf Download-Ereignisse; `start()` holt Ereignisse nach, die passiert
   sind, während die App geschlossen war.

### Automatisches Löschen (Regel des Benutzers)
- Eine Folge gilt als **gespielt**, sobald ≥ 98 % gehört wurden (`data-model.md`).
- Heruntergeladene, **gespielte** Folgen werden **96 Stunden nach `playedAt`** automatisch gelöscht
  (sofern „Gespielte Folgen löschen" für den Podcast an ist – Standard: an).
- Folgen **unter 98 %** werden **nie** automatisch gelöscht.
- Die Folge im Player wird nie automatisch gelöscht.
- Wird eine Folge wieder „ungespielt" markiert oder erneut abgespielt, entfällt die Löschung (`playedAt` = null).

### Speicherlimit
- Einstellbar in Optionen: 1 / 2 / 5 / 10 / 20 GB (Standard 5 GB, `settings['downloads.limitBytes']`).
- Über dem Limit: gespielte Downloads werden gelöscht, **älteste zuerst** (nach `playedAt`) – auch vor Ablauf der 96 h.
- **Ungespielte Downloads werden nie wegen des Limits gelöscht**; stattdessen lädt Auto-Download nichts Neues mehr.

### Auto-Download
- Pro Podcast (Podcast → ⋮ → Podcast-Einstellungen): Aus / Nur WLAN / Immer, „Neueste ungespielte Folgen behalten": 1/2/3/5/10.
- Geladen werden die **neuesten** Folgen mit Status `neu` ohne Download, bis N ungespielte Downloads existieren.
  Fehlgeschlagene zählen nicht mit und werden nicht automatisch erneut versucht (Knopf „Erneut herunterladen").
- Budget: Feed-Größenangabe (`audioSizeBytes`) gegen das Speicherlimit; reicht es nicht, wird gestoppt.
- Manuelle Downloads (langes Drücken → „Herunterladen") laufen über jedes Netz.

### Wartung (`runMaintenance`)
Reihenfolge: Abgleich → 96-h-Löschung → Speicherlimit → Auto-Download. Läuft beim App-Start (nach dem Refresh), nach jedem
Pull-to-Refresh, nach Änderung der Podcast-Einstellungen oder des Limits und über „Jetzt aufräumen" (Downloads-Tab, Optionen).
Kein Hintergrund-Job. Gleichzeitige Aufrufe teilen sich einen Lauf.

### Abgleich (`reconcile`)
- Dateien ohne Eintrag (oder mit `failed`-Eintrag) → löschen (Waisen, Reste).
- `done`-Eintrag ohne Datei → Eintrag entfernen, Folge wird wieder gestreamt.
- `queued`/`running`-Eintrag, aber das Paket kennt die Aufgabe nicht mehr (App wurde beendet):
  Datei da → `done` (Meldung verpasst); sonst → Eintrag entfernen.
- Beim Abspielen: Fehlt die Datei plötzlich, wird der Eintrag entfernt und gestreamt.
- Abo kündigen → laufende Downloads abbrechen, alle Dateien und Einträge des Podcasts löschen, Cover aus dem Cache.

### Caches
- Cover-Bilder: `CoverCacheManager` (`lib/data/storage/cover_cache.dart`) mit fester Obergrenze: 300 Objekte, 30 Tage. ✅
  Dekodiert wird nur in Anzeigegröße (`CoverImage`, `memCacheWidth`). ✅
  Beim Abo-Kündigen werden Podcast- und Folgen-Cover aus dem Cache entfernt. ✅
- HTTP-Antworten werden mit Größenlimit gelesen (30 MB), Feed-XML nach dem Parsen verworfen. ✅
- Temporäre Dateien (Backup-ZIP, OPML-Export) nach dem Teilen löschen.
- Kopien des Datei-Pickers (OPML-Import) werden direkt nach dem Einlesen gelöscht. ✅

### Sichtbarkeit
Downloads-Tab: „x von y belegt" + Balken, jede Datei mit Größe, 🧹 „Jetzt aufräumen". Optionen: Limit + „Jetzt aufräumen".

## Arbeitsspeicher
- Jede `StreamSubscription`, jeder `Timer`, `AnimationController`, `TextEditingController`, `ScrollController`
  wird in `dispose()` bzw. `ref.onDispose` freigegeben.
- Genau eine Player-Instanz (`PodcastAudioHandler`, erstellt in `main()`). Keine Player-Objekte in Widgets anlegen. ✅
- Nach 10 Minuten Pause gibt der Handler den Player (Decoder, Netzwerkpuffer) frei. ✅
- Der Live-Positions-Stream wird nur abonniert, solange Mini-/Vollbild-Player sichtbar sind (`autoDispose`). ✅
- `audio_service` nutzt für Benachrichtigungs-Cover den begrenzten `CoverCacheManager` (kein zweiter Cache). ✅
- Positions-Updates des Players gedrosselt in die DB schreiben (alle 5 s + bei Pause/Seek/Stopp/Folgenwechsel). ✅
- Lange Listen nur mit `ListView.builder`; Bilder mit `memCacheWidth`/`cacheWidth` dekodieren.
- Feed-XML nach dem Parsen verwerfen; Beschreibungen gekürzt speichern.
- Keine unbegrenzt wachsenden Listen/Maps in Services.

## Tests
- Unit-Tests für alle Regeln oben (mit fake `Clock` und temporärem Verzeichnis).
- `leak_tracker` in Widget-Tests aktiv.
- Vor Release (M8): DevTools-Speicherprofil, Soak-Test 2 h Wiedergabe + 50 Refreshes, Speicher darf nicht wachsen.
