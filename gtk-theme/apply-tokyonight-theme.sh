#!/usr/bin/env bash
# Installs and applies the Tokyonight-Purple-Dark GTK theme
# (https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme) for GTK3,
# GTK4/libadwaita, window manager chrome, and the GNOME Shell top panel
# (via the "User Themes" extension).
#
# Safe to re-run: re-clones/pulls the upstream repo and re-runs its
# installer, which is itself idempotent.
set -euo pipefail

THEME_NAME="Tokyonight-Purple-Dark"
THEME_REPO="https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git"
SRC_DIR="$HOME/.cache/tokyonight-gtk-theme-src"
USER_THEME_UUID="user-theme@gnome-shell-extensions.gcampax.github.com"

if ! command -v gsettings >/dev/null 2>&1; then
    echo "gsettings not found. This script must be run in a GNOME session." >&2
    exit 1
fi

if command -v apt >/dev/null 2>&1; then
    sudo apt install -y gtk2-engines-murrine gnome-themes-extra sassc gnome-tweaks gnome-shell-extension-user-theme
else
    echo "Non-apt system detected - install gtk-engine-murrine (or distro equivalent)," >&2
    echo "gnome-themes-extra, sassc, and a GNOME Shell 'User Themes' extension package" >&2
    echo "manually, then re-run this script." >&2
fi

if [ -d "$SRC_DIR/.git" ]; then
    git -C "$SRC_DIR" pull --ff-only
else
    git clone "$THEME_REPO" "$SRC_DIR"
fi

(cd "$SRC_DIR/themes" && ./install.sh -n "$THEME_NAME" -t purple -c dark -l)

gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.wm.preferences theme "$THEME_NAME"

if gnome-extensions list 2>/dev/null | grep -qF "$USER_THEME_UUID"; then
    gnome-extensions enable "$USER_THEME_UUID" 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME"
    echo "Done. '$THEME_NAME' applied for GTK3/GTK4, window chrome, and the Shell panel."
else
    gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME"
    echo "Done. '$THEME_NAME' applied for GTK3/GTK4 and window chrome."
    echo "The 'User Themes' extension isn't visible to the running Shell yet (newly"
    echo "installed system extensions need a Shell reload: Alt+F2, r, Enter on X11;"
    echo "log out/in on Wayland). After that, enable it and re-run this script, or run:"
    echo "  gnome-extensions enable $USER_THEME_UUID"
fi
