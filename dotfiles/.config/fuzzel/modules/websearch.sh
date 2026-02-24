#!/usr/bin/env bash

HISTFILE="$HOME/.cache/weblauncher_history"
mkdir -p "$(dirname "$HISTFILE")"
touch "$HISTFILE"

# Mostra histórico + permite digitar novo
query=$(cat "$HISTFILE" | tac |
  fuzzel --dmenu --lines 5 --placeholder "Search, URL, aw, aur, pkg, man, !g, !gh, !yt") || exit 0

[ -z "$query" ] && exit 0

# Salva no histórico (evita duplicata consecutiva)
grep -qxF "$query" "$HISTFILE" || echo "$query" >>"$HISTFILE"

# Trim
query="$(echo "$query" | xargs)"

urlencode() {
  python3 - <<EOF
import urllib.parse
print(urllib.parse.quote_plus("$1"))
EOF
}

encoded=$(urlencode "$query")

# ----------------------------
# 🔎 URL DETECTION
# ----------------------------

if [[ "$query" =~ ^https?:// ]]; then
  url="$query"

elif [[ "$query" =~ ^(localhost|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)(:[0-9]+)?(/.*)?$ ]]; then
  url="http://$query"

elif [[ "$query" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
  url="https://$query"

# ----------------------------
# 🧠 SHORTCUTS
# ----------------------------

elif [[ "$query" =~ ^aw\  ]]; then
  term="${query#aw }"
  url="https://wiki.archlinux.org/?search=$(urlencode "$term")"

elif [[ "$query" =~ ^aur\  ]]; then
  term="${query#aur }"
  url="https://aur.archlinux.org/packages?O=0&K=$(urlencode "$term")"

elif [[ "$query" =~ ^pkg\  ]]; then
  term="${query#pkg }"
  alacritty -e bash -c "pacman -Ss \"$term\"; echo; read -p 'Press enter to close...'" &
  exit 0

elif [[ "$query" =~ ^man\  ]]; then
  term="${query#man }"
  url="https://man.archlinux.org/search?q=$(urlencode "$term")"

elif [[ "$query" =~ ^!gh\  ]]; then
  term="${query#!gh }"
  url="https://github.com/search?q=$(urlencode "$term")"

elif [[ "$query" =~ ^!g\  ]]; then
  term="${query#!g }"
  url="https://www.google.com/search?q=$(urlencode "$term")"

elif [[ "$query" =~ ^!yt\  ]]; then
  term="${query#!yt }"
  url="https://www.youtube.com/results?search_query=$(urlencode "$term")"

# ----------------------------
# 🌐 DEFAULT
# ----------------------------

else
  url="https://duckduckgo.com/?q=$encoded"
fi

app.zen_browser.zen "$url"
