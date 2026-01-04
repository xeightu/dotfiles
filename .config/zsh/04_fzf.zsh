# ┌────────────────────────────────────────────────────────────────────────────┐
# │                          4. FZF Configuration                              │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── Search Engine (Backend) ────────────────────────────────────────────────┐

# --- Default Command ---
# [OPTIMIZATION] Use 'fd' (Rust) instead of 'find'. It respects .gitignore.
# [NOTE] --strip-cwd-prefix makes results look cleaner (file.txt vs ./file.txt)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'

# --- Keybinding Commands ---
# [CONFIG] Apply the same fast engine to Ctrl+T (Files) and Alt+C (Dirs).
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'


# ┌─── Visuals & Behavior ─────────────────────────────────────────────────────┐

# --- Preview Logic ---
# [INFO] Smart previewer: uses 'eza' for directories and 'bat' for files.
# [FIX] Prevents 'bat' errors when selecting directories in default mode.
_fzf_preview_cmd="
    if [[ -d {} ]]; then 
        eza --tree --level=2 --icons --git-ignore {}
    else 
        bat --color=always --style=numbers --line-range :500 {}
    fi"

# --- General Options ---
# [CONFIG] Global layout settings.
# [NOTE] 'pointer' and 'marker' enhance visibility.
export FZF_DEFAULT_OPTS="
    --height 60% 
    --layout=reverse 
    --border=rounded 
    --info=inline
    --prompt='🔭 '
    --pointer='▌'
    --marker='✓'
    --preview-window='right:55%:border-rounded:wrap'
    --preview='$_fzf_preview_cmd'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-d:preview-half-page-down'
"

# --- Theme (Catppuccin Mocha) ---
# [INFO] Matches system-wide aesthetic.
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"


# ┌─── Extensions ─────────────────────────────────────────────────────────────┐

# --- History Widget (Ctrl+R) ---
# [CONFIG] Make history search look distinct.
export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window down:3:hidden:wrap
    --bind '?:toggle-preview'
    --header 'Press ? to toggle full command preview'
"
