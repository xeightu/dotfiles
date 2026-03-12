#!/usr/bin/env bash

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

_state_file="/tmp/waybar_clock_state"

# ┌─── 2. State Toggle & Signal ───────────────────────────────────────────────┐

# [NOTE] Read current state with a fallback to 'time' if the file is missing
_current_state=$(cat "$_state_file" 2>/dev/null) || _current_state="time"

# Toggle display mode
if [[ "$_current_state" == "time" ]]; then
  echo "date" >"$_state_file"
else
  echo "time" >"$_state_file"
fi

# [NOTE] RTMIN+10 is the standard signal for triggering custom Waybar module updates
pkill -RTMIN+10 waybar
