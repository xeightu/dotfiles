#!/bin/bash

STATE_FILE="/tmp/waybar_clock_state"

# Если файла состояния нет, создаем его со значением "time"
if [ ! -f "$STATE_FILE" ]; then
  echo "time" >"$STATE_FILE"
fi

# Читаем текущее состояние
CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" = "time" ]; then
  # Показываем время
  # ★★★ ИСПРАВЛЕНИЕ ЗДЕСЬ ★★★
  TIME_TEXT=$(date +" %H:%M":%S)
  TOOLTIP_TEXT=$(date +"%A, %d %B %Y")
  printf '{"text": "%s", "tooltip": "<big>%s</big>"}\n' "$TIME_TEXT" "$TOOLTIP_TEXT"
else
  # Показываем дату
  # ★★★ ИСПРАВЛЕНИЕ ЗДЕСЬ ★★★
  DATE_TEXT=$(date +" %d.%m.%Y")
  TOOLTIP_TEXT=$(date +"%A, %d %B %Y")
  printf '{"text": "%s", "tooltip": "<big>%s</big>"}\n' "$DATE_TEXT" "$TOOLTIP_TEXT"
fi
