#!/usr/bin/env bash

TERMINAL="kitty"

# Detecta gerenciador AUR disponível
if command -v paru >/dev/null 2>&1; then
    AUR_CMD="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_CMD="yay"
else
    AUR_CMD="sudo pacman"
fi

# 1️⃣ Escolher tipo de instalação
install_type=$(echo -e "pacman\nflatpak" | fuzzel --dmenu --prompt "Tipo de pacote:" --lines 2) || exit 0
[ -z "$install_type" ] && exit 0

# 2️⃣ Digitar termo de busca
search_term=$(fuzzel --dmenu --prompt "Buscar app:" --placeholder "Digite nome...") || exit 0
[ -z "$search_term" ] && exit 0

# ===============================
# 3️⃣ Buscar pacotes e formatar lista
# ===============================
declare -a pkgs_list

if [ "$install_type" = "pacman" ]; then
    while IFS= read -r line; do
        pkg_name=$(echo "$line" | awk '{print $1}' | cut -d'/' -f2)
        pkg_desc=$(echo "$line" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}')
        pkgs_list+=("$pkg_name — $pkg_desc")
    done < <(pacman -Ss "$search_term" | grep "^[^ ]")
elif [ "$install_type" = "flatpak" ]; then
    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}')
        desc=$(echo "$line" | cut -d' ' -f2-)
        pkgs_list+=("$name — $desc")
    done < <(flatpak search "$search_term" | tail -n +2)
fi

# 4️⃣ Se nenhum pacote encontrado
if [ ${#pkgs_list[@]} -eq 0 ]; then
    notify-send "Nenhum pacote encontrado para '$search_term'"
    exit 0
fi

# 5️⃣ Selecionar pacote no Fuzzel
selected_line=$(printf "%s\n" "${pkgs_list[@]}" | fuzzel --dmenu --prompt "Selecione o pacote:" --lines 15) || exit 0
[ -z "$selected_line" ] && exit 0

# 6️⃣ Extrair apenas o nome
pkg_name=$(echo "$selected_line" | awk -F ' — ' '{print $1}')

# 7️⃣ Instalar no terminal
if [ "$install_type" = "pacman" ]; then
    $TERMINAL -e bash -c "$AUR_CMD -S $pkg_name"
elif [ "$install_type" = "flatpak" ]; then
    $TERMINAL -e bash -c "flatpak install flathub $pkg_name -y"
fi
