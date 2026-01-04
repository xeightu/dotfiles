#!/bin/bash

# [INFO] This script provides a network status indicator for hyprlock.

# [INFO] Get the primary active connection
ACTIVE_CONNECTION=$(nmcli -t -f NAME,DEVICE,STATE c show --active | head -n 1)

if [ -n "$ACTIVE_CONNECTION" ]; then
  # [INFO] Connection exists, let's determine the type
  DEVICE=$(echo "$ACTIVE_CONNECTION" | cut -d: -f2)
  NAME=$(echo "$ACTIVE_CONNECTION" | cut -d: -f1)

  if [[ "$DEVICE" == "wlan"* || "$DEVICE" == "wlp"* ]]; then
    # Wi-Fi connection
    ICON="󰖩"
    echo "${ICON}  ${NAME}"
  else
    # Ethernet or other wired connection
    ICON="󰈀"
    echo "${ICON}  Wired"
  fi
else
  # No active connection
  ICON="󰖪"
  echo "${ICON}  Disconnected"
fi
