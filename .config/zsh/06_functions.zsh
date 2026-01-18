# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                6. Functions                                │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─── Metro System ───────────────────────────────────────────────────────────┐
# │                                                                            │
# │  [INFO] Centralized registry for dotfiles navigation & management.         │
# │  [NOTE] Defines targets for 'edit', 'view', and 'goto' commands.           │
# │                                                                            │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── Configuration Data ─────────────────────────────────────────────────────┐

# --- Dynamic Variables ---
local zen_paths=($HOME/.zen/*"Default (release)"(/N))
local zen_profile="${zen_paths[1]:-$HOME/.zen/default}"
local bin_dir="$HOME/.local/bin"

# [INFO] Global cache to avoid rebuilding menu every time
typeset -g _metro_menu_cache=""

# --- Visual Assets ---

# [CONFIG] Visual indicators (Exported for FZF subshell visibility)
export METRO_ICON_FILE=""
export METRO_ICON_DIR=""
export METRO_ICON_CONF=""

# --- Modules (Folders) ---
# [INFO] Directories opened via file picker (edit) or tree view (view).
typeset -gA metro_modules
metro_modules=(
    [hypr]="$HYPR"
    [kitty]="$DOTS/kitty"
    [waybar]="$DOTS/waybar"
    [wofi]="$DOTS/wofi"
    [rofi]="$DOTS/rofi"
    [zsh]="$ZSH_CONFIG_DIR"
    [scripts]="$bin_dir"
    [pyre]="$DOTS/pyre"
)

# --- Files (Direct Access) ---
# [INFO] Specific files opened directly in the editor.
typeset -gA metro_files
metro_files=(
    # --- 1. Hyprland Core ---
    [hyprconf]="$HYPR/hyprland.conf"                   # Main configuration entry point
    [hyprbinds]="$HYPR/keybinds.conf"                  # Keybindings and input definitions
    [hyprdecor]="$HYPR/decoration.conf"                # Animations, blur, and decorations
    [hyprrules]="$HYPR/rules.conf"                     # Window rules and workspace assignments
    [hyprcolors]="$HYPR/colors.conf"                   # System-wide color palette
    [hyprlock]="$HYPR/hyprlock.conf"                   # Lock screen configuration
    [hypridle]="$HYPR/hypridle.conf"                   # Idle daemon configuration

    # --- 2. Desktop UI ---
    [wayconf]="$DOTS/waybar/config"                    # Bar layout and modules
    [waystyle]="$DOTS/waybar/style.css"                # CSS styling and geometry
    [waycolors]="$DOTS/waybar/colors.css"              # Bar-specific color variables
    [woficonf]="$DOTS/wofi/config"                     # Launcher behavior and size
    [wofistyle]="$DOTS/wofi/style.css"                 # Launcher CSS styling
    [woficolors]="$DOTS/wofi/colors.css"               # Launcher color variables
    [roficonf]="$DOTS/rofi/config.rasi"                # Rofi main config
    [rofistyle]="$DOTS/rofi/style.rasi"                # Rofi styling
    [roficolors]="$DOTS/rofi/colors.rasi"              # Rofi colors
    [kittyconf]="$DOTS/kitty/kitty.conf"               # Terminal settings and fonts
    [kittycolors]="$DOTS/kitty/colors.conf"            # Terminal color scheme
    [dunstconf]="$DOTS/dunst/dunstrc"                  # Notification daemon config

    # --- 3. Zsh Ecosystem ---
    [zshrc]="$HOME/.zshrc"                             # Main entry point
    [p10k]="$HOME/.p10k.zsh"                           # Powerlevel10k theme
    [zshenv]="$ZSH_CONFIG_DIR/01_environment.zsh"      # 01. Environment & Path
    [zshopts]="$ZSH_CONFIG_DIR/02_options.zsh"         # 02. Shell options & History
    [zshplugs]="$ZSH_CONFIG_DIR/03_plugins.zsh"        # 03. Plugin manager
    [zshfzf]="$ZSH_CONFIG_DIR/04_fzf.zsh"              # 04. FZF integration
    [zshals]="$ZSH_CONFIG_DIR/05_aliases.zsh"          # 05. Command aliases
    [zshfn]="$ZSH_CONFIG_DIR/06_functions.zsh"         # 06. Custom functions
    [zshinit]="$ZSH_CONFIG_DIR/07_init.zsh"            # 07. Initialization sequence

    # --- 4. Apps & Tools ---
    [fastfetch]="$DOTS/fastfetch/config.jsonc"         # Terminal fecth
    [nvim]="$DOTS/nvim/lua/config/lazy.lua"            # Neovim plugin manager
    [git]="$DOTS/lazygit/config.yml"                   # Git TUI interface
    [mise]="$DOTS/mise/config.toml"                    # Runtime manager config
    [clipse]="$DOTS/clipse/config.json"                # Clipboard history
    [uair]="$DOTS/uair/uair.toml"                      # Pomodoro timer
    [gammaconf]="$DOTS/gammastep/config.ini"           # Night light configuration
    [fast]="$DOTS/fastfetch/config.jsonc"              # System information tool
    [sampler]="$DOTS/sampler/sampler.yml"              # TUI System monitor
    [cava]="$DOTS/cava/config"                         # Audio visualizer
    [imv]="$DOTS/imv/config"                           # Image viewer
    [userjs]="${zen_profile}/user.js"                  # Browser hardening config

    # --- 5. System Configs ---
    [topgrade]="$DOTS/topgrade.toml"
    [mime]="$HOME/.config/mimeapps.list"               # Default app associations
    [ssh]="$HOME/.ssh/config"                          # SSH hosts and keys
    [keyd]="/etc/keyd/default.conf"                    # Keyboard remapping

    # --- 6. Scripts ---
    [pyreconf]="$bin_dir/pyre"                         # Engine entry point
    [pyrefn]="$HOME/.config/pyre/functions.sh"         # Engine library functions
    [bright]="$bin_dir/brightness-manager"             # Monitor brightness logic
    [ryzen]="/usr/local/sbin/apply-ryzen-settings.sh"  # CPU power management
    [gitig]="$HOME/.gitignore"                         # Global git ignore patterns
)


# ┌─── Internal Helpers ───────────────────────────────────────────────────────┐

# --- Menu Generator ---
# [INFO] Generates the formatted list for FZF. Uses cache for speed.
_metro_build_menu() {
    [[ -n "$_metro_menu_cache" ]] && { print -r -- "$_metro_menu_cache"; return; }

    local file_list
    file_list=$(for k in "${(@k)metro_files}"; do 
        printf "%-15s %s  %s\n" "$k" "$METRO_ICON_FILE" "${metro_files[$k]:t}"
    done | sort -k 3 -V)

    local module_list
    module_list=$(for k in "${(@k)metro_modules}"; do 
        printf "%-15s %s  %s/\n" "$k" "$METRO_ICON_DIR" "${metro_modules[$k]:t}"
    done | sort -k 3 -V)
    
    # [CACHE] Store the result
    _metro_menu_cache=$(printf "p10k           %s  Configure Powerlevel10k\n%s\n%s" \
        "$METRO_ICON_CONF" "$file_list" "$module_list")
    
    print -r -- "$_metro_menu_cache"
}

# --- Preview Resolver ---
# [INFO] Used only inside FZF subshell via explicit injection.
_metro_get_path() {
    local key="$1"
    if [[ -v metro_files[$key] ]]; then echo "${metro_files[$key]}"
    elif [[ -v metro_modules[$key] ]]; then echo "${metro_modules[$key]}"
    fi
}

# --- Unified Interactive Selector ---
# [INFO] Generic FZF launcher used by edit/view/goto.
_metro_pick() {
    local header="$1"
    local filter="${2:-cat}"
    
    # 1. Dependency Resolution (Startup)
    local _bat="${commands[bat]:-cat}"
    local _eza="${commands[eza]:-ls}"

    # 2. Context Serialization
    # [CRITICAL] Pack arrays and the helper function.
    local context="$(typeset -p metro_files metro_modules); $(typeset -f _metro_get_path)"
    
    # 3. Preview Logic (Injection)
    # [NOTE] We inject the resolved variables ($_eza, $_bat) directly into the string.
    local preview_cmd="
        alias=\$(echo {} | cut -d' ' -f1);
        path=\$(_metro_get_path \"\$alias\");
        if [[ -d \"\$path\" ]]; then
            $_eza --tree --level=2 --icons --group-directories-first \"\$path\";
        elif [[ -f \"\$path\" ]]; then
            $_bat --color=always --style=numbers --line-range :200 \"\$path\";
        fi
    "

    # 4. Execution
    _metro_build_menu | eval "$filter" | fzf \
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --no-separator \
        --preview-window="right:70%:border-rounded" \
        --header="$header" \
        --preview="$context; $preview_cmd"
}

# --- Module Selector ---
# [INFO] Sub-menu when editing a folder/module.
_edit_module() {
    local module_path="$1"
    local selected_file
    local cmd

    # [SAFETY] Guard against empty paths
    [[ -z "$module_path" ]] && return 1

    # 1. Dependency Resolution
    local _fd="${commands[fd]:-find}"
    local _bat="${commands[bat]:-cat}"

    # 2. Search Strategy (FD vs Find)
    if [[ "$_fd" == *"fd"* ]]; then
        # [FD] Modern search. Note: We pass module_path as the target arg.
        cmd="$_fd --type f --max-depth 2 --hidden --exclude .git --absolute-path . \"$module_path\""
    else
        # [FIND] POSIX fallback.
        cmd="find \"$module_path\" -maxdepth 2 -type f -not -name '.*'"
    fi

    # 3. Execution (with injected previewer)
    selected_file=$(eval "$cmd" | \
        fzf --height=50% \
            --layout=reverse \
            --border=rounded \
            --header="Editing Module: ${module_path:t} — Select a file" \
            --preview="$_bat --color=always --style=numbers --line-range :200 {}")

    [[ -n "$selected_file" ]] && $EDITOR "$selected_file"
}

# --- Autocompletion ---
_metro_completion() {
    local -a matches
    if [[ "$service" != "goto" ]]; then
        for k in "${(@k)metro_files}"; do 
            matches+=("$k:[File] ${metro_files[$k]:t}")
        done
        matches+=("p10k:[Action] Configure P10k")
    fi

    for k in "${(@k)metro_modules}"; do 
        matches+=("$k:[Module] ${metro_modules[$k]:t}/")
    done
    _describe 'metro config' matches
}


# ┌─── Public Commands ────────────────────────────────────────────────────────┐

# --- The Editor ---
# [INFO] Open configuration files or modules in editor.
# [EXAMPLE] edit             # Interactive mode
# [EXAMPLE] edit p10k        # Special configuration
edit() {
    # --- CLI Argument Mode ---
    if [[ -n "$1" ]]; then
        local target="$1"
        
        # Special case for Powerlevel10k
        [[ "$target" == "p10k" ]] && { p10k configure; return 0; }
        
        # [INFO] Check Files (Direct Array Access)
        if [[ -v metro_files[$target] ]]; then
            local f="${metro_files[$target]}"
            z "${f:h}" && $EDITOR "${f:t}"
            return 0
        fi

        # [INFO] Check Modules (Direct Array Access)
        if [[ -v metro_modules[$target] ]]; then
            _edit_module "${metro_modules[$target]}"
            return 0
        fi

        echo "Config not found: $target"
        return 1
    fi
    
    # --- Interactive Mode ---
    local selection
    selection=$(_metro_pick "Select a config file or module to edit")
    
    [[ -n "$selection" ]] && edit "${selection%% *}"
}

# --- The Viewer ---
# [INFO] View configuration files or directory trees.
# [EXAMPLE] view zsh         # View formatted with bat
# [EXAMPLE] view -c nvim     # View raw content (plain)
view() {
    # --- CLI Argument Mode ---
    if [[ -n "$1" ]]; then
        local target="$1"
        local opts=(--style=header,grid,numbers)
        
        # Check for raw flag
        if [[ "$1" == "-c" ]]; then 
            opts=(--style=plain); shift; target="$1"
        fi

        # [INFO] Render File Content
        if [[ -v metro_files[$target] ]]; then
            bat --paging=never "${opts[@]}" --color=always "${metro_files[$target]}"
            return 0
        fi

        # [INFO] Render Directory Tree
        if [[ -v metro_modules[$target] ]]; then
            eza --tree --level=3 --icons "${metro_modules[$target]}"
            return 0
        fi

        echo "Config not found: $target"
        return 1
    fi
    
    # --- Interactive Mode ---
    local selection
    selection=$(_metro_pick "View config content")
    
    [[ -n "$selection" ]] && view "${selection%% *}"
}

# --- The Navigator ---
# [INFO] Navigate to the directory containing the configuration.
# [EXAMPLE] goto zsh         # Jump to zsh config folder
# [EXAMPLE] goto nvim        # Jump to nvim config folder
goto() {
    # --- CLI Argument Mode ---
    if [[ -n "$1" ]]; then
        local target="$1"
        
        # [INFO] Jump to File Parent
        if [[ -v metro_files[$target] ]]; then
            z "${metro_files[$target]:h}"
            return 0
        fi

        # [INFO] Jump to Module Root
        if [[ -v metro_modules[$target] ]]; then
            z "${metro_modules[$target]}"
            return 0
        fi

        echo "Config not found: $target"
        return 1
    fi

    # --- Interactive Mode ---
    local selection
    selection=$(_metro_pick "Select a destination to GO TO" "grep '$METRO_ICON_DIR'")
    
    [[ -n "$selection" ]] && goto "${selection%% *}"
}


# ┌────────────────────────────────────────────────────────────────────────────┐
# │                       Interactive Shell Enhancements                       │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─── Navigation Helpers ─────────────────────────────────────────────────────┐

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

# --- Magic-Enter ---
# [INFO] Runs 'ls' on empty buffer, or 'git status' if in repo.
magic-enter() {
    # --- Guard Clause ---
    # If buffer is NOT empty, execute normal return
    if [[ -n "${BUFFER// }" ]]; then
        zle accept-line
        return
    fi

    # --- Execution Logic ---
    local cmd="eza --icons --group-directories-first --git"
    
    # [INFO] Append git status if inside a repository
    if command git status --porcelain &>/dev/null; then
        cmd="$cmd && git status -sb"
    fi

    BUFFER="$cmd"
    zle accept-line
}
zle -N magic-enter

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
        --header="$file — Fuzzy-search" \
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
    python -m http.server "$port" --bind 127.0.0.1
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

# [INFO] wl-copy wrapper supporting pipe/file/string.
# [INFO] Automatically strips ANSI colors.
# [EXAMPLE] echo "col" | copy    # Pipe mode
# [EXAMPLE] copy file.txt        # File mode
# [EXAMPLE] copy "text"          # String mode
copy() {
    local clip_cmd="wl-copy"

    # --- Input Processing ---
    if [[ -n "$1" ]]; then
        if [[ -f "$1" ]]; then
            # File Input
            sed 's/\x1b\[[0-9;?]*[A-Za-z]//g' "$1" | $clip_cmd
        else
            # String Input
            print -rn -- "$*" | sed 's/\x1b\[[0-9;?]*[A-Za-z]//g' | $clip_cmd
        fi
    else
        # Pipe Input
        sed 's/\x1b\[[0-9;?]*[A-Za-z]//g' | $clip_cmd
    fi

    # --- Feedback ---
    (( $? == 0 )) && print -P "%F{green}✔%f Copied to clipboard." >&2
}

# --- Backup File ---
# [INFO] Create a timestamped backup (file.bak.YYYYMMDD...)
bak() {
    [[ -z "$1" ]] && { echo "Usage: bak <filename>"; return 1; }
    cp -iv "$1" "$1.bak.$(date +'%Y%m%d-%H%M%S')"
}


# ┌─── Media & AI ─────────────────────────────────────────────────────────────┐

# --- AI Transcriber ---
# [INFO] Downloads audio from URL and transcribes it using local Whisper.
# [NOTE] Auto-switches to CPU if model is too heavy for standard GPUs.
# [UI] Displays metadata card + native download progress (Speed/ETA).
# [USAGE] vid2txt <url> [model: small|medium]
vid2txt() {
    # 1. Validation
    if [[ -z "$1" ]]; then
        echo "Usage: vid2txt <url> [model]"
        return 1
    fi

    # 2. Dependency Check
    # [INFO] Ensure core tools exist before execution
    (( $+commands[yt-dlp] ))  || { echo "Error: 'yt-dlp' not found."; return 1; }
    (( $+commands[whisper] )) || { echo "Error: 'whisper' not found."; return 1; }

    local url="$1"
    local model="${2:-small}"
    local device="cuda"

    # 3. Hardware Logic
    # [HARDWARE] GTX 1650 Limit: 'medium' requires ~5GB VRAM
    if [[ "$model" == "medium" || "$model" == "large" ]]; then
        print -P "%F{yellow}[!] Model '$model' exceeds VRAM limits. Switching to CPU mode.%f"
        device="cpu"
    fi

    # 4. Metadata Fetching
    print -P "%F{blue}>> Connecting to stream...%f"

    # [NOTE] Retrieve metadata in single pass
    local meta
    meta=("${(@f)$(yt-dlp --print "%(title)s" --print "%(uploader)s" --print "%(duration_string)s" "$url" 2>/dev/null)}")

    local raw_title="${meta[1]}"
    local uploader="${meta[2]:-Unknown}"
    local duration="${meta[3]:-N/A}"

    # [FALLBACK] Generate timestamp title if metadata fails
    [[ -z "$raw_title" ]] && raw_title="Transcription $(date +%s)"

    local clean_title
    clean_title=$(echo "$raw_title" | sed 's/[^a-zA-Z0-9а-яА-Я ]//g' | tr ' ' '_')

    local tmp_audio="/tmp/${clean_title}.wav"

    # 5. UI: Info Card
    echo ""
    print -P "%F{237}┌── %F{white}Media Info %F{237}────────────────────────────────────────────────┐%f"
    print -P "%F{237}│%f  Title:    %F{cyan}${raw_title:0:60}...%f"
    print -P "%F{237}│%f  Channel:  %F{cyan}$uploader%f"
    print -P "%F{237}│%f  Length:   %F{cyan}$duration%f"
    print -P "%F{237}└──────────────────────────────────────────────────────────────┘%f"
    echo ""

    # 6. Execution Pipeline
    # [FFMPEG] Force 16kHz mono for Whisper native format
    yt-dlp -x \
        --audio-format wav \
        --postprocessor-args "-ar 16000 -ac 1" \
        --output "$tmp_audio" \
        --no-warnings \
        --progress \
        "$url"

    echo ""
    print -P "%F{magenta}[AI] Transcribing ($model on $device / FP32)...%f"

    whisper "$tmp_audio" \
        --model "$model" \
        --device "$device" \
        --output_format txt \
        --output_dir . \
        --verbose False \
        --fp16 False

    # 7. Cleanup
    mv "${clean_title}.txt" "${clean_title}_subs.txt" 2>/dev/null
    command rm -f "$tmp_audio"

    print -P "%F{green}[OK] Saved:%f ${clean_title}_subs.txt"
}


# ┌─── Dotfiles Management ────────────────────────────────────────────────────┐

# --- Dotfiles Core ---
# [INFO] The primary engine for managing the bare repository (~/.dotfiles).
# [NOTE] Serves as the backend for all 'd*' aliases (dstat, dadd, dpush).
dotgit() {
    command git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
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
        echo "All critical dotfiles are tracked."
    fi
}

# [INFO] Interactive picker for changed dotfiles.
# [INFO] Simple & stable version using standard git diff.
dcf() {
    # [CONFIG] Raw git command to bypass aliases
    local raw_git="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

    # --- Status Check ---
    local changed_files
    changed_files=$(dotgit status --porcelain)
    
    [[ -z "$changed_files" ]] && { echo "No changes found in dotfiles."; return 0; }

    # --- Selection Logic ---
    local file
    
    # [INFO] Pipeline Strategy:
    # 1. sed: Removes status codes ('M ', 'D ') for clean paths.
    # 2. preview: Uses grep to switch between diff (modified) and bat (new).
    file=$(echo "$changed_files" | sed 's/^...//' | fzf \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --prompt="Diff > " \
        --header="Select a file to copy its changes" \
        --preview-window="right:65%:wrap:border-left" \
        --preview="$raw_git diff --color=always -- {} | grep . || bat --color=always --style=numbers -- {}"
    )

    # --- Execution ---
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
