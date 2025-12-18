# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                6. Functions                                │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─── Metro System - Config Maps ─────────────────────────────────────────────┐
# │                                                                            │
# │  [INFO] Centralized registry for dotfiles navigation.                      │
# │  [NOTE] Defines targets for 'edit' and 'view' commands.                    │
# │                                                                            │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── Configuration Data ─────────────────────────────────────────────────────┐

# --- Dynamic Variables ---
# [HELPER] Resolve paths dynamically to avoid hardcoding.
local zen_profile_dir
zen_profile_dir=$(/usr/bin/find "$HOME/.zen" -maxdepth 1 -type d -name "*Default (release)" 2>/dev/null | head -n 1)
local BIN="$HOME/.local/bin"

# --- Modules (Folders) ---
# [INFO] Directories opened via file picker (edit) or tree view (view).
typeset -A metro_modules
metro_modules=(
    [hypr]="$HYPR"
    [kitty]="$DOTS/kitty"
    [waybar]="$DOTS/waybar"
    [wofi]="$DOTS/wofi"
    [zsh]="$ZSH_CONFIG_DIR"
    [scripts]="$BIN"
)

# --- Files (Direct Access) ---
# [INFO] Specific files opened directly in the editor.
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
    [wayconf]="$DOTS/waybar/config"                      # Bar layout and modules
    [waystyle]="$DOTS/waybar/style.css"                  # CSS styling and geometry
    [waycolors]="$DOTS/waybar/colors.css"                # Bar-specific color variables
    [woficonf]="$DOTS/wofi/config"                       # Launcher behavior and size
    [wofistyle]="$DOTS/wofi/style.css"                   # Launcher CSS styling
    [woficolors]="$DOTS/wofi/colors.css"                 # Launcher color variables
    [kittyconf]="$DOTS/kitty/kitty.conf"                 # Terminal settings and fonts
    [kittycolors]="$DOTS/kitty/colors.conf"              # Terminal color scheme
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
    [gammaconf]="$DOTS/gammastep/config.ini"             # Night light configuration
    [nvim]="$DOTS/nvim/lua/config/lazy.lua"              # Neovim plugin manager
    [fast]="$DOTS/fastfetch/config.jsonc"                # System information tool
    [cava]="$DOTS/cava/config"                           # Audio visualizer
    [imv]="$DOTS/imv/config"                             # Image viewer
    [git]="$DOTS/lazygit/config.yml"                     # Git TUI interface
    [mise]="$DOTS/mise/config.toml"                      # Runtime manager config
    [uair]="$DOTS/uair/uair.toml"                        # Pomodoro timer
    [userjs]="${zen_profile_dir}/user.js"                # Browser hardening config

    # --- 5. System Configs (Root/Global) ---
    [mime]="$HOME/.config/mimeapps.list"                 # Default application associations
    [keyd]="/etc/keyd/default.conf"                      # Low-level keyboard remapping
    [ssh]="$HOME/.ssh/config"                            # SSH hosts and keys

    # --- 6. Scripts ---
    [pyre]="$BIN/pyre"                                   # Engine entry point
    [pyrefn]="$HOME/.config/pyre/functions.sh"           # Engine library functions
    [bright]="$BIN/brightness-manager"                   # Monitor brightness logic
    [ryzen]="/usr/local/sbin/apply-ryzen-settings.sh"    # CPU power management

    # --- 7. Meta ---
    [gitig]="$HOME/.gitignore"                           # Global git ignore patterns
)

# ┌─── Internal Helpers ───────────────────────────────────────────────────────┐

# --- Path Resolution ---
# [INFO] Helper for FZF preview: turns an alias into a real path.
_edit_resolve_path_for_preview() {
    local alias="$1"
    if [[ -v metro_files[$alias] ]]; then
        echo "${metro_files[$alias]}"
    elif [[ -v metro_modules[$alias] ]]; then
        echo "${metro_modules[$alias]}"
    fi
}

# --- Module Selector ---
# [INFO] Helper for 'edit': shows FZF menu for a specific folder.
_edit_module() {
    local module_path="$1"
    local selected_file

    selected_file=$(find "$module_path" -maxdepth 2 -not -path '*/.*' -type f | \
        fzf --header="Editing Module: $(basename "$module_path") — Select a file" \
            --preview="bat --color=always --style=numbers --line-range :200 {}")

    if [[ -n "$selected_file" ]]; then
        z "$(dirname "$selected_file")" && $EDITOR "$(basename "$selected_file")"
    fi
}

# --- Autocompletion ---
# [INFO] Zsh completion logic for public commands.
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


# ┌─── Public Commands ────────────────────────────────────────────────────────┐

# --- Editor Interface ---
# [INFO] The ultimate config file editor.
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

    # Generate lists
    local file_list=$(for key in "${(@k)metro_files}"; do printf "%-15s [File]   -> %s\n" "$key" "$(basename "${metro_files[$key]}")"; done | sort)
    local module_list=$(for key in "${(@k)metro_modules}"; do printf "%-15s [Module] -> %s/\n" "$key" "$(basename "${metro_modules[$key]}")"; done | sort)
    local full_list="p10k           [Action] -> Configure Powerlevel10k\n${file_list}\n${module_list}"
    
    # Serialize data for FZF preview
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

# --- Viewer Interface ---
# [INFO] Preview config files or modules.
view() {
    if [[ -n "$1" ]]; then
        local viewer_command="bat --paging=never --style=header,grid,numbers --color=always"
        local target_alias="$1"

        if [[ "$1" == "-c" ]]; then
            viewer_command="cat"
            shift
            target_alias="$1"
        fi

        if [[ -v metro_files[$target_alias] ]]; then
            eval "$viewer_command \"${metro_files[$target_alias]}\""
        elif [[ -v metro_modules[$target_alias] ]]; then
            eza --tree --level=5 --icons "${metro_modules[$target_alias]}"
        else
            echo "Config not found: $target_alias"
            return 1
        fi
        return 0
    fi

    # Interactive mode (same as edit but calls view)
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
# │                       Interactive Shell Enhancements                       │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── Navigation Helpers ─────────────────────────────────────────────────────┐

# --- Magic Enter ---
# [INFO] Runs 'eza' (ls) when pressing Enter on an empty line.
# [INFO] Shows 'git status' if inside a git repository.
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

# --- Project Jumper ---
# [INFO] Find directories containing .git and jump to them.
pj() {
    local search_dirs=("$HOME/Projects" "$HOME/Documents" "$DOTS" "$HOME/.config")
    local project_dir
    
    project_dir=$(fd --type d --hidden --glob ".git" "${search_dirs[@]}" \
        --exec dirname {} \; | \
        sed "s|$HOME|~|" | \
        fzf --height=50% --layout=reverse --border --prompt="Project > " \
            --preview="eza --tree --level=2 --icons --git-ignore $(echo {} | sed "s|~|$HOME|")" \
            --preview-window=right:60%)

    if [[ -n "$project_dir" ]]; then
        local real_path="${project_dir/#\~/$HOME}"
        z "$real_path"
    fi
}

# --- Make & Enter ---
# [INFO] Create a directory and cd into it immediately.
mkcd() {
    mkdir -p "$1" && cd "$1"
}


# ┌─── Development Tools ──────────────────────────────────────────────────────┐

# --- Ripgrep Fzf ---
# [INFO] Interactive grep across the entire project.
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

# --- Find Inside ---
# [INFO] Interactive fuzzy-search within a specific file.
fin() {
    if [[ -z "$1" ]]; then
        echo "Usage: fin <filename>"
        return 1
    fi

    local file="$1"
    [[ ! -f "$file" ]] && { echo "Error: File not found: $file"; return 1; }

    local selection
    selection=$(rg --no-heading --line-number --color=always -i "" "$file" | fzf \
        --ansi \
        --delimiter=: \
        --header="🔍 $file — Fuzzy-search" \
        --height=30% \
        --layout=reverse \
        --border=rounded \
        --preview-window="right:50%:wrap:border-rounded:follow" \
        --preview="bash -c ' \
            file=\"$file\"; line={1}; \
            start=\$(( line > 10 ? line - 10 : 1 )); \
            end=\$(( line + 10 )); \
            bat --paging=never --style=numbers --color=always --highlight-line \$line \$file --line-range \$start:\$end \
        '")

    [[ -z "$selection" ]] && return 0
    
    local line=$(echo "$selection" | awk -F: '{print $1}')
    ${EDITOR:-nvim} +"$line" "$file"
}

# --- Cheat Sheet ---
# [INFO] Query cht.sh for code snippets.
cht() {
    if [ "$#" -eq 0 ]; then
        echo "Usage: cht <language> <question>"
        return 1
    fi

    local lang=$1
    shift
    local query=$(echo "$*" | tr ' ' '+')

    if command -v bat >/dev/null; then
        curl -s "cht.sh/$lang/$query?T" | bat --language="$lang" --style=plain
    else
        curl -s "cht.sh/$lang/$query"
    fi
}

# --- Web Server ---
# [INFO] Serve current directory via Python.
serve() {
    echo "Serving current directory on http://localhost:8000"
    python -m http.server
}


# ┌─── System Utilities ───────────────────────────────────────────────────────┐

# --- Fuzzy Kill ---
# [INFO] Interactively select and kill processes.
fk() {
    local pid
    if [[ -n "$1" ]]; then
        pid=$(pgrep -f "$1" | fzf --preview="ps -fp {}" --header="Kill matches for '$1'")
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

# --- Backup File ---
# [INFO] Create a timestamped backup (file.bak.YYYYMMDD...)
bak() {
    [[ -z "$1" ]] && { echo "Usage: bak <filename>"; return 1; }
    cp -iv "$1" "$1.bak.$(date +'%Y%m%d-%H%M%S')"
}

# --- Clipboard Copy ---
# [INFO] Wayland-native clipboard copy.
copy() {
    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy
    else
        echo "Error: wl-copy not found." >&2
        return 1
    fi
}


# ┌─── Dotfiles Management ────────────────────────────────────────────────────┐

# --- Git Wrapper ---
# [INFO] Wrapper for the bare dotfiles repository.
dotgit() {
    git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# --- Dotfiles Doctor ---
# [INFO] Scans key directories for files not tracked by dotgit.
dfd() {
    local untracked_files
    # Added .local/bin to scan list
    untracked_files=$(dotgit ls-files --others --exclude-standard -- \
        "$HOME/.config" "$HOME/.local/bin" "$HOME/.zshrc" "$HOME/.p10k.zsh")

    if [ -n "$untracked_files" ]; then
        echo "┌─ [CRITICAL] Untracked Dotfiles ──────────────────────────────────┐"
        echo "$untracked_files" | sed 's/^/│  /;$s/│/└/'
        echo "└────────────────────────────────────────────────────────────────┘"
        echo "  Use 'dadd <path>' to add them."
    else
        echo "All dotfiles are tracked."
    fi
}

# --- Git Repo Scan ---
# [INFO] Show status of all git repositories in current directory.
gscan() {
    fd --type d --hidden --absolute-path '.git' --max-depth 2 . | while read -r gitdir; do
        local projectdir=$(dirname "$gitdir")
        if [[ "$projectdir" == *".git"* ]]; then continue; fi
        
        printf "\n--- Status for: %s ---\n" "$(basename "$projectdir")"
        git -C "$projectdir" status -s
    done
}
