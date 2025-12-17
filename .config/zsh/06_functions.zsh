# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                6. Functions                                │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                        Metro System - Config Maps                          │
# └────────────────────────────────────────────────────────────────────────────┘

# [HELPER] Find Zen Browser profile dynamically
local zen_profile_dir
zen_profile_dir=$(/usr/bin/find "$HOME/.zen" -maxdepth 1 -type d -name "*Default (release)" 2>/dev/null | head -n 1)

typeset -A metro_files
metro_files=(
    # --- 1. Hyprland Core (System Logic) ---
    [hyprconf]="$HYPR/hyprland.conf"                     # Main configuration entry point
    [hyprbinds]="$HYPR/keybinds.conf"                    # Keybindings and input definitions
    [hyprrules]="$HYPR/rules.conf"                       # Window rules and workspace assignments
    [hyprlook]="$HYPR/look.conf"                         # Animations, blur, and decorations
    [hyprcolors]="$HYPR/theme.conf"                      # System-wide color palette
    [hyprlock]="$HYPR/hyprlock.conf"                     # Lock screen configuration

    # --- 2. Desktop UI (Theming & Widgets) ---
    # > Waybar
    [wayconf]="$DOTS/waybar/config"                      # Bar layout and modules
    [waystyle]="$DOTS/waybar/style.css"                  # CSS styling and geometry
    [waycolors]="$DOTS/waybar/colors.css"                # Bar-specific color variables

    # > Wofi
    [woficonf]="$DOTS/wofi/config"                       # Launcher behavior and size
    [wofistyle]="$DOTS/wofi/style.css"                   # Launcher CSS styling
    [woficolors]="$DOTS/wofi/colors.css"                 # Launcher color variables

    # > Kitty
    [kittyconf]="$DOTS/kitty/kitty.conf"                 # Terminal settings and fonts
    [kittycolors]="$DOTS/kitty/colors.conf"              # Terminal color scheme

    # > Dunst
    [dunstconf]="$DOTS/dunst/dunstrc"                    # Notification daemon config

    # --- 3. Zsh Ecosystem (The Shell) ---
    [zshrc]="$HOME/.zshrc"                               # Shell entry point
    [zshenv]="$ZSH_CONFIG_DIR/01_environment.zsh"        # Environment variables
    [zshopts]="$ZSH_CONFIG_DIR/02_options.zsh"           # Shell options and history
    [zshplugs]="$ZSH_CONFIG_DIR/03_plugins.zsh"          # Plugin manager
    [zshfzf]="$ZSH_CONFIG_DIR/04_fzf.zsh"                # FZF integration settings
    [zshals]="$ZSH_CONFIG_DIR/05_aliases.zsh"            # Command aliases
    [zshfn]="$ZSH_CONFIG_DIR/06_functions.zsh"           # Custom functions
    [zshinit]="$ZSH_CONFIG_DIR/07_init.zsh"              # Initialization sequence
    [p10k]="$HOME/.p10k.zsh"                             # Prompt styling

    # --- 4. Applications & Tools ---
    [gammaconf]="$DOTS/gammastep/config.ini"             # Night light / Color temperature
    [nvim]="$DOTS/nvim/lua/config/lazy.lua"              # Neovim plugin manager
    [fast]="$DOTS/fastfetch/config.jsonc"                # System information tool
    [cava]="$DOTS/cava/config"                           # Audio visualizer
    [imv]="$DOTS/imv/config"                             # Image viewer
    [git]="$DOTS/lazygit/config.yml"                     # Git TUI interface
    [mise]="$DOTS/mise/config.toml"                      # Runtime manager (node, python, etc)
    [uair]="$DOTS/uair/uair.toml"                        # Pomodoro timer
    [userjs]="${zen_profile_dir}/user.js"                # Browser hardening / config

    # --- 5. System Configs (Root/Global) ---
    [mime]="$HOME/.config/mimeapps.list"                 # Default application associations
    [keyd]="/etc/keyd/default.conf"                      # Low-level keyboard remapping
    [ssh]="$HOME/.ssh/config"                            # SSH hosts and keys

    # --- 6. Scripts ---
    [pyre]="$HOME/.local/bin/pyre"                       # Custom automation engine
    [bright]="$HOME/.local/bin/brightness-manager"       # Monitor brightness logic
    [ryzen]="/usr/local/sbin/apply-ryzen-settings.sh"    # CPU power management

    # --- 7. Meta ---
    [gitig]="$HOME/.gitignore"                           # Global git ignore patterns
)

# --- Part 2: Links to modular configuration directories ---
# [CONFIG] Map of aliases to directories for full module browsing.
typeset -A metro_modules
metro_modules=(
    [hypr]="$HYPR"
    [kitty]="$DOTS/kitty"
    [waybar]="$DOTS/waybar"
    [wofi]="$DOTS/wofi"
    [zsh]="$ZSH_CONFIG_DIR"
)

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                       Metro System - Internal Helpers                      │
# └────────────────────────────────────────────────────────────────────────────┘
# [INFO] Private helper functions (prefixed with _) used by the main commands.

# --- _edit_resolve_path_for_preview - Helper for FZF preview ---
# [INFO] A dedicated helper to find a path for the previewer.
_edit_resolve_path_for_preview() {
    local alias="$1"
    if [[ -v metro_files[$alias] ]]; then
        echo "${metro_files[$alias]}"
    elif [[ -v metro_modules[$alias] ]]; then
        echo "${metro_modules[$alias]}"
    fi
}

# --- _edit_module - FZF sub-menu for a configuration module ---
# [INFO] This helper function is called by 'edit' for module directories.
_edit_module() {
    local module_path="$1"
    local selected_file

    selected_file=$(fd --type f . "$module_path" | fzf \
        --header="Editing Module: $(basename "$module_path") — Select a file" \
        --preview="bat --color=always --style=numbers --line-range :200 {}")

    if [[ -n "$selected_file" ]]; then
        z "$(dirname "$selected_file")" && $EDITOR "$(basename "$selected_file")"
    fi
}

# --- _metro_completion - Zsh Autocompletion Logic ---
# [INFO] Enables smart tab-completion for 'edit' and 'view' commands.
_metro_completion() {
    local -a matches
    local key

    for key in "${(@k)metro_files}"; do
        matches+=("$key:[File] $(basename "${metro_files[$key]}")")
    done

    for key in "${(@k)metro_modules}"; do
        matches+=("$key:[Module] $(basename "${metro_modules[$key]}")/")
    done

    matches+=("p10k:[Action] Configure Powerlevel10k")
    _describe 'metro config' matches
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                       Metro System - Public Commands                       │
# └────────────────────────────────────────────────────────────────────────────┘
# [INFO] The main commands exposed to the user.

# --- edit - The ultimate config file editor ---
edit() {
    if [[ -n "$1" ]]; then
        local target_alias="$1"
        if [[ "$target_alias" == "p10k" ]]; then p10k configure; return 0; fi

        if [[ -v metro_files[$target_alias] ]]; then
            local f="${metro_files[$target_alias]}"
            z "$(dirname "$f")" && $EDITOR "$(basename "$f")"
        elif [[ -v metro_modules[$target_alias] ]]; then
            _edit_module "${metro_modules[$target_alias]}"
        else
            echo "Config not found: $target_alias"
            return 1
        fi
        return 0
    fi

    local file_list=$(for key in "${(@k)metro_files}"; do printf "%-15s [File]   -> %s\n" "$key" "$(basename "${metro_files[$key]}")"; done | sort)
    local module_list=$(for key in "${(@k)metro_modules}"; do printf "%-15s [Module] -> %s/\n" "$key" "$(basename "${metro_modules[$key]}")"; done | sort)
    local full_list="p10k           [Action] -> Configure Powerlevel10k\n${file_list}\n${module_list}"
    
    local data_to_pass="$(typeset -p metro_files metro_modules); $(typeset -f _edit_resolve_path_for_preview)"
    local selected_item

    selected_item=$(echo -e "$full_list" | fzf \
        --header="Select a config file or module to edit" \
        --preview="$data_to_pass; \
            alias_to_preview=\$(echo {} | awk '{print \$1}'); \
            path_to_preview=\$(_edit_resolve_path_for_preview \"\$alias_to_preview\"); \
            if [[ -f \"\$path_to_preview\" ]]; then \
                bat --color=always --style=numbers --line-range :200 \"\$path_to_preview\"; \
            elif [[ -d \"\$path_to_preview\" ]]; then \
                eza --tree --level=2 --icons \"\$path_to_preview\"; \
            fi" \
        --preview-window="right:55%:border-rounded")

    if [[ -n "$selected_item" ]]; then
        edit "$(echo "$selected_item" | awk '{print $1}')"
    fi
}

# --- view - Preview config files or modules ---
view() {
    if [[ -n "$1" ]]; then
        local viewer_command="bat --paging=never"
        local target_alias="$1"

        if [[ "$1" == "-c" ]]; then
            viewer_command="cat"
            shift
            target_alias="$1"
        fi

        if [[ -v metro_files[$target_alias] ]]; then
            eval "$viewer_command \"${metro_files[$target_alias]}\""
        elif [[ -v metro_modules[$target_alias] ]]; then
            eza --tree --level=3 --icons "${metro_modules[$target_alias]}"
        else
            echo "Config not found: $target_alias"
            return 1
        fi
        return 0
    fi

    local file_list=$(for key in "${(@k)metro_files}"; do printf "%-15s [File]   -> %s\n" "$key" "$(basename "${metro_files[$key]}")"; done | sort)
    local module_list=$(for key in "${(@k)metro_modules}"; do printf "%-15s [Module] -> %s/\n" "$key" "$(basename "${metro_modules[$key]}")"; done | sort)
    local full_list="p10k           [Action] -> Configure Powerlevel10k\n${file_list}\n${module_list}"
    
    local data_to_pass="$(typeset -p metro_files metro_modules); $(typeset -f _edit_resolve_path_for_preview)"
    local selected_item

    selected_item=$(echo -e "$full_list" | fzf \
        --header="Select a config to view" \
        --preview="$data_to_pass; \
            alias_to_preview=\$(echo {} | awk '{print \$1}'); \
            path_to_preview=\$(_edit_resolve_path_for_preview \"\$alias_to_preview\"); \
            if [[ -f \"\$path_to_preview\" ]]; then \
                bat --color=always --style=numbers --line-range :200 \"\$path_to_preview\"; \
            elif [[ -d \"\$path_to_preview\" ]]; then \
                eza --tree --level=2 --icons \"\$path_to_preview\"; \
            fi" \
        --preview-window="right:55%:border-rounded")

    if [[ -n "$selected_item" ]]; then
        view "$(echo "$selected_item" | awk '{print $1}')"
    fi
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                             Magic Enter                                    │
# └────────────────────────────────────────────────────────────────────────────┘
magic-enter() {
    if [[ -z "${BUFFER// }" ]]; then
        local cmd="eza --icons --group-directories-first --git"
        
        if git status --porcelain &>/dev/null; then
            cmd="$cmd && git status -sb"
        fi
        
        BUFFER="$cmd"
        zle accept-line
    else
        zle accept-line
    fi
}

zle -N magic-enter


# --- dotgit - Wrapper for dotfiles management ---
dotgit() {
    git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# --- Project Jumper ---
pj() {
    local project_dir
    
    project_dir=$(fd --type d --hidden --glob ".git" \
        "$HOME/Projects" "$HOME/Documents" "$DOTS" "$HOME/.config" \
        --exec dirname {} \; | \
        sed "s|$HOME|~|" | \
        fzf --height=50% --layout=reverse --border --prompt="Project> " \
            --preview="eza --tree --level=2 --icons --git-ignore $(echo {} | sed "s|~|$HOME|")" \
            --preview-window=right:60%)

    if [[ -n "$project_dir" ]]; then
        local real_path=$(echo "$project_dir" | sed "s|~|$HOME|")
        z "$real_path"
    fi
}

# --- cht - Cheat Sheet Seeker ---
cht() {
    if [ "$#" -eq 0 ]; then
        echo "Usage: cht <language> <question>"
        echo "Example: cht python read file"
        return 1
    fi

    local lang=$1
    shift
    local query=$(echo "$*" | tr ' ' '+')

    if command -v bat > /dev/null; then
        curl -s "cht.sh/$lang/$query?T" | bat --language="$lang" --style=plain
    else
        curl -s "cht.sh/$lang/$query"
    fi
}

# --- dfd - Audit untracked configuration files ---
dfd() {
    local untracked_files
    untracked_files=$(dotgit ls-files --others --exclude-standard -- ~/.config ~/.local/bin ~/.zshrc ~/.p10k.zsh)

    if [ -n "$untracked_files" ]; then
        echo "┌─ [CRITICAL] Untracked Dotfiles ──────────────────────────────────┐"
        echo "$untracked_files" | sed 's/^/│  /;$s/│/└/'
        echo "└────────────────────────────────────────────────────────────────┘"
        echo "  Use 'dadd <path>' to add them."
    else
        echo "All dotfiles are tracked."
    fi
}

# --- Ripgrep Fzf - Search for a pattern across the entire project ---
rf() {
    local editor=${2:-${EDITOR:-nvim}}
    local selection
    
    selection=$(rg --line-number --no-heading --hidden --glob '!.git' "$1" | fzf \
        --height=50% \
        --border=rounded \
        --delimiter=':' \
        --header="🔍 Project Search: $1 — Enter → open, ESC → cancel" \
        --preview-window="right:60%:wrap:border-rounded:follow" \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} {1}")

    [[ -z "$selection" ]] && return 0

    local file=$(echo "$selection" | cut -d: -f1)
    local line=$(echo "$selection" | cut -d: -f2)

    z "$(dirname "$file")"
    "$editor" +"$line" "$file"
}

# --- Find Inside - Interactively fuzzy-search within a single file ---
fin() {
    if [[ -z "$1" ]]; then
        echo "Usage: fin <filename>"
        echo "  Opens an fzf-powered view for interactive fuzzy-searching within a file."
        return 1
    fi

    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file"
        return 1
    fi

    local selection
    
    selection=$(rg --no-heading --line-number --color=always -i "" "$file" | fzf \
        --ansi \
        --delimiter=: \
        --header="🔍 $file — Fuzzy-search, Enter → open, ESC → cancel" \
        --height=30% \
        --layout=reverse \
        --border=rounded \
        --preview-window="right:50%:wrap:border-rounded:follow" \
        --preview="bash -c ' \
            file_path=\"\$1\"; \
            line_num=\"{1}\"; \
            start=\$(( line_num > 10 ? line_num - 10 : 1 )); \
            end=\$(( line_num + 10 )); \
            bat --paging=never --style=numbers --color=always --highlight-line \"\$line_num\" \"\$file_path\" --line-range \"\$start:\$end\" \
        ' bash \"$file\"")

    if [[ $? -ne 0 || -z "$selection" ]]; then
        return 0
    fi

    local line=$(echo "$selection" | awk -F: '{print $1}' | head -n1)

    ${EDITOR:-nvim} +"$line" "$file"
}

# --- Fuzzy Kill - Find and kill processes interactively ---
fk() {
    local pid
    if [[ -n "$1" ]]; then
        pid=$(pgrep -f "$1" | fzf --preview="ps -fp {}" --header="Select PID to kill (matches '$1')")
    else
        pid=$(ps -u "$USER" -o pid,comm,args | sed 1d | fzf \
            --header="Select process to kill" \
            --preview="echo {}" \
            --preview-window=down:20% \
            | awk '{print $1}')
    fi

    if [[ -n "$pid" ]]; then
        echo "Killing PID $pid..."
        kill -9 "$pid" && echo "Process $pid terminated."
    fi
}

# --- copy - Copy piped input to the system clipboard ---
copy() {
    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy
    else
        echo "Error: wl-copy not found." >&2
        return 1
    fi
}

# --- Git Scan - Git status for all repos in current dir ---
gscan() {
    fd --type d --hidden --absolute-path '.git' --max-depth 2 . | while read -r gitdir; do
        local projectdir=$(dirname "$gitdir")
        if [[ "$projectdir" == *".git"* ]]; then continue; fi
        
        echo "\n--- Status for: $(basename "$projectdir") ---"
        git -C "$projectdir" status -s
    done
}

# --- serve - Start a simple web server ---
serve() {
    echo "Serving current directory on http://localhost:8000"
    python -m http.server
}

# --- bak - Create a timestamped backup of a file ---
bak() {
    if [[ -z "$1" ]]; then
        echo "Usage: bak <filename>"
        return 1
    fi
    cp -iv "$1" "$1.bak.$(date +'%Y%m%d-%H%M%S')"
}

# --- mkcd - Create a directory and enter it ---
mkcd() {
    mkdir -p "$1" && z "$1"
}
