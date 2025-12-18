#!/bin/bash

# ┌──────────────────────────────────────────────────┐
# │            Smart Split Orientation Toggle        │
# └──────────────────────────────────────────────────┘
# [INFO] This script intelligently toggles the split orientation
# [INFO] based on the current Hyprland layout.

# --- Get Current Layout ---
layout=$(hyprctl -j getoption general:layout | jq -r '.value')

# --- Main Logic ---
if [ "$layout" = "master" ]; then
  # [INFO] For master layout, change the stack orientation.
  hyprctl dispatch layoutmsg orientationnext
  notify-send "Master Layout" "Stack orientation changed" -i "view-dual-symbolic" -t 1000
else
  # [INFO] For dwindle layout, toggle the container split.
  hyprctl dispatch layoutmsg togglesplit

  # [INFO] Check the split state AFTER toggling to show the correct notification.
  active_window_json=$(hyprctl -j activewindow)

  # [INFO] A vertical split is assumed if the active window's width
  # [INFO] is nearly the full width of the monitor.
  is_vertical_split=$(echo "$active_window_json" | jq -r '
        .at[0] == 0 and .size[0] >= (.monitor | tonumber | (.x + .width - 10))
    ')

  if [ "$is_vertical_split" = "true" ]; then
    notify-send "Split Changed" "Orientation: Vertical" -i "object-flip-vertical-symbolic" -t 1000
  else
    notify-send "Split Changed" "Orientation: Horizontal" -i "object-flip-horizontal-symbolic" -t 1000
  fi
fi
