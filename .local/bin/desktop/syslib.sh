#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │                    System Maintenance Core Library                         │
# └────────────────────────────────────────────────────────────────────────────┘

C_RED="\033[1;31m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_BLUE="\033[1;34m"
C_CYAN="\033[1;36m"
C_NC="\033[0m"

# [INFO] Context Detection
if command -v paru &>/dev/null; then
  AUR_BIN="paru"
elif command -v yay &>/dev/null; then
  AUR_BIN="yay"
else
  AUR_BIN=""
fi

# ┌─── Helpers ────────────────────────────────────────────────────────────────┐

banner() { printf "\n%b══ %s ══%b\n" "${C_BLUE}" "$1" "${C_NC}"; }

ask() {
  local prompt="$1"
  local reply
  printf "%b%s [y/N]:%b " "${C_YELLOW}" "$prompt" "${C_NC}"
  read -r -n 1 reply
  echo ""
  [[ "$reply" =~ ^[Yy]$ ]]
}

require_network() {
  if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    printf "%b[CRITICAL] No internet connectivity.%b\n" "${C_RED}" "${C_NC}"
    return 1
  fi
}

# ┌─── Modules ────────────────────────────────────────────────────────────────┐

check_news() {
  require_network || return 1
  banner "ARCH LINUX NEWS"

  python3 -c "
import urllib.request as r, xml.etree.ElementTree as x, ssl, sys

try:
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    
    url = 'https://archlinux.org/feeds/news/'
    with r.urlopen(url, context=ctx, timeout=3) as f:
        root = x.fromstring(f.read())
        items = root.findall('./channel/item')[:3] # Только 3 свежих
        
        if not items:
            print('\033[1;30m(No recent news)\033[0m')
        
        for i in items:
            t = i.find('title').text
            d = i.find('pubDate').text[5:16] 
            print(f'\033[1;33m[{d}]\033[0m \033[1;37m{t}\033[0m')

except Exception as e:
    print(f'\033[1;31m[!] News unavailable (Connection/SSL)\033[0m')
"
  echo ""
}

optimize_mirrors() {
  banner "MIRROR OPTIMIZATION"
  local save_path="/etc/pacman.d/mirrorlist"

  if command -v reflector &>/dev/null; then
    if ask "Optimize mirrors (Reflector)?"; then
      # [FIX] Added connection and download timeouts to prevent SSL hangs
      if sudo reflector --latest 10 --protocol https --sort rate --save "$save_path" --connection-timeout 5 --download-timeout 60; then
        printf "%bMirrors updated via Reflector.%b\n" "${C_GREEN}" "${C_NC}"
      else
        printf "%bReflector failed (Network/SSL issue).%b\n" "${C_RED}" "${C_NC}"
      fi
    fi
  elif command -v rate-mirrors &>/dev/null; then
    if ask "Optimize mirrors (Rate-Mirrors)?"; then
      local tmp="/tmp/mirrorlist_gen"
      if rate-mirrors --save "$tmp" arch --max-delay=21600 && sudo mv "$tmp" "$save_path"; then
        printf "%bMirrors updated via Rate-Mirrors.%b\n" "${C_GREEN}" "${C_NC}"
      else
        printf "%bRate-mirrors failed.%b\n" "${C_RED}" "${C_NC}"
      fi
    fi
  else
    printf "%bNo mirror tools found.%b\n" "${C_RED}" "${C_NC}"
  fi
}

smart_snapshot() {
  command -v timeshift &>/dev/null || return 0
  banner "SYSTEM SNAPSHOT"
  ask "Create pre-update snapshot?" || return 0

  local tag="Pre-update"
  printf "%bCreating snapshot...%b\n" "${C_CYAN}" "${C_NC}"
  sudo timeshift --create --comments "$tag" --tags D >/dev/null

  local snaps
  mapfile -t snaps < <(sudo timeshift --list | grep "$tag" | awk '{print $3}' | grep -E '^[0-9]')
  local count=${#snaps[@]}
  local max=5

  if ((count > max)); then
    local rm_count=$((count - max))
    printf "%bRotating %d old snapshots...%b\n" "${C_CYAN}" "$rm_count" "${C_NC}"
    for ((i = 0; i < rm_count; i++)); do
      sudo timeshift --delete --snapshot "${snaps[$i]}" --yes >/dev/null
    done
  fi
  printf "%bSnapshot active.%b\n" "${C_GREEN}" "${C_NC}"
}

# ┌─── Pipeline ───────────────────────────────────────────────────────────────┐

sys_update() {
  require_network || return 1
  banner "SYSTEM UPDATE (VIA TOPGRADE)"

  if command -v topgrade &>/dev/null; then
    topgrade --yes --disable-pre-steps --disable-post-steps || return $?
    if [[ -n "$AUR_BIN" ]]; then
      $AUR_BIN -Syu --sudoloop --color=always
    else
      sudo pacman -Syu --color=always
    fi
  fi
}

sys_cleanup() {
  banner "SYSTEM CLEANUP"
  local orphans=()
  mapfile -t orphans < <(pacman -Qdtq 2>/dev/null)

  if ((${#orphans[@]} > 0)); then
    printf "%bFound %d orphans.%b\n" "${C_YELLOW}" "${#orphans[@]}" "${C_NC}"
    ask "Remove orphans?" && sudo pacman -Rns "${orphans[@]}"
  else
    printf "%bSystem is clean.%b\n" "${C_GREEN}" "${C_NC}"
  fi

  if command -v paccache &>/dev/null; then
    ask "Clean package cache (keep 2)?" && sudo paccache -rk2
  elif [[ -n "$AUR_BIN" ]]; then
    ask "Clean package cache?" && $AUR_BIN -Sc
  fi
  ask "Vacuum journals (50M)?" && sudo journalctl --vacuum-size=50M
}

sys_security() {
  banner "SECURITY CHECKS"
  command -v rkhunter &>/dev/null && ask "Run Rootkit Hunter?" && sudo rkhunter --check --sk --rwo
}
