# ┌─── Module: Metro System (Logic) ───────────────────────────────────────────┐
# │  [INFO] Core engine for dotfiles navigation (edit, view, goto).            │
# │  [DEPENDS] registry.zsh (globals: metro_files, METRO_ICON_*)               │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── Internal Helpers ────────────────────────────────────────────────────────┐

# [FLOW] Menu Generator: Generates the formatted list for FZF. Uses cache.
_metro_build_menu() {
    # [OPT] Use cache if available
    [[ -n "$_metro_menu_cache" ]] && { print -r -- "$_metro_menu_cache"; return; }

    local f_list m_list

    # [FLOW] Format and sort file list
    f_list=$(for k in "${(@k)metro_files}"; do
        printf "%-15s %s  %s\n" "$k" "$METRO_ICON_FILE" "${metro_files[$k]:t}"
    done | sort -k 3 -V)

    # [FLOW] Format and sort module (directory) list
    m_list=$(for k in "${(@k)metro_modules}"; do
        printf "%-15s %s  %s/\n" "$k" "$METRO_ICON_DIR" "${metro_modules[$k]:t}"
    done | sort -k 3 -V)
    
    # [CACHE] Store result and print
    _metro_menu_cache=$(printf "p10k           %s  Configure Powerlevel10k\n%s\n%s" \
        "$METRO_ICON_CONF" "$f_list" "$m_list")
    
    print -r -- "$_metro_menu_cache"
}

# [FLOW] Preview Resolver: Used inside FZF subshell via explicit injection.
_metro_get_path() {
    local key="$1"
    if [[ -v metro_files[$key] ]]; then echo "${metro_files[$key]}"
    elif [[ -v metro_modules[$key] ]]; then echo "${metro_modules[$key]}"
    fi
}

# [FLOW] Module Selector: Opens a sub-menu when editing a folder/module.
_edit_module() {
    local module_path="$1"
    [[ -z "$module_path" ]] && return 1 # [CRIT] Guard against empty paths

    local _fd="${commands[fd]:-find}"; local _bat="${commands[bat]:-cat}";
    local cmd

    if [[ "$_fd" == *"fd"* ]]; then
        # [OPT] Use 'fd' for speed: max-depth 2, absolute path
        cmd="$_fd --type f --max-depth 2 --hidden --exclude .git --absolute-path . \"$module_path\""
    else
        # [FLOW] POSIX fallback
        cmd="find \"$module_path\" -maxdepth 2 -type f -not -name '.*'"
    fi

    local selected_file=$(eval "$cmd" | fzf --height=50% --layout=reverse --border=rounded --header="Editing Module: ${module_path:t} — Select a file" --preview="$_bat --color=always --style=numbers --line-range :200 {}")
    
    [[ -n "$selected_file" ]] && $EDITOR "$selected_file"
}

# [FLOW] Unified Interactive Selector (FZF Launcher)
_metro_pick() {
    local header="$1"; local filter="${2:-cat}"; local _bat="${commands[bat]:-cat}"; local _eza="${commands[eza]:-ls}";
    
    # [CRIT] Pack arrays and the helper function into a string for FZF subshell execution
    local context="$(typeset -p metro_files metro_modules); $(typeset -f _metro_get_path)"
    
    # [FLOW] Preview Logic (Injected into FZF)
    local preview_cmd="alias=\$(echo {} | cut -d' ' -f1); path=\$(_metro_get_path \"\$alias\"); if [[ -d \"\$path\" ]]; then $_eza --tree --level=2 --icons --group-directories-first \"\$path\"; elif [[ -f \"\$path\" ]]; then $_bat --color=always --style=numbers --line-range :200 \"\$path\"; fi"

    _metro_build_menu | eval "$filter" | fzf --height=50% --layout=reverse --border=rounded --no-separator --preview-window="right:70%:border-rounded" --header="$header" --preview="$context; $preview_cmd"
}


# ┌── Public Commands ─────────────────────────────────────────────────────────┐

# [FLOW] The Editor: Open configuration files or modules in editor.
edit() {
    if [[ -n "$1" ]]; then
        # --- CLI Argument Mode ---
        [[ "$1" == "p10k" ]] && { p10k configure; return 0; }
        if [[ -v metro_files[$1] ]]; then local f="${metro_files[$1]}"; z "${f:h}" && $EDITOR "${f:t}"; return 0; fi # [FLOW] File: cd to dir, open file
        if [[ -v metro_modules[$1] ]]; then _edit_module "${metro_modules[$1]}"; return 0; fi # [FLOW] Module: Open sub-picker
        echo "Config not found: $1"; return 1
    fi
    # --- Interactive Mode ---
    local selection=$(_metro_pick "Select a config file or module to edit"); [[ -n "$selection" ]] && edit "${selection%% *}"
}

# [FLOW] The Viewer: View configuration files or directory trees.
view() {
    if [[ -n "$1" ]]; then
        # --- CLI Argument Mode ---
        local target="$1"; local opts=(--style=header,grid,numbers)
        if [[ "$1" == "-c" ]]; then opts=(--style=plain); shift; target="$1"; fi # [OPT] Raw content flag
        if [[ -v metro_files[$target] ]]; then bat --paging=never "${opts[@]}" --color=always "${metro_files[$target]}"; return 0; fi # [FLOW] Render File
        if [[ -v metro_modules[$target] ]]; then eza --tree --level=3 --icons "${metro_modules[$target]}"; return 0; fi # [FLOW] Render Directory
        echo "Config not found: $target"; return 1
    fi
    # --- Interactive Mode ---
    local selection=$(_metro_pick "View config content"); [[ -n "$selection" ]] && view "${selection%% *}"
}

# [FLOW] The Navigator: Navigate to the directory containing the configuration.
goto() {
    if [[ -n "$1" ]]; then
        # --- CLI Argument Mode ---
        local target="$1"
        if [[ -v metro_files[$target] ]]; then z "${metro_files[$target]:h}"; return 0; fi # [FLOW] Jump to File Parent Dir
        if [[ -v metro_modules[$target] ]]; then z "${metro_modules[$target]}"; return 0; fi # [FLOW] Jump to Module Root
        echo "Config not found: $target"; return 1
    fi
    # --- Interactive Mode (Filter for Directories) ---
    local selection=$(_metro_pick "Select a destination to GO TO" "grep '$METRO_ICON_DIR'"); [[ -n "$selection" ]] && goto "${selection%% *}"
}


# ┌── Completion ──────────────────────────────────────────────────────────────┐

# [FLOW] Autocompletion for edit/view/goto
_metro_completion() {
    local -a matches
    local service="${service:-$WIDGET}" # Get service name from context
    
    # [FLOW] Add file links if service is not 'goto'
    if [[ "$service" != "goto" ]]; then
        for k in "${(@k)metro_files}"; do 
            matches+=("$k:[File] ${metro_files[$k]:t}")
        done
        matches+=("p10k:[Action] Configure P10k")
    fi

    # [FLOW] Always add module links
    for k in "${(@k)metro_modules}"; do 
        matches+=("$k:[Module] ${metro_modules[$k]:t}/")
    done
    _describe 'metro config' matches
}
