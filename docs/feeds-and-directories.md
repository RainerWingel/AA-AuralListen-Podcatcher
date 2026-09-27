# Feeds, Verzeichnisse, OPML

## Verzeichnis-Suche
| Dienst | Key nötig | Zweck |
|--------|-----------|-------|
| Apple Podcasts (iTunes Search API) | nein | große internationale Abdeckung; `country=DE`, max. 25 Treffer |
| fyyd.de (`/0.2/search/podcast?term=`) | nein | deutsches Verzeichnis, gute Abdeckung deutschsprachiger Podcasts; max. 25 Treffer |

Code: `lib/data/directory/directory_search.dart`, UI: `lib/features/search/search_screen.dart`.
- Beide Dienste werden parallel gefragt (Timeout 15 s). Ergebnisse werden **abwechselnd** zusammengeführt
  (Platz 1 iTunes, Platz 1 fyyd, Platz 2 iTunes …), damit das Ranking beider Dienste erhalten bleibt.
- Dubletten fliegen raus: gleiche Feed-URL (Vergleich über `feedUrlKey`: ohne Schema, `www.`, Groß/Klein, End-Slash)
  **oder** gleicher Titel + Autor. Das erste Vorkommen gewinnt.
- Fällt ein Dienst aus, werden die anderen trotzdem angezeigt (Hinweis-Banner „… nicht erreichbar").
- iTunes-Treffer ohne `feedUrl` (Apple-exklusive Podcasts) werden übersprungen.
- Suche startet 600 ms nach dem Tippen (ab 3 Zeichen) oder sofort per Enter/Lupe.
- Bereits abonnierte Treffer zeigen ein Häkchen (Vergleich per `feedUrlKey`).
- **Podcast Index wird nicht genutzt** (siehe `decisions.md`). Falls später doch: Key nie im Code (Repo ist öffentlich),
  sondern in `config/secrets.json` (gitignored) und per `--dart-define-from-file` einbauen.

## RSS
Code: `lib/data/feed/` (`rss_parser.dart`, `feed_fetcher.dart`, `feed_dates.dart`), Ablauf in `lib/data/podcast_repository.dart`.
- Eigener Parser auf Basis von `xml`: RSS 2.0 + `itunes:` + `content:` + `podcast:` (Podcasting 2.0); `psc:` (Podlove Chapters) folgt in M6.
- Namespaced Elemente werden über die Namespace-URI gefunden; fehlt die Deklaration im Feed, über den Präfix
  (sonst würde ein undeklariertes `itunes:image` mit `<image>` verwechselt).
- Nur Audio: Items ohne `enclosure` oder mit `video/*` werden übersprungen (reine Video-Feeds wie „tagesschau" haben daher 0 Folgen).
- Doppelte guids im Feed: erstes Vorkommen gewinnt.
- `pubDate`: RFC 822 inkl. üblicher Abweichungen (Zonennamen, 2-stellige Jahre, ohne Sekunden) + ISO 8601.
- `itunes:duration`: Sekunden, `MM:SS`, `HH:MM:SS`.
- Show-Notes werden zu Klartext (max. 4000 Zeichen).
- Folgen-Identität: `guid`, Fallback `enclosure url`.
- Conditional GET mit `ETag` / `If-Modified-Since`; 304 → nur `lastRefreshAt` setzen.
- Redirects werden manuell verfolgt (max. 5). Nur wenn **alle** permanent sind (301/308), wird die gespeicherte `feedUrl` ersetzt.
  Umzüge insgesamt: siehe „Podcast-Umzug" unten.
- Schutz: Timeout 30 s, max. 30 MB pro Feed. Zeichensatz aus `Content-Type` bzw. XML-Deklaration (UTF-8, ISO-8859-1), BOM wird entfernt.
- User-Agent: `AA-PodcastGuru/<version> (+Repo-URL)`.
- Eingabe-URLs werden normalisiert: `https://` wird ergänzt, `feed://`/`itpc://`/`pcast://` → `https://`.
- Aktualisierung nur beim App-Start (`main.dart`) und per Pull-to-Refresh, max. 4 Feeds parallel.
  Gleichzeitige Aufrufe teilen sich einen Lauf.
- Fehlerhafte Feeds brechen den Refresh der anderen nicht ab; Fehler landen in `podcasts.lastError` und werden
  im Raster (rotes Symbol) und im Podcast-Detail angezeigt.

## Podcast-Umzug (neue Feed-Adresse)
Wechselt ein Podcast den Hoster, gibt es drei Wege; in allen Fällen bleiben Hörstand, Playlists, Lesezeichen und Downloads
erhalten, weil Folgen über ihre `guid` wiedererkannt werden (Hoster übernehmen die guids beim Umzug).
1. **HTTP 301/308** auf die neue Adresse → wird beim Refresh übernommen (siehe RSS).
2. **`<itunes:new-feed-url>`** im alten Feed (Apple-Standard, auch von Podigee, Libsyn usw. gesetzt):
   Der Refresh lädt die neue Adresse; lädt und parst sie, wird sie gespeichert, ETag/Last-Modified kommen vom neuen Feed.
   - Neue Adresse kaputt oder (noch) kein Feed → alter Feed wird normal verwendet, **kein** Fehler; nächster Refresh versucht es erneut.
   - Neue Adresse gehört schon zu einem anderen Abo → kein Umzug (nie zwei Abos zusammenlegen).
   - Neuer Feed zeigt per `new-feed-url` zurück → kein Umzug (sonst Ping-Pong).
   - Pro Refresh nur ein Sprung; eine Kette A → B → C wird über mehrere Refreshes verfolgt.
   - Beim Abonnieren einer alten Adresse wird direkt die neue gespeichert.
3. **Manuell** (Umzug ohne Redirect/Ankündigung, alte Adresse tot): Podcast-Einstellungen → „Feed-Adresse ändern".
   Die neue Adresse muss laden und ein Feed sein und darf nicht zu einem anderen Abo gehören (`changeFeedUrl`).

`refreshAll` zählt Umzüge (`RefreshSummary.moved`); Pull-to-Refresh meldet sie per Infobox. Beim App-Start passiert es still.
Nicht unterstützt: `<podcast:guid>`-basierte Umzugssuche über Podcast Index (kein Podcast Index, siehe `decisions.md`).
Ändern sich beim Umzug die guids, entstehen die Folgen neu (alte bleiben mit Hörstand stehen).

## Smoke-Test gegen echte Feeds
```bash
dart run tool/smoke_feeds.dart "Lage der Nation" "Hotel Matze"
```
Sucht über iTunes, lädt und parst die Feeds und zeigt Anzahl Folgen / Datum / Dauer. Nach Parser-Änderungen ausführen.

## Themen in Netzwerk-Feeds (z. B. WRINT)
Manche Feeds bündeln mehrere Sendereihen („Die Wrintheit", „Zum Thema" …) mit eigenem Bild.
- Das Bild taugt **nicht** zur Erkennung: Jede Folge hat eine eigene Bild-URL, auch wenn die Bilder gleich aussehen.
- Erkannt wird das Thema am **Folgen-Link**: `…/podcast/85079-zum-thema/173-…` → Schlüssel `zum-thema`
  (`episodeThemeFromLink`, Podigee-Netzwerke). Anzeigename per `themeDisplayName` („Zum Thema"; Umlaute fehlen,
  weil der Link keine enthält, z. B. „Realitatsabgleich").
- Gespeichert in `episodes.theme` (Schema v5). Feeds ohne solche Links haben kein Thema; die Themen-Auswahl erscheint
  erst ab 2 Themen.
- Beim Update auf v5 werden ETag/Last-Modified gelöscht, damit der nächste Refresh alle Folgen neu liest und das Thema nachträgt.

## OPML
Code: `lib/data/feed/opml.dart` (Parser), `lib/data/opml_importer.dart` (Import), `lib/features/settings/opml_import_flow.dart` (UI).
- Import: Einstellungen → „OPML-Datei importieren" (auch im leeren Abos-Tab). Datei auswählen
  (Castbox → Einstellungen → OPML exportieren), bestätigen, Fortschritt „x von n", Ergebnis „Neu / Bereits vorhanden / Fehlgeschlagen" + Namen.
- Alle `outline`-Elemente mit `xmlUrl` werden gelesen, auch verschachtelte (Castbox legt einen Ordner „feeds" an). Doppelte URLs werden entfernt.
- 4 Feeds werden parallel abonniert. Vorhandene Abos werden übersprungen.
- Dateiauswahl mit `FileType.any` (Android kennt keinen MIME-Typ für `.opml`); max. 5 MB.
- Nach dem Einlesen wird die temporäre Kopie des Datei-Pickers gelöscht (`FilePicker.clearTemporaryFiles`).
- Export (M7): OPML 2.0, über Teilen-Dialog.
