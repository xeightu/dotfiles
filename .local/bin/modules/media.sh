#!/usr/bin/env bash

# ┌─── 1. Environment Synchronization ─────────────────────────────────────────┐

# [FIX] Force D-Bus session path to allow IPC communication from lockscreen context
export DBUS_SESSION_BUS_ADDRESS
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# ┌─── 2. Media Metadata Logic ────────────────────────────────────────────────┐

_status=$(playerctl status 2>/dev/null)

if [[ "$_status" == "Playing" ]]; then
  # [NOTE] Retrieve artist and title via playerctl template
  _metadata=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)

  # Return formatted string with musical icon for UI widgets
  echo "  $_metadata"
else
  # Output nothing if the player is stopped or inactive
  echo ""
fi
