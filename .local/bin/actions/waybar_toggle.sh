#!/bin/bash

# ┌──────────────────────────────────────────────────┐
# │                   Waybar Toggle                  │
# └──────────────────────────────────────────────────┘
# [INFO] This script toggles the visibility of the Waybar status bar.
# [INFO] It checks if the 'waybar' process is running and either
# [INFO] kills it to hide or launches it to show.

# --- Main Logic ---
# [INFO] 'pgrep -x "waybar"' checks for an exact process name match.
if pgrep -x "waybar" >/dev/null; then
  # [INFO] If the process exists, kill it.
  killall waybar
else
  # [INFO] If the process does not exist, launch it in the background.
  waybar &
fi
