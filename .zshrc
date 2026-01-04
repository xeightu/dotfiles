# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ┌────────────────────────────────────────────────────────────────────────────┐
# │                           ZSH - MAIN ENTRY POINT                           │
# └────────────────────────────────────────────────────────────────────────────┘
# [INFO] This file sources all other configuration parts.
# Keep it clean and only add sourcing logic here.

# [CONFIG] Path to the Zsh configuration directory.
export ZSH_CONFIG_DIR="$HOME/.config/zsh"

# [INFO] Source all .zsh files from the config directory.
# The numeric prefixes ensure they are loaded in the correct sequence.
for config_file in "$ZSH_CONFIG_DIR"/*.zsh; do
  source "$config_file"
done

# [INFO] Clean up to avoid polluting the shell environment.
unset config_file

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/home/x8u/.spicetify
