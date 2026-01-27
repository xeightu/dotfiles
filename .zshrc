# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ┌─── ZSH Main Entry Point ───────────────────────────────────────────────────┐
# │  [INFO] The Hub: Orchestrates the loading of the configuration system.
# └────────────────────────────────────────────────────────────────────────────┘

# [CFG] Configuration Root
export ZSH_CONFIG_DIR="$HOME/.config/zsh"


# ┌── 1. Core Loader (10-70) ──────────────────────────────────────────────────┐

# [FLOW] Source numbered config files in sequence (10_env -> 70_init)
for config_file in "$ZSH_CONFIG_DIR/"(10|20|30|40|50|60|70)_*.zsh(N); do
  source "$config_file"
done


# ┌── 2. Apps Loader ──────────────────────────────────────────────────────────┐

# [FLOW] Load standalone applications from 'apps/' directory (e.g., vid2txt)
if [[ -d "$ZSH_CONFIG_DIR/apps" ]]; then
    for app in "$ZSH_CONFIG_DIR/apps"/*.zsh(N); do
        source "$app"
    done
fi


# ┌── 3. Finalization ─────────────────────────────────────────────────────────┐

# [OPT] Clean up loader variables
unset config_file app

# [CFG] Load Powerlevel10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
