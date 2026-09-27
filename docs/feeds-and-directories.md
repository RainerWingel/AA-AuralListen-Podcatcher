# Feeds, Verzeichnisse, OPML

## Verzeichnis-Suche
| Dienst | Key nötig | Zweck |
|--------|-----------|-------|
| iTunes Search API | nein | große internationale Abdeckung |
| fyyd.de | nein | deutsches Verzeichnis, gute Abdeckung deutschsprachiger Podcasts |

- Die Suche fragt alle aktiven Dienste parallel, führt Ergebnisse zusammen und dedupliziert per Feed-URL.
- Fällt ein Dienst aus, werden die anderen trotzdem angezeigt.
- **Podcast Index wird nicht genutzt** (siehe `decisions.md`). Falls später doch: Key nie im Code (Repo ist öffentlich),
  sondern in `config/secrets.json` (gitignored) und per `--dart-define-from-file` einbauen.

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
