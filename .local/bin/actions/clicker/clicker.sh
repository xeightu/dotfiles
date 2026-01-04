#!/bin/bash

# ┌─── Master Autoclicker Controller ──────────────────────────────────────────┐
# │ Orchestrates all sub-clickers.                                             │
# └────────────────────────────────────────────────────────────────────────────┘

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTER_PID="/tmp/clicker_master.pid"

# [CONFIG] Targets (Type -> Script Args)
# Now we call the same script with different args
declare -A TARGETS=(
  ["left"]="mouse.sh left"
  ["right"]="mouse.sh right"
  ["middle"]="mouse.sh middle"
  ["keyboard"]="keyboard.sh"
)

# ┌─── Helper: Kill Child ─────────────────────────────────────────────────────┐
kill_child() {
  local type="$1"
  local pid_file="/tmp/clicker_${type}.pid"

  if [ -f "$pid_file" ]; then
    local pid
    pid=$(cat "$pid_file")
    # Check if process exists before killing
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
    fi
    rm -f "$pid_file"
  fi
}

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$MASTER_PID" ]; then

  # --- Global OFF ---

  for type in "${!TARGETS[@]}"; do
    kill_child "$type"
  done

  rm -f "$MASTER_PID"
  notify-send "Master Clicker: OFF" -i "process-stop" -u "critical" -t 1000

else

  # --- Global ON ---

  notify-send "Master Clicker: ALL ON" -i "weather-storm" -u "critical" -t 1000

  # Clean stale locks first
  for type in "${!TARGETS[@]}"; do
    kill_child "$type"
  done

  # Launch everything
  for args in "${TARGETS[@]}"; do
    # Split script name and args
    read -r script arg <<<"$args"
    "$SCRIPT_DIR/$script" $arg >/dev/null 2>&1 &
  done

  touch "$MASTER_PID"

fi
