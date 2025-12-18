#!/bin/bash

# ┌─── Middle Mouse Autoclicker ───────────────────────────────────────────────┐
# │ Spam for the scroll wheel button (Code 274).                               │
# └────────────────────────────────────────────────────────────────────────────┘

# --- Configuration ---

# [CONFIG] Lock file matching the script name
PID_FILE="/tmp/clicker_middle.pid"

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$PID_FILE" ]; then

  # --- Termination Sequence ---

  kill "$(cat "$PID_FILE")"
  rm "$PID_FILE"

  notify-send "M-Click: OFF" \
    -i "process-stop" \
    -t 500

else

  # --- Initialization Sequence ---

  notify-send "M-Click: ON" \
    -i "input-mouse" \
    -t 500

  # [INFO] Start background loop with self-cleanup trap
  (
    trap 'rm -f $PID_FILE' EXIT

    while true; do
      ydotool key 274:1 274:0 # Middle Mouse Button
      sleep 0.01              # ~100 clicks/sec
    done
  ) &

  # [INFO] Save PID of the background process
  echo $! >"$PID_FILE"

fi
