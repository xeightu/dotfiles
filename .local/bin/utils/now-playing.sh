#!/bin/bash

# [FIX] Explicitly set the D-Bus session address for the user
# This is crucial for commands running outside a normal user session (like in hyprlock)
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Check the player status
PLAYER_STATUS=$(/usr/bin/playerctl status 2>/dev/null)

if [ "$PLAYER_STATUS" = "Playing" ]; then
  # If music is playing, format the metadata and print it
  # Using a Nerd Font icon for music 
  echo "  $(/usr/bin/playerctl metadata --format '{{artist}} - {{title}}')"
else
  # If nothing is playing or playerctl fails, print an empty string
  echo ""
fi
