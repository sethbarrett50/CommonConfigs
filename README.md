# CommonConfigs

Personal config files, kept in sync across machines via one repo and one install script.

## Quick start

```bash
git clone https://github.com/sethbarrett50/CommonConfigs.git
cd CommonConfigs
./install.sh
```

`install.sh` symlinks everything listed below into place, backing up any real
pre-existing file to `~/.config-backup/<timestamp>/` first. Safe to re-run.

A few things need a manual step afterward — see [Not automated](#not-automated).

## What's in here

| Path | Tool | Linked to |
|---|---|---|
| `bash/.bashrc`, `bash/.bash_aliases` | Bash | `~/.bashrc`, `~/.bash_aliases` |
| `starship/starship.toml` | [Starship](https://starship.rs) prompt, Tokyo Night themed | `~/.config/starship.toml` |
| `gnome-terminal/tokyo-night-apply.sh` | GNOME Terminal | run directly (see below) |
| `i3/config` | i3 window manager | `~/.config/i3/config` |
| `picom/picom.conf` | Picom compositor | `~/.config/picom/picom.conf` |
| `rofi/config.rasi`, `rofi/tokyo-neon.rasi` | Rofi launcher, Tokyo Night themed | `~/.config/rofi/` |
| `mpd/mpd.conf` | Music Player Daemon | `~/.config/mpd/mpd.conf` |
| `ncmpcpp/config` | ncmpcpp (mpd client) | `~/.config/ncmpcpp/config` |
| `vscode/settings.json` | VS Code, global user settings | `settings.json` |
| `vscode/linux/settings.json.linux`, `vscode/mac/settings.json.mac` | VS Code, LaTeX project settings | manual, see below |
| `continue/*` | [Continue](https://continue.dev) VS Code extension | manual, see below |
| `make/Makefile.*` | Per-project Makefile templates | manual, copy into a project |
| `wallpapers/` | Desktop wallpapers | manual, set via your DE |
| `gtk-theme/apply-tokyonight-theme.sh` | GTK3/GTK4/GNOME Shell theme | run directly (see below) |

### Terminal theme

Both the GNOME Terminal profile and the Starship prompt use the same Tokyo
Night palette as the Rofi theme, so terminal/launcher/prompt all look like
one system.

```bash
bash gnome-terminal/tokyo-night-apply.sh   # creates/updates a "Tokyo Night" profile, sets it default
./install.sh                                # links starship.toml (included in the full install)
```

`tokyo-night-apply.sh` is idempotent — re-run it any time to pick up palette
changes. It needs `JetBrainsMono Nerd Font` for the prompt's icons; without
it, it falls back to plain `JetBrains Mono`.

### System-wide GTK/Shell theme

`gtk-theme/apply-tokyonight-theme.sh` installs and applies
[Tokyonight-GTK-Theme](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme)
(purple accent, dark variant) system-wide — GTK3, GTK4/libadwaita apps, window
chrome, and the GNOME Shell top panel (via the "User Themes" extension). This
is what actually colors app title bars/menus/dialogs outside the terminal;
`gnome-terminal/tokyo-night-apply.sh`'s `gtk.css` block only targets the
terminal specifically and still applies on top (it's at user priority, so it
always wins over whatever this theme does for those same elements).

```bash
bash gtk-theme/apply-tokyonight-theme.sh
```

Installs packages via `apt` (needs `sudo`), clones the upstream theme repo to
`~/.cache/tokyonight-gtk-theme-src`, and re-running just re-pulls/re-applies.
If the Shell panel doesn't pick up the theme on the first run, the "User
Themes" extension was likely just installed and the running Shell hasn't
rescanned for it yet — reload the Shell (`Alt+F2`, `r`, Enter on X11; log out
and back in on Wayland) and re-run the script.

### Not automated

A few configs aren't symlinked by `install.sh` because they need a choice
`install.sh` can't make for you:

- **`continue/`** — two model configs for the [Continue](https://continue.dev)
  VS Code extension, both pointed at a local Ollama instance: `config.safe.yaml`
  (Qwen Coder, chat/edit only) and `config.agent.yaml` (Devstral, adds tool
  use). Copy whichever one fits to `~/.continue/config.yaml`. The `*_rules/`
  directories are Continue's custom instruction files (global style, Python,
  Svelte) — copy the ones you want into `~/.continue/rules/`.
- **`make/Makefile.*`** — per-project build file templates (LaTeX, Python,
  Svelte, generic shell). Copy the relevant one into a project as `Makefile`.
- **`vscode/linux/settings.json.linux`, `vscode/mac/settings.json.mac`** —
  LaTeX-Workshop *workspace* settings (not global), pointed at the matching
  OS's toolchain paths, meant to pair with `make/Makefile.latex`. Copy the
  OS-appropriate one into a LaTeX project as `.vscode/settings.json`.
- **`wallpapers/`** — set through whatever your desktop environment uses
  (e.g. `nitrogen`, `feh`, or GNOME Settings).

## Repo conventions

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branching/PR workflow.
