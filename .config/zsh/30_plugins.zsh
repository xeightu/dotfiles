# ┌─── 3. Plugins & Framework ─────────────────────────────────────────────────┐
# │  [INFO] External extensions and Oh My Zsh core initialization.
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── 3.1. Plugin Definition ──────────────────────────────────────────────────┐

# [CFG] OMZ Plugin List
plugins=(
    zsh-completions                             # [OPT] Extended completions
    zsh-autosuggestions                         # [OPT] Fish-like hints
    zsh-syntax-highlighting                     # [CRIT] MUST be absolute last
)


# ┌── 3.2. Framework Initialization ───────────────────────────────────────────┐

# [FLOW] Launch Oh My Zsh core logic
source "$ZSH/oh-my-zsh.sh"

# [FLOW] Load Powerlevel10k Instant Prompt / Config
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
