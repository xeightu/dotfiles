#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │                 Power & Session Menu             │
# └──────────────────────────────────────────────────┘
# [INFO] This script displays a Wofi menu for session control with
# [INFO] a confirmation dialog for critical actions.

# --- Configuration ---
# [CONFIG] Define menu entries with Nerd Font icons, ordered logically.
lock=" Lock"
suspend=" Suspend"
hibernate="󰒲 Hibernate"
logout=" Logout"
reboot=" Reboot"
shutdown=" Shutdown"

# [CONFIG] Wofi window dimensions.
main_menu_width="300"
main_menu_height="250"
confirm_menu_width="300"
confirm_menu_height="100"

# --- Function: Confirmation Dialog ---
# [INFO] Shows a 'Yes/No' confirmation dialog for a given action.
confirm_action() {
  local question="$1"
  local confirm_options=" Yes\n No"

  local confirm_choice=$(echo -e "$confirm_options" | wofi --dmenu \
    --prompt "$question" \
    --width "$confirm_menu_width" \
    --height "$confirm_menu_height")

  if [[ "$confirm_choice" == *"Yes"* ]]; then
    return 0 # Success
  else
    return 1 # Cancelled
  fi
}

# --- Main Logic ---
# [INFO] Assemble the main menu options in a logical order.
options="$lock\n$suspend\n$hibernate\n$logout\n$reboot\n$shutdown"

# [INFO] Show the main menu.
choice=$(echo -e "$options" | wofi --dmenu \
  --prompt "Power Menu" \
  --width "$main_menu_width" \
  --height "$main_menu_height")

# [INFO] Process the user's choice.
case "$choice" in
"$lock")
  hyprlock
  ;;
"$logout")
  if confirm_action "Are you sure?"; then
    hyprctl dispatch exit
  fi
  ;;
"$suspend")
  systemctl suspend
  ;;
"$hibernate")
  if confirm_action "Are you sure?"; then
    systemctl hibernate
  fi
  ;;
"$reboot")
  if confirm_action "Are you sure?"; then
    systemctl reboot
  fi
  ;;
"$shutdown")
  if confirm_action "Are you sure?"; then
    systemctl poweroff
  fi
  ;;
esac
