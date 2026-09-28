# Git-Workflow

## Repository
- GitHub: `RainerWingel/aa-podcast-guru` (**öffentlich**).
- Remote per SSH-Host-Alias: `git@github.com-home:RainerWingel/aa-podcast-guru.git`
  (`~/.ssh/config` → `github.com-home` nutzt `~/.ssh/id_ed25519_home`).
- Commit-Identität (repo-lokal): `RainerWingel <156608819+RainerWingel@users.noreply.github.com>` –
  **keine** echten Namen/E-Mail-Adressen in Commits.
- Weil das Repo öffentlich ist: vor jedem Commit prüfen, dass keine Secrets, Keystores, persönlichen Daten
  oder `ssh-temp/` enthalten sind (`git status`, `git diff --cached`).

## Branches (seit 2026-09-28: nur `main`)
- **Alles wird direkt auf `main` committet und gepusht** – keine Feature-Branches, keine Pull Requests
  (Wunsch des Benutzers). Gilt für beide Agenten.
- Deshalb **vor jedem Push** lokal: `dart format .` · `flutter analyze` (0 Probleme) · `flutter test` (alle grün).
  Die CI läuft danach auf `main` als zweite Absicherung; ist sie rot, sofort auf `main` reparieren.
- Vor dem Arbeiten `git pull --ff-only`, damit man auf dem Stand des anderen Agenten aufsetzt.
- Früher (bis PR #31): Branches + PRs mit geprüftem Merge; die Historie bleibt so stehen.

## Commits
- Conventional Commits auf Englisch: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `ci:`.
- Klein und in sich abgeschlossen; Doku-Änderungen im selben Commit wie der zugehörige Code.

## Übergabe zwischen Agenten (Claude ⇄ ChatGPT)
1. Arbeit auf `main` committen und pushen – nie mit uncommitteten Änderungen aufhören.
2. In `docs/roadmap.md` abhaken, was erledigt ist; Offenes als Checkbox eintragen.
3. Neue Entscheidungen in `docs/decisions.md`.
4. Der nächste Agent startet mit `git pull`, liest `AGENTS.md` → `docs/roadmap.md` → betroffene Themen.
