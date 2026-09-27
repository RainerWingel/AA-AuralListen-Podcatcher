# Git-Workflow

## Repository
- GitHub: `RainerWingel/aa-podcast-guru` (**öffentlich**).
- Remote per SSH-Host-Alias: `git@github.com-home:RainerWingel/aa-podcast-guru.git`
  (`~/.ssh/config` → `github.com-home` nutzt `~/.ssh/id_ed25519_home`).
- Commit-Identität (repo-lokal): `RainerWingel <156608819+RainerWingel@users.noreply.github.com>` –
  **keine** echten Namen/E-Mail-Adressen in Commits.
- Weil das Repo öffentlich ist: vor jedem Commit prüfen, dass keine Secrets, Keystores, persönlichen Daten
  oder `ssh-temp/` enthalten sind (`git status`, `git diff --cached`).

## Branches
- `main` ist immer lauffähig, CI grün.
- Arbeit auf `feature/<kurz>`, `fix/<kurz>`, `chore/<kurz>`, `docs/<kurz>`.
- Ein Meilenstein bzw. eine abgeschlossene Aufgabe = ein Pull Request.
- Der Agent merged seinen PR selbst, sobald die CI grün ist: `gh pr merge <n> --merge --delete-branch`
  (GitHub-Auto-Merge ist im Repo nicht aktiviert).

## Commits
- Conventional Commits auf Englisch: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `ci:`.
- Klein und in sich abgeschlossen; Doku-Änderungen im selben Commit wie der zugehörige Code.

## Übergabe zwischen Agenten (Claude ⇄ ChatGPT)
1. Arbeit committen und pushen – nie mit uncommitteten Änderungen aufhören.
2. In `docs/roadmap.md` abhaken, was erledigt ist; Offenes als Checkbox eintragen.
3. Neue Entscheidungen in `docs/decisions.md`.
4. Der nächste Agent startet mit `git pull`, liest `AGENTS.md` → `docs/roadmap.md` → betroffene Themen.
