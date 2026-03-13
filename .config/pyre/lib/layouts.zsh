# ┌─── 1. Showcase Layout (The "Rice" Display) ────────────────────────────────┐

launch_showcase_layout() {
    hyprctl keyword source "$PYRE_DIR/layouts/showcase.conf"

    # [FIX] Using '&!' (disown) to prevent terminal hang on script exit
    # [NOTE] Specific titles used for windowrule matching
    kitty --title "fastfetch" -o font_size=10.0 sh -c "fastfetch; sleep infinity" &!
    
    # [FIX] Brief delay ensures Hyprland processes the first window before the next
    sleep 0.1
    
    kitty --title "tty-clock" -o font_size=10.0 tty-clock -c -C 4 &!
    kitty --title "cava"      -o font_size=10.0 cava &!
    kitty --title "unimatrix" -o font_size=10.0 unimatrix -s 94 &!
    kitty --title "pipes"     -o font_size=10.0 pipes.sh -p 2 -t 1 -s 13 -f 60 -r 1500 &!
}


# ┌─── 2. Dual Pane Layout (File Management) ──────────────────────────────────┐

launch_dual_pane_layout() {
    hyprctl keyword source "$PYRE_DIR/layouts/dual.conf"
    
    if (( ${+commands[thunar]} )); then
        thunar &!
    else
        kitty --title "file-manager" yazi &!
    fi

    sleep 0.2
    kitty --title "fm-yazi" -o font_size=10.0 yazi &!
    
    # [FIX] Wait for windows to map, then revert to global tiling rules
    sleep 0.5
    hyprctl keyword source "$PYRE_DIR/layouts/reset.conf"
}


# ┌─── 3. Starship Layout (Command Bridge) ────────────────────────────────────┐

launch_astro_layout() {
    hyprctl keyword source "$PYRE_DIR/layouts/astro.conf"
    
    # [FIX] 'astroterm' must be in $PATH
    kitty --title "astro_main" -o font_size=12.0 \
        astroterm -c -u -C -r 2.5 -t 4 -l 1 -s 200 &!
    
    # [TODO] Add secondary sensor monitoring windows if needed
    _notify "Starship Bridge Activated" "preferences-desktop-display"
}


# ┌─── 4. Dispatcher ──────────────────────────────────────────────────────────┐

apply_layout_by_name() {
    local _name="${1:l}"
    
    case "$_name" in
        "mainframe"|"showcase") launch_showcase_layout ;;
        "dual"*)                launch_dual_pane_layout ;;
        "starship"|"astro")     launch_astro_layout ;;
        *)                      _notify "Layout '$_name' not recognized." "dialog-error" ;;
    esac
}
