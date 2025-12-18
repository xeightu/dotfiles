#!/bin/bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                PYRE ENGINE                                 │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                            1. PATHS & SETTINGS                             │
# └────────────────────────────────────────────────────────────────────────────┘
WALLPAPER_DIR="$HOME/Pictures/walls"
STATE_FILE="$HOME/.config/pyre/state"
MENU_STATE_FILE="$HOME/.config/pyre/main_menu_last_choice"

# Paths derived from your structure
HYPR_DIR="$HOME/.config/hypr"
SCRIPTS_DESKTOP="$HOME/.local/bin/desktop"
SCRIPTS_UTILS="$HOME/.local/bin/utils"
SCRIPTS_SHOT="$HOME/.local/bin/screenshots"
SCRIPTS_WAYBAR="$HOME/.local/bin/waybar"
ENGINE_THEMES_DIR="$HYPR_DIR/themes"

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                              2. CORE FUNCTIONS                             │
# └────────────────────────────────────────────────────────────────────────────┘

check_dependencies() {
  local missing=0
  for cmd in wofi swww kitty notify-send hyprctl socat jq; do
    if ! command -v "$cmd" &>/dev/null; then
      notify-send "Pyre Error" "Required command not found: $cmd" -i "dialog-error"
      missing=1
    fi
  done
  [ "$missing" -eq 1 ] && exit 1
}

reload_services() {
  hyprctl reload

  # Smart Waybar Reload
  if pgrep -x "waybar" >/dev/null; then
    pkill -SIGUSR2 waybar
  else
    waybar &
  fi

  pkill dunst && dunst &

  if ! pgrep -x "swww-daemon" >/dev/null; then
    swww-daemon &
  fi

  # Re-apply keyboard settings if needed (sometimes gets lost)
  "$SCRIPTS_WAYBAR/get_layout.sh" >/dev/null
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                            3. LAYOUT LAUNCHERS                             │
# └────────────────────────────────────────────────────────────────────────────┘

launch_showcase_layout() {
  hyprctl keyword source "$HYPR_DIR/layouts/showcase.conf"
  sleep 0.1
  kitty --title "fastfetch" -o font_size=10.0 -o window_padding_width="10 10 10 0" sh -c "fastfetch; sleep infinity" &
  sleep 0.2
  kitty --title "tty-clock" -o font_size=10.0 -o window_padding_width=0 tty-clock -c -C 4 &
  kitty --title "cava" -o font_size=10.0 -o window_padding_width=0 cava &
  kitty --title "unimatrix" -o font_size=10.0 -o window_padding_width=0 unimatrix -s 90 &
  kitty --title "pipes" -o font_size=10.0 -o window_padding_width=0 pipes.sh &
}

launch_f0urth_layout_simple() {
  local small_font_size=9
  for i in {1..4}; do
    kitty -o font_size=$small_font_size &
    sleep 0.1
  done
}

launch_dual_pane_layout() {
  hyprctl keyword source "$HYPR_DIR/layouts/dual_pane.conf"
  if command -v thunar &>/dev/null; then thunar & else kitty --title "file-manager" yazi & fi
  sleep 0.3
  kitty -o font_size=10.0 --title "fm-yazi" yazi &
  sleep 1
  hyprctl keyword source "$HYPR_DIR/layouts/dual_pane_clear.conf"
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                         4. THEME & WALLPAPER ENGINE                        │
# └────────────────────────────────────────────────────────────────────────────┘

apply_theme() {
  local theme_name_lower=$1
  local theme_name_capitalized=$(echo "$theme_name_lower" | sed 's/./\U&/')

  if [ ! -f "$ENGINE_THEMES_DIR/hypr/$theme_name_lower.conf" ]; then
    notify-send "Pyre Error" "Theme '$theme_name_lower' not found!" -i "dialog-error"
    return 1
  fi

  cp "$ENGINE_THEMES_DIR/hypr/$theme_name_lower.conf" "$HYPR_DIR/theme.conf"
  [ -f "$ENGINE_THEMES_DIR/waybar/$theme_name_lower.css" ] && cp "$ENGINE_THEMES_DIR/waybar/$theme_name_lower.css" "$HOME/.config/waybar/theme.css"
  [ -f "$ENGINE_THEMES_DIR/wofi/$theme_name_lower.css" ] && cp "$ENGINE_THEMES_DIR/wofi/$theme_name_lower.css" "$HOME/.config/wofi/theme.css"

  local theme_wallpaper_dir="$WALLPAPER_DIR/$theme_name_lower"
  [ ! -d "$theme_wallpaper_dir" ] && theme_wallpaper_dir="$WALLPAPER_DIR"

  if [ -d "$theme_wallpaper_dir" ]; then
    local wallpaper=$(find "$theme_wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    [ -n "$wallpaper" ] && swww img "$wallpaper" --transition-type wipe --transition-pos 0.5,0.5 --transition-step 90
  fi

  reload_services
  notify-send " Pyre Engine" "Theme applied: $theme_name_capitalized" -i "preferences-desktop-theme"
  echo "$theme_name_lower" >"$STATE_FILE"
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                            5. MENUS & DISPATCHER                           │
# └────────────────────────────────────────────────────────────────────────────┘

show_theme_menu() {
  local options=$(find "$ENGINE_THEMES_DIR/hypr" -name "*.conf" -exec basename {} .conf \; | awk '{print " " toupper(substr($0,1,1))substr($0,2)}')
  local choice=$(echo -e "$options" | wofi --dmenu --prompt "Select Theme:" --width 300 --height 200)
  [ -n "$choice" ] && apply_theme "$(echo "$choice" | sed -e 's/ //' | tr '[:upper:]' '[:lower:]')"
}

show_layout_menu() {
  local options=("󰄛 Showcase" " F0urth" " Dual Pane")
  local choice=$(printf "%s\n" "${options[@]}" | wofi --dmenu --prompt "Select Layout:" --width 300 --height 120)
  case "$choice" in
  "󰄛 Showcase") (launch_showcase_layout) & ;;
  " F0urth") (launch_f0urth_layout_simple) & ;;
  " Dual Pane") (launch_dual_pane_layout) & ;;
  esac
}

show_actions_menu() {
  local options=" Toggle Waybar\n Toggle Mic\n󰹴 Switch Split\n󰍽 Autoclicker (Main)\n󰍽 Autoclicker (Right)\n󰆾 Cursor Bounce"
  local choice=$(printf "%b" "$options" | wofi --dmenu --prompt "Actions:" --width 300 --height 240)

  case "$choice" in
  " Toggle Waybar") "$SCRIPTS_DESKTOP/toggle_waybar.sh" ;;
  " Toggle Mic") "$SCRIPTS_UTILS/toggle_mic.sh" ;;
  "󰹴 Switch Split") "$SCRIPTS_UTILS/switch_split.sh" ;;
  "󰍽 Autoclicker (Main)") "$SCRIPTS_UTILS/autoclick_toggle.sh" ;;
  "󰍽 Autoclicker (Right)") "$SCRIPTS_UTILS/autoclick_right.sh" ;;
  "󰆾 Cursor Bounce") "$SCRIPTS_UTILS/cursor_bounce.sh" ;;
  esac
}

show_admin_menu() {
  kitty --class kitty-maintenance -e "$SCRIPTS_DESKTOP/sysmenu.sh"
}

show_screenshot_type_menu() {
  local options=" Area\n Window\n Fullscreen"
  local choice=$(printf "%b" "$options" | wofi --dmenu --prompt "Capture:" --width 200 --height 120)

  case "$choice" in
  " Area") "$SCRIPTS_SHOT/area.sh" ;;
  " Window") "$SCRIPTS_SHOT/window.sh" ;;
  " Fullscreen")
    sleep 0.5
    local TMP="/tmp/screenshot_full_$(date +%s).png"
    grim "$TMP"
    "$SCRIPTS_SHOT/action_menu.sh" "$TMP"
    ;;
  esac
}

show_tools_menu() {
  local options=" Screenshot (Menu)\n OCR Text\n Clipboard (Clipse)\n Notif History\n Network Status"
  local choice=$(printf "%b" "$options" | wofi --dmenu --prompt "Tools:" --width 300 --height 200)
  case "$choice" in
  " Screenshot (Menu)") show_screenshot_type_menu ;;
  " OCR Text") "$SCRIPTS_SHOT/ocr.sh" ;;
  " Clipboard (Clipse)") kitty --class clipse -e clipse ;;
  " Notif History") kitty --class kitty-notif -e "$SCRIPTS_UTILS/notif_history.sh" ;;
  " Network Status") notify-send "Network" "$("$SCRIPTS_UTILS/network-status.sh")" ;;
  esac
}

show_main_menu() {
  local options=(" Themes" " Layouts" " Tools" " Actions" " Admin" "󰒃 Powermenu" " Reload")
  local menu_string

  if [ -f "$MENU_STATE_FILE" ] && last_choice=$(<"$MENU_STATE_FILE"); then
    local other_options=$(printf "%s\n" "${options[@]}" | grep -vF -- "$last_choice")
    menu_string="$last_choice\n$other_options"
  else
    menu_string=$(printf "%s\n" "${options[@]}")
  fi

  local choice=$(echo -e "$menu_string" | wofi --dmenu --prompt "Pyre Control:" --width 300 --height 280)

  if [ -n "$choice" ]; then
    echo "$choice" >"$MENU_STATE_FILE"
    case "$choice" in
    " Themes") show_theme_menu ;;
    " Layouts") show_layout_menu ;;
    " Tools") show_tools_menu ;;
    " Actions") show_actions_menu ;;
    " Admin") show_admin_menu ;;
    "󰒃 Powermenu") "$SCRIPTS_DESKTOP/powermenu.sh" ;;
    " Reload") reload_services ;;
    esac
  fi
}
