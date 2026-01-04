# ┌────────────────────────────────────────────────────────────────────────────┐
# │                           2. Zsh Core & Options                            │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── History (Atuin Fallback) ───────────────────────────────────────────────┐
# [INFO] Atuin handles the real history. This is just a local session buffer.

HISTSIZE=10000                 # Keep it moderate
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# [CRITICAL] Needed for history expansions (!!, !$) to work locally.
setopt APPEND_HISTORY          # Append to file, don't overwrite
setopt INC_APPEND_HISTORY      # Write immediately (crash safety)
setopt HIST_IGNORE_SPACE       # Don't save commands starting with space (secrets)
setopt HIST_VERIFY             # Show '!!' expansion before running (Safety)


# ┌─── Navigation & Globbing ──────────────────────────────────────────────────┐

# --- Directory Stack ---
# [INFO] Makes 'cd' smart. Use 'popd' to go back.
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD              # Save directory to stack on cd
setopt PUSHD_IGNORE_DUPS       # Don't save duplicates in directory stack
setopt PUSHD_SILENT            # Don't print stack after pushd/popd

# --- Globbing ---
# [CRITICAL] EXTENDED_GLOB allows using ^ for negation (ls ^*.txt).
setopt EXTENDED_GLOB           # Advanced pattern matching features
setopt NOMATCH                 # Print error if glob fails (standard behavior)


# ┌─── User Experience (UX) ───────────────────────────────────────────────────┐

# [INFO] 'INTERACTIVE_COMMENTS' is handled by Oh My Zsh.
setopt CORRECT                 # Suggest corrections for commands (spelling)
setopt NO_BEEP                 # Silence system beep
setopt NOTIFY                  # Report status of background jobs immediately
setopt NO_HUP                  # Don't kill background jobs on shell exit


# ┌─── Oh My Zsh Integration ──────────────────────────────────────────────────┐

# --- Theme & Update ---
export ZSH_THEME="powerlevel10k/powerlevel10k"

# [CONFIG] Disable auto-update prompt (manual is better).
zstyle ':omz:update' mode reminder
