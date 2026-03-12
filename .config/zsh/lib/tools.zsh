# ┌─── 1. ZLE & Interaction Widgets ───────────────────────────────────────────┐

_MAGIC_ENTER_ACTIVE=0


_magic_enter_info() {
    # [NOTE] File listing
    eza --icons --group-directories-first

    # [NOTE] Git & Dotfiles Analytics
    local _gs_raw=""
    local _is_dots=0

    if [[ "$PWD" == "$HOME" ]]; then
        # Target bare repository when in HOME
        _gs_raw=$(git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" status -sb 2>/dev/null)
        _is_dots=1
    elif git rev-parse --is-inside-work-tree &>/dev/null; then
        _gs_raw=$(git status -sb 2>/dev/null)
    fi

    if [[ -n "$_gs_raw" ]]; then
        local _branch_line=$(echo "$_gs_raw" | head -n 1)
        local _changes=$(echo "$_gs_raw" | tail -n +2 | head -n 11)
        
        # Parse branch name and upstream sync status
        local _branch_name=${${_branch_line#\#\# }%%...*}
        local _sync=""
        [[ "$_branch_line" == *'['* ]] && _sync=" %F{216}[${${_branch_line#*[}%]*}]%f"
        
        # Resolve stash count (specific to dotfiles if in HOME)
        local _stash_cmd=(git stash list)
        (( _is_dots )) && _stash_cmd=(git --git-dir="$HOME/.dotfiles/" stash list)
        
        local _stash_n=$("${_stash_cmd[@]}" 2>/dev/null | wc -l)
        local _stash=""
        (( _stash_n > 0 )) && _stash=" %F{183}󰇝 $_stash_n%f"

        # Separate icon for dotfiles to distinguish from regular repos
        local _icon=" "
        (( _is_dots )) && _icon="󱂵 Dotfiles: "

        print -P "\n%F{111}${_icon}${_branch_name}%f${_sync}${_stash}"

        if [[ -n "$_changes" ]]; then
            echo "$_changes"
            [[ $(echo "$_gs_raw" | wc -l) -gt 12 ]] && print -P "%F{243}  ... and more files%f"
        else
            print -P "%F{151}  󰄬 Repository clean%f"
        fi
    fi

    # [NOTE] Docker: Contextual container status
    local _sock="${DOCKER_HOST#unix://}"
    [[ -z "$_sock" ]] && _sock="/var/run/docker.sock"

    if [[ -S "$_sock" && -r "$_sock" ]] && [[ -f "docker-compose.yml" || -f "docker-compose.yaml" ]]; then
        local _containers=$(docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null | tail -n +2)
        
        if [[ -n "$_containers" ]]; then
            print -P "\n%F{114}󰡨 Active Containers:%f"
            echo "$_containers"
        fi
    fi
}


_magic_enter_precmd() {
    if (( _MAGIC_ENTER_ACTIVE )); then
        _magic_enter_info
        _MAGIC_ENTER_ACTIVE=0
    fi
}


# magic_enter: Context-aware executor providing directory and repository analytics
magic_enter() {
    if [[ -n "${BUFFER// }" ]]; then
        zle accept-line
        return
    fi

    # [NOTE] Leading space prevents command from being saved to history
    BUFFER=" :"
    _MAGIC_ENTER_ACTIVE=1
    zle accept-line
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _magic_enter_precmd
zle -N magic_enter


# ┌─── 2. File & Web Utilities ────────────────────────────────────────────────┐

# sbak: Smart backup system with diff-preview and interactive restoration
sbak() {
    local _arg_1="$1"
    local _arg_2="$2"

    # [NOTE] Display guide if no arguments are provided
    if [[ -z "$_arg_1" ]]; then
        print -P "%F{216}󰑕 SBAK (Smart Backup) Guide%f"
        print -P "  %F{111}Usage:%f   sbak <file_or_dir>     %F{243}# Create timestamped backup%f"
        print -P "  %F{111}Restore:%f sbak -r [backup_file]  %F{243}# Interactive or direct restore%f"
        return 0
    fi

    # 1. Action: Restore Logic
    if [[ "$_arg_1" == "-r" ]]; then
        local _target="$_arg_2"

        if [[ -z "$_target" ]]; then
            # [NOTE] Interactive picker with diff preview
            _target=$(command find . -maxdepth 2 -name "*.bak.*" 2>/dev/null | fzf \
                --height=60% --layout=reverse --border=rounded \
                --prompt="󰑕 Restore > " \
                --preview="
                    _f={1}; _o=\${_f%.bak.*};
                    if [[ -f \"\$_o\" ]]; then
                        diff --color=always -u \"\$_o\" \"\$_f\" | delta 2>/dev/null || diff --color=always -u \"\$_o\" \"\$_f\";
                    else
                        echo 'Original file missing, showing backup content:';
                        bat --color=always --style=numbers \"\$_f\";
                    fi")
        fi

        [[ -z "$_target" ]] && return 0

        if [[ ! -e "$_target" ]]; then
            print -P "%F{203}✘ Error: Backup not found: $_target%f"
            return 1
        fi

        local _origin="${_target%.bak.*}"
        
        # [WARN] Destructive operation. Using Zsh-native 'read -q' for one-key confirmation.
        print -Pn "%F{216}󰑕 Restore %B${_target:t}%b? [y/N] %f"
        if read -q; then
            print # Move to new line after keypress
            command cp -av "$_target" "$_origin"
            print -P "%F{151}✔ Restore complete.%f"
        else
            print -P "\n%F{243}Restore cancelled.%f"
        fi
        return 0
    fi

    # 2. Action: Create Logic
    if [[ ! -e "$_arg_1" ]]; then
        print -P "%F{203}✘ Error: Path not found: $_arg_1%f"
        return 1
    fi

    local _stamp=$(date +'%Y%m%d-%H%M%S')
    local _dest="${_arg_1}.bak.${_stamp}"

    # [NOTE] Preserve all attributes and show creation log
    if command cp -av "$_arg_1" "$_dest"; then
        print -P "%F{151}󰄬 Snapshot created:%f ${_dest:t}"
    else
        return 1
    fi
}

# cht: Access interactive coding cheat-sheets from the terminal
cht() {
    [[ $# -eq 0 ]] && { echo "Usage: cht <language> <question>"; return 1; }
    local _lang="$1"; shift; local _query="${*// /+}"; 
    
    if command -v bat >/dev/null; then
        curl -s "cht.sh/$_lang/$_query?T" | bat --language="$_lang" --style=plain
    else
        curl -s "cht.sh/$_lang/$_query"
    fi
}


# ┌─── 3. Search & Triage (FZF/RG) ─────────────────────────────────────────────┐

# rf: Interactive project search via Ripgrep and Fzf
rf() {
    local _root="${1:-.}"
    local _selection
    
    # [NOTE] Excluding .git is essential for search performance
    _selection=$(rg --line-number --no-heading --hidden --glob '!.git' . "$_root" | fzf \
        --height=50% \
        --delimiter=':' \
        --header="🔍 Search: $_root" \
        --preview-window="right:60%:wrap:border-rounded:follow" \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} {1}")

    [[ -z "$_selection" ]] && return 0

    local _file="${_selection%%:*}"      
    local _remaining="${_selection#*:}" 
    local _line="${_remaining%%:*}"      

    z "${_file:h}"
    ${EDITOR:-nvim} +"$_line" "$_file"
}

# File Tracer: Locate and jump to configuration files by string occurrences
ft() {
    local _query="$1"

    # [NOTE] Display a soft-colored mini-guide if no arguments are provided
    if [[ -z "$_query" ]]; then
        print -P "%F{216}󱔗 FT (File Tracer) Guide%f"
        print -P "  %F{111}Usage:%f  ft <filename_or_string>"
        print -P "  %F{111}Scope:%f  Searches in .config, .local/bin, and .zshrc"
        print -P "  %F{111}Note:%f   Use filenames for best results (e.g., %Bft network.sh%b)"
        return 0
    fi

    local _roots=("$HOME/.config" "$HOME/.local/bin" "$HOME/.zshrc")
    local -a _results

    # [NOTE] Perform a literal, smart-case search across core configuration paths
    _results=("${(@f)$(rg --line-number --column --no-heading --smart-case --fixed-strings -- "$_query" "${_roots[@]}" 2>/dev/null)}")

    # Filter out potential empty elements from the array result
    _results=(${_results:#})

    if (( ${#_results} == 0 )); then
        print -P "%F{216}󱔗 No config entries found for:%f %B$_query%b"
        return 1
    fi

    if (( ${#_results} == 1 )); then
        # [NOTE] Automatic jump to the file if a unique match is found
        local _file="${_results[1]%%:*}"
        local _line=$(echo "${_results[1]}" | cut -d: -f2)

        print -P "%F{151}󱔗 Unique match found:%f ${_file:t}:$_line"
        ${EDITOR:-nvim} +"$_line" "$_file"
    else
        # [NOTE] List multiple matches using soft Mocha colors (Mauve/Sky)
        print -P "%F{183}󱔗 Multiple occurrences found:%f\n"
        rg --line-number --column --color=always --smart-case --fixed-strings -- "$_query" "${_roots[@]}"
    fi
}

# fin: Fuzzy-search for strings within a specific file
fin() {
    local _file="$1"
    [[ -f "$_file" ]] || { echo "Error: File not found: $_file"; return 1; }

    local _selection
    _selection=$(rg --no-heading --line-number --color=always -i "" "$_file" | fzf \
        --ansi --delimiter=: --header="$_file" --height=30% \
        --preview="bat --paging=never --style=numbers --color=always --highlight-line {2} $_file")

    [[ -z "$_selection" ]] && return 0
    ${EDITOR:-nvim} +"${_selection%%:*}" "$_file"
}


# ┌─── 4. System Integration ──────────────────────────────────────────────────┐

# fk: Interactive process terminator powered by procs and fzf
fk() {
    # [NOTE] check if procs is installed, fallback to standard ps if missing
    local _gen_cmd="command ps -u $USER -o pid,ppid,comm,args"
    local _header_n=1
    
    if (( $+commands[procs] )); then
        # [NOTE] --color always is required for fzf --ansi to render properly
        _gen_cmd="command procs --color always"
        _header_n=2
    fi

    local _selection=$(eval "$_gen_cmd" | fzf --ansi \
        --height=60% \
        --layout=reverse \
        --border=rounded \
        --header-lines=$_header_n \
        --prompt="󰆚 Kill Process > " \
        --header="Enter: SIGTERM | Alt-Enter: SIGKILL | Ctrl-R: Refresh" \
        --bind="ctrl-r:reload($_gen_cmd)" \
        --preview="echo {} | command awk '{print \$1}' | xargs -I PID procs --color always PID 2>/dev/null" \
        --preview-window="bottom:3:wrap")

    [[ -z "$_selection" ]] && return 0

    # [NOTE] Extract PID (assumed to be the first column in procs/ps output)
    local _pid=$(echo "$_selection" | command awk '{print $1}')

    # [WARN] Using SIGKILL (-9) is effective but may result in data loss.
    # Standard SIGTERM (-15) is preferred for graceful shutdown.
    if [[ -n "$_pid" ]]; then
        print -Pn "%F{216}󰆚 Terminate PID $_pid? [y/N] %f"
        if read -q; then
            print
            command kill -9 "$_pid" && print -P "%F{151}󰄬 Process $_pid terminated.%f"
        else
            print -P "\n%F{243}Cancelled.%f"
        fi
    fi
}

# copy: Sanitized text transfer to system clipboard with ANSI stripping
copy() {
    # [NOTE] Detect available clipboard backend (Wayland > X11 > Fallback)
    local _clip=""
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        _clip="wl-copy"
    elif [[ -n "$DISPLAY" ]]; then
        _clip="xclip -selection clipboard"
    fi

    local _input=""

    # 1. Input Resolution
    if [[ -n "$1" ]]; then
        # If argument is a file, read it; otherwise treat as raw string
        [[ -f "$1" ]] && _input=$(command cat "$1") || _input="$*"
    elif [[ ! -t 0 ]]; then
        # Capture from STDIN (pipe context)
        _input=$(command cat)
    else
        print -P "%F{209}Usage:%f <cmd> | copy  OR  copy <string/file>"
        return 1
    fi

    # 2. Execution Logic
    if [[ -z "$_clip" ]]; then
        # [NOTE] Fallback for TTY/SSH: pipe to stdout to avoid breaking chains
        print -rn -- "$_input"
        return 0
    fi

    # [NOTE] Perl-based sanitization handles ANSI escapes, charset escapes 
    # and OSC sequences in one pass before sending to the clipboard.
    print -rn -- "$_input" \
        | command perl -pe "s/\e(?:[()][A-Z0-9]|\][0-9]*;.*?(?:\a|\e\\\\)|\[[0-9;?]*[@-~])//g" \
        | command ${(z)_clip}

    # 3. Finalization
    if [[ $? -eq 0 ]]; then
        # Only notify if the command was run interactively
        [[ -t 1 ]] && print -P "%F{151}✔%f Copied to clipboard."
    else
        print -P "%F{203}✘%f Clipboard failure." >&2
        return 1
    fi
}

vencord() {
    print -P "%F{183}󰓄 Running Vencord Installer...%f"
    sh -c "$(curl -sS https://vencord.dev/install.sh)"
}


# ┌─── 5. System Diagnosis ────────────────────────────────────────────────────┐

# zdoc: Detailed environment health monitor and configuration audit
zdoc() {
    local _err=0 _warn=0
    local _indent="│ "
    local _k _v _f _cmd _expanded

    # 1. Header (Mocha Palette)
    local _title=" SYSTEM DIAGNOSIS "
    local _hr=$(printf "─%.0s" {1..$(( ${#_title} + 4 ))})
    print -P "\n%F{111}┌${_hr}┐%f"
    print -P "%F{111}│%f  %B%F{183}${_title}%f%b  %F{111}│%f"
    print -P "%F{111}└${_hr}┘%f"

    # --- SECTION 1: Performance ---
    print -P "%F{111}%B[1] Performance%b%f"
    local _start_time=$(date +%s%N)
    zsh -i -c exit
    local _end_time=$(date +%s%N)
    local _duration=$(( (_end_time - _start_time) / 1000000 ))
    
    local _perf_color=114
    (( _duration > 150 )) && _perf_color=209
    (( _duration > 300 )) && _perf_color=203
    print -P "${_indent}%F{$_perf_color}󱎫%f Shell Startup: %B${_duration}ms%b"

    # --- SECTION 2: Zsh Core Filesystem ---
    print -P "\n%F{111}%B[2] Zsh Core%b%f"
    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        for _f in "$ZSH_CONFIG_DIR"/(10|20|30|40|50|60|70)_*.zsh(N); do
            if [[ -f "$_f" ]]; then
                print -P "${_indent}%F{114}󰄬%f ${_f:t}"
            else
                print -P "${_indent}%F{203}✘%f Missing: ${_f:t}"
                ((_err++))
            fi
        done
    else
        print -P "${_indent}%F{203}✘ ZSH_CONFIG_DIR missing%f"
        ((_err++))
    fi

    # --- SECTION 3: Metro Registry ---
    print -P "\n%F{111}%B[3] Metro Registry%b%f"
    local _broken_routes=0
    local -A _all_routes
    _all_routes=("${(@kv)metro_files}" "${(@kv)metro_modules}")
    
    for _k _v in "${(@kv)_all_routes}"; do
        [[ ! -e "$_v" ]] && ((_broken_routes++))
    done
    
    if (( _broken_routes == 0 )); then
        print -P "${_indent}%F{114}󰄬%f Files registered:  %B${#metro_files}%b"
        print -P "${_indent}%F{114}󰄬%f Modules registered: %B${#metro_modules}%b"
    else
        print -P "${_indent}%F{203}󰞇%f Broken paths detected: %B$_broken_routes%b"
        ((_err++))
    fi

    # --- SECTION 4: Dependencies ---
    print -P "\n%F{111}%B[4] Dependencies%b%f"
    local _alias_fail=0
    local _alias_total=0
    for _k _v in "${(@kv)aliases}"; do
        _cmd=${${_v[(w)1]}//[\'\"]/}
        case "$_cmd" in sudo|command|"|"|">"|done|"{"|"}") continue ;; esac
        ((_alias_total++))
        _expanded=${_cmd/#\~/$HOME}
        ! whence "$_expanded" >/dev/null 2>&1 && ((_alias_fail++))
    done
    
    if (( _alias_fail == 0 )); then
        print -P "${_indent}%F{114}󰄬%f Aliases: %B$_alias_total%b commands verified"
    else
        print -P "${_indent}%F{203}✘%f Missing commands: %B$_alias_fail%b"
        ((_err++))
    fi

    # --- SECTION 5: Logic & Services ---
    print -P "\n%F{111}%B[5] Logic & Services%b%f"

    # [NOTE] Check specifically for failed systemd user units
    local _failed_units=("${(@f)$(systemctl --user --failed --quiet | grep '●' | awk '{print $2}')}")
    if [[ -n "$_failed_units" && "$_failed_units" != "" ]]; then
        for _unit in $_failed_units; do
            print -P "${_indent}%F{203}✘ Failed Unit:%f $_unit"
            ((_err++))
        done
    else
        print -P "${_indent}%F{114}󰄬%f Systemd: All units healthy"
    fi

    # Hyprland Syntax check via hyprctl
    if command -v hyprctl >/dev/null 2>&1; then
        if hyprctl configcheck &>/dev/null; then
            print -P "${_indent}%F{114}󰄬%f Desktop: Configuration valid"
        else
            print -P "${_indent}%F{203}✘ Desktop: Syntax error in hyprland.conf%f"
            ((_err++))
        fi
    fi

    # 6. Final Verdict
    local _result="DIAGNOSIS COMPLETE: $_err Errors, $_warn Warnings"
    local _v_color=$(( _err > 0 ? 203 : (_warn > 0 ? 209 : 114) ))
    local _v_hr=$(printf "─%.0s" {1..$(( ${#_result} + 4 ))})

    print -P "\n%F{$_v_color}┌${_v_hr}┐%f"
    print -P "%F{$_v_color}│%f  %B$_result%b  %F{$_v_color}│%f"
    print -P "%F{$_v_color}└${_v_hr}┘%f"

    return $(( _err > 0 ? 1 : 0 ))
}
