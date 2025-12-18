#!/bin/bash
# ┌────────────────────────────────────────────┐
# │             SCREENSHOT - AREA              │
# └────────────────────────────────────────────┘
# [INFO] Captures a screen area and passes the result to the action menu.

# --- Main Logic ---
# [INFO] 1. Call the capture engine to get a temporary file path.
TMP_FILE=$(~/.local/bin/screenshots/_capture.sh)

# [INFO] 2. If a file was created, pass it to the action menu.
if [ -n "$TMP_FILE" ]; then
  ~/.local/bin/screenshots/action_menu.sh "$TMP_FILE"
fi
