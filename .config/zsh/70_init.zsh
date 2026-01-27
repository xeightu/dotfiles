# ┌─── 7. Initialization & Startup ────────────────────────────────────────────┐
# │  [INFO] External tool hooks, completion wiring, and global keybindings.
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── 7.1. External Integrations ──────────────────────────────────────────────┐

# [FIX] Distro-specific paths (Arch Linux standard)
# These files provide FZF TUI bindings and command-not-found database
[[ -f "/usr/share/fzf/key-bindings.zsh" ]] && source "/usr/share/fzf/key-bindings.zsh"
[[ -f "/usr/share/fzf/completion.zsh" ]]   && source "/usr/share/fzf/completion.zsh"
[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && source "/usr/share/doc/pkgfile/command-not-found.zsh"


# [OPT] Binary-check before heavy 'eval' calls to prevent startup lag
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v atuin  >/dev/null && eval "$(atuin init zsh)"
command -v mise   >/dev/null && eval "$(mise activate zsh)"


# ┌── 7.2. Metro System Wiring ────────────────────────────────────────────────┐

# [FLOW] Register custom completions for Metro navigation engine
# Requires _metro_completion to be defined in Section 6
if type compdef &>/dev/null; then
    compdef _metro_completion edit
    compdef _metro_completion view
    compdef _metro_completion goto
fi


# ┌── 7.3. Custom Keybindings ─────────────────────────────────────────────────┐

# [FLOW] Map Enter/Ctrl+J to the context-aware 'magic-enter'
bindkey "^J" magic-enter
bindkey "^M" magic-enter

# [FIX] Force autosuggestions to clear when magic-enter executes
# This prevents visual artifacts from old suggestions
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(magic-enter accept-line)
