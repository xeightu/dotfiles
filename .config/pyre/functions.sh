#!/usr/bin/env zsh

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

# Base Directories
HOME_DIR="${HOME:-/home/$USER}"
CONF_DIR="$HOME_DIR/.config"
CACHE_DIR="$HOME_DIR/.cache/pyre"
ASSETS_DIR="$HOME_DIR/Pictures/walls"

# Pyre Internal Paths
PYRE_DIR="$CONF_DIR/pyre"
PYRE_STATE="$PYRE_DIR/state"
PYRE_LAYOUTS="$PYRE_DIR/layouts"
MENU_STATE="$PYRE_DIR/main_menu_last_choice"

# External Configs
HYPR_DIR="$CONF_DIR/hypr"
THEME_SRC="$HYPR_DIR/themes"

# Script Modules
SCRIPTS_ROOT="$HOME_DIR/.local/bin"
SCRIPTS_DESK="$SCRIPTS_ROOT/desktop"
SCRIPTS_MODS="$SCRIPTS_ROOT/modules"
SCRIPTS_ACTS="$SCRIPTS_ROOT/actions"
SCRIPTS_CLICK="$SCRIPTS_ACTS/clicker"

# UI Constants
typeset -a WOFI_CMD=(wofi --dmenu -i)
SWWW_TRANS="--transition-type grow --transition-pos 0.5,0.5 --transition-duration 1.2 --transition-fps 60"

# [NOTE] Ensure environment persistence directory exists
mkdir -p "$PYRE_DIR"


# ┌─── 2. System Helpers ──────────────────────────────────────────────────────┐

_notify() {
    notify-send "$1" "$2" -i "${3:-dialog-information}" -u "${4:-normal}"
}

_is_running() {
    pgrep -x "$1" >/dev/null 2>&1
}

# Unified Wofi Launcher
_wofi_menu() {
    local _prompt="$1"
    local _width="${2:-280}"
    local _height="${3:-200}"

    "${WOFI_CMD[@]}" \
        --prompt "$_prompt" \
        --width "$_width" \
        --height "$_height"
}

_set_wallpaper() {
    local _img="$1"
    [[ ! -f "$_img" ]] && return 1

    # [FIX] Initialize swww daemon if it crashed or was never started
    if _is_running swww-daemon; then
        swww img "$_img" ${=SWWW_TRANS}
    else
        swww init && swww img "$_img" ${=SWWW_TRANS}
    fi
}


# ┌─── 3. Core Logic ──────────────────────────────────────────────────────────┐

check_dependencies() {
    local _deps=(wofi swww kitty notify-send hyprctl socat jq)
    local _missing=()

    for _cmd in "${_deps[@]}"; do
        if ! command -v "$_cmd" &>/dev/null; then
            _missing+=("$_cmd")
        fi
    done

    (( ${#_missing} > 0 )) && exit 1
}

reload_services() {
    hyprctl reload

    # Waybar toggle/reload logic
    if _is_running waybar; then
        pkill -SIGUSR2 waybar
    else
        waybar &!
    fi

    # Restart notifications and background daemons
    pkill dunst; dunst &!
    _is_running swww-daemon || swww-daemon &!
    
    # Refresh keyboard layout state
    "$SCRIPTS_MODS/kb_layout.sh" >/dev/null 2>&1
}

apply_theme() {
    local _theme_name="${1:l}"
    local _theme_conf="$THEME_SRC/hypr/$_theme_name.conf"

    if [[ ! -f "$_theme_conf" ]]; then
        _notify "Error" "Theme '$_theme_name' not found." "dialog-error"
        return 1
    fi

    # [NOTE] Atomic theme switching via symlinks for Hyprland, Waybar and Wofi
    ln -sf "$_theme_conf" "$HYPR_DIR/theme.conf"

    [[ -f "$THEME_SRC/waybar/$_theme_name.css" ]] && \
        ln -sf "$THEME_SRC/waybar/$_theme_name.css" "$CONF_DIR/waybar/theme.css"

    [[ -f "$THEME_SRC/wofi/$_theme_name.css" ]] && \
        ln -sf "$THEME_SRC/wofi/$_theme_name.css" "$CONF_DIR/wofi/theme.css"

    # Wallpapers handled by theme-specific subdirectories
    local _theme_wall_dir="$ASSETS_DIR/$_theme_name"
    [[ ! -d "$_theme_wall_dir" ]] && _theme_wall_dir="$ASSETS_DIR"

    local -a _walls=("$_theme_wall_dir"/*.(jpg|jpeg|png)(N))
    
    if (( ${#_walls} > 0 )); then
        _set_wallpaper "${_walls[$RANDOM % ${#_walls} + 1]}"
    fi

    echo "$_theme_name" > "$PYRE_STATE"
    reload_services
    _notify "Pyre Engine" "Active: ${_theme_name:(C)}" "preferences-desktop-theme"
}


# ┌─── 4. Layout Launchers ────────────────────────────────────────────────────┐

launch_showcase_layout() {
    hyprctl keyword source "$PYRE_LAYOUTS/showcase.conf"
    
    # [NOTE] Spawn terminal-based eye candy with infinity sleep to keep windows open
    kitty --title "fastfetch" -o font_size=10.0 sh -c "fastfetch; sleep infinity" &!
    sleep 0.1
    kitty --title "tty-clock" -o font_size=10.0 tty-clock -c -C 4 &!
    kitty --title "cava"      -o font_size=10.0 cava &!
    kitty --title "unimatrix" -o font_size=10.0 unimatrix -s 94 &!
    kitty --title "pipes"     -o font_size=10.0 pipes.sh -p 2 -t 1 -s 13 -f 60 -r 1500 &!
}

launch_dual_pane_layout() {
    hyprctl keyword source "$PYRE_LAYOUTS/dual.conf"
    
    # [NOTE] Prefer GUI file manager if available, otherwise fallback to Yazi
    if (( ${+commands[thunar]} )); then
        thunar &!
    else
        kitty --title "file-manager" yazi &!
    fi

    sleep 0.2
    kitty --title "fm-yazi" -o font_size=10.0 yazi &!
    sleep 0.5
    # Reset layout to prevent new windows from following 'dual' rules
    hyprctl keyword source "$PYRE_LAYOUTS/reset.conf"
}

launch_astro_layout() {
    hyprctl keyword source "$PYRE_LAYOUTS/astro.conf"
    kitty --title "astroterm" -o font_size=12.0 astroterm -c -u -C -r 2.5 -t 4 -l 1 -s 200 &!
}


# ┌─── 5. Interactive Menus ───────────────────────────────────────────────────┐

show_theme_menu() {
    local -a _themes=("$THEME_SRC/hypr"/*.conf(N))
    local _list=""
    
    for _path in "${_themes[@]}"; do
        _list+=" ${_path:t:r:(C)}\n"
    done

    local _choice=$(print -n "$_list" | _wofi_menu "Select Theme:")
    [[ -n "$_choice" ]] && apply_theme "${${_choice# }:l}"
}

show_wallpaper_menu() {
    local _current_theme=$(<"$PYRE_STATE" 2>/dev/null || echo "mocha")
    local _target_dir="$ASSETS_DIR/$_current_theme"
    [[ ! -d "$_target_dir" ]] && _target_dir="$ASSETS_DIR"

    local -a _walls=("$_target_dir"/*.(jpg|jpeg|png)(N))
    (( ${#_walls} == 0 )) && return 1

    local _list=""
    for _w in "${_walls[@]}"; do
        _list+="${_w:t}\n"
    done

    local _selected=$(print -n "$_list" | sort | _wofi_menu "Wallpaper:" "500" "600")
    [[ -n "$_selected" ]] && _set_wallpaper "$_target_dir/$_selected"
}

show_layout_menu() {
    local _options="󰅪 Mainframe\n Dual Pane\n Starship"
    local _choice=$(print -n "$_options" | _wofi_menu "Layout:" "280" "190")

    case "$_choice" in
        *"Mainframe") launch_showcase_layout ;;
        *"Dual"*)    launch_dual_pane_layout ;;
        *"Astro"*)   launch_astro_layout ;;
    esac
}

show_actions_menu() {
    local _options=" Toggle Waybar\n Toggle Mic\n󰹴 Split Switch\n󰍽 Autoclicker\n󰆾 Cursor Bounce"
    local _choice=$(print -n "$_options" | _wofi_menu "Actions:" "240" "280")

    case "$_choice" in
        " Toggle Waybar")   "$SCRIPTS_ACTS/waybar_toggle.sh" ;;
        " Toggle Mic")      "$SCRIPTS_ACTS/mic_toggle.sh" ;;
        "󰹴 Split Switch")    "$SCRIPTS_ACTS/split_switch.sh" ;;
        "󰍽 Autoclicker")     "$SCRIPTS_CLICK/clicker.sh" ;;
        "󰆾 Cursor Bounce")   "$SCRIPTS_ACTS/cursor_bounce.sh" ;;
    esac
}

show_main_menu() {
    local -a _items=(
        " Themes" " Wallpapers" " Layouts" 
        " Tools" " Actions" " Admin" 
        "󰒃 Powermenu" " Reload"
    )

    local _last_choice=$(<"$MENU_STATE" 2>/dev/null)
    local _menu_string

    # [NOTE] Sort items so the last used choice appears first for ergonomics
    if [[ -n "$_last_choice" ]]; then
        local -a _other_options=(${_items:#$_last_choice})
        _menu_string="$_last_choice\n$(print -l "${_other_options[@]}")"
    else
        _menu_string=$(print -l "${_items[@]}")
    fi

    local _choice=$(print -n "$_menu_string" | _wofi_menu "Pyre Control" "240" "400")

    if [[ -n "$_choice" ]]; then
        echo "$_choice" > "$MENU_STATE"
        case "$_choice" in
            " Themes")     show_theme_menu ;;
            " Wallpapers") show_wallpaper_menu ;;
            " Layouts")    show_layout_menu ;;
            " Actions")    show_actions_menu ;;
            " Admin")      kitty --class maint -e "$SCRIPTS_DESK/sysmenu.sh" ;;
            "󰒃 Powermenu")  "$SCRIPTS_ACTS/powermenu.sh" ;;
            " Reload")     reload_services ;;
        esac
    fi
}
