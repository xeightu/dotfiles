#!/usr/bin/env bash

# ┌─── 1. Layout Extraction Logic ─────────────────────────────────────────────┐

# [NOTE] Transform full keymap name (e.g., "English (US)") to short uppercase (EN)
# [NOTE] Requires 'jq' for JSON parsing of Hyprland device state

if ! command -v jq >/dev/null 2>&1; then
  echo "??"
  exit 1
fi

hyprctl devices -j |
  jq -r '.keyboards[] | select(.main == true) | .active_keymap' |
  head -n 1 |
  cut -c 1-2 |
  tr '[:lower:]' '[:upper:]'
