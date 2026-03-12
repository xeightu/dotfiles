# ┌─── 1. Plugin Definitions ──────────────────────────────────────────────────┐

plugins=(
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)


# ┌─── 2. Completion Subsystem ────────────────────────────────────────────────┐

# [NOTE] Skip security checks to significantly reduce shell startup time
zstyle ':omz:lib:completion' compinit-options '-C'

# [NOTE] Enable caching to speed up completions for heavy tools like git or docker
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"


# ┌─── 3. Framework Execution ─────────────────────────────────────────────────┐

# [WARN] This script initializes OMZ and may override existing shell settings
source "$ZSH/oh-my-zsh.sh"
