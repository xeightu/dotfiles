# ┌─── 1. History Configuration ───────────────────────────────────────────────┐

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# Share history across concurrent shell sessions
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# [WARN] Skip recording commands starting with a space to prevent secret leaks
setopt HIST_IGNORE_SPACE

# Load history expansion into the buffer for editing before execution
setopt HIST_VERIFY


# ┌─── 2. Directory Navigation ────────────────────────────────────────────────┐

# Change directory by typing the path without 'cd'
setopt AUTO_CD

# Maintain a deduplicated directory stack for fast 'cd -' navigation
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT


# ┌─── 3. Globbing & Matching ─────────────────────────────────────────────────┐

# Enable advanced pattern matching (e.g., ^, ~, #)
setopt EXTENDED_GLOB

# Throw an error if a glob pattern finds no matches
setopt NOMATCH


# ┌─── 4. Shell UX & Job Control ──────────────────────────────────────────────┐

setopt CORRECT
setopt NO_BEEP

# Report background job status changes immediately
setopt NOTIFY

# [WARN] Prevent background jobs from being terminated when the shell exits
setopt NO_HUP


# ┌─── 5. UI & Framework ──────────────────────────────────────────────────────┐

export ZSH_THEME="powerlevel10k/powerlevel10k"

# Non-blocking framework update reminders
zstyle ":omz:update" mode reminder
