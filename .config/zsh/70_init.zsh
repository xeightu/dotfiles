# ┌─── 1. Arch Linux Integrations ─────────────────────────────────────────────┐

# [FIX] Load distro-specific completions and key-bindings if available
[[ -f "/usr/share/fzf/key-bindings.zsh" ]] && source "/usr/share/fzf/key-bindings.zsh"
[[ -f "/usr/share/fzf/completion.zsh" ]]   && source "/usr/share/fzf/completion.zsh"

# Command-not-found handler (pkgfile)
[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && \
    source "/usr/share/doc/pkgfile/command-not-found.zsh"


# ┌─── 2. External Tool Hooks ─────────────────────────────────────────────────┐

# [NOTE] Cache 'eval' output to minimize shell startup latency
() {
    local _hook_cache="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/hooks"
    [[ -d "$_hook_cache" ]] || mkdir -p "$_hook_cache"

    local _tool _bin _cache _cmd
    
    for _tool in zoxide atuin mise; do
        (( $+commands[$_tool] )) || continue
        
        _bin="${commands[$_tool]}"
        _cache="$_hook_cache/${_tool}_hook.zsh"

        case "$_tool" in
            mise) _cmd="activate zsh" ;;
            *)    _cmd="init zsh"     ;;
        esac

        # [NOTE] Regenerate cache only if binary is newer (-nt) or cache is empty
        if [[ "$_bin" -nt "$_cache" || ! -s "$_cache" ]]; then
            "$_tool" $=_cmd >! "$_cache" 2>/dev/null
        fi

        source "$_cache"
    done
}


# ┌─── 3. Shell Completion Wiring ─────────────────────────────────────────────┐

# Register internal 'metro' commands with the completion system
if (( $+functions[compdef] )); then
    compdef _metro_completion edit
    compdef _metro_completion view
    compdef _metro_completion goto
fi


# ┌─── 4. Event Loop & Keybindings ────────────────────────────────────────────┐

# Bind magic-enter (smart context action) to Return keys
bindkey "^J" magic_enter
bindkey "^M" magic_enter

# [FIX] Force autosuggestions to clear when executing custom widgets
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(magic_enter accept-line)
