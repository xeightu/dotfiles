# ┌─── 1. Internal Logic & Caching ────────────────────────────────────────────┐

# [NOTE] Generates a formatted menu for FZF. Uses memory caching for speed.
_metro_build_menu() {
    local _reg_file="$ZSH_CONFIG_DIR/lib/registry.zsh"
    
    # Invalidate cache if the source registry was modified
    if [[ -f "$_metro_menu_cache_file" && "$_reg_file" -nt "$_metro_menu_cache_file" ]]; then
        unset _metro_menu_cache
    fi

    if [[ -n "$_metro_menu_cache" ]]; then
        print -r -- "$_metro_menu_cache"
        return
    fi

    local _f_list _m_list

    # Format files: [key] icon path
    _f_list=$(for _k in "${(@k)metro_files}"; do
        printf "%-15s %s  %s\n" "$_k" "$METRO_ICON_FILE" "${metro_files[$_k]:t}"
    done | sort -k 3 -V)

    # Format modules: [key] icon path/
    _m_list=$(for _k in "${(@k)metro_modules}"; do
        printf "%-15s %s  %s/\n" "$_k" "$METRO_ICON_DIR" "${metro_modules[$_k]:t}"
    done | sort -k 3 -V)
    
    _metro_menu_cache=$(printf "p10k           %s  Configure Powerlevel10k\n%s\n%s" \
        "$METRO_ICON_CONF" "$_f_list" "$_m_list")
    
    print -r -- "$_metro_menu_cache"
}

# Resolver for FZF subshells to find the actual path by its alias
_metro_get_path() {
    local _key="$1"
    if [[ -v metro_files[$_key] ]]; then echo "${metro_files[$_key]}"
    elif [[ -v metro_modules[$_key] ]]; then echo "${metro_modules[$_key]}"
    fi
}


# ┌─── 2. Interactive Pickers ─────────────────────────────────────────────────┐

# [NOTE] Generic interactive selector with dynamic previews
_metro_pick() {
    local _header="$1"
    local _filter="${2:-cat}"
    local _bat="${commands[bat]:-cat}"
    local _eza="${commands[eza]:-ls}"

    # [NOTE] Explicit context injection for the FZF subshell
    # Since FZF preview runs in a separate shell, we must pass globals and functions
    local _context="
        $(typeset -p metro_files metro_modules METRO_ICON_FILE METRO_ICON_DIR);
        $(typeset -f _metro_get_path);
        _bat=\"$_bat\"; _eza=\"$_eza\";
    "
    
    local _preview_cmd="
        alias=\$(echo {} | cut -d' ' -f1);
        path=\$(_metro_get_path \"\$alias\");
        if [[ -d \"\$path\" ]]; then
            \$_eza --tree --level=2 --icons --group-directories-first \"\$path\";
        elif [[ -f \"\$path\" ]]; then
            \$_bat --color=always --style=numbers --line-range :200 \"\$path\";
        fi
    "

    _metro_build_menu | eval "$_filter" | fzf \
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --no-separator \
        --preview-window="right:70%:border-rounded" \
        --header="$_header" \
        --preview="$_context $_preview_cmd"
}

# Sub-picker for selecting files within a module (directory)
_edit_module_picker() {
    local _module_path="$1"
    local _fd="${commands[fd]:-find}"
    local _bat="${commands[bat]:-cat}"
    local _cmd

    if [[ "$_fd" == *"fd"* ]]; then
        _cmd="$_fd --type f --max-depth 2 --hidden --exclude .git --absolute-path . \"$_module_path\""
    else
        _cmd="find \"$_module_path\" -maxdepth 2 -type f -not -path '*/.*'"
    fi

    eval "$_cmd" | fzf \
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --header="Sub-Module: ${_module_path:t}" \
        --preview="$_bat --color=always --style=numbers --line-range :200 {}"
}

# Sub-picker for deep directory navigation
_goto_module_picker() {
    local _base_path="$1"
    local _fd="${commands[fd]:-find}"
    local _cmd

    if [[ "$_fd" == *"fd"* ]]; then
        _cmd="$_fd --type d --max-depth 3 --hidden --exclude .git . \"$_base_path\""
    else
        _cmd="find \"$_base_path\" -maxdepth 3 -type d -not -path '*/.*'"
    fi

    eval "$_cmd" | fzf \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --header="Drill-down: ${_base_path:t}" \
        --preview="eza --tree --level=2 --icons {}"
}


# ┌─── 3. Public Commands ─────────────────────────────────────────────────────┐

# edit: Intelligent editor wrapper with automatic privilege escalation
edit() {
    local _target="$1"
    local _path=""

    # 1. Selection logic (Registry vs Manual)
    if [[ -z "$_target" ]]; then
        local _selection=$(_metro_pick "Edit: Select a config or module")
        [[ -z "$_selection" ]] && return 0
        _target="${_selection%% *}"
    fi

    # 2. Path Resolution
    if [[ "$_target" == "p10k" ]]; then
        p10k configure
        return 0
    elif [[ -v metro_files[$_target] ]]; then
        _path="${metro_files[$_target]}"
    elif [[ -v metro_modules[$_target] ]]; then
        _path=$(_edit_module_picker "${metro_modules[$_target]}")
        [[ -z "$_path" ]] && return 0
    else
        # Fallback to manual file check
        _path="$_target"
    fi

    [[ ! -e "$_path" ]] && { print -P "%F{203}✘ Path not found: $_path%f"; return 1; }

    # 3. Action: Smart Execution
    if [[ -f "$_path" ]]; then
        # [NOTE] Check write permissions. If denied, escalate to sudoedit.
        if [[ ! -w "$_path" ]]; then
            print -P "%F{216}󰌆 System file detected. Escalating to sudoedit...%f"
            sudo -e "$_path"
        else
            # Jump to directory for relative path stability in Nvim
            cd "${_path:h}" && ${EDITOR:-nvim} "${_path:t}"
        fi
    elif [[ -d "$_path" ]]; then
        cd "$_path" && ${EDITOR:-nvim} .
    fi
}

# view: Unified content renderer for Metro configs and filesystem paths
view() {
    local _opt_copy=0 _opt_drill=0 _opt_search=0
    local _target="" _selection="" _path=""
    local _is_dir=0

    # [FIX] Flexible flag parsing
    while [[ "$1" == -* ]]; do
        case "$1" in
            -c|--copy)   _opt_copy=1 ;;
            -d|--drill)  _opt_drill=1 ;;
            -s|--search) _opt_search=1 ;;
            -[cds]*) 
                [[ "$1" == *c* ]] && _opt_copy=1
                [[ "$1" == *d* ]] && _opt_drill=1
                [[ "$1" == *s* ]] && _opt_search=1
                ;;
            *) break ;;
        esac
        shift
    done
    _target="$1"

    # 1. Path Resolution: Registry First -> Filesystem Second
    if [[ -z "$_target" ]]; then
        _selection=$(_metro_pick "Metro View: Choose Source")
        [[ -z "$_selection" ]] && return 0
        _target="${_selection%% *}"
    fi

    if [[ -v metro_files[$_target] ]]; then
        _path="${metro_files[$_target]}"
    elif [[ -v metro_modules[$_target] ]]; then
        _path="${metro_modules[$_target]}"
        _is_dir=1
    elif [[ -d "$_target" ]]; then
        _path="$_target"
        _is_dir=1
    elif [[ -f "$_target" ]]; then
        _path="$_target"
    else
        [[ -n "$_target" ]] && print -P "%F{203}✘ Path or Config not found: $_target%f"
        return 1
    fi

    # 2. Execution Logic
    if (( _is_dir )); then
        if (( _opt_drill )); then
            local _sub_file=$(_edit_module_picker "$_path")
            [[ -n "$_sub_file" ]] && { (( _opt_copy )) && copy < "$_sub_file" || bat "$_sub_file" }
        else
            eza --tree --level=3 --icons --group-directories-first "$_path"
        fi
    else
        if (( _opt_search )); then
            # [NOTE] Minimalist search within resolved file
            local _sel=$(command rg --line-number --color=always --smart-case "" "$_path" | fzf --ansi \
                --height=45% --layout=reverse --border=rounded \
                --prompt="󰍉 Search ${_target:t} > " --no-preview --preview-window=hidden)
            [[ -n "$_sel" ]] && ${EDITOR:-nvim} +"${_sel%%:*}" "$_path"
        elif (( _opt_copy )); then
            copy < "$_path"
        else
            bat --paging=never --color=always --style=header,grid,numbers "$_path"
        fi
    fi
}

# goto: Jump engine for configuration directories
goto() {
    local _opt_drill=0
    local _target=""
    local _selection=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--drill) _opt_drill=1; shift ;;
            *)          _target="$1"; shift ;;
        esac
    done

    if [[ -z "$_target" ]]; then
        _selection=$(_metro_pick "GoTo: Select destination" "grep '$METRO_ICON_DIR'")
        [[ -z "$_selection" ]] && return 0
        _target="${_selection%% *}"
    fi

    if [[ -v metro_files[$_target] ]]; then
        z "${metro_files[$_target]:h}"
    elif [[ -v metro_modules[$_target] ]]; then
        local _dest="${metro_modules[$_target]}"
        if [[ $_opt_drill -eq 1 ]]; then
            local _sub_dir=$(_goto_module_picker "$_dest")
            [[ -n "$_sub_dir" ]] && _dest="$_sub_dir"
        fi
        z "$_dest"
    else
        [[ -n "$_target" ]] && print -P "%F{203}Destination not found: $_target%f"
    fi
}

# nconf: Rapidly create new files within Metro modules
nconf() {
    local _module="$1"
    local _filename="$2"

    if [[ -z "$_module" || -z "$_filename" ]]; then
        print -P "%F{209}Usage: nconf <module_key> <filename>%f"
        return 1
    fi

    if [[ -v metro_modules[$_module] ]]; then
        local _full_path="${metro_modules[$_module]}/${_filename}"
        mkdir -p "${_full_path:h}"
        ${EDITOR:-nvim} "$_full_path"
    else
        print -P "%F{203}Module not found: $_module%f"
        return 1
    fi
}


# ┌─── 4. Registry Management ─────────────────────────────────────────────────┐

# mreg: Add and sort new key-path pairs in the persistent data store
mreg() {
    local _key="$1"
    local _path_raw="$2"
    local _data_store="${ZSH_CONFIG_DIR}/lib/registry.data.zsh"

    [[ -z "$_key" || -z "$_path_raw" ]] && { print -P "%F{209}Usage: mreg <key> <path>%f"; return 1; }

    local _path_abs="${_path_raw:A}"
    [[ -e "$_path_abs" ]] || { print -P "%F{203}Error: Path not found: $_path_abs%f"; return 1; }

    if [[ -v metro_files[$_key] || -v metro_modules[$_key] ]]; then
        print -P "%F{203}Error: Key '%B$_key%b' already exists.%f"
        return 1
    fi

    local _target="metro_files"
    [[ -d "$_path_abs" ]] && _target="metro_modules"
    local _new_entry="${_target}+=([$_key]=\"$_path_abs\")"

    # [NOTE] Atomic alphabetical sort ensures the flat-file remains readable and git-friendly
    local _header=$(head -n 5 "$_data_store")
    local _body=$(grep -v "^#" "$_data_store")
    
    {
        print -r -- "$_header"
        print -r -- "$_body"
        print -r -- "$_new_entry"
    } | sort -u | grep -v "^$" >! "$_data_store"

    source "$_data_store"
    _metro_menu_cache=""
    print -P "%F{114}✔%f Registered and sorted: %B$_key%b"
}

# unreg: Interactively remove keys from the registry
unreg() {
    local _key="$1"
    local _data_store="${ZSH_CONFIG_DIR}/lib/registry.data.zsh"

    if [[ -z "$_key" ]]; then
        local _selection
        _selection=$(grep -v "^#" "$_data_store" | \
            sed -E 's/.*\[(.*)\]="(.*)"\)/\1 \2/' | \
            column -t | \
            fzf --height=40% \
                --layout=reverse \
                --border=rounded \
                --header="Unregister: Select route to DELETE" \
                --preview="echo 'Target: {2}'")

        [[ -z "$_selection" ]] && return 0
        _key="${_selection%% *}"
    fi

    # [WARN] Destructive operation below. Zero-fork deletion using Zsh array filtering.
    local -a _lines=("${(@f)$(<"$_data_store")}")
    local -a _filtered=("${(@)_lines:#*\[$_key\]=*}")

    if (( ${#_lines} == ${#_filtered} )); then
        print -P "%F{203}Error: Key '$_key' not found.%f"
        return 1
    fi

    print -l -- "${_filtered[@]}" >! "$_data_store"
    unset "metro_files[$_key]" "metro_modules[$_key]"
    _metro_menu_cache=""
    
    print -P "%F{114}✔%f Unregistered: %B$_key%b"
}


# ┌─── 5. Zsh Completion ──────────────────────────────────────────────────────┐

_metro_completion() {
    # [FIX] Suppress massive list if prefix is empty
    if [[ -z "$PREFIX" ]]; then
        compstate[list]=''
        return 0
    fi

    local -a _m_f_disp _m_m_disp
    local _cmd="${words[1]}"
    local _ret=1

    # 1. [NOTE] Prepare Registry matches
    for _k in "${(@k)metro_files}"; do
        _m_f_disp+=("${_k}:[File] - ${metro_files[$_k]:t}")
    done
    
    [[ "$_cmd" != "goto" ]] && _m_f_disp+=("p10k:[Action] - Configure P10k")

    for _k in "${(@k)metro_modules}"; do
        _m_m_disp+=("${_k}:[Module] - ${metro_modules[$_k]:t}/")
    done

    # 2. [NOTE] Styling: Scoped to metro tags to avoid breaking standard files
    zstyle ":completion:${curcontext}:*" group-name ''
    zstyle ":completion:${curcontext}:*" format $'\e[34m-- %d --\e[0m'
    
    zstyle ":completion:${curcontext}:metro-*" list-separator ' - '
    zstyle ":completion:${curcontext}:metro-*" list-colors \
        "=(#b)([^ ]#) #(- )#(\[File\]) #(- )#*=0=34=243=183=243" \
        "=(#b)([^ ]#) #(- )#(\[Module\]) #(- )#*=0=34=243=111=243" \
        "=(#b)([^ ]#) #(- )#(\[Action\]) #(- )#*=0=34=243=216=243"

    # 3. [NOTE] Manual Tag Loop: The most stable way to handle multiple sources
    _tags metro-files metro-mods local-files
    
    while _tags; do
        if _requested metro-files; then
            _describe -t metro-files "registry files" _m_f_disp && _ret=0
        fi
        
        if _requested metro-mods; then
            _describe -t metro-mods "registry modules" _m_m_disp && _ret=0
        fi
        
        if _requested local-files; then
            # [FIX] Use explicit tag to prevent duplication and skip hidden junk
            _files -t local-files -g "*~.*" && _ret=0
        fi
        
        # If any tag found a match, stop to prevent duplication across groups
        (( _ret == 0 )) && return 0
    done
}
