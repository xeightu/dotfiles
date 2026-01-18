#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │ HYPRLAND INPUT LAYOUT PARSER                                               │
# └────────────────────────────────────────────────────────────────────────────┘

# [INFO] Extracts the active keymap of the main keyboard.
# [LOGIC] English (US) -> EN | Russian -> RU | Ukrainian -> UK

hyprctl devices -j |
  jq -r '.keyboards[] | select(.main == true) | .active_keymap' |
  head -n 1 |
  cut -c 1-2 |
  tr '[:lower:]' '[:upper:]'
