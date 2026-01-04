#!/bin/bash

STATE_FILE="/tmp/waybar_clock_state"

# Читаем текущее состояние
CURRENT_STATE=$(cat "$STATE_FILE")

# Переключаем состояние
if [ "$CURRENT_STATE" = "time" ]; then
  echo "date" >"$STATE_FILE"
else
  echo "time" >"$STATE_FILE"
fi

# Отправляем сигнал Waybar для обновления кастомных модулей
# (сигнал 10 - стандартный для пользовательских обновлений)
pkill -RTMIN+10 waybar
