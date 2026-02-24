#!/usr/bin/env bash

TERMINAL="kitty"

# 1️⃣ Listar todos os serviços do usuário
# Usando list-unit-files para pegar todos (enabled/disabled/oneshot)
# Pipe direto para Fuzzel para evitar problemas de linhas
service=$(systemctl --user list-unit-files --type=service --no-pager 2>/dev/null \
    | awk 'NR>1 {print $1}' \
    | fuzzel --dmenu --prompt "Selecione o serviço:" ) || exit 0

[ -z "$service" ] && exit 0

# 2️⃣ Escolher ação
action=$(echo -e "Start\nStop\nReload\nStatus" \
    | fuzzel --dmenu --prompt "Escolha ação para $service:") || exit 0

[ -z "$action" ] && exit 0

# 3️⃣ Executar a ação
# Converte para minúscula
action=$(echo "$action" | tr '[:upper:]' '[:lower:]')

$TERMINAL -e bash -c "systemctl --user $action $service; exec bash"
