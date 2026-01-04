# ┌────────────────────────────────────────────────────────────────────────────┐
# │                                5. Aliases                                  │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── Core & Safety ──────────────────────────────────────────────────────────┐

# --- Privileges & Basics ---
alias sudo="sudo "                      # Allows aliases to be sudo'ed
alias please='sudo $(history -p !!)'    # Rerun last command with sudo
alias sedit="sudo -e"                   # Sudo Edit
alias c="clear"                         # Quick clear
alias q="exit"                          # Quick exit
alias h="history"                       # Show history

# --- Safety Nets ---
alias cp="cp -iv"                       # Confirm before overwriting
alias mv="mv -iv"                       # Confirm before moving
alias ln="ln -iv"                       # Confirm link creation

# --- Trash Management ---
# [CRITICAL] 'rm' moves to trash. Use 'rm!' to bypass.
alias rm="rip"                          # Move to trash
alias rm!="command rm"                  # Force permanent delete
alias rml="rip -s"                      # List trash (Seance)
alias rmu="rip -u"                      # Undo delete (Unbury)
alias rmd="rip -d"                      # Empty trash (Decompose)
alias rmr="rip -s | fzf | xargs -I{} rip -u '{}'" # Restore via FZF


# ┌─── Filesystem & Operations ────────────────────────────────────────────────┐

# --- File Manipulation ---
alias cpwd="pwd | copy"                 # Copy current path
alias cx="chmod +x"                     # Make executable
alias x="ouch decompress"               # Smart extract
alias pack="ouch compress"              # Smart compress
alias o="xdg-open"                      # Open with default app

# --- Navigation ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cdi="zi"                          # Interactive zoxide jump


# ┌─── Modern Replacements ─────────────────────────────────────────────┐

# --- List ---
# [INFO] Define base command once to "bake it" into all aliases below.
_ls_cmd="eza --icons --group-directories-first --git"

if command -v eza >/dev/null 2>&1; then
    alias ls="$_ls_cmd"
    alias ll="$_ls_cmd -lh --header"
    alias la="$_ls_cmd -lha --header"
    alias lt="$_ls_cmd --tree --level=2"
    alias ltf="$_ls_cmd --tree --level=10"
    alias lsz="$_ls_cmd -lrh --sort=size"
    alias ld="$_ls_cmd -lrh --sort=modified"
fi

unset _ls_cmd

# --- Viewers & Editors ---
alias cat="bat --paging=never --style=plain"
alias less="bat --paging=always"
alias v="nvim"
alias vim="nvim"

# --- Analysis & Network ---
alias grep="rg"                         # Ripgrep
alias find="fd"                         # Fast find
alias df="duf"                          # Disk Usage/Free
alias du="dust"                         # Disk Usage
alias ping="gping"                      # Graphical Ping


# ┌─── Git & Dotfiles ─────────────────────────────────────────────────────────┐

# --- Git Shortcuts ---
alias g="git"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gst="git status"
alias lg="lazygit"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# --- Dotfiles (Bare Repo) ---
alias dot="dotgit"                      # Base command wrapper
alias dstat="dotgit status"             # Short status
alias ddiff="dotgit diff"               # View changes
alias dpull="dotgit pull"               # Update from remote
alias dpush="dotgit push"               # Push to remote
alias dadd="dotgit add"                 # Stage files
alias dgc="dotgit commit -m"            # Commit
alias dlog="dotgit log --oneline --graph --decorate"
alias ldot="lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"


# ┌─── Zsh Superpowers ────────────────────────────────────────────────────────┐

# --- Suffix Aliases ---
# [INFO] Open files by typing name: 'readme.md' -> nvim readme.md
alias -s {md,txt,yaml,json,toml,lua,conf,ini}="nvim"
alias -s {png,jpg,jpeg,gif,webp}="imv"
alias -s {mp4,mkv,mov,webm}="mpv"
alias -s {pdf}="zathura"

# --- Global Aliases ---
# [INFO] Expand anywhere: 'cat file G pattern' -> 'cat file | rg pattern'
alias -g G="| rg"                       # Pipe to Grep
alias -g L="| less"                     # Pipe to Less
alias -g C="| copy"                     # Pipe to Clipboard
alias -g N="> /dev/null 2>&1"           # Silence output


# ┌─── Applications & Utilities ───────────────────────────────────────────────┐

# --- System Tools ---
alias update="~/.local/bin/desktop/sysup.sh"
alias menu="~/.local/bin/desktop/sysmenu.sh"
alias install="yay -S"
alias remove="yay -Rns"
alias search="yay -Ss"
alias aideupd="sudo aide-update"

# --- Network Utils ---
alias myip='curl ifconfig.me'                     # Public IP
alias ports='sudo ss -tulpn | grep LISTEN'        # Open ports

# --- TUI Apps ---
alias top="btop"
alias lzd="lazydocker"
alias zj="zellij"
alias za="zellij attach"
alias zk="zellij kill-all-sessions"
alias sampler="sampler --config ~/.config/sampler/sampler.yml"
alias py="python"

# --- Typing Practice ---
alias tt="ttyper"
alias ttru="ttyper --language-file ~/.config/ttyper/languages/russian"
alias ttpy="ttyper -l python"


# ┌─── Hardware & Services ────────────────────────────────────────────────────┐

# --- Audio & Sync ---
alias soundfix="systemctl --user restart pipewire wireplumber pipewire-pulse"
alias st="systemctl --user enable --now syncthing"

# --- Brightness Manager ---
alias breset="~/.local/bin/brightness-manager --force"
alias blog="journalctl --user -u brightness-manager -n 20 --no-pager"

# [FIX] Lockfile logic for disabling auto-brightness
_BR_LOCK="${XDG_RUNTIME_DIR:-/tmp}/brightness_disabled"
alias bon="command rm -f \"$_BR_LOCK\" && echo 'Auto brightness re-enabled.'"
alias boff="touch \"$_BR_LOCK\" && echo 'Auto brightness disabled.'"


# ┌─── Installers & One-offs ──────────────────────────────────────────────────┐

alias spiceinstall="curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh"
alias spiceup="spicetify upgrade"
alias spicefix="spicetify restore backup && spicetify backup apply"
