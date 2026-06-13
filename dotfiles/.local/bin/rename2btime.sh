#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

file="$1"

birth=$(stat -c %w "$file")

if [[ "$birth" == "-" ]]; then
  # fallback para mtime
  date_str=$(stat -c %y "$file" | cut -d' ' -f1 | tr -d '-')
else
  date_str=$(echo "$birth" | cut -d' ' -f1 | tr -d '-')
fi

mv "$file" "${date_str}_$file"
