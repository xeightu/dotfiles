#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │ SYSTEM MAINTENANCE CORE LIBRARY                                            │
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─── Visual Constants ───────────────────────────────────────────────────────┐

C_RED="\033[1;31m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_BLUE="\033[1;34m"
C_GREY="\033[1;30m"
C_NC="\033[0m"

# ┌─── Context Detection ──────────────────────────────────────────────────────┐

# [INFO] Detect best available AUR helper or fallback to pacman
if command -v paru &>/dev/null; then
  export PKG_BIN="paru"
  export PKG_CMD="paru"
elif command -v yay &>/dev/null; then
  export PKG_BIN="yay"
  export PKG_CMD="yay"
else
  export PKG_BIN="pacman"
  export PKG_CMD="sudo pacman"
fi

# ┌─── System Helpers ─────────────────────────────────────────────────────────┐

banner() {
  printf "\n%b%s%b\n" "${C_BLUE}" "┌────────────────────────────────────────────────────────────┐" "${C_NC}"
  printf "%b│ %-58s │%b\n" "${C_BLUE}" "$1" "${C_NC}"
  printf "%b%s%b\n" "${C_BLUE}" "└────────────────────────────────────────────────────────────┘" "${C_NC}"
}

die() {
  printf "%b[CRITICAL] %s%b\n" "${C_RED}" "$1" "${C_NC}"
  exit 1
}

has_cmd() {
  command -v "$1" &>/dev/null
}

require_network() {
  if ! ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    die "No internet connectivity."
  fi
}

# [USAGE] ask "Question?" "default_Y_or_N"
ask() {
  local prompt="$1"
  local default="${2:-N}"
  local color="${C_YELLOW}"
  local choice_str="[y/N]"

  [[ "$default" == "Y" ]] && choice_str="[Y/n]"

  printf "%b%s %s:%b " "$color" "$prompt" "$choice_str" "${C_NC}"
  read -r -n 1 reply
  echo ""

  if [[ -z "$reply" ]]; then
    reply="$default"
  fi

  [[ "$reply" =~ ^[Yy]$ ]]
}

# ┌─── Modules ────────────────────────────────────────────────────────────────┐

# --- Arch News (Python Parser) ---

check_news() {
  require_network
  banner "ARCH LINUX NEWS"

  if ! has_cmd python3; then
    printf "%b[WARN] Python3 missing. Skipping news.%b\n" "${C_YELLOW}" "${C_NC}"
    return 1
  fi

  # [INFO] Inline python script to avoid external dependencies
  python3 -c "
import urllib.request as r, xml.etree.ElementTree as x, ssl

try:
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    
    # [CONFIG] Fetch only latest 3 items
    url = 'https://archlinux.org/feeds/news/'
    with r.urlopen(url, context=ctx, timeout=4) as f:
        root = x.fromstring(f.read())
        items = root.findall('./channel/item')[:3]
        
        if not items:
            print('\033[1;30m(No recent news)\033[0m')
        
        for i in items:
            t = i.find('title').text
            d = i.find('pubDate').text[5:16] 
            print(f'\033[1;33m[{d}]\033[0m \033[1;37m{t}\033[0m')

except Exception:
    print(f'\033[1;31m[!] News unavailable (Connection/SSL)\033[0m')
"
}

# --- Mirror Optimization ---

optimize_mirrors() {
  local mirrorlist="/etc/pacman.d/mirrorlist"
  banner "MIRROR OPTIMIZATION"

  # [CASE] Reflector (Preferred)
  if has_cmd reflector; then
    if ask "Optimize mirrors (Reflector)?" "Y"; then
      printf "%bRanking mirrors...%b\n" "${C_GREY}" "${C_NC}"

      # [FIX] timeouts added to prevent hangs on dead mirrors
      if sudo reflector \
        --latest 10 \
        --protocol https \
        --sort rate \
        --save "$mirrorlist" \
        --download-timeout 10; then
        printf "%bReflector: Success.%b\n" "${C_GREEN}" "${C_NC}"
      else
        printf "%bReflector: Failed.%b\n" "${C_RED}" "${C_NC}"
      fi
    fi
    return 0
  fi

  # [CASE] Rate-Mirrors (Fallback)
  if has_cmd rate-mirrors; then
    if ask "Optimize mirrors (Rate-Mirrors)?" "Y"; then
      local tmp="/tmp/mirrorlist_gen"
      if rate-mirrors --save "$tmp" arch --max-delay=21600 && sudo mv "$tmp" "$mirrorlist"; then
        printf "%bRate-Mirrors: Success.%b\n" "${C_GREEN}" "${C_NC}"
      else
        printf "%bRate-Mirrors: Failed.%b\n" "${C_RED}" "${C_NC}"
      fi
    fi
    return 0
  fi
}

# --- System Snapshot ---

smart_snapshot() {
  if ! has_cmd timeshift; then return 0; fi

  banner "SYSTEM SNAPSHOT"
  if ask "Create pre-update snapshot?" "Y"; then
    local comment
    comment="Update-$(date +%Y%m%d-%H%M)"

    printf "%bCreating snapshot...%b\n" "${C_GREY}" "${C_NC}"

    if sudo timeshift --create --comments "$comment" --tags D >/dev/null; then
      printf "%bSnapshot created: %s%b\n" "${C_GREEN}" "$comment" "${C_NC}"
    else
      printf "%bSnapshot failed.%b\n" "${C_RED}" "${C_NC}"
    fi
  fi
}

# --- Cleanup & Maintenance ---

sys_cleanup() {
  banner "SYSTEM CLEANUP"

  # 1. Orphan Packages
  if pacman -Qdtq &>/dev/null; then
    local count
    count=$(pacman -Qdtq | wc -l)
    printf "%bFound %d orphans.%b\n" "${C_YELLOW}" "$count" "${C_NC}"

    if ask "Remove orphans?" "N"; then
      local orphans
      mapfile -t orphans < <(pacman -Qdtq)
      sudo pacman -Rns "${orphans[@]}"
    fi

  else
    printf "%bNo orphans found.%b\n" "${C_GREEN}" "${C_NC}"
  fi

  # 2. Package Cache
  if ask "Clean package cache?" "Y"; then
    if has_cmd paccache; then
      # [CONFIG] Keep last 2 versions
      sudo paccache -rk2
    else
      $PKG_CMD -Sc
    fi
  fi

  # 3. System Journals
  if ask "Vacuum system logs (>50M)?" "Y"; then
    sudo journalctl --vacuum-size=50M
  fi
}

# --- Security Checks ---

sys_security() {
  if has_cmd rkhunter; then
    banner "SECURITY CHECKS"
    if ask "Run Rootkit Hunter?" "N"; then
      sudo rkhunter --check --sk --rwo
    fi
  fi
}
