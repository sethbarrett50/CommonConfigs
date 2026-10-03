#!/usr/bin/env bash
# Symlinks this repo's configs into place. Safe to re-run: existing real
# files/dirs are backed up once (not clobbered), existing symlinks from a
# previous run are just re-pointed.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"
BACKED_UP=0

link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        local rel="${dest#"$HOME"/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        mv "$dest" "$BACKUP_DIR/$rel"
        BACKED_UP=1
        echo "Backed up existing $dest -> $BACKUP_DIR/$rel"
    fi

    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

link "$REPO_DIR/bash/.bashrc" "$HOME/.bashrc"
link "$REPO_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
link "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
link "$REPO_DIR/i3/config" "$HOME/.config/i3/config"
link "$REPO_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
link "$REPO_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
link "$REPO_DIR/rofi/tokyo-neon.rasi" "$HOME/.config/rofi/tokyo-neon.rasi"
link "$REPO_DIR/mpd/mpd.conf" "$HOME/.config/mpd/mpd.conf"
link "$REPO_DIR/ncmpcpp/config" "$HOME/.config/ncmpcpp/config"

case "$(uname -s)" in
    Linux*)
        link "$REPO_DIR/vscode/linux/settings.json.linux" "$HOME/.config/Code/User/settings.json"
        if command -v gsettings >/dev/null 2>&1; then
            echo
            echo "GNOME Terminal detected - run this separately to install the Tokyo Night profile:"
            echo "  bash $REPO_DIR/gnome-terminal/tokyo-night-apply.sh"
        fi
        ;;
    Darwin*)
        link "$REPO_DIR/vscode/mac/settings.json.mac" "$HOME/Library/Application Support/Code/User/settings.json"
        ;;
esac

echo
echo "Not symlinked (copy manually, they need per-project/per-mode choices):"
echo "  - continue/*        (pick config.agent.yaml or config.safe.yaml -> ~/.continue/config.yaml)"
echo "  - make/Makefile.*   (per-project build templates)"
echo "  - wallpapers/       (set via your DE's wallpaper tool)"
echo

if [ "$BACKED_UP" -eq 1 ]; then
    echo "Existing files were backed up to $BACKUP_DIR"
else
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

echo "Done."
