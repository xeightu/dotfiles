#!/usr/bin/env bash

# ┌─── 1. Configuration & Constants ───────────────────────────────────────────┐

BTN_TYPE="${1:-left}"
PID_FILE="/tmp/clicker_${BTN_TYPE}.pid"

# [NOTE] 0.02s ≈ 50Hz; aligns with common game tick rates
SLEEP_TIME="0.02"

# [NOTE] 20 clicks per tick saturate most input buffers without overflow
BATCH_SIZE=20

case "$BTN_TYPE" in
"left") CODE="272" ;;
"right") CODE="273" ;;
"middle") CODE="274" ;;
*)
  notify-send "Automation" "Error: Unknown button '$BTN_TYPE'" -u critical -i "error"
  exit 1
  ;;
esac

# ┌─── 2. Internal Helpers ────────────────────────────────────────────────────┐

# [NOTE] Ensure ydotool daemon is available for IPC
check_env() {
  if ! pgrep -x "ydotoold" >/dev/null; then
    notify-send "Automation" "Error: ydotoold not running" -u critical -i "error"
    exit 1
  fi
}

# [NOTE] Pre-generate burst payload to reduce per-iteration overhead
generate_payload() {
  local payload=""
  for _ in $(seq 1 "$BATCH_SIZE"); do
    payload+="$CODE:1 $CODE:0 "
  done
  echo "$payload"
}

# ┌─── 3. Execution Controller (Toggle) ───────────────────────────────────────┐

if [[ -f "$PID_FILE" ]]; then
  pid=$(<"$PID_FILE")

  # [FIX] Force-terminate loop and its children to avoid orphaned ydotool processes
  pkill -P "$pid" 2>/dev/null
  kill -9 "$pid" 2>/dev/null

  rm -f "$PID_FILE"

  notify-send "Automation" "Clicker ($BTN_TYPE): OFF" -i "process-stop" -u low -t 800
  exit 0
fi

# ┌─── 4. Activation & Background Loop ────────────────────────────────────────┐

check_env
PAYLOAD="$(generate_payload)"

# [WARN] High-frequency input simulation starts immediately
notify-send "Automation" "Clicker ($BTN_TYPE): ON" -i "input-mouse" -u critical -t 1000

(
  # [NOTE] Ensure PID file cleanup on external termination
  trap 'rm -f "$PID_FILE"' EXIT INT TERM

  while true; do
    # [NOTE] Word splitting intentional to pass burst as discrete arguments
    ydotool key $PAYLOAD 2>/dev/null || break
    sleep "$SLEEP_TIME"
  done
) &

echo $! >"$PID_FILE"
