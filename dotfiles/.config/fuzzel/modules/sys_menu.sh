#!/usr/bin/env bash
MENU="Lock\0icon\x1fsystem-lock-screen
Logout\0icon\x1fsystem-log-out
Reboot\0icon\x1fsystem-reboot
Shutdown\0icon\x1fsystem-shutdown"

sel=$(echo -e "$MENU" | fuzzel --dmenu --placeholder "Sistema" | tr '[:upper:]' '[:lower:]')

case "$sel" in
    lock) hyprlock ;;
    logout) hyprctl dispatch exit ;;
    reboot) systemctl reboot ;;
    shutdown) systemctl poweroff ;;
esac
