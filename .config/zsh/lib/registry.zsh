# ┌─── Module: Registry (Data) ────────────────────────────────────────────────┐
# │  [INFO] Centralized storage for paths, arrays, and visual assets.          │
# │  [NOTE] This file MUST be sourced before any function in lib/ is called.   │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── Global Constants ────────────────────────────────────────────────────────┐

# [CFG] Visual indicators for Metro UI
export METRO_ICON_FILE=""                     # File icon
export METRO_ICON_DIR=""                      # Directory icon
export METRO_ICON_CONF=""                     # Config icon


# [OPT] Dynamic path resolution
local zen_paths=($HOME/.zen/*"Default (release)"(/N))
typeset -g zen_profile="${zen_paths[1]:-$HOME/.zen/default}" # Browser profile path
typeset -g bin_dir="$HOME/.local/bin"                       # Local binaries path


# [OPT] Internal state cache
typeset -g _metro_menu_cache=""


# ┌── Registry: Metro Modules (Directories) ───────────────────────────────────┐

# [CFG] Folders opened via file picker (edit) or tree view (view).
typeset -gA metro_modules
metro_modules=(
    # --- Desktop Environment ---
    [hypr]="$HYPR"
    [waybar]="$DOTS/waybar"
    [wofi]="$DOTS/wofi"
    [rofi]="$DOTS/rofi"
    [kitty]="$DOTS/kitty"
    [z]="$ZSH_CONFIG_DIR"
    [zlib]="$ZSH_CONFIG_DIR/lib"
    [zapps]="$ZSH_CONFIG_DIR/apps"
    [scripts]="$bin_dir"

    # --- Projects ---
    [pyre]="$DOTS/pyre"
    [sre]="$HOME/Projects/SRE-Elite-Path"
    [labs]="$HOME/Projects/SRE-Elite-Path/02_Lab_Journal"
    [phoenix]="$HOME/Projects/SRE-Elite-Path/03_Projects/Project_Phoenix"
)


# ┌── Registry: Metro Files (Direct Access) ───────────────────────────────────┐

# [CFG] Specific files opened directly in the editor.
typeset -gA metro_files
metro_files=(
    # --- WM: Hyprland ---
    [hconf]="$HYPR/hyprland.conf"
    [hbinds]="$HYPR/keybinds.conf"
    [hdecor]="$HYPR/decoration.conf"
    [hrules]="$HYPR/rules.conf"
    [hcolors]="$HYPR/colors.conf"
    [hlock]="$HYPR/hyprlock.conf"
    [hidle]="$HYPR/hypridle.conf"


    # --- Bar: Waybar ---
    [wbconf]="$DOTS/waybar/config"
    [wbstyle]="$DOTS/waybar/style.css"
    [wbcolors]="$DOTS/waybar/colors.css"


    # --- Launcher: Wofi ---
    [wfconf]="$DOTS/wofi/config"
    [wfstyle]="$DOTS/wofi/style.css"
    [wfcolors]="$DOTS/wofi/colors.css"


    # --- Launcher: Rofi ---
    [roficonf]="$DOTS/rofi/config.rasi"
    [rofistyle]="$DOTS/rofi/style.rasi"
    [roficolors]="$DOTS/rofi/colors.rasi"


    # --- Terminal: Kitty ---
    [kconf]="$DOTS/kitty/kitty.conf"
    [kcolors]="$DOTS/kitty/colors.conf"


    # --- Zsh Core Files ---
    [zrc]="$HOME/.zshrc"
    [p10k]="$HOME/.p10k.zsh"
    [zenv]="$ZSH_CONFIG_DIR/10_environment.zsh"
    [zopts]="$ZSH_CONFIG_DIR/20_options.zsh"
    [zplugs]="$ZSH_CONFIG_DIR/30_plugins.zsh"
    [zfzf]="$ZSH_CONFIG_DIR/40_fzf.zsh"
    [zals]="$ZSH_CONFIG_DIR/50_aliases.zsh"
    [zfn]="$ZSH_CONFIG_DIR/60_functions.zsh"
    [zinit]="$ZSH_CONFIG_DIR/70_init.zsh"
    [zreg]="$ZSH_CONFIG_DIR/lib/registry.zsh"
    [zmetro]="$ZSH_CONFIG_DIR/lib/metro.zsh"
    [ztools]="$ZSH_CONFIG_DIR/lib/tools.zsh"
    [zdot]="$ZSH_CONFIG_DIR/lib/dotfiles.zsh"

    # --- Apps & Tools ---
    [ff]="$DOTS/fastfetch/config.jsonc"
    [nvim]="$DOTS/nvim/lua/config/lazy.lua"
    [git]="$DOTS/lazygit/config.yml"
    [dunstconf]="$DOTS/dunst/dunstrc"
    [mise]="$DOTS/mise/config.toml"
    [clipse]="$DOTS/clipse/config.json"
    [uair]="$DOTS/uair/uair.toml"
    [gammaconf]="$DOTS/gammastep/config.ini"
    [sampler]="$DOTS/sampler/sampler.yml"
    [cava]="$DOTS/cava/config"
    [imv]="$DOTS/imv/config"
    [userjs]="${zen_profile}/user.js"


    # --- System / Scripts ---
    [topgrade]="$DOTS/topgrade.toml"
    [mime]="$HOME/.config/mimeapps.list"
    [ssh]="$HOME/.ssh/config"
    [keyd]="/etc/keyd/default.conf"

    [pyreconf]="$bin_dir/pyre"
    [pyrefn]="$HOME/.config/pyre/functions.sh"
    [bright]="$bin_dir/brightness-manager"
    [ryzen]="/usr/local/sbin/apply-ryzen-settings.sh"
    [gitig]="$HOME/.gitignore"
)
