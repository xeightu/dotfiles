#!/bin/bash

# ┌─── High-Performance Mouse Clicker ─────────────────────────────────────────┐
# │ Architecture: Batch execution with Game-Tick synchronization.              │
# └────────────────────────────────────────────────────────────────────────────┘

BUTTON_TYPE="${1:-left}"
PID_FILE="/tmp/clicker_${BUTTON_TYPE}.pid"

# ┌─── Configuration ──────────────────────────────────────────────────────────┐

# [CONFIG] Button Codes
case "$BUTTON_TYPE" in
"left") CODE="272" ;;
"right") CODE="273" ;;
"middle") CODE="274" ;;
*)
  notify-send "Clicker Error" "Unknown button: $1"
  exit 1
  ;;
esac

# [CONFIG] Batch Size & Timing
# - BATCH:  Number of clicks sent per command (20 is safer for games).
# - SLEEP:  Delay to match Game Tick Rate (0.02s ~= 50 ticks/sec).
BATCH_SIZE=20
SLEEP_TIME=0.02

# ┌─── Generator ──────────────────────────────────────────────────────────────┐

# [INFO] Construct argument list.
# 20 clicks = 40 events. Efficient but digestible for game engines.

BURST_CMD=""

for _ in $(seq 1 "$BATCH_SIZE"); do
  BURST_CMD+="$CODE:1 $CODE:0 "
done

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

# [FIX] Check process health
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then

  # --- Stop Sequence ---

  kill "$(cat "$PID_FILE")"
  rm -f "$PID_FILE"

  notify-send "Clicker ($BUTTON_TYPE): OFF" \
    -i "process-stop" \
    -u "low" \
    -t 500

else

  # --- Start Sequence ---

  [ -f "$PID_FILE" ] && rm -f "$PID_FILE"

  notify-send "Clicker ($BUTTON_TYPE): ON" \
    -i "input-mouse" \
    -u "critical" \
    -t 500

  (
    trap 'rm -f "$PID_FILE"' EXIT

    # [CRITICAL] Syntax Fix:
    # Variable must be UNQUOTED ($BURST_CMD) to allow argument splitting.
    while true; do
      # shellcheck disable=SC2086
      ydotool key $BURST_CMD
      sleep "$SLEEP_TIME"
    done
  ) &

  echo $! >"$PID_FILE"

fi
