#!/usr/bin/env bash

# ┌─── 1. Path Configuration ──────────────────────────────────────────────────┐

_menu_exe="$HOME/.local/bin/screenshots/action_menu.sh"
_temp_dir="/tmp"

# ┌─── 2. Execution (Region Capture) ──────────────────────────────────────────┐

# [NOTE] --freeze: Locks the screen state to prevent UI changes during selection
# [NOTE] --silent: Bypasses default hyprshot notifications to avoid duplication
hyprshot -m region \
  --freeze \
  --silent \
  -o "$_temp_dir" \
  -f "area_$(date +%s).png" \
  -- "$_menu_exe"
