# ┌─── 1. Initialization ──────────────────────────────────────────────────────┐

# [NOTE] Uncomment to profile shell startup performance
# zmodload zsh/zprof

# [NOTE] Enable instant prompt to reduce perceived startup time
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ┌─── 2. Global Environment ──────────────────────────────────────────────────┐

export ZSH_CONFIG_DIR="${HOME}/.config/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# [NOTE] Redirect zcompdump to cache to keep $HOME clean
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/zcompdump-${HOST}-${ZSH_VERSION}"

# [NOTE] Skip security checks to significantly speed up shell startup
zstyle ":omz:lib:completion" compinit-options "-C"


# ┌─── 3. Module Loader ───────────────────────────────────────────────────────┐

# Load core configurations (10_*, 20_*, etc.)
for _f in "$ZSH_CONFIG_DIR"/(10|20|30|40|50|60|70)_*.zsh(N); do
    source "$_f"
done

# Load application-specific configs
if [[ -d "$ZSH_CONFIG_DIR/apps" ]]; then
    for _a in "$ZSH_CONFIG_DIR/apps"/*.zsh(N); do
        source "$_a"
    done
fi


# ┌─── 4. Post-Load & Finalization ────────────────────────────────────────────┐

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Print profiling results if zprof was loaded
(( $+builtins[zprof] )) && zprof | head -n 20

# [NOTE] Prevent loop variables from leaking into the global scope
unset _f _a
