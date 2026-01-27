# ┌─── Module: Dotfiles Ops ───────────────────────────────────────────────────┐
# │  [INFO] Bare repository management engine and related helpers.             │
# │  [DEPENDS] git, copy function (from tools.zsh), fzf, bat.                  │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌── Core Engine ─────────────────────────────────────────────────────────────┐

# [FLOW] Primary engine for managing the bare repository (~/.dotfiles).
# [NOTE] Serves as the backend for all 'd*' aliases (dstat, dadd, dpush).
dotgit() {
    # [CRIT] Fixed paths to avoid context drift and ensure bare repository mode
    command git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}


# ┌── Diagnostics ─────────────────────────────────────────────────────────────┐

# [FLOW] Dotfiles Doctor: Diagnostic tool to detect "Ghost Files" (untracked).
dfd() {
    local untracked_files

    # [OPT] Explicitly hunt for untracked items in critical paths
    untracked_files=$(dotgit ls-files --others --exclude-standard -- \
        "$HOME/.config" "$HOME/.local/bin" "$HOME/.zshrc" "$HOME/.p10k.zsh")

    if [[ -n "$untracked_files" ]]; then
        print -P "%F{9}┌─ [CRIT] Untracked Dotfiles ──────────────────────────────────┐%f"
        echo "$untracked_files" | sed 's/^/│  /' # [OPT] Visual border
        print -P "%F{9}└────────────────────────────────────────────────────────────────┘%f"
        print -P "%F{yellow}  Use 'dadd <path>' to secure them.%f"
        return 1
    else
        print -P "%F{10}All critical dotfiles are tracked.%f"
    fi
}


# ┌── Interactive Diff ────────────────────────────────────────────────────────┐

# [FLOW] Interactive picker for changed dotfiles.
dcf() {
    # [CONFIG] Raw git command to bypass aliases
    local raw_git="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
    local changed_files
    
    changed_files=$(dotgit status --porcelain)
    [[ -z "$changed_files" ]] && { echo "No changes found in dotfiles."; return 0; }

    local file
    
    # [INFO] Pipeline Strategy: Remove status code, pass path to FZF
    file=$(echo "$changed_files" | sed 's/^...//' | fzf \
        --height=40% \
        --header="Select a file to copy its changes" \
        --preview-window="right:65%:wrap:border-left" \
        --preview="$raw_git diff --color=always -- {} | grep . || bat --color=always --style=numbers -- {}") # Preview Diff (tracked) or Content (new)

    [[ -z "$file" ]] && return 0
    
    # [ACTION] Copy content or diff
    if dotgit ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        # Case 1: Modified or Deleted -> Copy Diff
        dotgit diff --no-color -- "$file" | copy
        print -P "%F{10}✔ Diff copied for: %B$file%b%f"
    else
        # Case 2: New/Untracked -> Copy Content
        cat "$file" | copy
        print -P "%F{14}✔ New file content copied: %B$file%b%f"
    fi
}
