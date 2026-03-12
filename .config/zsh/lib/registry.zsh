# [NOTE] Prevent double sourcing of the registry engine
[[ -n "$_REGISTRY_LOADED" ]] && return
_REGISTRY_LOADED=1


# ┌─── 1. Global Assets & Visuals ─────────────────────────────────────────────┐

# Icons used for the Metro TUI navigation
typeset -g METRO_ICON_FILE="" 
typeset -g METRO_ICON_DIR=""  
typeset -g METRO_ICON_CONF="" 

# [NOTE] Dynamic resolution for environment-specific paths
_zen_paths=($HOME/.zen/*"Default (release)"(/N))

typeset -g bin_dir="${HOME}/.local/bin"
typeset -g zen_profile="${_zen_paths[1]:-$HOME/.zen/default}"


# ┌─── 2. Data Structure Initialization ───────────────────────────────────────┐

# Initialize global associative arrays for files and modules
typeset -gA metro_files
typeset -gA metro_modules

# Reset FZF menu cache to ensure fresh data on reload
typeset -g _metro_menu_cache=""


# ┌─── 3. Data Sourcing ───────────────────────────────────────────────────────┐

# [NOTE] Load the master registry containing static "factory" paths
if [[ -f "${ZSH_CONFIG_DIR}/lib/registry.data.zsh" ]]; then
    source "${ZSH_CONFIG_DIR}/lib/registry.data.zsh"
fi

# Load the user registry for paths added dynamically via 'mreg'
if [[ -f "${ZSH_CONFIG_DIR}/lib/registry.user.zsh" ]]; then
    source "${ZSH_CONFIG_DIR}/lib/registry.user.zsh"
fi
