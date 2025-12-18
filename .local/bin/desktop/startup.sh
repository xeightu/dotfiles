#!/bin/bash
# [INFO] This script runs on startup to restore the last session state.

STATE_FILE="$HOME/.config/pyre/state"

if [ -f "$STATE_FILE" ]; then
  last_theme=$(<"$STATE_FILE")
  # [INFO] Call pyre to apply the last theme without showing a menu.
  pyre theme "$last_theme"
fi
