#!/usr/bin/env bash

# ┌─── 1. UI Palette & High-Contrast Constants ────────────────────────────────┐

CLR_PANEL="\e[38;5;12m"
CLR_TITLE="\e[1;38;5;15m"
CLR_WARN="\e[38;5;11m"
CLR_ERR="\e[38;5;9m"
CLR_OK="\e[38;5;10m"
CLR_SUB="\e[38;5;243m"
CLR_BOLD="\e[1m"
CLR_NC="\e[0m"

# ┌─── 2. Package Management Environment ───────────────────────────────────────┐

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

# ┌─── 3. Core Utility Functions ───────────────────────────────────────────────┐

die() {
  printf "%b%b[CRITICAL] %s%b\n" "${CLR_ERR}" "${CLR_BOLD}" "$1" "${CLR_NC}" >&2
  exit 1
}

has_command() {
  command -v "$1" &>/dev/null
}

render_banner() {
  local _text=" $1 "
  local _width=${#_text}
  local _hr
  _hr=$(printf '─%.0s' $(seq 1 "$_width"))

  printf "\n%b┌%s┐%b\n" "${CLR_PANEL}" "${_hr}" "${CLR_NC}"
  printf "%b│%b%b%s%b%b│%b\n" \
    "${CLR_PANEL}" "${CLR_NC}" "${CLR_TITLE}" "$_text" \
    "${CLR_NC}" "${CLR_PANEL}" "${CLR_NC}"
  printf "%b└%s┘%b\n" "${CLR_PANEL}" "${_hr}" "${CLR_NC}"
}

_check_requirements() {
  local _deps=(sudo python3 awk sed grep wc)
  for _tool in "${_deps[@]}"; do
    command -v "$_tool" &>/dev/null || die "Missing dependency: $_tool"
  done
}

ask() {
  local _prompt="$1"
  local _default="${2:-N}"
  local _choice_str="[y/N]"
  [[ "$_default" == "Y" ]] && _choice_str="[Y/n]"

  printf "%b%s %s:%b " "${CLR_WARN}" "$_prompt" "$_choice_str" "${CLR_NC}"
  read -r -n 1 _reply
  echo ""

  [[ -z "$_reply" ]] && _reply="$_default"
  [[ "$_reply" =~ ^[Yy]$ ]]
}

# ┌─── 4. Information & Networking ─────────────────────────────────────────────┐

require_network() {
  if ! ping -c 1 -W 1 archlinux.org &>/dev/null; then
    die "No internet connectivity."
  fi
}

check_arch_news() {
  require_network
  render_banner "ARCH LINUX NEWS"

  # [FIX] Escape sequence \x1b used to prevent SyntaxWarning in Python 3.12+
  python3 -c "
import urllib.request as r, xml.etree.ElementTree as x, ssl
try:
    with r.urlopen('https://archlinux.org/feeds/news/', timeout=3) as f:
        items = x.fromstring(f.read()).findall('./channel/item')[:3]
        for i in items:
            t = i.find('title').text
            d = i.find('pubDate').text[5:16]
            print(f'\x1b[38;5;243m[{d}]\x1b[0m \x1b[1m{t}\x1b[0m')
except Exception:
    print('News temporarily unavailable')
"
}

# ┌─── 5. Mirror Optimization ─────────────────────────────────────────────────┐

optimize_mirrors() {
  local _list="/etc/pacman.d/mirrorlist"
  local _tmp="/tmp/mirrorlist.new"
  local _backup="$_list.bak"
  local _countries='Estonia,Finland,Sweden,Germany'
  local _max_age_days=7

  render_banner "MIRROR OPTIMIZATION"

  if [[ -f "$_list" ]]; then
    local _age_days=$((($(date +%s) - $(stat -c %Y "$_list")) / 86400))
    if ((_age_days < _max_age_days)); then
      printf "%bMirrors updated %d days ago. Update anyway?%b " "${CLR_SUB}" "$_age_days" "${CLR_NC}"
      if ! ask "" "N"; then return 0; fi
    fi
  fi

  if has_command reflector; then
    sudo reflector --country "$_countries" --latest 15 --protocol https \
      --sort rate --save "$_tmp" --threads "$(nproc)"
  elif has_command rate-mirrors; then
    rate-mirrors --save "$_tmp" arch
  else
    printf "%b[WARN] No optimization tools found.%b\n" "${CLR_WARN}" "${CLR_NC}"
    return 1
  fi

  # [WARN] Critical content validation before overwriting system files
  if [[ -f "$_tmp" ]] && grep -q "^Server =" "$_tmp"; then
    printf "%bApplying new mirrorlist...%b\n" "${CLR_OK}" "${CLR_NC}"
    sudo cp "$_list" "$_backup"
    sudo mv "$_tmp" "$_list"

    # [NOTE] Forced database sync is required after changing mirror origins
    printf "%bRefreshing package databases...%b\n" "${CLR_SUB}" "${CLR_NC}"
    sudo pacman -Syy
  else
    die "Generated mirrorlist is empty or invalid! Aborting to protect system."
  fi
}

# ┌─── 6. Data Integrity & Maintenance ─────────────────────────────────────────┐

smart_snapshot() {
  local _limit=5
  local _regex="[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}"

  has_command timeshift || return 0
  [[ ! -f /etc/timeshift/timeshift.json ]] && return 1

  render_banner "SYSTEM SNAPSHOT"

  # [NOTE] Displaying existing snapshots for user awareness
  printf "%bCurrent Snapshots:%b\n" "${CLR_SUB}" "${CLR_NC}"
  sudo timeshift --list 2>/dev/null | grep -E "^[0-9]+.*>.*" || echo "   (Empty)"

  if ask "Create pre-update snapshot?" "Y"; then
    local _comment
    _comment="Update-$(date +%Y%m%d-%H%M)"

    printf "%bCreating snapshot...%b\n" "${CLR_SUB}" "${CLR_NC}"

    # [FIX] Redirecting stderr to null to suppress Timeshift's internal status warnings
    sudo timeshift --create --comments "$_comment" --tags D 2>/dev/null

    # [NOTE] Manual retention policy to ensure storage space
    local _snaps
    mapfile -t _snaps < <(sudo timeshift --list --scripted 2>/dev/null | grep -oE "$_regex" | sort)

    if ((${#_snaps[@]} > _limit)); then
      local _to_del=$((${#_snaps[@]} - _limit))

      # [WARN] Verbosely notifying about old snapshot removal (Restored)
      printf "\n%bRetention policy: removing %d old snapshots...%b\n" "${CLR_WARN}" "$_to_del" "${CLR_NC}"

      for ((i = 0; i < _to_del; i++)); do
        printf "Deleting: %s ... " "${_snaps[i]}"

        if sudo timeshift --delete --snapshot "${_snaps[i]}" --scripted --yes &>/dev/null; then
          printf "%bOK%b\n" "${CLR_OK}" "${CLR_NC}"
        else
          printf "%bFAILED%b\n" "${CLR_ERR}" "${CLR_NC}"
        fi
      done

      local _rem=$((${#_snaps[@]} - _to_del))
      printf "%bStorage optimal (%d/%d retained).%b\n" "${CLR_OK}" "$_rem" "$_limit" "${CLR_NC}"
    fi
  fi
}

sys_cleanup() {
  render_banner "SYSTEM CLEANUP"

  if ask "Clean package cache?" "Y"; then
    if has_command paccache; then
      sudo paccache -rk2
    else
      # [NOTE] Fallback to standard manager if paccache (pacman-contrib) is missing
      $PKG_CMD -Sc
    fi
  fi

  if ask "Vacuum journals (>50M)?" "Y"; then
    sudo journalctl --vacuum-size=50M
  fi
}

# ┌─── 7. Diagnostics & Telemetry ──────────────────────────────────────────────┐

run_health_report() {
  render_banner "SYSTEM HEALTH"

  # 1. Systemd Integrity with detailed unit listing
  printf "%bChecking services...%b " "${CLR_PANEL}" "${CLR_NC}"
  local _failed
  _failed=$(systemctl --user --failed --quiet | grep "units listed" | awk '{print $1}')

  if [[ -n "$_failed" && "$_failed" != "0" ]]; then
    printf "%b[!] %s FAILED UNITS%b\n" "${CLR_ERR}" "$_failed" "${CLR_NC}"
    # [NOTE] Restored detailed output of failed units
    systemctl --user --failed --no-legend | awk '{print "  ➜ " $2}'
  else
    printf "%b[OK] Healthy%b\n" "${CLR_OK}" "${CLR_NC}"
  fi

  # 2. Storage checks
  local _usage
  _usage=$(df "$HOME" --output=pcent | tail -1 | tr -dc '0-9')
  printf "%bChecking storage...%b " "${CLR_PANEL}" "${CLR_NC}"
  if ((_usage > 90)); then
    printf "%b[!] %s%% (Critical)%b\n" "${CLR_ERR}" "$_usage" "${CLR_NC}"
  else
    printf "%b[OK] %s%% used%b\n" "${CLR_OK}" "$_usage" "${CLR_NC}"
  fi

  # 3. Kernel checks (Restored sudo access)
  printf "%bChecking kernel...%b  " "${CLR_PANEL}" "${CLR_NC}"
  local _kerrs
  _kerrs=$(sudo dmesg --level=err,crit,alert,emerg 2>/dev/null | wc -l)
  if ((_kerrs > 0)); then
    printf "%b[!] %d critical errors%b\n" "${CLR_WARN}" "$_kerrs" "${CLR_NC}"
  else
    printf "%b[OK] Healthy%b\n" "${CLR_OK}" "${CLR_NC}"
  fi
}
