#!/usr/bin/env bash

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

STEP="5%"
TIMEOUT=500

# ┌─── 2. Hardware Interaction ────────────────────────────────────────────────┐

# [NOTE] Expects '+' or '-' as the first argument to change direction
if ! brightnessctl set "${STEP}${1}" >/dev/null 2>&1; then
  echo "Error: Invalid argument or hardware access failed." >&2
  exit 1
fi

_raw_val=$(brightnessctl get)
_max_val=$(brightnessctl max)
_percentage=$((_raw_val * 100 / _max_val))

# ┌─── 3. Visual Feedback ─────────────────────────────────────────────────────┐

# [NOTE] Using app name (-a) ensures previous notifications are replaced
dunstify -a "brightness-control" \
  -u low \
  -i "display-brightness" \
  -h int:value:"$_percentage" \
  -t "$TIMEOUT" \
  "Brightness: ${_percentage}%"
