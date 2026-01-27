# ┌─── 4. FZF Configuration ───────────────────────────────────────────────────┐
# │  [INFO] Fuzzy finder backend resolution, search engine, and UI layout.
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── 4.1. Backend Discovery ──────────────────────────────────────────────────┐

# [OPT] Pre-resolve binary paths at startup to avoid subshell lookup overhead
local _fd="${commands[fd]:-find}"
local _bat="${commands[bat]:-cat}"
local _eza="${commands[eza]:-ls}"


# ┌── 4.2. Search Engine Logic ────────────────────────────────────────────────┐

if [[ "$_fd" == *"fd"* ]]; then
    # [OPT] Use 'fd' for performance and native .gitignore awareness
    export FZF_DEFAULT_COMMAND="$_fd --type f --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_ALT_C_COMMAND="$_fd --type d --hidden --follow --exclude .git --strip-cwd-prefix"
else
    # [FLOW] Fallback to POSIX 'find' if modern tools are missing
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*'"
    export FZF_ALT_C_COMMAND="find . -type d -not -path '*/.git/*'"
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"               # [CFG] Map file search


# ┌── 4.3. Layout & Visuals ───────────────────────────────────────────────────┐

# [OPT] Smart preview: tree for directories, syntax highlighting for files
local _preview_cmd="
    if [[ -d {} ]]; then 
        $_eza --tree --level=2 --icons --group-directories-first --git-ignore {}; 
    else 
        $_bat --color=always --style=numbers --line-range :500 {}; 
    fi"

# [CFG] Main UI configuration and Catppuccin Mocha theme
export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border=rounded --info=inline
    --pointer='▌' --marker='✓'
    --preview-window='right:55%:border-rounded:wrap'
    --preview='${_preview_cmd}'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-d:preview-half-page-down'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#b4befe,hl:#b4befe
    --color=fg:#cdd6f4,header:#b4befe,info:#b4befe,pointer:#b4befe
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#b4befe,hl+:#b4befe
    --color=border:#b4befe
"


# ┌── 4.4. Extensions ─────────────────────────────────────────────────────────┐

# [CFG] Ctrl+R: Toggleable command preview to inspect long lines
export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window down:3:hidden:wrap
    --bind '?:toggle-preview'
    --header 'Press ? to toggle full command preview'
"
