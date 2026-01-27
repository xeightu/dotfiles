# ┌─── 5. Aliases ─────────────────────────────────────────────────────────────┐
# │  [INFO] Command shortcuts, modern tool replacements, and safety wrappers.    │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── 5.1. Core & Safety ──────────────────────────────────────────────────────┐

alias sudo="sudo "                              # [OPT] Allow alias expansion
alias pls='sudo $(fc -ln -1)'                   # [FIX] Retrospective sudo (Zsh native)
alias sedit="sudo -e"                           # [OPT] Sudo edit logic
alias c="clear"                                 # Quick clear
alias q="exit"                                  # [FLOW] Quick exit (Builtin)
alias h="history"                               # [FLOW] Show history (Builtin)

# [CRIT] Safety nets to prevent accidental overwrites
alias cp="cp -iv"                               
alias mv="mv -iv"                               
alias ln="ln -iv"                               

# [CRIT] Trash redirection via 'rip-bin'
alias rm="rip"                                  # [FLOW] Use trash instead of rm
alias rm!="command rm"                          # [CRIT] Bypass trash (Force)
alias rml="rip -s"                              # [FLOW] List trash
alias rmu="rip -u"                              # [FLOW] Undo delete
alias rmd="rip -d"                              # [CRIT] Empty trash
alias rmr="rip -s 2>/dev/null | fzf | xargs -I{} rip -u '{}'" # [OPT] Interactive restore


# ┌── 5.2. Filesystem & Navigation ────────────────────────────────────────────┐

alias cpwd="pwd | copy"                         # [OPT] Copy path to clipboard
alias cx="chmod +x"                             # [OPT] Quick executable
alias x="ouch decompress"                       # [OPT] Smart extraction
alias pack="ouch compress"                      # [OPT] Smart compression
alias o="xdg-open"                              # [FLOW] Open via default app

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cdi="zi"                                  # [OPT] Interactive zoxide jump


# ┌── 5.3. Modern Tool Replacements ───────────────────────────────────────────┐

# [OPT] Eza: Modern 'ls' replacement
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

alias cat="bat --paging=never --style=plain"    # [OPT] Syntax highlighted cat
alias less="bat --paging=always"                # [OPT] Syntax highlighted pager
alias v="nvim"                                  # [CFG] Editor shortcut
alias vim="nvim"

alias grep="rg"                                 # [OPT] Faster search (Ripgrep)
alias find="fd"                                 # [OPT] Faster find (fd)
alias df="duf"                                  # [OPT] Visual disk usage
alias du="dust"                                 # [OPT] Visual directory usage
alias ping="gping"                              # [OPT] Graphical ping telemetry

# [OPT] Process & Network monitoring
if command -v procs >/dev/null 2>&1; then
    alias ps="procs"                            
    alias pst="procs --tree"                    
    alias psw="procs --watch"                   
    alias fdopen="procs --insert file"          
fi

alias net="sudo bandwhich"                      # [OPT] Traffic monitor
alias trace="trip"                              # [OPT] Modern traceroute
alias lsof="sudo lsfd"                          # [OPT] Modern/faster lsof


# ┌── 5.4. Git & Dotfiles (The Mirror) ────────────────────────────────────────┐

alias g="git"                                   # [FLOW] Base git
alias ga="git add"
alias gaa="git add --all"
alias gst="git status"
alias gdiff="git diff"
alias gc="git commit -m"
alias gca="git commit --v --amend"
alias gca!="git commit --v --amend --no-edit"   
alias gp="git push"
alias gl="git pull"
alias grs="git restore"
alias grss="git restore --staged"
alias lg="lazygit"                              

# [FLOW] Dotfiles management via Bare Repository
alias dot="dotgit"
alias dst="dotgit status"
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
alias ldot="lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"


# ┌── 5.5. Zsh Superpowers ────────────────────────────────────────────────────┐

# [FLOW] Suffix Aliases: Open files by typing their name
alias -s {md,txt,yaml,json,toml,lua,conf,ini}="nvim"
alias -s {png,jpg,jpeg,gif,webp}="imv"
alias -s {mp4,mkv,mov,webm}="mpv"
alias -s {pdf}="zathura"

# [FLOW] Global Aliases: Expand anywhere in the command line
alias -g G="| rg"                               
alias -g L="| less"                             
alias -g C="| copy"                             
alias -g N="> /dev/null 2>&1"                   


# ┌── 5.6. Applications & Utilities ───────────────────────────────────────────┐

# [CFG] System Tools
alias update="~/.local/bin/desktop/sysup.sh"
alias menu="~/.local/bin/desktop/sysmenu.sh"
alias install="paru -S"
alias remove="paru -Rns"
alias search="paru -Ss"
alias aideupd="sudo aide-update"

# [OPT] TUI Apps
alias top="btop"
alias lzd="lazydocker"
alias zj="zellij"
alias za="zellij attach"
alias zk="zellij kill-all-sessions"
alias sampler="sampler --config ~/.config/sampler/sampler.yml"
alias py="python"

# [OPT] Typing Practice
alias tt="ttyper"
alias ttru="ttyper --language-file ~/.config/ttyper/languages/russian"
alias ttpy="ttyper -l python"


# ┌── 5.7. Network Transfer (Copyparty) ───────────────────────────────────────┐

_cp_cmd="~/.local/bin/copyparty-sfx.py"
alias host="$_cp_cmd"                           # [FLOW] Read-Only mode
alias share="$_cp_cmd -v .::rw"                 # [FLOW] Read/Write mode
alias drop="$_cp_cmd -v .::rw --nols"           # [CRIT] Blind upload
alias qshare="$_cp_cmd -v .::rw --qr"           # [OPT] Share + QR Code
alias qdrop="$_cp_cmd -v .::rw --nols --qr"     # [OPT] Drop + QR Code
alias vault="$_cp_cmd -a admin:123 -v .::rw:A"  # [CRIT] Password Protected
unset _cp_cmd


# ┌── 5.8. Hardware & Services ────────────────────────────────────────────────┐

# [FIX] Audio & Sync services
alias soundfix="systemctl --user restart pipewire wireplumber pipewire-pulse"
alias st="systemctl --user enable --now syncthing"

# [FIX] Brightness manager state control
alias breset="~/.local/bin/brightness-manager --force"
alias blog="journalctl --user -u brightness-manager -n 20 --no-pager"

_br_lock="${XDG_RUNTIME_DIR:-/tmp}/brightness_disabled"
alias bon="command rm -f \"$_br_lock\" && echo 'Auto brightness re-enabled.'"
alias boff="touch \"$_br_lock\" && echo 'Auto brightness disabled.'"
