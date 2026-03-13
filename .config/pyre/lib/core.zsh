# ┌─── 1. Environment & Paths ─────────────────────────────────────────────────┐

export PYRE_DIR="$HOME/.config/pyre"
export PYRE_STATE="$PYRE_DIR/state"
export MENU_STATE="$PYRE_DIR/main_menu_last_choice"

export HYPR_DIR="$HOME/.config/hypr"
export THEME_SRC="$HYPR_DIR/themes"
export ASSETS_DIR="$HOME/Pictures/walls"


# ┌─── 2. UI Constructor (Rofi Wrapper) ──────────────────────────────────────┐

# [FIX] 'children: ["element-text"]' forces the removal of empty icon slots
typeset -a ROFI_BASE=(
    rofi -dmenu -i
    -theme-str 'element {children: ["element-text"];} element-text {horizontal-align: 0; expand: true;}'
)

_notify() {
    # [NOTE] Unified notification portal
    notify-send "Pyre Engine" "$1" -i "${2:-preferences-desktop-theme}" -u "${3:-normal}"
}

_rofi_menu() {
    local prompt="$1"
    local width="${2:-300}"
    local lines="${3:-8}"
    local input="$4"

    local entry_flag="entry {enabled: true;}"
    [[ "$lines" -lt 10 ]] && entry_flag="entry {enabled: false;}"

    print -n "$input" | "${ROFI_BASE[@]}" \
        -p "$prompt" \
        -theme-str "window {width: ${width}px;} listview {lines: $lines;} $entry_flag mode-switcher {enabled: false;}"
}


# ┌─── 3. System Utilities ────────────────────────────────────────────────────┐

_is_running() {
    pgrep -x "$1" >/dev/null 2>&1
}

check_dependencies() {
    local -a deps=(rofi swww kitty notify-send hyprctl jq)
    local -a _missing=()

    for _cmd in "${deps[@]}"; do
        if ! command -v "$_cmd" &>/dev/null; then
            _missing+=("$_cmd")
        fi
    done

    # [WARN] Halt execution if core tools are missing
    if (( ${#_missing} > 0 )); then
        echo "[CRIT] Missing dependencies: ${_missing[@]}"
        exit 1
    fi
}
