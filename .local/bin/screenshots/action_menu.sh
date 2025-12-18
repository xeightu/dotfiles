#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │            SCREENSHOT - ACTION MENU              │
# └──────────────────────────────────────────────────┘
# [INFO] This script receives a path to a temporary screenshot file
# [INFO] and presents a Wofi menu to decide its fate.

# --- Configuration ---
# [CONFIG] The base directory for all saved screenshots.
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# --- Initialization ---
# [INFO] Automatically create a sorted directory for the current month (YYYY-MM).
SORTED_DIR="$SCREENSHOT_DIR/$(date +'%Y-%m')"
mkdir -p "$SORTED_DIR"

# [INFO] Get the temporary file path from the first script argument.
TMP_FILE="$1"

# [FIX] If the file doesn't exist (e.g., capture was cancelled), exit.
if [ ! -f "$TMP_FILE" ]; then
  exit 1
fi

# --- Main Logic ---
# [INFO] Define menu options with Nerd Font icons.
options=" Copy\n Edit\n Save\n Delete"

# [CONFIG] Wofi command with correct styling and size.
wofi_command="wofi --show dmenu --prompt=Action --width 180 --height 160"

# [INFO] Display the Wofi menu and capture the user's choice.
CHOICE=$(echo -e "$options" | ${wofi_command})

case "$CHOICE" in
" Copy")
  wl-copy --type image/png <"$TMP_FILE"
  rm "$TMP_FILE"
  notify-send "Screenshot Copied" "Temporary file deleted."
  ;;
" Edit")
  swappy -f "$TMP_FILE"
  ;;
" Save")
  FILENAME="$(date +'%Y-%m-%d_%H-%M-%S').png"
  mv "$TMP_FILE" "$SORTED_DIR/$FILENAME"
  notify-send "Screenshot Saved" "Path: $SORTED_DIR/$FILENAME"
  ;;
" Delete")
  rm "$TMP_FILE"
  notify-send "Screenshot Deleted"
  ;;
*)
  rm "$TMP_FILE"
  ;;
esac
