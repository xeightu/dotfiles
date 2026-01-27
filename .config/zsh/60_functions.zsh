# ┌─── 6. Functions (The Loader) ──────────────────────────────────────────────┐
# │  [INFO] Central hub for loading the internal function library.             │
# │  [FLOW] registry.zsh is the critical dependency.                           │
# └────────────────────────────────────────────────────────────────────────────┘


ZSH_LIB_DIR="$HOME/.config/zsh/lib"


# ┌── 6.1. Critical Dependency (Registry) ─────────────────────────────────────┐

# [FLOW] Load The Registry first. If it fails, stop loading to prevent crashes.
if [[ -f "$ZSH_LIB_DIR/registry.zsh" ]]; then
    source "$ZSH_LIB_DIR/registry.zsh"
else
    print -P "%F{9}[CRIT] Function library registry missing!%f"
    return 1 # [FLOW] Fail-fast exit
fi


# ┌── 6.2. Domain Modules (Spokes) ────────────────────────────────────────────┐

# [FLOW] Iterate and load all logic spokes (metro, tools, dotfiles).
for module in "$ZSH_LIB_DIR"/(metro|tools|dotfiles).zsh(N); do
    source "$module"
done


# [OPT] Clean up local loader variable
unset ZSH_LIB_DIR
