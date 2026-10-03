# Contributing

This is a personal dotfiles repo, but it follows a real branch workflow so
`dev` stays in a known-good state and history stays readable.

## Branching

- `main` — stable, what you'd actually `git pull` onto a machine.
- `dev` — integration branch. All work lands here first via PR.
- Everything else is a short-lived feature branch cut **from `dev`**:

  ```
  git checkout dev
  git pull
  git checkout -b feature/<short-description>
  ```

  Use `feature/` for new configs or scripts, `fix/` for bug fixes, `chore/`
  for maintenance (dependency bumps, CI tweaks, etc).

## Pull requests

- Open the PR against **`dev`**, never `main`. `main` only moves when `dev`
  is cut over deliberately.
- Keep PRs scoped to one change (one tool, one script, one doc) — easier to
  review, easier to revert if a config turns out to be wrong.
- Fill in the PR template: what changed, how you tested it (even "ran it on
  machine X" counts — these are configs, not unit-testable libraries most of
  the time), and anything that needs a manual step to take effect.
- Never commit directly to `dev` or `main`.

## CI

PRs run:
- **Gitleaks** secret scanning (`.github/workflows/sec.yml`) — don't bypass
  this; if it flags something, rotate the credential, don't just force-push
  over it.
- **Dependabot** keeps GitHub Actions versions current.

## Secrets

Nothing that looks like a credential (tokens, keys, `.env` files) belongs in
this repo, ever — `.gitignore` already excludes the common patterns. If you
need a machine-specific secret for a tool here, keep it outside the repo and
reference it by path/env var instead.
