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
local zen_paths=($HOME/.zen/*"Default (release)"(/N))
local zen_profile_dir="${zen_paths[1]:-$HOME/.zen/default}"        # Fallback if not found
local BIN="$HOME/.local/bin"

# --- Modules (Folders) ---
# [INFO] Directories opened via file picker (edit) or tree view (view).
typeset -A metro_modules
metro_modules=(
    [hypr]="$HYPR"
    [kitty]="$DOTS/kitty"
    [waybar]="$DOTS/waybar"
    [wofi]="$DOTS/wofi"
    [rofi]="$DOTS/rofi"
    [zsh]="$ZSH_CONFIG_DIR"
    [scripts]="$BIN"
    [pyre]="$DOTS/pyre"
)

# --- Files (Direct Access) ---
# [INFO] Specific files opened directly in the editor.
typeset -A metro_files
metro_files=(
    # --- 1. Hyprland Core (System Logic) ---
    [hyprconf]="$HYPR/hyprland.conf"                     # Main configuration entry point
    [hyprbinds]="$HYPR/keybinds.conf"                    # Keybindings and input definitions
    [hyprdecor]="$HYPR/decoration.conf"                  # Animations, blur, and decorations
    [hyprrules]="$HYPR/rules.conf"                       # Window rules and workspace assignments
    [hyprcolors]="$HYPR/colors.conf"                     # System-wide color palette
    [hyprlock]="$HYPR/hyprlock.conf"                     # Lock screen configuration
    [hypridle]="$HYPR/hypridle.conf"                     # Idle daemon configuration

    # --- 2. Desktop UI (Theming & Widgets) ---

    # Waybar (Status Bar)
    [wayconf]="$DOTS/waybar/config"                      # Bar layout and modules
    [waystyle]="$DOTS/waybar/style.css"                  # CSS styling and geometry
    [waycolors]="$DOTS/waybar/colors.css"                # Bar-specific color variables

    # Wofi (App Launcher)
    [woficonf]="$DOTS/wofi/config"                       # Launcher behavior and size
    [wofistyle]="$DOTS/wofi/style.css"                   # Launcher CSS styling
    [woficolors]="$DOTS/wofi/colors.css"                 # Launcher color variables

    # Rofi (App Launcher)
    [roficonf]="$DOTS/rofi/config.rasi"                  # Launcher behavior and size
    [rofistyle]="$DOTS/rofi/style.rasi"                  # Launcher CSS styling
    [roficolors]="$DOTS/rofi/colors.rasi"                # Launcher color variables


    # Kitty (Terminal)
    [kittyconf]="$DOTS/kitty/kitty.conf"                 # Terminal settings and fonts
    [kittycolors]="$DOTS/kitty/colors.conf"              # Terminal color scheme

    # Dunst (Notifications)
    [dunstconf]="$DOTS/dunst/dunstrc"                    # Notification daemon config

    # --- 3. Zsh Ecosystem (The Shell) ---

    # Core & Entry Points
    [zshrc]="$HOME/.zshrc"                               # Main entry point (loads modules)
    [p10k]="$HOME/.p10k.zsh"                             # Powerlevel10k theme configuration

    # Modules (Load Order 01-07)
    [zshenv]="$ZSH_CONFIG_DIR/01_environment.zsh"        # 01. Environment & Path
    [zshopts]="$ZSH_CONFIG_DIR/02_options.zsh"           # 02. Shell options & History
    [zshplugs]="$ZSH_CONFIG_DIR/03_plugins.zsh"          # 03. Plugin manager
    [zshfzf]="$ZSH_CONFIG_DIR/04_fzf.zsh"                # 04. FZF integration
    [zshals]="$ZSH_CONFIG_DIR/05_aliases.zsh"            # 05. Command aliases
    [zshfn]="$ZSH_CONFIG_DIR/06_functions.zsh"           # 06. Custom functions
    [zshinit]="$ZSH_CONFIG_DIR/07_init.zsh"              # 07. Initialization sequence

    # --- 4. Applications & Tools ---

    # Development & Runtime
    [nvim]="$DOTS/nvim/lua/config/lazy.lua"              # Neovim plugin manager
    [git]="$DOTS/lazygit/config.yml"                     # Git TUI interface
    [mise]="$DOTS/mise/config.toml"                      # Runtime manager config

    # Productivity & Utils
    [clipse]="$DOTS/clipse/config.json"                  # Clipboard history
    [uair]="$DOTS/uair/uair.toml"                        # Pomodoro timer
    [gammaconf]="$DOTS/gammastep/config.ini"             # Night light configuration

    # Media & Visuals
    [fast]="$DOTS/fastfetch/config.jsonc"                # System information tool
    [sampler]="$DOTS/sampler/sampler.yml"
    [cava]="$DOTS/cava/config"                           # Audio visualizer
    [imv]="$DOTS/imv/config"                             # Image viewer

    # Web
    [userjs]="${zen_profile_dir}/user.js"                # Browser hardening config

    # --- 5. System Configs (Root/Global) ---
    [mime]="$HOME/.config/mimeapps.list"                 # Default application associations
    [ssh]="$HOME/.ssh/config"                            # SSH hosts and keys
    [keyd]="/etc/keyd/default.conf"                      # Low-level keyboard remapping

    # --- 6. Scripts ---

    # Pyre Engine (My Framework)
    [pyreconf]="$BIN/pyre"                               # Engine entry point
    [pyrefn]="$HOME/.config/pyre/functions.sh"           # Engine library functions

    # Hardware Control
    [bright]="$BIN/brightness-manager"                   # Monitor brightness logic
    [ryzen]="/usr/local/sbin/apply-ryzen-settings.sh"    # CPU power management

    # --- 7. Meta ---
    [gitig]="$HOME/.gitignore"                           # Global git ignore patterns
)


# ┌─── Internal Helpers ───────────────────────────────────────────────────────┐

# --- Menu Generator ---
# [INFO] Generates the formatted list for FZF once.
_metro_build_menu() {
    local file_list
    file_list=$(for key in "${(@k)metro_files}"; do 
        printf "%-15s [File]   -> %s\n" "$key" "${metro_files[$key]:t}"
    done | sort -k 4 -V)

    local module_list
    module_list=$(for key in "${(@k)metro_modules}"; do 
        printf "%-15s [Module] -> %s/\n" "$key" "${metro_modules[$key]:t}"
    done | sort -k 4 -V)
    
    printf "p10k           [Action] -> Configure Powerlevel10k\n%s\n%s" "$file_list" "$module_list"
}

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

    selected_file=$(command find "$module_path" -maxdepth 2 -type f -not -name '.*' | \
        fzf --header="Editing Module: ${module_path:t} — Select a file" \
            --preview="bat --color=always --style=numbers --line-range :200 \"{}\"")

    if [[ -n "$selected_file" ]]; then
        z "${selected_file:h}" && $EDITOR "${selected_file:t}"
    fi
}

# --- Autocompletion ---
# [INFO] Zsh completion logic for public commands.
_metro_completion() {
    local -a matches
    local key

    # [LOGIC] Only show files if NOT using 'goto'
    # 'goto' is strictly for directory navigation
    if [[ "$service" != "goto" ]]; then
        for key in "${(@k)metro_files}"; do
            matches+=("$key:[File] ${metro_files[$key]:t}")
        done
        matches+=("p10k:[Action] Configure Powerlevel10k")
    fi

    # [LOGIC] Modules are always relevant
    for key in "${(@k)metro_modules}"; do
        matches+=("$key:[Module] ${metro_modules[$key]:t}/")
    done

    _describe 'metro config' matches
}


# ┌─── Public Commands ────────────────────────────────────────────────────────┐

# --- Editor Interface ---
# [INFO] The ultimate config file editor with FZF integration.
# [EXAMPLE] edit hypr        # Opens module folder
# [EXAMPLE] edit hyprconf    # Opens specific file
edit() {
    # 1. CLI ARGUMENT MODE (Direct Access)
    if [[ -n "$1" ]]; then
        local target_alias="$1"

        # Case A: Powerlevel10k Special
        if [[ "$target_alias" == "p10k" ]]; then
            p10k configure
            return 0
        fi

        # Case B: Direct File Match
        if [[ -v metro_files[$target_alias] ]]; then
            local f="${metro_files[$target_alias]}"
            z "${f:h}" && $EDITOR "${f:t}"        # [OPTIMIZATION] Zsh Modifiers (:h/:t)
            return 0
        fi
        
        # Case C: Module Directory Match
        if [[ -v metro_modules[$target_alias] ]]; then
            _edit_module "${metro_modules[$target_alias]}"
            return 0
        fi

        # Case D: Not Found (Error)
        echo "Config not found: $target_alias"
        return 1
    fi
    
    # 2. INTERACTIVE MODE (FZF Menu)
    # [CRITICAL] Prepare data for the preview window subshell (Context Serialization)
    local data_to_pass="$(typeset -p metro_files metro_modules); $(typeset -f _edit_resolve_path_for_preview)"
    local selected_item

    # [INFO] Launch FZF with detailed preview
    selected_item=$(_metro_build_menu | fzf \
        --header="Select a config file or module to edit" \
        --preview="$data_to_pass; \
            alias_to_preview=\$(echo {} | cut -d' ' -f1); \
            path_to_preview=\$(_edit_resolve_path_for_preview \"\$alias_to_preview\"); \
            if [[ -f \"\$path_to_preview\" ]]; then \
                bat --color=always --style=numbers --line-range :200 \"\$path_to_preview\"; \
            elif [[ -d \"\$path_to_preview\" ]]; then \
                eza --tree --level=2 --icons \"\$path_to_preview\"; \
            fi" \
        --preview-window="right:55%:border-rounded")
    
    [[ -n "$selected_item" ]] && edit "${selected_item%% *}"
}

# --- Viewer Interface ---
# [INFO] Preview config files or modules without opening editor.
# [EXAMPLE] view hypr        # Shows tree view of folder
# [EXAMPLE] view hyprconf    # Cats/Bats the file
# [EXAMPLE] view -c hyprconf # Forces raw 'cat' output
view() {
    # 1. CLI ARGUMENT MODE
    if [[ -n "$1" ]]; then
        local target_alias="$1"
        # [OPTIMIZATION] Use an array for command arguments to avoid 'eval'
        local viewer_cmd=(bat --paging=never --style=header,grid,numbers --color=always)

        # [INFO] Flag handling: '-c' forces raw output (useful for piping)
        if [[ "$1" == "-c" ]]; then
            viewer_cmd=(bat --paging=never --style=plain --color=always)
            shift
            target_alias="$1"
        fi

        # Case A: File Match
        if [[ -v metro_files[$target_alias] ]]; then
            "${viewer_cmd[@]}" "${metro_files[$target_alias]}"
            return 0
        fi
        
        # Case B: Module Match
        if [[ -v metro_modules[$target_alias] ]]; then
            eza --tree --level=5 --icons "${metro_modules[$target_alias]}"
            return 0
        fi
        
        # Case C: Not Found
        echo "Config not found: $target_alias"
        return 1
    fi
    
    # 2. INTERACTIVE MODE (FZF Menu)
    # [CRITICAL] Context serialization for FZF preview
    local data_to_pass="$(typeset -p metro_files metro_modules); $(typeset -f _edit_resolve_path_for_preview)"
    local selected_item

    # [INFO] Launch FZF with detailed preview
    selected_item=$(_metro_build_menu | fzf \
        --header="Select a config file or module to edit" \
        --preview="$data_to_pass; \
            alias_to_preview=\$(echo {} | cut -d' ' -f1); \
            path_to_preview=\$(_edit_resolve_path_for_preview \"\$alias_to_preview\"); \
            if [[ -f \"\$path_to_preview\" ]]; then \
                bat --color=always --style=numbers --line-range :200 \"\$path_to_preview\"; \
            elif [[ -d \"\$path_to_preview\" ]]; then \
                eza --tree --level=2 --icons \"\$path_to_preview\"; \
            fi" \
        --preview-window="right:55%:border-rounded")

    [[ -n "$selected_item" ]] && view "${selected_item%% *}"
}

# --- Navigator Interface ---
# [INFO] Quickly 'cd' into a config directory.
# [EXAMPLE] goto hypr        # cd ~/.config/hypr
# [EXAMPLE] goto zshrc       # cd ~ (where .zshrc lives)
goto() {
    # 1. CLI ARGUMENT MODE
    if [[ -n "$1" ]]; then
        local target="$1"

        # Case A: File Match -> Jump to parent dir
        if [[ -v metro_files[$target] ]]; then 
            # [OPTIMIZATION] Jump to directory containing the file (:h)
            z "${metro_files[$target]:h}"
            return 0
        fi
        
        # Case B: Module Match -> Jump to dir
        if [[ -v metro_modules[$target] ]]; then 
            z "${metro_modules[$target]}"
            return 0
        fi
        
        # Case C: Not Found
        echo "Config not found: $target"
        return 1
    fi

    # 2. INTERACTIVE MODE
    # [CRITICAL] Context serialization (Required for preview to see variables)
    local data_to_pass="$(typeset -p metro_files metro_modules); $(typeset -f _edit_resolve_path_for_preview)"
    local selected_item

    # [INFO] Interactive Selection
    # [LOGIC] grep "\[Module\]" ensures we only show directories, not files
    selected_item=$(_metro_build_menu | grep "\[Module\]" | fzf \
        --header="Select a destination to GO TO" \
        --preview="$data_to_pass; \
            alias_to_preview=\$(echo {} | awk '{print \$1}'); \
            path_to_preview=\$(_edit_resolve_path_for_preview \"\$alias_to_preview\"); \
            if [[ -f \"\$path_to_preview\" ]]; then \
                bat --color=always --style=numbers --line-range :200 \"\$path_to_preview\"; \
            elif [[ -d \"\$path_to_preview\" ]]; then \
                eza --tree --level=2 --icons \"\$path_to_preview\"; \
            fi" \
        --height=45% \
        --layout=reverse \
        --border=rounded \
        --prompt="Goto > ")

    # [OPTIMIZATION] Strip description and recurse
    [[ -n "$selected_item" ]] && goto "${selected_item%% *}"
}


# ┌────────────────────────────────────────────────────────────────────────────┐
# │                       Interactive Shell Enhancements                       │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─── Navigation Helpers ─────────────────────────────────────────────────────┐

# --- Magic Enter ---
# [INFO] Runs 'eza' (ls) when pressing Enter on an empty line.
# [INFO] Shows 'git status' if inside a git repository.
magic-enter() {
    # Guard: If buffer is NOT empty, execute normal return
    if [[ -n "${BUFFER// }" ]]; then
        zle accept-line
        return
    fi

    # Happy Path: Buffer is empty, run magic
    local cmd="eza --icons --group-directories-first --git"
    
    # [CHECK] Use 'command git' to bypass aliases/wrappers for speed
    if command git status --porcelain &>/dev/null; then
        cmd="$cmd && git status -sb"
    fi

    BUFFER="$cmd"
    zle accept-line
}
zle -N magic-enter

# --- Project Jumper ---
# [INFO] Find directories containing .git and jump to them.
# [EXAMPLE] pj      # Lists all git repos in predefined paths
pj() {
    # [CONFIG] Search locations
    local search_dirs=("$HOME/Projects" "$HOME/Documents" "$DOTS" "$HOME/.config")
    local project_dir
    
    project_dir=$(fd --type d --hidden --glob ".git" "${search_dirs[@]}" --format '{//}' | \
        sort -u | \
        sed "s|$HOME|~|" | \
        fzf --height=50% --layout=reverse --border --prompt="Project > " \
            --preview="expanded_path=\$(echo {} | sed \"s|^~|$HOME|\"); eza --tree --level=2 --icons --git-ignore \$expanded_path" \
            --preview-window=right:60%)

    if [[ -n "$project_dir" ]]; then
        z "${project_dir/#\~/$HOME}"
    fi
}

# --- Make & Enter ---
# [INFO] Create a directory and cd into it immediately.
mkcd() {
    [[ -z "$1" ]] && return 1
    mkdir -p "$1" && cd "$1"
}


# ┌─── Development Tools ──────────────────────────────────────────────────────┐

# --- Ripgrep Fzf ---
# [INFO] Interactive grep across the entire project.
# [USAGE] rf <path>
rf() {
    local root="${1:-.}"
    local selection
    
    # [OPTIMIZATION] --no-ignore allows searching inside .config
    selection=$(rg --line-number --no-heading --hidden --glob '!.git' . "$root" | fzf \
        --height=50% \
        --border=rounded \
        --delimiter=':' \
        --header="🔍 Project Search: $root — Enter → open" \
        --preview-window="right:60%:wrap:border-rounded:follow" \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} {1}")

    [[ -z "$selection" ]] && return 0

    # [OPTIMIZATION] Native Zsh splitting instead of cut/awk
    # Format: file:line:content
    local file="${selection%%:*}"      # Get everything before first colon
    local remaining="${selection#*:}"  # Remove file part
    local line="${remaining%%:*}"      # Get line number (next segment)

    z "${file:h}"
    ${EDITOR:-nvim} +"$line" "$file"
}

# --- Find Inside ---
# [INFO] Interactive fuzzy-search within a specific file.
# [USAGE] fin <filename>
fin() {
    local file="$1"
    [[ -f "$file" ]] || { echo "Error: File not found: $file"; return 1; }

    local selection
    selection=$(rg --no-heading --line-number --color=always -i "" "$file" | fzf \
        --ansi \
        --delimiter=: \
        --header="🔍 $file — Fuzzy-search" \
        --height=30% \
        --layout=reverse \
        --border=rounded \
        --preview-window="right:50%:wrap:border-rounded:follow" \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} $file")

    [[ -z "$selection" ]] && return 0
    
    # [OPTIMIZATION] Native Zsh splitting
    local line="${selection%%:*}"
    ${EDITOR:-nvim} +"$line" "$file"
}

# --- Cheat Sheet ---
# [INFO] Query cht.sh for code snippets.
# [EXAMPLE] cht python reverse list
cht() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: cht <language> <question>"
        return 1
    fi

    local lang="$1"
    shift
    local query="${*// /+}" # [OPTIMIZATION] Replace spaces with + natively

    if command -v bat >/dev/null; then
        curl -s "cht.sh/$lang/$query?T" | bat --language="$lang" --style=plain
    else
        curl -s "cht.sh/$lang/$query"
    fi
}

# --- Web Server ---
# [INFO] Serve current directory via Python.
serve() {
    local port="${1:-8000}"
    echo "Serving current directory on http://localhost:$port"
    python -m http.server "$port"
}

# --- Vencord ---
# [INFO] Install Vencord.
vencord() {
  sh -c "$(curl -sS https://vencord.dev/install.sh)"
}


# ┌─── System Utilities ───────────────────────────────────────────────────────┐

# --- Fuzzy Kill ---
# [INFO] Interactively select and kill processes.
fk() {
    local pid
    
    # [INFO] If argument provided, filter by it. Otherwise show all user procs.
    if [[ -n "$1" ]]; then
        pid=$(pgrep -f "$1" | fzf --preview="ps -fp {}" --header="Kill matches for '$1'")
    else
        # [OPTIMIZATION] ps output directly formatted to avoid awk later if possible
        pid=$(ps -u "$USER" -o pid,comm,args | sed 1d | fzf \
            --header="Select process to kill" \
            --preview="echo {}" \
            --preview-window=down:20% \
            --height=40% \
            --layout=reverse | awk '{print $1}')
    fi

    if [[ -n "$pid" ]]; then
        echo "Killing PID $pid..."
        kill -9 "$pid" && echo "Process $pid terminated."
    fi
}

# --- Metro Doctor ---
# [INFO] Verifies that all paths defined in metro_files/modules actually exist.
# [USAGE] mdoc
mdoc() {
    local missing=0
    
    echo "Scanning Metro System routes..."
    
    # Check Files
    for alias in "${(@k)metro_files}"; do
        if [[ ! -f "${metro_files[$alias]}" ]]; then
            echo "  [FILE]   Broken link: '$alias' -> ${metro_files[$alias]}"
            ((missing++))
        fi
    done

    # Check Modules
    for alias in "${(@k)metro_modules}"; do
        if [[ ! -d "${metro_modules[$alias]}" ]]; then
            echo "  [MODULE] Broken link: '$alias' -> ${metro_modules[$alias]}"
            ((missing++))
        fi
    done

    if (( missing == 0 )); then
        echo "All routes are valid."
    else
        echo "Found $missing broken routes."
        return 1
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
    # Guard: Check dependency first
    if ! command -v wl-copy >/dev/null 2>&1; then
        echo "Error: wl-copy not found (are you on Wayland?)." >&2
        return 1
    fi

    # Happy Path
    sed 's/\x1b\[[0-9;]*m//g' | wl-copy
}


# ┌─── Dotfiles Management ────────────────────────────────────────────────────┐

# --- Dotfiles Core ---
# [INFO] The primary engine for managing the bare repository (~/.dotfiles).
# [NOTE] Serves as the backend for all 'd*' aliases (dstat, dadd, dpush).
dotgit() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# --- Dotfiles Doctor ---
# [INFO] Diagnostic tool to detect "Ghost Files" (files created but not added to git).
# [NOTE] Unlike 'dstat', this explicitly hunts for untracked items in critical paths.
# [CONFIG] Scans: ~/.config, ~/.local/bin, and shell entry points.
dfd() {
    local untracked_files
    
    untracked_files=$(dotgit ls-files --others --exclude-standard -- \
        "$HOME/.config" "$HOME/.local/bin" "$HOME/.zshrc" "$HOME/.p10k.zsh")

    if [[ -n "$untracked_files" ]]; then
        echo "┌─ [CRITICAL] Untracked Dotfiles ──────────────────────────────────┐"
        echo "$untracked_files" | sed 's/^/│  /;$s/│/└/'
        echo "└────────────────────────────────────────────────────────────────┘"
        echo "  Use 'dadd <path>' to secure them."
    else
        echo "✨ All critical dotfiles are tracked."
    fi
}

# --- Dotfiles Smart Copy ---
# [INFO] Interactive picker for changed dotfiles.
# [NOTE] simple & stable version: uses standard git diff.
dcf() {
    # [CONFIG] Raw git command to bypass aliases
    local raw_git="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

    # [CHECK] Get status
    local changed_files
    changed_files=$(dotgit status --porcelain)
    [[ -z "$changed_files" ]] && { echo "✨ No changes found in dotfiles."; return 0; }

    local file
    # [CORE] Clean Selection Logic
    # 1. sed removes status codes ('M  ', 'D  ') -> FZF sees clean paths.
    # 2. PREVIEW LOGIC:
    #    We pipe 'git diff' to 'grep .'. 
    #    - If diff has text (Mod/Del) -> grep returns true -> 'bat' is skipped.
    #    - If diff is empty (New file) -> grep returns false -> '||' runs 'bat'.
    file=$(echo "$changed_files" | sed 's/^...//' | fzf \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --prompt="Diff > " \
        --header="Select a file to copy its changes" \
        --preview-window="right:65%:wrap:border-left" \
        --preview="$raw_git diff --color=always -- {} | grep . || bat --color=always --style=numbers -- {}"
    )

    # [ACTION] Handle selection
    if [[ -n "$file" ]]; then
        # Check if file is tracked
        if dotgit ls-files --error-unmatch "$file" >/dev/null 2>&1; then
            # Case 1: Modified or Deleted -> Copy Diff
            dotgit diff --no-color -- "$file" | copy
            print -P "%F{green}✔ Diff copied for: %B$file%b%f"
        else
            # Case 2: New/Untracked -> Copy Content
            cat "$file" | copy
            print -P "%F{yellow}✔ New file content copied: %B$file%b%f"
        fi
    fi
}
