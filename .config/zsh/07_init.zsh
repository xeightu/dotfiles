# ┌────────────────────────────────────────────────────────────────────────────┐
# │                          7. Initialization & Startup                       │
# └────────────────────────────────────────────────────────────────────────────┘
# [INFO] Robust initialization to prevent errors if a tool is not installed.

# --- Load Frameworks & Themes ---
source "$ZSH/oh-my-zsh.sh"
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# --- Load FZF ---
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/doc/pkgfile/command-not-found.zsh

# --- Load Shell Integrations ---
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v atuin >/dev/null && eval "$(atuin init zsh)"
command -v mise >/dev/null && eval "$(mise activate zsh)"

# --- Metro System Wiring ---
if type compdef &>/dev/null; then
    compdef _metro_completion edit
    compdef _metro_completion view
fi

# --- Custom Keybindings ---
bindkey "^M" magic-enter
bindkey "^J" magic-enter
