#!/usr/bin/env bash

# ┌─── 1. Environment & State ─────────────────────────────────────────────────┐

# [NOTE] Check dependencies for window geometry parsing
if ! command -v jq >/dev/null 2>&1; then
  notify-send "System" "Error: jq is required for split toggling" -u critical
  exit 1
fi

_current_layout=$(hyprctl -j getoption general:layout | jq -r '.value')

# ┌─── 2. Layout Branching ────────────────────────────────────────────────────┐

if [[ "$_current_layout" == "master" ]]; then
  # --- Master Layout Action ---
  hyprctl dispatch layoutmsg orientationnext
  notify-send "Layout" "Master: Stack orientation rotated" -i "view-dual-symbolic" -t 1000

else
  # --- Dwindle Layout Action ---
  hyprctl dispatch layoutmsg togglesplit

  # [NOTE] Split state detection logic:
  # Compares active window width against monitor width to determine orientation
  _active_win=$(hyprctl -j activewindow)
  _is_vertical=$(echo "$_active_win" | jq -r '
        .at[0] == 0 and .size[0] >= (.monitor | tonumber | (.x + .width - 10))
    ')

  if [[ "$_is_vertical" == "true" ]]; then
    notify-send "Layout" "Dwindle: Vertical Split" -i "object-flip-vertical-symbolic" -t 1000
  else
    notify-send "Layout" "Dwindle: Horizontal Split" -i "object-flip-horizontal-symbolic" -t 1000
  fi
fi
