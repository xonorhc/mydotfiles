#!/usr/bin/env bash

set -euo pipefail

bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
for ((i = 0; i < ${#bar}; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

config_file="$(mktemp)"
trap 'rm -f "$config_file"' EXIT

cat >"$config_file" <<EOF
[general]
framerate = 30
bars = 10

[input]
method = pulse

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

cava -p "$config_file" | while read -r line; do
  if playerctl status 2>/dev/null | grep -q "Playing"; then
    echo "$line" | sed "$dict"
  else
    echo ""
  fi
done
