#!/bin/bash

# ┌─── Keyboard Alpha-Batch ───────────────────────────────────────────────────┐
# │ Target: A-Z Keys Only.                                                     │
# │ Speed: ~1300 CPM (Chars Per Minute) depending on sleep.                    │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─── Configuration & State ──────────────────────────────────────────────────┐

PID_FILE="/tmp/clicker_keyboard.pid"
SLEEP_TIME="0.02" # [CONFIG] Tick rate (0.02s = 50Hz)

# ┌─── Payload Generator ──────────────────────────────────────────────────────┐

# [INFO] Generates command string for QWERTY rows.
# Row 1: Q-P (16-25) | Row 2: A-L (30-38) | Row 3: Z-M (44-50)
generate_alpha_payload() {
  local keys=""

  for code in {16..25} {30..38} {44..50}; do
    keys+="$code:1 $code:0 "
  done

  echo "$keys"
}

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then

  # --- Stop Sequence ---

  kill "$(cat "$PID_FILE")"
  rm -f "$PID_FILE"

  notify-send "Keyboard: OFF" \
    -u "low" \
    -t 500

else

  # --- Start Sequence ---

  [ -f "$PID_FILE" ] && rm -f "$PID_FILE"

  notify-send "Keyboard: ON (Alpha)" \
    -u "critical" \
    -t 500

  # [OPTIMIZATION] Pre-calculate payload to avoid loop overhead.
  PAYLOAD=$(generate_alpha_payload)

  (
    trap 'rm -f "$PID_FILE"' EXIT

    while true; do
      # shellcheck disable=SC2086
      ydotool key $PAYLOAD
      sleep "$SLEEP_TIME"
    done
  ) &

  echo $! >"$PID_FILE"

fi
