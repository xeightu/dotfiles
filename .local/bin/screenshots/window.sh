#!/usr/bin/env bash

# ┌─── 1. Path Configuration ──────────────────────────────────────────────────┐

_menu_exe="$HOME/.local/bin/screenshots/action_menu.sh"
_temp_dir="/tmp"

# ┌─── 2. Execution (Active Window) ───────────────────────────────────────────┐

# [NOTE] --freeze: Locks the screen state to prevent UI drift during the process
# [NOTE] --silent: Bypasses built-in notifications to prevent UI noise duplication
hyprshot -m window \
  -m active \
  --freeze \
  --silent \
  -o "$_temp_dir" \
  -f "win_$(date +%s).png" \
  -- "$_menu_exe"
