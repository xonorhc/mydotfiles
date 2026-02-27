#!/usr/bin/env bash

BASE_DIR="${1:-$HOME}"

SELECTED=$(fd --type f --hidden --follow --exclude .git . "$BASE_DIR" \
    | fuzzel --dmenu --prompt "Open: ")

if [ -n "$SELECTED" ]; then
    DIR=$(dirname "$SELECTED")
    FILE=$(basename "$SELECTED")
    kitty -e bash -c "cd \"$DIR\" && nvim \"$FILE\"" &
fi
