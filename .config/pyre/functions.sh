#!/usr/bin/env zsh
# ┌─── Pyre Engine - Logic Library ────────────────────────────────────────────┐
# │  [INFO] Core functions sourced by the main entry point.                    │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── 1. Configuration & Paths ───────────────────────────────────────────────┐

# --- Assets & State ---
WALLPAPER_DIR="$HOME/Pictures/walls"
STATE_FILE="$HOME/.config/pyre/state"
MENU_STATE_FILE="$HOME/.config/pyre/main_menu_last_choice"

# --- System Paths ---
HYPR_DIR="$HOME/.config/hypr"
PYRE_LAYOUTS="$HOME/.config/pyre/layouts"

SCRIPTS_CORE="$HOME/.local/bin/core"
SCRIPTS_MODULES="$HOME/.local/bin/modules"
SCRIPTS_ACTIONS="$HOME/.local/bin/actions"
SCRIPTS_SHOT="$HOME/.local/bin/screenshots"
SCRIPTS_CLICKER="$SCRIPTS_ACTIONS/clicker"

# Legacy Aliases
SCRIPTS_UTILS="$SCRIPTS_ACTIONS"
SCRIPTS_DESKTOP="$SCRIPTS_CORE"
ENGINE_THEMES_DIR="$HYPR_DIR/themes"

# --- Automation Settings ---
# [CONFIG] Themes available for cycling via 'pyre theme next'.
THEME_CYCLE_LIST=("Mocha")


# ┌─── 2. Core Functions ──────────────────────────────────────────────────────┐

# [CRITICAL] Verify system requirements before execution.
check_dependencies() {
    local -a missing_cmds=()
    for cmd in wofi swww kitty notify-send hyprctl socat jq; do
        # [FIX] Use standard 'command -v' to fix syntax highlighting issues
        if ! command -v "$cmd" &>/dev/null; then
            notify-send "Pyre Error" "Required command not found: $cmd" -i "dialog-error"
            missing_cmds+=("$cmd")
        fi
    done
    (( ${#missing_cmds} > 0 )) && exit 1
}

# [INFO] Restart UI components to apply changes.
reload_services() {
    hyprctl reload

    # [FIX] Smart Waybar Reload (Signal vs Restart)
    if pgrep -x "waybar" >/dev/null; then
        pkill -SIGUSR2 waybar
    else
        waybar &!
    fi

    pkill dunst; dunst &!

    if ! pgrep -x "swww-daemon" >/dev/null; then
        swww-daemon &!
    fi

    # [FIX] Re-apply keyboard settings (sometimes lost on reload)
    "$SCRIPTS_MODULES/kb_layout.sh" >/dev/null
}


# ┌─── 3. Layout Launchers ────────────────────────────────────────────────────┐

launch_showcase_layout() {
    hyprctl keyword source "$PYRE_LAYOUTS/showcase.conf"
    sleep 0.1
    
    # [INFO] Launch visual terminals
    # [OPTIMIZATION] Using '&!' to disown processes immediately in Zsh
    kitty --title "fastfetch" -o font_size=10.0 -o window_padding_width="10 10 10 0" sh -c "fastfetch; sleep infinity" &!
    sleep 0.2
    
    kitty --title "tty-clock" -o font_size=10.0 -o window_padding_width=0 tty-clock -c -C 4 &!
    kitty --title "cava"      -o font_size=10.0 -o window_padding_width=0 cava &!
    kitty --title "unimatrix" -o font_size=10.0 -o window_padding_width=0 unimatrix -s 90 &!
    kitty --title "pipes"     -o font_size=10.0 -o window_padding_width=0 pipes.sh &!
}

launch_dual_pane_layout() {
    hyprctl keyword source "$PYRE_LAYOUTS/dual.conf"
    
    if (( ${+commands[thunar]} )); then 
        thunar &!
    else 
        kitty --title "file-manager" yazi &!
    fi
    
    sleep 0.3
    kitty -o font_size=10.0 --title "fm-yazi" yazi &!
    
    sleep 1
    hyprctl keyword source "$PYRE_LAYOUTS/reset.conf"
}


# ┌─── 4. Theme & Wallpaper Engine ────────────────────────────────────────────┐

# --- Automation Logic ---

switch_theme_next() {
    # [LOGIC] Cycles through THEME_CYCLE_LIST using native Zsh arrays.
    if [[ -f "$STATE_FILE" ]]; then
        local current_theme=$(<"$STATE_FILE")
        
        # [OPTIMIZATION] Zsh native index lookup (no loops needed!)
        local idx=${THEME_CYCLE_LIST[(i)$current_theme]}
        
        # If index > size, theme not found, start from 1. Else next.
        if (( idx > ${#THEME_CYCLE_LIST} )); then
            idx=1
        else
            idx=$(( (idx % ${#THEME_CYCLE_LIST}) + 1 ))
        fi
        
        local next_theme="${THEME_CYCLE_LIST[$idx]}"

        # [OPTIMIZATION] Skip reload if theme hasn't changed
        if [[ "$next_theme" != "$current_theme" ]]; then
            apply_theme "$next_theme"
        else
            notify-send "Pyre" "No other themes configured." -i "dialog-information"
        fi
    else
        apply_theme "${THEME_CYCLE_LIST[1]}"
    fi
}

change_wallpaper_random() {
    # [LOGIC] Picks a random wallpaper using Zsh globs (no 'find' or 'shuf').
    local current_state=$(<"$STATE_FILE" 2>/dev/null || echo "Mocha")
    
    # [OPTIMIZATION] Zsh Modifier ':l' (lowercase) instead of 'tr'
    local theme_wall_dir="$WALLPAPER_DIR/${current_state:l}"
    
    # Fallback
    [[ ! -d "$theme_wall_dir" ]] && theme_wall_dir="$WALLPAPER_DIR"

    if [[ -d "$theme_wall_dir" ]]; then
        # [OPTIMIZATION] Native Zsh globbing with (N)ullglob to find images
        local -a walls=("$theme_wall_dir"/*.(jpg|jpeg|png)(N))
        
        if (( ${#walls} > 0 )); then
            # Pick random element: array[RANDOM % size + 1]
            local wallpaper="${walls[$RANDOM % ${#walls} + 1]}"
            
            swww img "$wallpaper" \
                --transition-type grow \
                --transition-pos 0.5,0.5 \
                --transition-duration 1.2 \
                --transition-fps 60
        fi
    fi
}

# --- Core Logic ---

apply_theme() {
    local theme_name_lower="${1:l}" # Zsh: lowercase
    local theme_name_capitalized="${1:(C)}" # Zsh: Capitalize

    # [CRITICAL] Validate theme existence
    if [[ ! -f "$ENGINE_THEMES_DIR/hypr/$theme_name_lower.conf" ]]; then
        notify-send "Pyre Error" "Theme '$theme_name_lower' not found!" -i "dialog-error"
        return 1
    fi

    # [INFO] Apply configurations
    cp "$ENGINE_THEMES_DIR/hypr/$theme_name_lower.conf" "$HYPR_DIR/theme.conf"
    
    [[ -f "$ENGINE_THEMES_DIR/waybar/$theme_name_lower.css" ]] && \
        cp "$ENGINE_THEMES_DIR/waybar/$theme_name_lower.css" "$HOME/.config/waybar/theme.css"
        
    [[ -f "$ENGINE_THEMES_DIR/wofi/$theme_name_lower.css" ]] && \
        cp "$ENGINE_THEMES_DIR/wofi/$theme_name_lower.css" "$HOME/.config/wofi/theme.css"

    # [INFO] Apply wallpaper (First run/Theme switch)
    local theme_wallpaper_dir="$WALLPAPER_DIR/$theme_name_lower"
    [[ ! -d "$theme_wallpaper_dir" ]] && theme_wallpaper_dir="$WALLPAPER_DIR"

    if [[ -d "$theme_wallpaper_dir" ]]; then
        local -a walls=("$theme_wallpaper_dir"/*.(jpg|jpeg|png)(N))
        if (( ${#walls} > 0 )); then
            local wallpaper="${walls[$RANDOM % ${#walls} + 1]}"
            swww img "$wallpaper" --transition-type wipe --transition-pos 0.5,0.5 --transition-step 90
        fi
    fi

    # [INFO] Finalize
    reload_services
    notify-send " Pyre Engine" "Theme applied: $theme_name_capitalized" -i "preferences-desktop-theme"
    echo "$theme_name_lower" >"$STATE_FILE"
}


# ┌─── 5. Menus & Dispatcher ──────────────────────────────────────────────────┐

show_theme_menu() {
    # [OPTIMIZATION] Build list using Zsh loops instead of find|basename|awk
    local list=""
    for f in "$ENGINE_THEMES_DIR/hypr"/*.conf(N); do
        local name="${f:t:r}" # tail, remove ext
        # Format: Icon + Capitalized Name
        list+=" ${name:(C)}\n"
    done
        
    local choice=$(print -n "$list" | wofi --dmenu --prompt "Select Theme:" --width 300 --height 200)
    
    # Remove icon and lowercase to apply
    [[ -n "$choice" ]] && apply_theme "${${choice# }:l}"
}

show_wallpaper_menu() {
    # [LOGIC] Interactive wallpaper picker for the current theme.
    local current_state=$(<"$STATE_FILE" 2>/dev/null || echo "Mocha")
    local theme_wall_dir="$WALLPAPER_DIR/${current_state:l}"
    
    # Fallback to all wallpapers if theme dir is empty/missing
    [[ ! -d "$theme_wall_dir" ]] && theme_wall_dir="$WALLPAPER_DIR"

    # [OPTIMIZATION] Zsh Globbing to get files
    local -a walls=("$theme_wall_dir"/*.(jpg|jpeg|png|gif)(N))
    
    if (( ${#walls} == 0 )); then
        notify-send "Pyre" "No wallpapers found in $theme_wall_dir" -i "dialog-error"
        return 1
    fi

    # Generate list of filenames for Wofi
    local list=""
    for w in "${walls[@]}"; do
        list+="${w:t}\n" # :t = tail (filename only)
    done

    local selected_name=$(print -n "$list" | sort | wofi --dmenu --prompt "Select Wallpaper:" --width 500 --height 600 -i)

    if [[ -n "$selected_name" ]]; then
        # Reconstruct full path
        local full_path="$theme_wall_dir/$selected_name"
        
        if [[ -f "$full_path" ]]; then
            swww img "$full_path" \
                --transition-type grow \
                --transition-pos 0.5,0.5 \
                --transition-duration 1.2 \
                --transition-fps 60
            notify-send "Pyre" "Wallpaper set: $selected_name" -i "preferences-desktop-wallpaper"
        fi
    fi
}

show_layout_menu() {
    local -a options=("󰄛 Showcase" " Dual Pane")
    # Zsh: print -l prints array elements on new lines
    local choice=$(print -l "${options[@]}" | wofi --dmenu --prompt "Select Layout:" --width 300 --height 120)
    
    case "$choice" in
        "󰄛 Showcase")  (launch_showcase_layout) &! ;;
        " Dual Pane") (launch_dual_pane_layout) &! ;;
    esac
}

show_actions_menu() {
    local options=" Toggle Waybar\n Toggle Mic\n󰹴 Switch Split\n󰍽 Autoclicker (Main)\n󰍽 Autoclicker (Right)\n󰆾 Cursor Bounce"
    local choice=$(print -n "$options" | wofi --dmenu --prompt "Actions:" --width 300 --height 240)

    case "$choice" in
        " Toggle Waybar")         "$SCRIPTS_ACTIONS/waybar_toggle.sh" ;;
        " Toggle Mic")            "$SCRIPTS_ACTIONS/mic_toggle.sh" ;;
        "󰹴 Switch Split")          "$SCRIPTS_ACTIONS/split_switch.sh" ;;
        "󰍽 Autoclicker (Main)")    "$SCRIPTS_CLICKER/clicker.sh" ;;
        "󰍽 Autoclicker (Right)")   "$SCRIPTS_CLICKER/mouse.sh" right ;;
        "󰆾 Cursor Bounce")         "$SCRIPTS_ACTIONS/cursor_bounce.sh" ;;
    esac
}

show_admin_menu() {
    kitty --class kitty-maintenance -e "$SCRIPTS_DESKTOP/sysmenu.sh"
}

show_screenshot_type_menu() {
    local options=" Area\n Window\n Fullscreen"
    local choice=$(print -n "$options" | wofi --dmenu --prompt "Capture:" --width 200 --height 120)

    case "$choice" in
        " Area")       "$SCRIPTS_SHOT/area.sh" ;;
        " Window")     "$SCRIPTS_SHOT/window.sh" ;;
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
    local choice=$(print -n "$options" | wofi --dmenu --prompt "Tools:" --width 300 --height 200)
    
    case "$choice" in
        " Screenshot (Menu)")     show_screenshot_type_menu ;;
        " OCR Text")              "$SCRIPTS_SHOT/ocr.sh" ;;
        " Clipboard (Clipse)")    kitty --class clipse -e clipse ;;
        " Notif History")         kitty --class kitty-notif -e "$SCRIPTS_UTILS/notif_history.sh" ;;
        " Network Status")        notify-send "Network" "$("$SCRIPTS_MODULES/network.sh")" ;;
    esac
}

show_wallpaper_control_menu() {
    local options=" Random\n Select"
    local choice=$(print -n "$options" | wofi --dmenu --prompt "Wallpaper:" --width 250 --height 150)

    case "$choice" in
        " Random") change_wallpaper_random ;;
        " Select") show_wallpaper_menu ;;
    esac
}

show_main_menu() {
    # [CONFIG] Added "Wallpapers" to the list
    local -a options=(" Themes" " Wallpapers" " Layouts" " Tools" " Actions" " Admin" "󰒃 Powermenu" " Reload")
    local menu_string

    # [LOGIC] Remember last choice for better UX
    if [[ -f "$MENU_STATE_FILE" ]]; then
        local last_choice=$(<"$MENU_STATE_FILE")
        # Zsh array filtering: Remove elements matching the pattern "$last_choice"
        local -a other_options=(${options:#"$last_choice"})
        menu_string="$last_choice\n$(print -l "${other_options[@]}")"
    else
        menu_string=$(print -l "${options[@]}")
    fi

    local choice=$(print -n "$menu_string" | wofi --dmenu --prompt "Pyre Control:" --width 300 --height 320)

    if [[ -n "$choice" ]]; then
        print "$choice" >"$MENU_STATE_FILE"
        case "$choice" in
            " Themes")        show_theme_menu ;;
            " Wallpapers")    show_wallpaper_control_menu ;;  # [NEW] Link to wallpaper menu
            " Layouts")       show_layout_menu ;;
            " Tools")         show_tools_menu ;;
            " Actions")       show_actions_menu ;;
            " Admin")         show_admin_menu ;;
            "󰒃 Powermenu")     "$SCRIPTS_DESKTOP/powermenu.sh" ;;
            " Reload")        reload_services ;;
        esac
    fi
}
