#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 [--dry-run|-n] <directory>"
    exit 1
}

DRY_RUN=false

case "${1:-}" in
    --dry-run|-n)
        DRY_RUN=true
        shift
        ;;
esac

[ $# -eq 1 ] || usage

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a valid directory."
    exit 1
fi

find "$TARGET_DIR" -depth | while IFS= read -r item; do
    dir=$(dirname "$item")
    base=$(basename "$item")

    new_base="${base// /_}"

    if [ "$base" != "$new_base" ]; then
        old_path="$item"
        new_path="$dir/$new_base"

        if $DRY_RUN; then
            echo "[DRY-RUN] $old_path -> $new_path"
        else
            mv -v -- "$old_path" "$new_path"
        fi
    fi
done
