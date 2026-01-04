#!/bin/bash

# ┌─── Keyboard Autoclicker (Hydra Engine) ────────────────────────────────────┐
# │ Architecture: 8 Concurrent Threads x Full Spectrum Injection.              │
# │ Logic: Phase-shifted execution loops for maximum input density.            │
# └────────────────────────────────────────────────────────────────────────────┘

PID_FILE="/tmp/clicker_keyboard.pid"

# ┌─── Generator ──────────────────────────────────────────────────────────────┐

# [INFO] Construct the master payload containing all active keycodes.
# Range: Alphanumeric, Function Keys, Navigation, Modifiers.

generate_payload() {
  local keys=""

  # 1. Alphanumeric & Symbols (Standard Layout)
  for code in {2..13} {16..27} {30..41} {43..53} 57; do
    keys+="$code:1 $code:0 "
  done

  # 2. Function Keys (F1-F6 + F10-F12)
  for code in {59..64} 68 87 88; do
    keys+="$code:1 $code:0 "
  done

  # 3. Virtual Keys (Ghost inputs)
  for code in {183..189} {191..194}; do
    keys+="$code:1 $code:0 "
  done

  # 4. Modifiers (Shift)
  for code in 42 54; do
    keys+="$code:1 $code:0 "
  done

  # 5. Navigation & Numpad
  for code in 28 14 {71..83} 110 102 104 111 107 109; do
    keys+="$code:1 $code:0 "
  done

  echo "$keys"
}

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then

  # --- Stop Sequence ---

  # [CRITICAL] Kill the Process Group to terminate all sub-threads instantly.
  PGID=$(ps -o pgid= -p "$(cat "$PID_FILE")" | grep -o '[0-9]*')
  kill -- -"$PGID" 2>/dev/null
  rm -f "$PID_FILE"

  notify-send "Hydra: DISENGAGED" \
    -i "process-stop" \
    -u "low" \
    -t 200

else

  # --- Start Sequence ---

  [ -f "$PID_FILE" ] && rm -f "$PID_FILE"

  notify-send "Hydra: 8-CORE ACTIVE" \
    -i "weather-severe-alert" \
    -u "critical" \
    -t 500

  # [OPTIMIZATION] Pre-calculate the massive payload once to save CPU cycles.
  FULL_PAYLOAD=$(generate_payload)

  (
    # [SYSTEM] Enable Job Control for proper thread management.
    set -m
    trap 'kill $(jobs -p); rm -f $PID_FILE' EXIT

    # [SAFETY] Lower priority to maintain system responsiveness.
    renice -n 5 -p $$ >/dev/null 2>&1

    # ┌─── Thread Pool (Phase Shifted) ────────────────────────────────────────┐

    # Thread 1: T+0.00s
    (while true; do
      # shellcheck disable=SC2086
      ydotool key $FULL_PAYLOAD
    done) &

    # Thread 2: T+0.05s
    (
      sleep 0.05
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    # Thread 3: T+0.10s
    (
      sleep 0.10
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    # Thread 4: T+0.15s
    (
      sleep 0.15
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    # Thread 5: T+0.20s
    (
      sleep 0.20
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    # Thread 6: T+0.25s
    (
      sleep 0.25
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    # Thread 7: T+0.30s
    (
      sleep 0.30
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    # Thread 8: T+0.35s
    (
      sleep 0.35
      while true; do
        # shellcheck disable=SC2086
        ydotool key $FULL_PAYLOAD
      done
    ) &

    wait
  ) &

  echo $! >"$PID_FILE"

fi
