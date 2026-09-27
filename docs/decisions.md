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
