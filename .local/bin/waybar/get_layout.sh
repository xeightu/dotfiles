#!/bin/bash

# ┌──────────────────────────────────────────────────┐
# │               Keyboard Layout Script             │
# └──────────────────────────────────────────────────┘
# [INFO] This script gets the current active keyboard layout from Hyprland
# [INFO] and formats it into a short code (e.g., "EN", "RU") for Waybar.

hyprctl -j devices |
  jq -r '.keyboards[] | select(.main == true) | .active_keymap' |
  awk '{print $1}' |
  sed 's/English/EN/' |
  sed 's/Russian/RU/'
