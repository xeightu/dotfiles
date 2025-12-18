#!/bin/bash
# ┌───────────────────────────────────────┐
# │          IDLE MANAGER DAEMON          │
# └───────────────────────────────────────┘

# [INFO] This script launches hypridle with configured timeouts
# [INFO] for screen locking and power management.

hypridle -w \
  timeout 300 '~/.local/bin/desktop/smartlock.sh' \
  timeout 600 'hyprctl dispatch dpms off' \
  resume 'sleep 1 && hyprctl dispatch dpms on' \
  before-sleep 'hyprlock'
