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

if UUID=$(find_existing_uuid); then
    echo "Updating existing '$PROFILE_NAME' profile ($UUID)..."
else
    UUID=$(uuidgen)
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
dconf write "${PROFILE_PATH}use-system-font" "false"
dconf write "${PROFILE_PATH}font" "'${FONT}'"
dconf write "${PROFILE_PATH}audible-bell" "false"
dconf write "${PROFILE_PATH}default-size-columns" "120"
dconf write "${PROFILE_PATH}default-size-rows" "32"

gsettings set org.gnome.Terminal.ProfilesList default "$UUID"

echo "Done. '$PROFILE_NAME' is now the default GNOME Terminal profile."
echo "Open a new terminal window/tab to see it."
