# ┌────────────────────────────────────────────────────────────────────────────┐
# │                          4. FZF Configuration                              │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── Backend Setup ──────────────────────────────────────────────────────────┐

# --- Binary Resolution ---
# [INFO] Resolve paths at startup using Zsh 'commands' hash.
local _fd="${commands[fd]:-find}"
local _bat="${commands[bat]:-cat}"
local _eza="${commands[eza]:-ls}"

# --- Search Engine ---
if [[ "$_fd" == *"fd"* ]]; then
    # [FD] Modern, fast, respects .gitignore
    export FZF_DEFAULT_COMMAND="$_fd --type f --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_ALT_C_COMMAND="$_fd --type d --hidden --follow --exclude .git --strip-cwd-prefix"
else
    # [FIND] POSIX fallback
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*'"
    export FZF_ALT_C_COMMAND="find . -type d -not -path '*/.git/*'"
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


# ┌─── Visuals & Behavior ─────────────────────────────────────────────────────┐

# --- Preview Logic ---
# [NOTE] Injects resolved absolute paths to prevent subshell errors.
local _preview_cmd="
    if [[ -d {} ]]; then 
        $_eza --tree --level=2 --icons --group-directories-first --git-ignore {}; 
    else 
        $_bat --color=always --style=numbers --line-range :500 {}; 
    fi"

# --- Layout & Bindings ---
export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border=rounded
    --info=inline
    --pointer='▌'
    --marker='✓'
    --preview-window='right:55%:border-rounded:wrap'
    --preview='${_preview_cmd}'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-d:preview-half-page-down'
"

# --- Theme (Catppuccin Mocha) ---
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"


# ┌─── Extensions ─────────────────────────────────────────────────────────────┐

# --- History Widget (Ctrl+R) ---
export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window down:3:hidden:wrap
    --bind '?:toggle-preview'
    --header 'Press ? to toggle full command preview'
"
