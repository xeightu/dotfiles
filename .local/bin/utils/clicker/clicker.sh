#!/bin/bash

# ┌─── Master Autoclicker Controller ──────────────────────────────────────────┐
# │ Orchestrates Left, Right, Middle, and Keyboard clickers simultaneously.    │
# └────────────────────────────────────────────────────────────────────────────┘

# --- Configuration ---

# [CONFIG] Resolve script directory relative to this file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# [CONFIG] Path to the master lock file
PID_FILE="/tmp/clicker.pid"

# [CONFIG] List of subordinate scripts to manage
SCRIPTS=(
  "left.sh"
  "right.sh"
  "middle.sh"
  "keyboard.sh"
)

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$PID_FILE" ]; then

  # --- Termination Sequence ---

  # [INFO] Kill specific PIDs.
  for script in "${SCRIPTS[@]}"; do
    # Convert "left.sh" -> "clicker_left.pid"
    name="${script%.sh}"
    child_pid="/tmp/clicker_${name}.pid"

    if [ -f "$child_pid" ]; then
      kill "$(cat "$child_pid")" 2>/dev/null
      rm -f "$child_pid"
    fi
  done

  # [INFO] Remove master lock and notify
  rm "$PID_FILE"

  notify-send "Master Clicker: OFF" \
    -i "process-stop" \
    -u "critical" \
    -t 1000

else

  # --- Initialization Sequence ---

  notify-send "Master Clicker: ON" \
    -i "weather-storm" \
    -u "critical" \
    -t 1000

  # [INFO] Launch all scripts in background, suppressing output
  for script in "${SCRIPTS[@]}"; do
    "$SCRIPT_DIR/$script" >/dev/null 2>&1 &
  done

  # [INFO] Create master lock file
  touch "$PID_FILE"

fi
