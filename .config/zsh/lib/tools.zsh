# ┌─── Module: System & Dev Tools ─────────────────────────────────────────────┐
# │  [INFO] A collection of interactive helpers and core system utilities.     │
# │  [DEPENDS] fzf, rg, bat, zoxide (z), commands from 05_aliases.zsh          │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── ZLE & Basic Functions ───────────────────────────────────────────────────┐

# [FLOW] Magic Enter: Interactive context-aware executor
magic-enter() {
    # [FLOW] Execute command if buffer is not empty
    if [[ -n "${BUFFER// }" ]]; then
        zle accept-line
        return
    fi
    
    # [FLOW] Execution Logic (Default: eza)
    local cmd="eza --icons --group-directories-first --git"
    
    # [OPT] Append git status if inside a repository
    command git status --porcelain &>/dev/null && cmd="$cmd && git status -sb"

    BUFFER="$cmd"
    zle accept-line
}
zle -N magic-enter # [FLOW] Widget registration (Keybindings in 70_init)


# [FLOW] Make & Enter: Create a directory and cd into it immediately.
mkcd() {
    [[ -z "$1" ]] && return 1
    mkdir -p "$1" && cd "$1"
}


# [FLOW] Backup File: Create a timestamped backup (file.bak.YYYYMMDD...)
bak() {
    [[ -z "$1" ]] && { echo "Usage: bak <filename>"; return 1; }
    # [CRIT] Using aliased cp -iv (from 50_aliases)
    cp -iv "$1" "$1.bak.$(date +'%Y%m%d-%H%M%S')" 
}


# [FLOW] Web Server: Serve current directory via Python.
serve() {
    local port="${1:-8000}"
    echo "Serving current directory on http://localhost:$port"
    python -m http.server "$port" --bind 127.0.0.1
}


# [FLOW] Vencord Installer
vencord() {
    print -P "%F{yellow}Running Vencord Installer...%f"
    sh -c "$(curl -sS https://vencord.dev/install.sh)"
}


# ┌── Fuzzy Search Utilities ──────────────────────────────────────────────────┐

# [FLOW] Ripgrep Fzf: Interactive grep across the entire project.
rf() {
    local root="${1:-.}"
    local selection
    
    # [OPT] Exclude .git is crucial for speed and relevant results
    selection=$(rg --line-number --no-heading --hidden --glob '!.git' . "$root" | fzf \
        --height=50% \
        --delimiter=':' \
        --header="🔍 Project Search: $root — Enter → open" \
        --preview-window="right:60%:wrap:border-rounded:follow" \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} {1}")

    [[ -z "$selection" ]] && return 0

    # [FLOW] Native Zsh splitting (Format: file:line:content)
    local file="${selection%%:*}"      
    local remaining="${selection#*:}" 
    local line="${remaining%%:*}"      

    z "${file:h}" # [DEPENDS] Zoxide function
    ${EDITOR:-nvim} +"$line" "$file"
}


# [FLOW] Path Tracer: Find where a specific path/string is referenced.
pt() {
    local query="$1"
    [[ -z "$query" ]] && { print -P "%F{red}Usage: pt <path_segment>%f"; return 1; }

    local search_roots=(
        "$HOME/.config"
        "$HOME/.local/bin"
        "$HOME/.zshrc"
    )

    local selection
    # [CORE] Logic: Display only filename, but pass File:Line to preview/output
    selection=$(rg --line-number --no-heading --color=never --fixed-strings --no-ignore "$query" "${search_roots[@]}" 2>/dev/null | \
        cut -d: -f1,2 | \
        fzf \
            --delimiter=: \
            --with-nth=1 \
            --height=50% \
            --header="Trace: $query" \
            --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} {1}" \
            --preview-window="right:65%:wrap:border-rounded:+{2}/2")

    [[ -z "$selection" ]] && return 0

    # [ACTION] Parse hidden data
    local file="${selection%:*}"
    local line="${selection##*:}"

    ${EDITOR:-nvim} +"$line" "$file"
}


# [FLOW] Find Inside: Interactive fuzzy-search within a specific file.
fin() {
    local file="$1"
    [[ -f "$file" ]] || { echo "Error: File not found: $file"; return 1; }

    local selection
    selection=$(rg --no-heading --line-number --color=always -i "" "$file" | fzf \
        --ansi \
        --delimiter=: \
        --header="$file — Fuzzy-search" \
        --height=30% \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} $file")

    [[ -z "$selection" ]] && return 0
    
    local line="${selection%%:*}"
    ${EDITOR:-nvim} +"$line" "$file"
}


# [FLOW] Cheat Sheet: Query cht.sh for code snippets.
cht() {
    if [[ $# -eq 0 ]]; then echo "Usage: cht <language> <question>"; return 1; fi
    local lang="$1"; shift; local query="${*// /+}"; # [OPT] Replace spaces with +
    
    if command -v bat >/dev/null; then
        curl -s "cht.sh/$lang/$query?T" | bat --language="$lang" --style=plain
    else
        curl -s "cht.sh/$lang/$query"
    fi
}


# ┌── System Utilities ────────────────────────────────────────────────────────┐

# [FLOW] Fuzzy Kill: Interactively select and kill processes.
fk() {
    local pid
    if [[ -n "$1" ]]; then
        pid=$(pgrep -f "$1" | fzf --preview="ps -fp {}" --header="Kill matches for '$1'")
    else
        # [OPT] Use ps and sed/awk to get PID for user processes
        pid=$(ps -u "$USER" -o pid,comm,args | sed 1d | fzf --height=40% --layout=reverse | awk '{print $1}')
    fi

    if [[ -n "$pid" ]]; then
        echo "Killing PID $pid..."
        # [CRIT] Requires kill command
        kill -9 "$pid" && echo "Process $pid terminated."
    fi
}


# [FLOW] Copy Helper: wl-copy wrapper supporting pipe/file/string.
copy() {
    local clip_cmd="wl-copy"
    local strip_cmd="sed 's/\x1b\[[0-9;?]*[A-Za-z]//g'" # [FIX] ANSI stripping logic
    
    if [[ -n "$1" ]]; then
        if [[ -f "$1" ]]; then
            eval "$strip_cmd \"$1\" | $clip_cmd" # File Input
        else
            print -rn -- "$*" | eval "$strip_cmd | $clip_cmd" # String Input
        fi
    else
        eval "$strip_cmd | $clip_cmd" # Pipe Input
    fi

    (( $? == 0 )) && print -P "%F{green}✔%f Copied to clipboard." >&2
}

# ┌── Diagnostics ─────────────────────────────────────────────────────────────┐

# ┌── 6.4. Diagnostics & Health ───────────────────────────────────────────────┐


# [FLOW] Metro Doctor: Verifies configuration routes.
mdoc() {
    local _m_err=0
    local _indent="│ "
    local _k _v # [FIX] Use neutral names to avoid system variable collision
    
    # [INFO] Check Files
    for _k _v in "${(@kv)metro_files}"; do
        if [[ ! -f "$_v" ]]; then
            print -P "%F{9}${_indent}[FILE]   Broken:%f $_k -> $_v"
            ((_m_err++))
        fi
    done

    # [INFO] Check Modules
    for _k _v in "${(@kv)metro_modules}"; do
        if [[ ! -d "$_v" ]]; then
            print -P "%F{9}${_indent}[MODULE] Broken:%f $_k -> $_v"
            ((_m_err++))
        fi
    done

    if (( _m_err == 0 )); then
        print -P "%F{10}${_indent}[PASS]%f All configuration routes are valid."
        return 0
    else
        print -P "%F{9}${_indent}[FAIL] Found $_m_err broken routes.%f"
        return $_m_err
    fi
}


# [FLOW] Zsh Doctor: High-level system health monitor.
zdoc() {
    # [CRIT] Ensure all counters and variables are local and neutralized
    local errors=0
    local warnings=0
    local indent="│ "
    local _k _v _f _cmd _expanded_cmd _alias_err=0

    print -P "%F{11}┌── Zsh Doctor: System Diagnosis ───────────────────────────────┐%f"

    # 1. Core Files
    print -P "%F{6}│ %B1. Core Filesystem%b%f"
    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        for _f in "$ZSH_CONFIG_DIR"/(10|20|30|40|50|60|70)_*.zsh(N); do
            [[ -f "$_f" ]] && print -P "%F{10}${indent}[PASS]%f ${_f:t}" || { print -P "%F{9}${indent}[CRIT] Missing: $_f%f"; ((errors++)); }
        done
    else
        print -P "%F{9}${indent}[CRIT] ZSH_CONFIG_DIR not found.%f"; ((errors++))
    fi

    # 2. External Dependencies
    print -P "%F{6}│ %B2. External Dependencies%b%f"
    for _k _v in "${(@kv)aliases}"; do
        _cmd=${${_v[(w)1]}//[\'\"]/}
        [[ "$_cmd" == "sudo" || "$_cmd" == "command" || "$_cmd" == "|" || "$_cmd" == ">" ]] && continue
        
        _expanded_cmd=${_cmd/#\~/$HOME}
        if ! whence "$_expanded_cmd" >/dev/null 2>&1; then
            print -P "%F{9}${indent}[FAIL] Alias '%B$_k%b' -> '%F{214}$_cmd%f' missing.%f"
            ((_alias_err++))
        fi
    done
    (( _alias_err == 0 )) && print -P "%F{10}${indent}[PASS]%f All aliases are valid."
    (( errors += _alias_err ))

    # 3. Metro System
    print -P "%F{6}│ %B3. Metro System Routes%b%f"
    if type mdoc &>/dev/null; then
        mdoc # Prints its own status and results
        (( errors += $? ))
    else
        print -P "%F{11}${indent}[WARN] mdoc not found.%f"; ((warnings++))
    fi

    print -P "%F{11}└─────────────────────────────────────────────────────────────┘%f"

    # 4. Final Verdict (Safe Print)
    if (( errors > 0 )); then
        printf "\033[31m[FATAL] Diagnosis complete. Found %d errors.\033[0m\n" "$errors"
        return 1
    elif (( warnings > 0 )); then
        printf "\033[33m[WARN] Diagnosis complete. Found %d warnings.\033[0m\n" "$warnings"
        return 0
    else
        printf "\033[32m[OK] System health is excellent (0 errors).\033[0m\n"
        return 0
    fi
}
