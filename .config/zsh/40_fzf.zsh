# ┌─── 1. Dependency Resolution ───────────────────────────────────────────────┐

# [FIX] Fallback to standard utilities if modern replacements are missing
local _fd="${commands[fd]:-find}"
local _bat="${commands[bat]:-cat}"
local _eza="${commands[eza]:-ls}"


# ┌─── 2. Search Engine Strategy ──────────────────────────────────────────────┐

# [NOTE] Prefer 'fd' for fast, parallelized filesystem traversal
if [[ "$_fd" == *"fd"* ]]; then
    export FZF_DEFAULT_COMMAND="$_fd --type f --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_ALT_C_COMMAND="$_fd --type d --hidden --follow --exclude .git --strip-cwd-prefix"
else
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*'"
    export FZF_ALT_C_COMMAND="find . -type d -not -path '*/.git/*'"
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


# ┌─── 3. Preview Logic ───────────────────────────────────────────────────────┐

# [NOTE] Render directory trees via 'eza' or file content via 'bat'
local _preview_cmd="
    if [[ -d {} ]]; then 
        $_eza --tree --level=2 --icons --group-directories-first --git-ignore {}; 
    else 
        $_bat --color=always --style=numbers --line-range :500 {}; 
    fi"


# ┌─── 4. UI & Theming ────────────────────────────────────────────────────────┐

# [NOTE] Catppuccin Mocha palette with rounded borders and custom icons
export FZF_DEFAULT_OPTS="
  --height=70% --layout=reverse --border=rounded --margin=0,1 --info=inline
  --prompt='  ' --pointer=' ' --marker='󰄬 '
  --separator='─' --scrollbar='│'
  
  --preview-window='right:55%:border-left:wrap'
  --preview='${_preview_cmd}'
  
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --bind='shift-up:preview-page-up'
  --bind='shift-down:preview-page-down'
  
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#b4befe
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#b4befe,hl+:#f38ba8
  --color=selected-bg:#45475a
  --color=border:#585b70,label:#cdd6f4,separator:#585b70
"

# ┌─── 5. History Widget ──────────────────────────────────────────────────────┐

# Interactive history search (Ctrl+R) with command preview toggle
export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window down:3:hidden:wrap
    --bind '?:toggle-preview'
    --header 'Press ? to toggle full command preview'
"
