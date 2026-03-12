# ┌─── 1. Shell Fundamentals & Safety ─────────────────────────────────────────┐

# [FIX] Allow aliases to be expanded after sudo
alias sudo="sudo "

# Rerun last command as root
alias pls='sudo $(fc -ln -1)'

# [WARN] Interactive prompts to prevent accidental data loss
alias cp="cp -iv"
alias mv="mv -iv"
alias ln="ln -iv"
alias mkdir="mkdir -pv"

# [WARN] Replace destructive 'rm' with 'rip' (trash-bin)
alias rm="rip"
alias rml="rip -s"
alias rmu="rip -u"
alias rmd="rip -d"
alias rmr="rip -s 2>/dev/null | fzf | xargs -I{} rip -u '{}'"

# [WARN] Actual file destruction
alias rm!="command rm"

# Navigation & Basic shortcuts
alias c="clear"
alias q="exit"
alias h="history"
alias sedit="sudo -e"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cdi="zi"
alias cpwd="pwd | copy"

# [NOTE] Column-formatted PATH for easy debugging
alias path='echo -e ${PATH//:/\\n}'


# ┌─── 2. Daily Productivity (Search & View) ──────────────────────────────────┐

# [NOTE] Modular eza configuration with Git integration
_EZA_BASE="eza --icons --group-directories-first --git"
if command -v eza >/dev/null 2>&1; then
    alias ls="$_EZA_BASE"
    alias ll="$_EZA_BASE -lh --header"
    alias la="$_EZA_BASE -lha --header"
    alias lt="$_EZA_BASE --tree --level=2"
    alias ltf="$_EZA_BASE --tree --level=10"
    alias lsz="$_EZA_BASE -lrh --sort=size"
    alias ld="$_EZA_BASE -lrh --sort=modified"
fi
unset _EZA_BASE

# Bat / Nvim
# [NOTE] bat --style=header provides file boundaries for multiple arguments
alias cat="bat --style=header --paging=never"
alias less="bat --paging=always"
alias v="nvim"
alias vim="nvim"
alias o="xdg-open"

# Search & Monitoring
alias grep="rg"
alias find="fd"
alias df="duf"
alias du="dust"

if command -v procs >/dev/null 2>&1; then
    alias ps="procs"
    alias pst="procs --tree"
    alias psw="procs --watch"
    alias fdopen="procs --insert file"
fi


# ┌─── 3. Development (Git & Dotfiles) ────────────────────────────────────────┐

alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gst="git status"
alias gdiff="git diff"
alias gc="git commit -m"
alias gca="git commit --v --amend"
alias gca!="git commit --v --amend --no-edit"
alias gp="git push"
alias gl="git pull"
alias gcl="git clone"
alias gcp="git cherry-pick"
alias grs="git restore"
alias grss="git restore --staged"
alias lg="lazygit"

# Bare repository management
alias dot="dotgit"
alias dst="dotgit status -sb"
alias ddiff="dotgit diff"
alias da="dotgit add"
alias daa="dotgit add -u"
alias dgc="dotgit commit -m"
alias dca="dotgit commit --v --amend"
alias dca!="dotgit commit --v --amend --no-edit"
alias dp="dotgit push"
alias dl="dotgit pull"
alias drs="dotgit restore"
alias drss="dotgit restore --staged"

# [FIX] Force lazygit to use the bare repository context
alias ldot="lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"


# ┌─── 4. Hardware & System Services ──────────────────────────────────────────┐

_BR_LOCK="${XDG_RUNTIME_DIR:-/tmp}/brightness_disabled"

# [NOTE] Soft Mocha-themed status notifications (Pastel Green/Peach/Mauve)
alias bon="command rm -f \"$_BR_LOCK\" && print -P '%F{151}󰖨  Auto-brightness re-enabled.%f'"
alias boff="touch \"$_BR_LOCK\" && print -P '%F{216}󰓄  Auto-brightness suspended.%f'"
alias breset="print -P '%F{183}󰑐 Triggering re-sync...%f' && ~/.local/bin/brightness-manager --force"

# System Control
alias soundfix="systemctl --user restart pipewire wireplumber pipewire-pulse"
alias st="systemctl --user enable --now syncthing"


# ┌─── 5. Apps & Package Management ───────────────────────────────────────────┐

alias i="paru -S"
alias re="paru -Rns"
alias s="paru -Ss"
alias aideupd="sudo aide-update"

alias u="~/.local/bin/desktop/sysup.sh"
alias menu="~/.local/bin/desktop/sysmenu.sh"

alias top="btop"
alias lzd="lazydocker"
alias sampler="sampler --config ~/.config/sampler/sampler.yml"
alias py="python"
alias ff="fastfetch"
alias m="mailsy"

# Multiplexers
alias zj="zellij"
alias za="zellij attach"
alias zk="zellij kill-all-sessions"

# QoL Tools
alias tt="ttyper"
alias ttru="ttyper --language-file ~/.config/ttyper/languages/russian"
alias ttpy="ttyper -l python"


# ┌─── 6. Network & External Tools ────────────────────────────────────────────┐

alias ip="ip -c"
alias ipb="ip -brief -color address"
alias ipl="ip -brief -color link"
alias ping="gping"
alias net="sudo bandwhich"
alias trace="trip"
alias lsof="sudo lsfd"

# Temporary file server (copyparty)
_CP_CMD="~/.local/bin/copyparty-sfx.py"
alias host="$_CP_CMD"
alias share="$_CP_CMD -v .::rw"
alias drop="$_CP_CMD -v .::rw --nols"
alias qshare="$_CP_CMD -v .::rw --qr"
alias qdrop="$_CP_CMD -v .::rw --nols --qr"
alias vault="$_CP_CMD -a admin:123 -v .::rw:A"
unset _CP_CMD


# ┌─── 7. File Automation & Global Filters ────────────────────────────────────┐

alias x="ouch decompress"
alias pack="ouch compress"
alias cx="chmod +x"

# [NOTE] Suffix aliases: Automatically open files by extension in $EDITOR
alias -s {md,txt,yaml,json,toml,lua,conf,ini,zsh,py}="nvim"
alias -s {png,jpg,jpeg,gif,webp}="imv"
alias -s {mp4,mkv,mov,webm}="mpv"
alias -s {pdf}="zathura"

# Global aliases: Quick pipeline filters
alias -g G="| rg"
alias -g L="| less"
alias -g C="| copy"
alias -g N="> /dev/null 2>&1"
