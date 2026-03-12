#!/usr/bin/env bash

# ┌─── 1. Data Acquisition ──────────────────────────────────────────────────┐

# [NOTE] Automatically detect primary battery path for hardware portability
_bat_path=$(upower -e | grep 'battery' | head -n 1)

if [[ -z "$_bat_path" ]]; then
  echo "󰂃 No Battery"
  exit 0
fi

# [NOTE] Capture raw data once to minimize redundant system calls
_bat_info=$(upower -i "$_bat_path")
_status=$(echo "$_bat_info" | awk '/state:/ {print $2}')
_pct=$(echo "$_bat_info" | awk '/percentage:/ {print $2}' | tr -d '%')

# ┌─── 2. Icon Logic ────────────────────────────────────────────────────────┐

if [[ "$_status" == "charging" || "$_status" == "fully-charged" ]]; then
  _icon="󱐋"
elif ((_pct > 90)); then
  _icon="󰁹"
elif ((_pct > 70)); then
  _icon="󰂀"
elif ((_pct > 40)); then
  _icon="󰁾"
elif ((_pct > 15)); then
  _icon="󰁺"
else
  # [NOTE] Warning icon for critical levels
  _icon="󰂃"
fi

# ┌─── 3. Final Output ──────────────────────────────────────────────────────┐

# Plain text output formatted for hyprlock labels
echo "${_icon}  ${_pct}%"
