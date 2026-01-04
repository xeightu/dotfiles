#!/bin/bash
# [INFO] This script provides a smart battery status for hyprlock.

# [FIX] Automatically find the battery path instead of hardcoding it.
# This makes the script portable across different machines.
BATTERY_PATH=$(upower -e | grep 'battery')

# [INFO] If no battery is found, exit gracefully.
if [ -z "$BATTERY_PATH" ]; then
  echo "󰂃 No Battery"
  exit 0
fi

# [INFO] Get battery status and percentage using a reliable awk command.
STATUS=$(upower -i $BATTERY_PATH | awk '/state:/ {print $2}')
PERCENTAGE=$(upower -i $BATTERY_PATH | awk '/percentage:/ {sub(/%/, ""); print $2}')

if [ "$STATUS" = "charging" ]; then
  ICON="" # Charging icon
elif [ "$PERCENTAGE" -gt 80 ]; then
  ICON="󰁹" # Full
elif [ "$PERCENTAGE" -gt 30 ]; then
  ICON="󰁾" # Medium
else
  ICON="󰁺" # Low
fi

# [OUTPUT] Print plain text without any color tags.
echo "${ICON}  ${PERCENTAGE}%"
