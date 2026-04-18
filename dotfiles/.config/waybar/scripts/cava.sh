#!/usr/bin/env bash

set -euo pipefail

# --- NOVO: Captura de sinais para limpeza ---
cleanup() {
    # Mata todos os processos filhos (o cava e o loop)
    pkill -P $$ 2>/dev/null || true
    rm -f "$config_file"
    exit 0
}

# Trap para SIGINT (Ctrl+C), SIGTERM (Waybar fechando) e EXIT
trap cleanup SIGINT SIGTERM EXIT
# --------------------------------------------

bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
for ((i = 0; i < ${#bar}; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

config_file="$(mktemp)"

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

# Use exec ou capture o PID do cava para controle total
cava -p "$config_file" | while read -r line; do
  if playerctl status 2>/dev/null | grep -q "Playing"; then
    echo "$line" | sed "$dict"
  else
    echo " "
    sleep 1
  fi
done
