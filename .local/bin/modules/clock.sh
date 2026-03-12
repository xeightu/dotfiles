#!/usr/bin/env bash

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

_state_file="/tmp/waybar_clock_state"

# [NOTE] Ensure initial state exists to prevent read errors on first run
[[ -f "$_state_file" ]] || echo "time" >"$_state_file"

# ┌─── 2. Data Acquisition ────────────────────────────────────────────────────┐

_current_state=$(<"$_state_file")
_tooltip_text=$(date +"%A, %d %B %Y")

if [[ "$_current_state" == "time" ]]; then
  # [NOTE] Format: Icon + HH:MM:SS
  _display_text=$(date +" %H:%M:%S")
else
  # [NOTE] Format: Icon + DD.MM.YYYY
  _display_text=$(date +" %d.%m.%Y")
fi

# ┌─── 3. Final Output ────────────────────────────────────────────────────────┐

# [NOTE] Returns JSON structure compatible with Waybar's custom module logic
printf '{"text": "%s", "tooltip": "<big>%s</big>"}\n' "$_display_text" "$_tooltip_text"
