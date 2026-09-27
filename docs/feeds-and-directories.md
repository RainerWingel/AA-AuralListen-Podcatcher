# Feeds, Verzeichnisse, OPML

## Verzeichnis-Suche
| Dienst | Key nötig | Zweck |
|--------|-----------|-------|
| iTunes Search API | nein | große internationale Abdeckung |
| fyyd.de | nein | deutsches Verzeichnis, gute Abdeckung deutschsprachiger Podcasts |
| Podcast Index | ja (kostenlos, Key + Secret) | **zurückgestellt**: Registrierung nimmt keine Freemail-Adressen an; optional später |

- Die Suche fragt alle aktiven Dienste parallel, führt Ergebnisse zusammen und dedupliziert per Feed-URL.
- Fällt ein Dienst aus, werden die anderen trotzdem angezeigt.
- **Podcast-Index-Key:** Das Repo ist öffentlich → Key steht **nie** im Code. Er kommt aus
  `config/secrets.json` (gitignored, Vorlage: `config/secrets.example.json`) und wird per
  `--dart-define-from-file` eingebaut. Ohne Key wird Podcast Index einfach übersprungen.

## RSS
- Eigener Parser auf Basis von `xml`: RSS 2.0 + `itunes:` + `podcast:` (Podcasting 2.0) + `psc:` (Podlove Chapters).
- Folgen-Identität: `guid`, Fallback `enclosure url`.
- Conditional GET mit `ETag` / `If-Modified-Since`; 304 → nichts tun.
- Redirects (301) → gespeicherte `feedUrl` aktualisieren.
- Aktualisierung nur beim App-Start und per Pull-to-Refresh, parallel mit Begrenzung (z. B. 4 gleichzeitig).
- Fehlerhafte Feeds brechen den Refresh der anderen nicht ab; Fehler werden am Podcast angezeigt.

## OPML
- Import: Datei auswählen (Castbox → Einstellungen → OPML exportieren), alle `outline` mit `xmlUrl` übernehmen,
  vorhandene Abos überspringen, Ergebnis anzeigen („8 neu, 2 bereits vorhanden, 0 fehlerhaft").
- Export (M7): OPML 2.0, über Teilen-Dialog.
