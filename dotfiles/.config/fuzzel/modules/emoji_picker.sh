#!/usr/bin/env bash

CACHE="$HOME/.cache/emoji-list.txt"
HISTORY="$HOME/.cache/emoji-history.txt"
URL="https://unicode.org/Public/emoji/latest/emoji-test.txt"

mkdir -p "$HOME/.cache"

# ==============================
# 1️⃣ Gera lista base (se necessário)
# ==============================
if [ ! -s "$CACHE" ]; then
    curl -Ls "$URL" \
        | grep -v '^#' \
        | grep '; fully-qualified' \
        | awk -F'#' '{print $2}' \
        | sed 's/^ *//' \
        > "$CACHE"
fi

# ==============================
# 2️⃣ Junta histórico + lista
# Histórico aparece primeiro
# ==============================
if [ -f "$HISTORY" ]; then
    LIST=$( (cat "$HISTORY"; cat "$CACHE") | awk '!seen[$0]++' )
else
    LIST=$(cat "$CACHE")
fi

# ==============================
# 3️⃣ Seleção no Fuzzel
# ==============================
SELECTED=$(echo "$LIST" | \
    fuzzel --dmenu \
           --prompt "Emoji   " \
           --lines 15)

[ -z "$SELECTED" ] && exit 0

EMOJI=$(echo "$SELECTED" | awk '{print $1}')

# ==============================
# 4️⃣ Copia + salva histórico
# ==============================
printf "%s" "$EMOJI" | wl-copy
echo "$SELECTED" >> "$HISTORY"

notify-send "Emoji copiado" "$EMOJI"
