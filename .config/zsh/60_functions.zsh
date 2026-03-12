# ┌─── 1. Core Dependency (Registry) ──────────────────────────────────────────┐

_LIB_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/lib"

# [WARN] Fail-fast if the registry is missing to prevent critical shell errors
if [[ ! -r "$_LIB_DIR/registry.zsh" ]]; then
    print -P "%F{red}[CRIT] Function library registry missing at $_LIB_DIR!%f" >&2
    return 1
fi

source "$_LIB_DIR/registry.zsh"


# ┌─── 2. Module Loader (Spokes) ──────────────────────────────────────────────┐

# [NOTE] Dynamically source all .zsh modules; (N) prevents errors if empty
for _mod in "$_LIB_DIR"/*.zsh(N); do
    # Skip the registry as it is already sourced above
    [[ "$_mod" == *"registry.zsh" ]] && continue
    
    source "$_mod"
done

# Clean up internal variables to prevent global scope pollution
unset _LIB_DIR _mod
