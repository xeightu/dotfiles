#!/usr/bin/env bash

# ┌─── 1. Process Toggle Logic ────────────────────────────────────────────────┐

# [NOTE] Check for an exact process name match to determine visibility state
if pgrep -x "waybar" >/dev/null; then
  # Terminate all instances to hide the status bar
  pkill -x waybar
else
  # Launch waybar in the background and detach it from the parent shell
  waybar &
fi
