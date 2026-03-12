#!/usr/bin/env bash

# ┌─── 1. Configuration & Registry ────────────────────────────────────────────┐

# [NOTE] Define labels and their corresponding system commands in one place
declare -A ACTIONS=(
  ["  Lock"]="hyprlock"
  ["  Suspend"]="systemctl suspend"
  ["󰒲  Hibernate"]="systemctl hibernate"
  ["  Logout"]="hyprctl dispatch exit"
  ["  Reboot"]="systemctl reboot"
  ["  Power Off"]="systemctl poweroff"
)

# Order of appearance in the menu
ORDER=("  Lock" "  Suspend" "󰒲  Hibernate" "  Logout" "  Reboot" "  Power Off")

# ┌─── 2. Internal Helpers ────────────────────────────────────────────────────┐

_run_rofi() {
  local _prompt="$1"
  local _theme="$2"
  local _options="$3"

  echo -e "$_options" | rofi -dmenu -i -p "$_prompt" -theme-str "$_theme"
}

_confirm() {
  local _msg="$1"
  # [NOTE] High-contrast modal theme for confirmation dialogs
  local _theme="window {width: 270px; border: 2px; border-color: @urgent;} listview {lines: 2;} entry {enabled: false;} element { children: [ \"element-text\" ]; }"
  local _choice
  _choice=$(_run_rofi "$_msg" "$_theme" "󰄬 Yes\n󰅖 No")

  [[ "$_choice" == *"Yes"* ]]
}

# ┌─── 3. Main Logic ──────────────────────────────────────────────────────────┐

# [NOTE] Calculate uptime to display in the prompt for better UX context
_uptime=$(uptime -p | sed -e 's/up //')
_menu_options=$(
  IFS=$'\n'
  echo "${ORDER[*]}"
)

# [NOTE] Main Menu: centered, medium width
_main_theme="window {width: 350px; border: 2px; border-color: @selected;} listview {lines: 6;} entry {enabled: false;} element { children: [ \"element-text\" ]; }"
_selection=$(_run_rofi "Uptime: $_uptime" "$_main_theme" "$_menu_options")

# Exit if nothing selected (ESC)
[[ -z "$_selection" ]] && exit 0

_cmd="${ACTIONS[$_selection]}"

# ┌─── 4. Execution Logic ─────────────────────────────────────────────────────┐

case "$_selection" in
*"Lock"* | *"Suspend"*)
  # [NOTE] Non-destructive actions execute immediately
  eval "$_cmd"
  ;;
*)
  # [WARN] Destructive actions require explicit user confirmation
  if _confirm "Confirm ${_selection#* }?"; then
    eval "$_cmd"
  fi
  ;;
esac
