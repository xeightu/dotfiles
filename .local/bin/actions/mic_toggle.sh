#!/usr/bin/env bash

# ┌─── 1. Toggle Audio State ──────────────────────────────────────────────────┐

# [NOTE] Uses WirePlumber's wpctl to flip the mute state on the default source
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# ┌─── 2. Status Check & Notification ─────────────────────────────────────────┐

# [NOTE] Capture volume output to determine current state after toggle
_status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if [[ "$_status" == *"MUTED"* ]]; then
  dunstify -a "toggle-mic" \
    -u low \
    -i "microphone-sensitivity-muted" \
    "Microphone: OFF"
else
  dunstify -a "toggle-mic" \
    -u low \
    -i "microphone-sensitivity-high" \
    "Microphone: ON"
fi
