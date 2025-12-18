#!/bin/bash

# ┌─── Left Mouse Autoclicker ─────────────────────────────────────────────────┐
# │ High-speed spam for the primary mouse button (Code 272).                   │
# └────────────────────────────────────────────────────────────────────────────┘

# --- Configuration ---

# [CONFIG] Lock file matching the script name
PID_FILE="/tmp/clicker_left.pid"

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$PID_FILE" ]; then

  # --- Termination Sequence ---

  kill "$(cat "$PID_FILE")"
  rm "$PID_FILE"

  notify-send "L-Click: OFF" \
    -i "process-stop" \
    -t 500

else

  # --- Initialization Sequence ---

  notify-send "L-Click: ON" \
    -i "input-mouse" \
    -t 500

  # [INFO] Start background loop with self-cleanup trap
  (
    trap 'rm -f $PID_FILE' EXIT

    while true; do
      ydotool key 272:1 272:0 # Left Mouse Button
      sleep 0.01              # ~100 clicks/sec
    done
  ) &

  # [INFO] Save PID of the background process
  echo $! >"$PID_FILE"

fi
