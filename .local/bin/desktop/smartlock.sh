#!/usr/bin/env bash

# ┌─── 1. Environment & Dependencies ──────────────────────────────────────────┐

# [NOTE] Script requires jq for JSON parsing and pactl for audio state detection
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required for smart lock logic." >&2
  exit 1
fi

# ┌─── 2. Inhibit Checks ──────────────────────────────────────────────────────┐

# --- Check: Active Audio ---
# [NOTE] Prevents locking while media (YouTube, Spotify, etc.) is playing
if pactl list sink-inputs 2>/dev/null | grep -q "state: RUNNING"; then
  exit 0
fi

# --- Check: Fullscreen Applications ---
_win_json=$(hyprctl activewindow -j 2>/dev/null)

if [[ -n "$_win_json" && "$_win_json" != "{}" ]]; then
  # [NOTE] Check explicit fullscreen flag first
  _is_fullscreen=$(echo "$_win_json" | jq -r '.fullscreen')
  [[ "$_is_fullscreen" == "true" ]] && exit 0

  # [NOTE] Fallback: Detect "fake" fullscreen (borderless windows covering the screen)
  _win_w=$(echo "$_win_json" | jq -r '.size[0]')
  _win_h=$(echo "$_win_json" | jq -r '.size[1]')
  _mon_id=$(echo "$_win_json" | jq -r '.monitor')

  # Get dimensions of the monitor containing the active window
  _screen_json=$(hyprctl monitors -j | jq -r ".[] | select(.id == $_mon_id)")
  _screen_w=$(echo "$_screen_json" | jq -r '.width')
  _screen_h=$(echo "$_screen_json" | jq -r '.height')

  # Allow a 20px tolerance for window decorations or panels
  if ((_win_w >= (_screen_w - 20) && _win_h >= (_screen_h - 20))); then
    exit 0
  fi
fi

# --- Check: Manual Inhibit Flag ---
# [NOTE] Allows users to manually pause auto-locking via 'touch /tmp/idle-inhibit'
[[ -f "/tmp/idle-inhibit" ]] && exit 0

# ┌─── 3. Action ──────────────────────────────────────────────────────────────┐

# [NOTE] No inhibit conditions met; proceeding to lock the session
exec hyprlock
