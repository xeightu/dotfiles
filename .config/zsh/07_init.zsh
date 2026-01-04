# ┌────────────────────────────────────────────────────────────────────────────┐
# │                          7. Initialization & Startup                       │
# └────────────────────────────────────────────────────────────────────────────┘
# [INFO] Robust initialization to prevent errors if a tool is not installed.

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
    compdef _metro_completion goto
fi

# --- Custom Keybindings ---
bindkey "^J" magic-enter
bindkey "^M" magic-enter
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(magic-enter accept-line)
