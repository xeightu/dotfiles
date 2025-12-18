# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                5. Aliases                                  │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── System & Maintenance ───────────────────────────────────────────────────┐

# --- Package Management ---
# [INFO] Shortcuts for Arch Linux (yay/pacman) and system scripts.
alias sudo="sudo "                                      # Enable aliases with sudo
alias c="clear"                                         # Clear terminal
alias h="history"                                       # Show history
alias update="~/.local/bin/desktop/sysup.sh"            # System update wrapper
alias menu="~/.local/bin/desktop/sysmenu.sh"            # System action menu
alias install="yay -S"                                  # Install package
alias remove="sudo pacman -Rns"                         # Clean remove
alias search="yay -Ss"                                  # Search AUR/Repos


# ┌─── Filesystem & Navigation ────────────────────────────────────────────────┐

# --- Jumps ---
alias ..="cd .."
alias ...="cd ../.."
alias cdi="zi"                                          # Interactive zoxide jump

# --- Eza (Modern ls) ---
alias ls="eza --icons --group-directories-first --git"
alias ll="eza -lh --icons --git --group-directories-first --header"
alias la="eza -lha --icons --git --group-directories-first --header"
alias lt="eza --tree --level=2 --icons"
alias ltf="eza --tree --level=10 --icons"
alias lsz="eza -lrh --sort=size --icons"
alias ld="eza -lrh --sort=modified --icons"

# --- Content Viewers ---
alias cat="bat --paging=never --style=plain"
alias less="bat --paging=always"

# --- File Operations ---
alias cp="cp -iv"                                       # Interactive copy
alias mv="mv -iv"                                       # Interactive move
alias cpwd="pwd | copy"                                 # Copy current path
alias cx="chmod +x"                                     # Make executable
alias rm="rip"                                          # Safe delete (trash)
alias rml="rip -s"                                      # List deleted (Seance)
alias rmu="rip -u"                                      # Restore last (Unbury)
alias rmd="rip -d"                                      # Empty trash (Decompose)
alias rmr="rip -s | fzf | xargs -I{} rip -u '{}'"       # Restore via FZF
alias rmdir="rm"                                        # Treat dir removal same as file
alias x="ouch decompress"                               # Smart extract
alias pack="ouch compress"                              # Smart compress
alias o="xdg-open"                                      # Open with default app

# --- Search & Analysis ---
alias find="fd"                                         # Modern find
alias grep="rg"                                         # Modern grep
alias ncdu="gdu"                                        # Disk usage analyzer
alias df="duf"                                          # Disk free viewer


# ┌─── Git & Dotfiles ─────────────────────────────────────────────────────────┐

# --- Git Shortcuts ---
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lgit="lazygit"

# --- Dotfiles Wrapper ---
# [INFO] Commands for managing the bare repository (requires 'dotgit' function).
alias dstat="dotgit status"
alias dls="dotgit ls-files | eza --tree --icons"
alias dadd="dotgit add"
alias dpush="dotgit push"
alias ddel="dotgit rm"
alias dgcm="dotgit commit -m"
alias dgc="dotgit commit"
alias ddf="dotgit diff"
alias dlog="dotgit log --oneline --graph --decorate"
alias lg="lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"


# ┌─── Applications & TUI ─────────────────────────────────────────────────────┐

# --- Monitoring & Utils ---
alias top="btop"
alias lzd="lazydocker"
alias sampler="sampler --config ~/.config/sampler/sampler.yml"
alias aideupd="sudo aide-update"
alias ping="gping"

# --- Zellij (Multiplexer) ---
alias zj="zellij"
alias za="zellij attach"
alias zk="zellij kill-all-sessions"

# --- Typing Practice ---
alias tt="ttyper"                                                         # English
alias ttru="ttyper --language-file ~/.config/ttyper/languages/russian"    # Russian
alias ttpy="ttyper -l python"                                             # Code (Python)


# ┌─── Hardware & Services ────────────────────────────────────────────────────┐

# --- Audio & Sync ---
alias soundreload="systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service"
alias st="systemctl --user enable --now syncthing"

# --- Brightness Manager ---
_BR_LOCK="${XDG_RUNTIME_DIR:-/tmp}/brightness_disabled"

alias bon="rm -f \"$_BR_LOCK\" && echo '🌞 Auto brightness re-enabled.'"
alias boff="touch \"$_BR_LOCK\" && echo '🌙 Auto brightness disabled.'"
alias breset="~/.local/bin/brightness-manager --force"
alias blog="journalctl --user -u brightness-manager -n 20 --no-pager"


# ┌─── Installers & One-offs ──────────────────────────────────────────────────┐

# [INFO] Scripts for third-party tools installation/maintenance.
alias vencord="sh -c \"$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)\""
alias spiceinstall="curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh"
alias spicefix="spicetify backup apply"
