# ┌─── 1. PATH Management ─────────────────────────────────────────────────────┐

# [NOTE] Enforce unique elements to prevent redundant directory lookups
typeset -U path

# Prepend user binaries to prioritize them over system packages
path=(
    "$HOME/.local/bin"
    $path
)
export PATH


# ┌─── 2. Directory Shortcuts ─────────────────────────────────────────────────┐

# Global paths for dependent modules and scripts
export ZSH="$HOME/.oh-my-zsh"
export DOTS="$HOME/.config"
export HYPR="$DOTS/hypr"


# ┌─── 3. Application Defaults ────────────────────────────────────────────────┐

# Use 'bat' for syntax-highlighted man pages if available
if command -v bat >/dev/null 2>&1; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    # [FIX] Strip formatting characters to ensure compatibility with 'bat'
    export MANROFFOPT="-c"
fi

export EDITOR="nvim"


# ┌─── 4. Shell Behavior ──────────────────────────────────────────────────────┐

# [WARN] Disables completion folder security checks (insecure but faster)
export ZSH_DISABLE_COMPFIX="true"
