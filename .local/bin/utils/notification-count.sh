#!/bin/bash

# [INFO] This script shows a notification counter, but only if there are notifications.

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# [INFO] Get the count of all notifications in the history.
COUNT=$(/usr/bin/dunstctl count history 2>/dev/null)

if [ -n "$COUNT" ] && [ "$COUNT" -gt 0 ]; then
  # [INFO] If there are notifications in history, show the count.
  echo "󰂚  ${COUNT}"
else
  # [INFO] If history is empty, show nothing.
  echo ""
fi
