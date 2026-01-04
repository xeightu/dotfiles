#!/bin/bash

# ┌──────────────────────────────────────────────────┐
# │               Brightness Control Script          │
# └──────────────────────────────────────────────────┘
# [INFO] This script changes the screen brightness and shows a notification
# [INFO] with a progress bar. It accepts '+' or '-' as an argument.

# --- Change Brightness ---
# [CONFIG] The step percentage for brightness change.
STEP="5%"
brightnessctl set "$STEP$1"

# --- Show Notification ---
# [INFO] Get current and max brightness to calculate the percentage.
BRIGHTNESS=$(brightnessctl get)
MAX_BRIGHTNESS=$(brightnessctl max)
PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# [CONFIG] Notification timeout in milliseconds.
TIMEOUT="500"

# [INFO] Use dunstify to show a notification that can be replaced (using -a)
# [INFO] and has a progress bar (using -h).
dunstify -a "brightness-control" -u low -i "display-brightness" -h int:value:"$PERCENTAGE" "Brightness: ${PERCENTAGE}%" -t "$TIMEOUT"
