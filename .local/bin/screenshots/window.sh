#!/bin/bash
# ┌───────────────────────────────────────────────┐
# │              SCREENSHOT - WINDOW              │
# └───────────────────────────────────────────────┘
# [INFO] This script now captures the active window and pipes it to the action menu.

# --- Initialization ---
# [INFO] Create a unique temporary file path.
TMP_FILE="/tmp/screenshot_window_$(date +'%s').png"

# --- Main Logic ---
# [INFO] 1. Get the active window's geometry.
GEOMETRY=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

# [INFO] 2. Take the screenshot and save it to the temporary file.
grim -g "$GEOMETRY" "$TMP_FILE"

# [INFO] 3. Pass the temporary file to the action menu.
~/.local/bin/screenshots/action_menu.sh "$TMP_FILE"
