#!/usr/bin/env bash

LOW_BAT=20
SAFE_BAT=25

while true; do
  CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity)
  STATUS=$(cat /sys/class/power_supply/BAT1/status)

  if [ "$STATUS" == "Discharging" ] && [ "$CAPACITY" -le "$LOW_BAT" ]; then
    powerprofilesctl set power-saver
    brightnessctl set 10%
    notify-send "Eco-Mode" "Bateria em $CAPACITY%. Brilho reduzido." # FIX: Alerta repetindo com o loop

  elif [ "$STATUS" == "Charging" ] || [ "$CAPACITY" -gt "$SAFE_BAT" ]; then
    CURRENT=$(powerprofilesctl get)
    if [ "$CURRENT" == "power-saver" ]; then
      powerprofilesctl set balanced
      brightnessctl set 50%
      notify-send "Power-Mode" "Carregando ou bateria segura. Perfil Equilibrado."
    fi
  fi
  sleep 30
done
