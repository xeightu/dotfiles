#!/usr/bin/env bash

# ┌─── 1. Data Acquisition ────────────────────────────────────────────────────┐

# [NOTE] Retrieve the primary active connection details via NetworkManager
_active_conn=$(nmcli -t -f NAME,DEVICE,STATE c show --active | head -n 1)

# ┌─── 2. Status Parsing & UI Logic ───────────────────────────────────────────┐

if [[ -n "$_active_conn" ]]; then
  _name=$(echo "$_active_conn" | cut -d: -f1)
  _device=$(echo "$_active_conn" | cut -d: -f2)

  # [NOTE] Pattern match for common wireless device naming conventions
  if [[ "$_device" == "wlan"* || "$_device" == "wlp"* ]]; then
    _icon="󰖩"
    _output="${_icon}  ${_name}"
  else
    _icon="󰈀"
    _output="${_icon}  Wired"
  fi
else
  # Fallback for no active network detected
  _icon="󰖪"
  _output="${_icon}  Disconnected"
fi

# ┌─── 3. Final Output ────────────────────────────────────────────────────────┐

# Plain text output intended for hyprlock status widgets
echo "$_output"
