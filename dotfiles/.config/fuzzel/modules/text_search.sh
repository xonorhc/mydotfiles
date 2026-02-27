#!/usr/bin/env bash

BASE_DIR="${1:-$HOME}"

# Pergunta o termo de busca
QUERY=$(fuzzel --dmenu --prompt "Search text: ")

# Se vazio, sai
[ -z "$QUERY" ] && exit 0

# Busca com ripgrep
RESULT=$(rg --line-number --column --no-heading --color=never \
    --smart-case \
    --hidden --follow \
    --glob '!.git/*' \
    --glob '!node_modules/*' \
    --glob '!target/*' \
    "$QUERY" "$BASE_DIR" \
    | fuzzel --dmenu --prompt "Results: ")

# Se nada selecionado, sai
[ -z "$RESULT" ] && exit 0

# Extrai arquivo, linha e coluna
FILE=$(echo "$RESULT" | cut -d: -f1)
LINE=$(echo "$RESULT" | cut -d: -f2)
COL=$(echo "$RESULT" | cut -d: -f3)

# Abre no Neovim na posição correta
foot -e nvim +"call cursor($LINE, $COL)" "$FILE" &
