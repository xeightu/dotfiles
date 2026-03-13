# ┌─── 1. Interactive Menus ───────────────────────────────────────────────────┐

show_main_menu() {
    local -a _items=(
        " Themes" " Wallpapers" " Layouts" 
        " Tools" " Actions" " Admin" 
        "󰒃 Power" " Reload"
    )

    local _last_choice=$(<"$MENU_STATE" 2>/dev/null)
    local _menu_string

    if [[ -n "$_last_choice" ]]; then
        # [FIX] Zsh array filtering to move last_choice to the head of the list
        local -a _other_options=(${_items:#$_last_choice})
        _menu_string="$_last_choice\n$(print -l "${_other_options[@]}")"
    else
        _menu_string=$(print -l "${_items[@]}")
    fi

    local _choice=$(_rofi_menu "Pyre Control" 280 8 "$_menu_string")

    if [[ -n "$_choice" ]]; then
        echo "$_choice" > "$MENU_STATE"
        case "$_choice" in
            " Themes")     show_theme_menu ;;
            " Wallpapers") show_wallpaper_menu ;;
            " Layouts")    show_layout_menu ;;
            " Actions")    show_actions_menu ;;
            " Admin")      kitty --class maint -e "$HOME/.local/bin/desktop/sysmenu.sh" ;;
            "󰒃 Power")      "$HOME/.local/bin/actions/powermenu.sh" ;;
            " Reload")     reload_services ;;
        esac
    fi
}


# ┌─── 2. Dynamic Sub-Menus ───────────────────────────────────────────────────┐

show_theme_menu() {
    local -a _themes=("$THEME_SRC/hypr"/*.conf(N))
    local _list=""

    for _path in "${_themes[@]}"; do
        _list+=" ${_path:t:r:(C)}\n"
    done

    local _choice=$(_rofi_menu "Select Theme:" 300 10 "$_list")
    
    # [NOTE] Strip icon and lowercase for file matching
    [[ -n "$_choice" ]] && apply_theme "${${_choice# }:l}"
}

show_wallpaper_menu() {
    local _current_theme=$(<"$PYRE_STATE" 2>/dev/null || echo "mocha")
    local _target_dir="$ASSETS_DIR/$_current_theme"
    [[ ! -d "$_target_dir" ]] && _target_dir="$ASSETS_DIR"

    local -a _walls=("$_target_dir"/*.(jpg|jpeg|png|webp)(N))
    (( ${#_walls} == 0 )) && { _notify "No wallpapers in $_target_dir" "dialog-error"; return 1 }

    local _list=$(print -l "${(@)_walls:t}" | sort)

    # [NOTE] Wider window (500px) to accommodate potentially long filenames
    local _selected=$(_rofi_menu "Wallpaper:" 500 12 "$_list")
    
    [[ -n "$_selected" ]] && apply_wallpaper "$_target_dir/$_selected"
}


# ┌─── 3. Functional Sub-Menus ────────────────────────────────────────────────┐

show_layout_menu() {
    local _options="󰅪 Mainframe\n Dual Pane\n Starship"
    local _choice=$(_rofi_menu "Layout:" 280 3 "$_options")

    case "$_choice" in
        "󰅪 Mainframe") apply_layout_by_name "mainframe" ;;
        " Dual Pane") apply_layout_by_name "dual" ;;
        " Starship")  apply_layout_by_name "starship" ;;
    esac
}

show_actions_menu() {
    local _options=" Toggle Waybar\n Toggle Mic\n󰹴 Split Switch\n󰍽 Autoclicker\n󰆾 Cursor Bounce"
    local _choice=$(_rofi_menu "Actions:" 300 5 "$_options")

    case "$_choice" in
        " Toggle Waybar")   "$HOME/.local/bin/actions/waybar_toggle.sh" ;;
        " Toggle Mic")      "$HOME/.local/bin/actions/mic_toggle.sh" ;;
        "󰹴 Split Switch")    "$HOME/.local/bin/actions/split_switch.sh" ;;
        "󰍽 Autoclicker")     "$HOME/.local/bin/actions/clicker/clicker.sh" ;;
        "󰆾 Cursor Bounce")   "$HOME/.local/bin/actions/cursor_bounce.sh" ;;
    esac
}
