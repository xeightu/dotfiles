# ┌─── 1. Core Engine ─────────────────────────────────────────────────────────┐

dotgit() {
    # [NOTE] Absolute paths prevent context drift in subdirectories
    command git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}


# ┌─── 2. Diagnostics ─────────────────────────────────────────────────────────┐

# dfd: Dotfiles Doctor - Dynamically renders a warning box for untracked files
dfd() {
    local _untracked
    # Scan critical paths for files not yet tracked in git
    _untracked=$(dotgit ls-files --others --exclude-standard -- \
        "$HOME/.config" "$HOME/.local/bin" "$HOME/.zshrc")

    [[ -z "$_untracked" ]] && return 0

    # 1. Calculate dynamic width
    local _lines=("${(@f)_untracked}")
    local _max_w=20 # Minimum base width
    for _line in $_lines; do
        (( ${#_line} > _max_w )) && _max_w=${#_line}
    done
    
    # [NOTE] Cap width to 80 chars to prevent terminal overflow
    (( _max_w > 80 )) && _max_w=80

    # 2. Render Box Components
    # Width = max string length + padding
    local _hr_w=$(( _max_w + 4 ))
    local _hr_line=$(printf "─%.0s" {1..$_hr_w})
    
    # 3. Output
    print -P "%F{9}┌${_hr_line}┐%f"
    print -P "%F{9}│%f  %BUNTRACKED DOTFILES%b"
    print -P "%F{9}├${_hr_line}┤%f"
    
    for _line in $_lines; do
        # Truncate string if it exceeds max width
        local _display_text=${_line:0:$_max_w}
        print -P "%F{9}│%f  ${_display_text}%f"
    done
    
    print -P "%F{9}└${_hr_line}┘%f"
    print -P "  %F{11}➜ Use 'da <path>' or 'ldot' to secure them.%f"
    
    return 1
}


# ┌─── 3. Snippet Sharing ─────────────────────────────────────────────────────┐

# Interactively copy changes or full files to clipboard
dcf() {
    local files
    files=$(dotgit status --porcelain)

    [[ -z "$files" ]] && return 0

    local selection
    selection=$(echo "$files" | fzf \
        --height=60% \
        --header="Copy changes/content to clipboard" \
        --preview='
git_status=$(echo {} | cut -c1-2)
file=$(echo {} | cut -c4-)

case "$git_status" in
  "??")
      bat --color=always --style=numbers -- "$file"
      ;;
  *D)
      echo "FILE WAS DELETED"
      git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --color=always -- "$file"
      ;;
  *)
      git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --color=always -- "$file" | grep . || \
      bat --color=always --style=numbers -- "$file"
      ;;
esac
')

    [[ -z "$selection" ]] && return 0

    local file
    file=$(echo "$selection" | cut -c4-)

    if dotgit ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        dotgit diff --no-color -- "$file" | copy
    else
        cat "$file" | copy
    fi
}
