#!/usr/bin/env bash
# Creates (or updates) a "Tokyo Night" GNOME Terminal profile from the same
# palette used in rofi/tokyo-neon.rasi, and sets it as the default profile.
#
# Safe to re-run: if a profile named "Tokyo Night" already exists, its
# settings are updated in place instead of creating a duplicate.
set -euo pipefail

PROFILE_NAME="Tokyo Night"
FONT="JetBrainsMono Nerd Font 11"

if ! command -v gsettings >/dev/null 2>&1 || ! command -v dconf >/dev/null 2>&1; then
    echo "gsettings/dconf not found. This script must be run in a GNOME session." >&2
    exit 1
fi

if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font\|JetBrains Mono Nerd Font"; then
    echo "Warning: JetBrainsMono Nerd Font not found. Starship icons may not render correctly." >&2
    echo "Falling back to JetBrains Mono (no icon glyphs)." >&2
    FONT="JetBrains Mono 11"
fi

LIST_PATH="/org/gnome/terminal/legacy/profiles:/"
find_existing_uuid() {
    local uuid
    for uuid in $(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "[]'," ); do
        local name
        name=$(dconf read "${LIST_PATH}:${uuid}/visible-name" 2>/dev/null | tr -d "'")
        if [ "$name" = "$PROFILE_NAME" ]; then
            echo "$uuid"
            return 0
        fi
    done
    return 1
}

gen_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
    elif [ -r /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import uuid; print(uuid.uuid4())'
    else
        od -An -N16 -tx1 /dev/urandom | tr -d ' \n' | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/'
    fi
}

if UUID=$(find_existing_uuid); then
    echo "Updating existing '$PROFILE_NAME' profile ($UUID)..."
else
    UUID=$(gen_uuid)
    echo "Creating new '$PROFILE_NAME' profile ($UUID)..."
    CURRENT_LIST=$(gsettings get org.gnome.Terminal.ProfilesList list)
    if [ "$CURRENT_LIST" = "@as []" ] || [ "$CURRENT_LIST" = "[]" ]; then
        NEW_LIST="['$UUID']"
    else
        NEW_LIST=$(echo "$CURRENT_LIST" | sed "s/\]$/, '$UUID']/")
    fi
    gsettings set org.gnome.Terminal.ProfilesList list "$NEW_LIST"
fi

PROFILE_PATH="${LIST_PATH}:${UUID}/"

dconf write "${PROFILE_PATH}visible-name" "'${PROFILE_NAME}'"
dconf write "${PROFILE_PATH}use-theme-colors" "false"
dconf write "${PROFILE_PATH}background-color" "'#0B1026'"
dconf write "${PROFILE_PATH}foreground-color" "'#C0CAF5'"
dconf write "${PROFILE_PATH}bold-color-same-as-fg" "true"
dconf write "${PROFILE_PATH}palette" "['#15161E', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#A9B1D6', '#414868', '#FF899D', '#9FE044', '#FABA4A', '#8DB0FF', '#C7A9FF', '#A4DAFF', '#C0CAF5']"
dconf write "${PROFILE_PATH}cursor-colors-set" "true"
dconf write "${PROFILE_PATH}cursor-background-color" "'#C0CAF5'"
dconf write "${PROFILE_PATH}cursor-foreground-color" "'#0B1026'"
dconf write "${PROFILE_PATH}cursor-shape" "'block'"
dconf write "${PROFILE_PATH}highlight-colors-set" "true"
dconf write "${PROFILE_PATH}highlight-background-color" "'#565F89'"
dconf write "${PROFILE_PATH}highlight-foreground-color" "'#C0CAF5'"
dconf write "${PROFILE_PATH}use-system-font" "false"
dconf write "${PROFILE_PATH}font" "'${FONT}'"
dconf write "${PROFILE_PATH}audible-bell" "false"
dconf write "${PROFILE_PATH}default-size-columns" "120"
dconf write "${PROFILE_PATH}default-size-rows" "32"

gsettings set org.gnome.Terminal.ProfilesList default "$UUID"

# The profile's palette only covers the terminal content area - the
# headerbar/title bar is GTK window chrome and follows the GTK theme
# instead. Force it dark, then override its color with scoped CSS so it
# matches the Tokyo Night body instead of the default Adwaita gray/black.
if gsettings list-keys org.gnome.Terminal.Legacy.Settings 2>/dev/null | grep -q '^theme-variant$'; then
    gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
fi

GTK_CSS="$HOME/.config/gtk-3.0/gtk.css"
MARK_BEGIN="/* BEGIN tokyo-night-terminal (managed by tokyo-night-apply.sh) */"
MARK_END="/* END tokyo-night-terminal */"

mkdir -p "$(dirname "$GTK_CSS")"
touch "$GTK_CSS"
if grep -qF "$MARK_BEGIN" "$GTK_CSS"; then
    awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
        $0==b {skip=1}
        skip && $0==e {skip=0; next}
        !skip {print}
    ' "$GTK_CSS" > "${GTK_CSS}.tmp"
    mv "${GTK_CSS}.tmp" "$GTK_CSS"
fi

cat >> "$GTK_CSS" <<CSS
$MARK_BEGIN
headerbar.titlebar {
    background-color: #0b1026;
    background-image: none;
    color: #c0caf5;
    box-shadow: none;
}
headerbar.titlebar button {
    background-color: transparent;
    background-image: none;
    border-color: transparent;
    box-shadow: none;
    color: #c0caf5;
}
header.top {
    background-color: #0b1026;
    background-image: none;
    box-shadow: none;
}
$MARK_END
CSS

echo "Done. '$PROFILE_NAME' is now the default GNOME Terminal profile."
echo "Fully quit GNOME Terminal (not just close the window - all windows/processes) and reopen it for the headerbar CSS to take effect."
