# ┌─── 1. Wallpaper Logic ─────────────────────────────────────────────────────┐

_set_wallpaper_random() {
    local _theme=$(<"$PYRE_STATE" 2>/dev/null || echo "mocha")
    local _dir="$ASSETS_DIR/$_theme"
    [[ ! -d "$_dir" ]] && _dir="$ASSETS_DIR"

    local -a _walls=($_dir/*.(jpg|jpeg|png|webp)(N))
    (( ${#_walls} > 0 )) && apply_wallpaper "${_walls[$RANDOM % ${#_walls} + 1]}"
}

apply_wallpaper() {
    local _img="$1"
    [[ ! -f "$_img" ]] && return 1

    # [NOTE] SWWW transition parameters
    local _trans="--transition-type grow --transition-pos 0.5,0.5 --transition-duration 1.2"

    _is_running swww-daemon || swww init
    swww img "$_img" ${=_trans}

    # [WARN] Pywal can be slow; executed in background to prevent UI lock
    local _theme=$(<"$PYRE_STATE" 2>/dev/null)
    if [[ "$_theme" != "mocha" ]]; then
        (wal -i "$_img" -n -q --backend colorz) &!
    fi
}


# ┌─── 2. Theme Management ────────────────────────────────────────────────────┐

apply_theme() {
    local _theme="${1:l}"
    local _theme_conf="$THEME_SRC/hypr/$_theme.conf"

    # [FIX] Fallback to Catppuccin Mocha if requested theme is missing
    if [[ ! -f "$_theme_conf" ]]; then
        _notify "Theme '$_theme' missing. Falling back to Mocha." "dialog-warning"
        _theme="mocha"
        _theme_conf="$THEME_SRC/hypr/mocha.conf"
    fi

    # ┌─── 2.1. Symlink Rotation ──────────────────────────────────────────┐

    ln -sf "$_theme_conf" "$HYPR_DIR/theme.conf"

    [[ -f "$THEME_SRC/waybar/$_theme.css" ]] && \
        ln -sf "$THEME_SRC/waybar/$_theme.css" "$HOME/.config/waybar/theme.css"

    [[ -f "$THEME_SRC/rofi/$_theme.rasi" ]] && \
        ln -sf "$THEME_SRC/rofi/$_theme.rasi" "$HOME/.config/rofi/theme.rasi"

    # ┌─── 2.2. State Persistence ─────────────────────────────────────────┐

    echo "$_theme" > "$PYRE_STATE"
    
    _set_wallpaper_random

    reload_services
    _notify "Pyre Theme: ${(C)_theme}" "preferences-desktop-theme"
}


# ┌─── 3. Service Orchestration ───────────────────────────────────────────────┐

reload_services() {
    hyprctl reload

    # [NOTE] SIGUSR2 is faster than pkill/restart for Waybar
    if _is_running waybar; then
        pkill -SIGUSR2 waybar
    else
        waybar &!
    fi

    pkill dunst
    dunst &!

    # [FIX] Force update keyboard layout indicator
    "$HOME/.local/bin/modules/kb_layout.sh" >/dev/null 2>&1 &!
}
