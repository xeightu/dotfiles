# ┌─── 1. Environment & Path ──────────────────────────────────────────────────┐
# │  [INFO] Core pathing and global environment variables.
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── 1.1. Pathing ────────────────────────────────────────────────────────────┐

# [OPT] Automatically remove duplicate entries in PATH
typeset -U path

# [CFG] Priority binaries
path=(
    "$HOME/.local/bin"
    $path
)
export PATH


# ┌── 1.2. Constants ──────────────────────────────────────────────────────────┐

export ZSH="$HOME/.oh-my-zsh"                   # [CFG] Framework root
export DOTS="$HOME/.config"                     # [CFG] Config root
export HYPR="$DOTS/hypr"                        # [CFG] WM config root


# ┌── 1.3. Tooling Configuration ──────────────────────────────────────────────┐

# [OPT] Colored Man Pages via 'bat'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# [OPT] Speed up OMZ loading by bypassing security checks
export ZSH_DISABLE_COMPFIX="true" 

# [CFG] System default text editor
export EDITOR="nvim"
