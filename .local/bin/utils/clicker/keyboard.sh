#!/bin/bash

# ┌─── Keyboard Autoclicker (Hyprland Safe) ───────────────────────────────────┐
# │ High-Density Spam (~110 keys). Optimized for maximum DPS.                  │
# │ EXCLUDED: F7-F9 (Binds), Ctrl/Alt (Safety), Media Keys, Tab/Esc.           │
# └────────────────────────────────────────────────────────────────────────────┘

# --- Configuration ---

PID_FILE="/tmp/clicker_keyboard.pid"

# ┌─── Helper Functions ───────────────────────────────────────────────────────┐

generate_keys() {
  local keys=""

  # 1. Alphanumeric, Space & Symbols (Standard Layout)
  #    Codes cover: 1-0, Q-P, A-L, Z-M, Space, and all Punctuation.
  for code in {2..13} {16..27} {30..41} {43..53} 57; do
    keys+="$code:1 $code:0 "
  done

  # 2. Safe Function Keys (Real)
  #    F1-F6 (59-64).
  for code in {59..64}; do
    keys+="$code:1 $code:0 "
  done

  #    F10 (68), F11 (87), F12 (88).
  #    [BANNED]: F7-F9 (Script Binds).
  for code in 68 87 88; do
    keys+="$code:1 $code:0 "
  done

  # 3. Ghost Function Keys (Virtual F13-F24)
  #    Range: 183-194.
  #    [EXCLUDED] 190 (F20) - Hardwired to Mic Mute.
  for code in {183..189} {191..194}; do
    keys+="$code:1 $code:0 "
  done

  # 4. Modifiers (RESTRICTED for Hyprland)
  #    [ALLOWED] Shift (42, 54) - Safe (just capitalizes letters).
  #    [BANNED]  Ctrl (29, 97)  - Risk of triggering system shortcuts.
  #    [BANNED]  Alt (56, 100)  - Risk of triggering 'SUPER_ALT' gestures.
  #    [BANNED]  Super (125)    - Reserved for Window Manager.
  for code in 42 54; do
    keys+="$code:1 $code:0 "
  done

  # 5. Navigation & Action
  #    Enter (28), Backspace (14).
  #    Numpad Block (71-83).
  #    Nav Block: Insert, Home, PgUp, Delete, End, PgDn.
  #    [BANNED]: Tab (15), Esc (1), Print (99).
  for code in 28 14 {71..83} 110 102 104 111 107 109; do
    keys+="$code:1 $code:0 "
  done

  echo "$keys"
}

# ┌─── Main Logic ─────────────────────────────────────────────────────────────┐

if [ -f "$PID_FILE" ]; then

  # --- Stop ---
  kill "$(cat "$PID_FILE")"
  rm "$PID_FILE"

  notify-send "K-Click: OFF" \
    -i "input-keyboard" \
    -t 500

else

  # --- Start ---
  notify-send "K-Click: HYPR-SAFE" \
    -i "weather-storm" \
    -t 500

  KEYS_CMD=$(generate_keys)

  (
    trap 'rm -f $PID_FILE' EXIT

    while true; do
      ydotool key $KEYS_CMD
      sleep 0.01
    done
  ) &

  echo $! >"$PID_FILE"

fi
