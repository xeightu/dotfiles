# ┌─── 2. Zsh Core & Options ──────────────────────────────────────────────────┐
# │  [INFO] Local session logic and shell behavior settings.
# └────────────────────────────────────────────────────────────────────────────┘

# ┌── 2.1. History (Session Buffer) ───────────────────────────────────────────┐

HISTSIZE=10000                                  # [CFG] Internal buffer size
SAVEHIST=10000                                  # [CFG] Persistent limit
HISTFILE="$HOME/.zsh_history"                   # [CFG] Local fallback file

setopt APPEND_HISTORY                           # [FLOW] Merge session history
setopt INC_APPEND_HISTORY                       # [FIX] Write immediately (crash safety)
setopt HIST_IGNORE_SPACE                        # [CRIT] Stealth mode: don't log space-prefixed
setopt HIST_VERIFY                              # [CRIT] Safety: show expansion before exec


# ┌── 2.2. Navigation & Globbing ──────────────────────────────────────────────┐

setopt AUTO_CD                                  # [FLOW] Direct directory execution
setopt AUTO_PUSHD                               # [FLOW] Build directory stack on cd
setopt PUSHD_IGNORE_DUPS                        # [OPT] Clean stack: no duplicates
setopt PUSHD_SILENT                             # [OPT] Silent stack management

setopt EXTENDED_GLOB                            # [OPT] Enable regex-like patterns (^, ~, #)
setopt NOMATCH                                  # [FIX] Enforce error on failed glob


# ┌── 2.3. UX & Framework ─────────────────────────────────────────────────────┐

setopt CORRECT                                  # [OPT] Suggest spelling fixes
setopt NO_BEEP                                  # [OPT] Silence terminal bell
setopt NOTIFY                                   # [FLOW] Immediate bg job status
setopt NO_HUP                                   # [OPT] Persist bg jobs on shell exit

export ZSH_THEME="powerlevel10k/powerlevel10k"  # [CFG] Visual skin
zstyle ":omz:update" mode reminder              # [CFG] Update alerts only
