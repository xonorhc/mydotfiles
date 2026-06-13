#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

for f in *.*; do
  dt=$(stat -c %w "$f")
  if [[ "$dt" == "-" ]]; then
    dt=$(stat -c %y "$f")
  fi
  dt=$(echo "$dt" | cut -d' ' -f1 | tr -d '-')
  mv "$f" "${dt}_$f"
done
