#!/usr/bin/env bash

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

# [NOTE] Max characters before truncation to keep UI stable
MAX_LEN=50

# [NOTE] Mapping icons to window classes
declare -A ICONS=(
  ["kitty"]="󰄛"
  ["obsidian"]="󱓧"
  ["com.ayugram.desktop"]="󰍡"
  ["zen"]="󰈹"
  ["discord"]="󰙯"
  ["vesktop"]="󰙯"
  ["spotify"]="󰓇"
  ["steam"]="󰓓"
  ["thunar"]="󰉋"
  ["org.prismlauncher.PrismLauncher"]="󰍳"
)

# ┌─── 2. Title Resolution Logic ──────────────────────────────────────────────┐

_resolve_display_text() {
  local _win_info
  _win_info=$(hyprctl activewindow -j)
  local _class
  _class=$(echo "$_win_info" | jq -r '.class // empty')

  # Exit if no window is focused
  [[ -z "$_class" || "$_class" == "null" ]] && {
    echo '{"text": ""}'
    return
  }

  local _title
  _title=$(echo "$_win_info" | jq -r '.title')
  local _icon="${ICONS[$_class]}"
  local _final=""

  # --- Naming Logic ---
  # [NOTE] If we have a manual override in the case, use it.
  # Otherwise, use the window title (as in the old script).
  case "$_class" in
  "kitty") _final="Kitty" ;;
  "zen") _final="Zen Browser" ;;
  "com.ayugram.desktop") _final="AyuGram" ;;
  "spotify") _final="Spotify" ;;
  *) _final="$_title" ;;
  esac

  # [FIX] If the title is empty (some apps), fallback to a cleaned class name
  if [[ -z "$_final" || "$_final" == "null" ]]; then
    _final="${_class##*.}" # Takes 'PrismLauncher' from 'org.xxx.PrismLauncher'
    _final="${_final^}"    # Capitalize
  fi

  # --- Post-Processing ---
  # Truncate if too long
  if ((${#_final} > MAX_LEN)); then
    _final="${_final:0:$((MAX_LEN - 3))}..."
  fi

  # Prepend icon if found in the map
  [[ -n "$_icon" ]] && _final="$_icon  $_final"

  # [NOTE] Return JSON with class for potential CSS styling
  jq -n -c \
    --arg text "$_final" \
    --arg class "${_class,,}" \
    '{"text": $text, "class": $class}'
}

# ┌─── 3. Event Loop (Kinetics) ──────────────────────────────────────────────┐

_resolve_display_text

_socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# [NOTE] Listens for both window changes and title changes (e.g. switching tabs)
socat -U - "UNIX-CONNECT:$_socket" | while read -r _line; do
  if [[ "$_line" == "activewindow>>"* || "$_line" == "windowtitle>>"* ]]; then
    _resolve_display_text
  fi
done
