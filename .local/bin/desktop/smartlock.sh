#!/bin/bash
# ┌────────────────────────────────────┐
# │          SMART LOCK SCRIPT         │
# └────────────────────────────────────┘
# Prevents locking if sound, fullscreen, or inhibit flag is active.

# --- Check 1: Any active sound output (PipeWire / PulseAudio)
if pactl list sink-inputs 2>/dev/null | grep -q "state: RUNNING"; then
  echo "[smart_lock] Audio active — skipping lock"
  exit 0
fi

# --- Check 2: Fullscreen or borderless window ---
active_win_json=$(hyprctl activewindow -j 2>/dev/null)
if [ -n "$active_win_json" ]; then
  fullscreen=$(echo "$active_win_json" | jq -r '.fullscreen')
  if [ "$fullscreen" = "true" ]; then
    echo "[smart_lock] Fullscreen window — skipping lock"
    exit 0
  fi

  # fallback: check if window covers the monitor
  win_w=$(echo "$active_win_json" | jq -r '.size[0]')
  win_h=$(echo "$active_win_json" | jq -r '.size[1]')
  screen_json=$(hyprctl monitors -j | jq -r '.[0]')
  screen_w=$(echo "$screen_json" | jq -r '.width')
  screen_h=$(echo "$screen_json" | jq -r '.height')

  # allow small borders (e.g., borderless window)
  if [ "$win_w" -ge $((screen_w - 20)) ] && [ "$win_h" -ge $((screen_h - 20)) ]; then
    echo "[smart_lock] Borderless fullscreen — skipping lock"
    exit 0
  fi
fi

# --- Check 3: Idle inhibit flag (manual override) ---
if [ -f /tmp/idle-inhibit ]; then
  echo "[smart_lock] Inhibit flag present — skipping lock"
  exit 0
fi

# --- Action: Lock screen ---
echo "[smart_lock] No activity detected — locking screen"
exec hyprlock
