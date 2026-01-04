# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                3. Plugins                                  │
# └────────────────────────────────────────────────────────────────────────────┘

# --- Plugin Definition ---
# [INFO] Plugins are initialized at the end of this file.
# [CRITICAL] 'zsh-syntax-highlighting' MUST be the absolute last plugin.

plugins=(
    # --- Completion ---
    zsh-completions             # Additional completion definitions for tools
    
    # --- User Interface (UX) ---
    zsh-autosuggestions         # Fish-like grey autosuggestions from history
    zsh-syntax-highlighting     # Command coloring (Green=Valid, Red=Error)
)

# ┌─── Framework Initialization ───────────────────────────────────────────────┐
# --- Launch Core ---
source "$ZSH/oh-my-zsh.sh"

# --- Load Theme (Instant Prompt) ---
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
