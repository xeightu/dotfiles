#!/usr/bin/env bash

# ┌─── 1. Global Environment & Configuration ──────────────────────────────────┐

# [NOTE] Strict list of packages that trigger the 'urgent' (reboot) state
# Using word boundaries to avoid false matches like 'util-linux'
REBOOT_PKGS=(
  "linux" "linux-lts" "linux-zen" "linux-hardened"
  "nvidia" "nvidia-lts" "nvidia-dkms"
  "systemd" "glibc" "wayland" "mesa" "dbus" "cryptsetup"
)

# [NOTE] Formatting the list into a regex: \b(pkg1|pkg2|pkg3)\b
CRITICAL_REGEX="\b($(
  IFS='|'
  echo "${REBOOT_PKGS[*]}"
))\b"

# Icons for Waybar state
ICON_UPD="" # Standard updates
ICON_REB="󰚰" # Reboot/Critical updates

# ┌─── 2. Data Acquisition ────────────────────────────────────────────────────┐

# [NOTE] checkupdates is the safest way to probe sync databases without root
_repo_list=$(checkupdates 2>/dev/null)
_repo_count=$(echo "$_repo_list" | grep -c .) || _repo_count=0

# [NOTE] yay/paru used for AUR tracking
_aur_list=$(yay -Qua 2>/dev/null)
_aur_count=$(echo "$_aur_list" | grep -c .) || _aur_count=0

_total=$((_repo_count + _aur_count))

# ┌─── 3. Logic & State Detection ─────────────────────────────────────────────┐

_class="updates"
_icon="$ICON_UPD"

if ((_total > 0)); then
  # Check if any incoming package is in the critical list
  if echo "$_repo_list$_aur_list" | grep -iqE "$CRITICAL_REGEX"; then
    _icon="$ICON_REB"
    _class="urgent"
  fi

  if [[ ! -d "/usr/lib/modules/$(uname -r)" ]]; then
    _icon="$ICON_REB"
    _class="urgent"
    _reboot_pending="<b>[!] REBOOT REQUIRED: Kernel mismatch</b>\n\n"
  fi

  # ┌─── 4. Tooltip & JSON Construction ─────────────────────────────────────┐

  _tooltip="<b> Updates Available: $_total</b>\n\n"
  _tooltip+="${_reboot_pending}"

  [[ $_repo_count -gt 0 ]] && _tooltip+="<b>[Repos: $_repo_count]</b>\n$_repo_list\n\n"
  [[ $_aur_count -gt 0 ]] && _tooltip+="<b>[AUR: $_aur_count]</b>\n$_aur_list"

  _safe_tooltip=$(echo "$_tooltip" | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

  printf '{"text": "%s %d", "tooltip": "%s", "class": "%s"}\n' \
    "$_icon" "$_total" "$_safe_tooltip" "$_class"
else
  printf '{"text": "", "tooltip": "System is up to date", "class": "updated"}\n'
fi
