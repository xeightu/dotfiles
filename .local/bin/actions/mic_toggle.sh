#!/bin/bash

# Выполняем ВАШУ команду для переключения мута микрофона
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Проверяем состояние ПОСЛЕ переключения
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
  # Если микрофон выключен
  dunstify -a "toggle-mic" -u low -i "microphone-sensitivity-muted" "Microphone: OFF"
else
  # Если микрофон включен
  dunstify -a "toggle-mic" -u low -i "microphone-sensitivity-high" "Microphone: ON"
fi
