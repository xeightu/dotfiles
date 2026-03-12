#!/usr/bin/env bash

# ┌─── 1. Global Environment ──────────────────────────────────────────────────┐

# [NOTE] Resolve absolute path to ensure the library is sourced correctly
_script_dir="$(dirname "$(realpath "$0")")"

if [[ -f "$_script_dir/syslib.sh" ]]; then
  source "$_script_dir/syslib.sh"
else
  echo "Error: syslib.sh not found in $_script_dir" >&2
  exit 1
fi

LOCK_FILE="/tmp/sysup.lock"
LOG_FILE="/var/log/pacman.log"

# [NOTE] Precise package names prevent false positives like 'util-linux'
REBOOT_PKGS_CORE=("linux" "linux-lts" "linux-zen" "linux-hardened" "linux-firmware")
REBOOT_PKGS_DRV=("nvidia" "nvidia-lts" "nvidia-dkms" "mesa" "vulkan-icd-loader")
REBOOT_PKGS_SYS=("systemd" "glibc" "dbus" "openssl" "pam" "wayland" "hyprland")
REBOOT_PKGS_BOOT=("grub" "mkinitcpio" "dracut" "efibootmgr" "cryptsetup")

# [NOTE] Combine all arrays into one before joining with '|' to avoid spaces in regex
_all_reboot_pkgs=("${REBOOT_PKGS_CORE[@]}" "${REBOOT_PKGS_DRV[@]}" "${REBOOT_PKGS_SYS[@]}" "${REBOOT_PKGS_BOOT[@]}")
REBOOT_PKG_REGEX="\b($(
  IFS='|'
  echo "${_all_reboot_pkgs[*]}"
))\b"

# ┌─── 2. Process Safety & Execution Guards ───────────────────────────────────┐

_check_requirements() {
  local _deps=(sudo python3 awk sed grep wc)
  for _tool in "${_deps[@]}"; do
    command -v "$_tool" &>/dev/null || die "Missing dependency: $_tool"
  done
}

_acquire_lock() {
  exec 9>>"$LOCK_FILE"

  if ! flock -n 9; then
    die "Update is already running."
  fi
}

_cleanup_trap() {
  # [WARN] Revoke sudo token on exit to prevent unauthorized session reuse
  sudo -k
}

trap _cleanup_trap EXIT INT TERM

# ┌─── 3. Reboot Analysis ─────────────────────────────────────────────────────┐

analyze_reboot_necessity() {
  local _log_start_line="$1"
  local _update_detected=0

  # [NOTE] Arch Linux removes old kernel modules immediately after update;
  # failing to reboot will break new module loading for the current session.
  if [[ -f "$LOG_FILE" ]]; then
    # Use -w for word-regexp matching as an extra safety layer
    local _changes
    _changes=$(sudo tail -n +"$((_log_start_line + 1))" "$LOG_FILE" | grep -E "\[ALPM\] upgraded $REBOOT_PKG_REGEX")

    if [[ -n "$_changes" ]]; then
      _update_detected=1
      printf "\n%b%b[CRITICAL] Core components updated:%b\n" "${CLR_BOLD}" "${CLR_WARN}" "${CLR_NC}"
      echo "$_changes" | awk '{print "   ➜ " $4}'
    fi
  fi

  if [[ $_update_detected -eq 1 ]]; then
    # [WARN] Delaying reboot after kernel/systemd updates may lead to system instability
    if ask "A reboot is recommended. Reboot now?" "Y"; then
      systemctl reboot
    fi
  else
    printf "\n%bSystem updated successfully. No reboot required.%b\n" "${CLR_OK}" "${CLR_NC}"
  fi
}

# ┌─── 4. Main Execution Pipeline ─────────────────────────────────────────────┐

main() {
  _check_requirements
  _acquire_lock
  require_network
  # [NOTE] Capture log state before transaction for post-update delta analysis
  local _initial_log_line
  _initial_log_line=$(sudo cat "$LOG_FILE" 2>/dev/null | wc -l)
  _initial_log_line=${_initial_log_line:-0}
  check_arch_news
  smart_snapshot
  render_banner "SYSTEM UPDATE"
  if ask "Start full system update via Topgrade?" "Y"; then
    if has_command topgrade; then
      topgrade
      _tg_res=$?

      if [[ $_tg_res -eq 1 ]]; then
        printf "\n%b[NOTE] Update sequence was interrupted or skipped by user.%b\n" "${CLR_WARN}" "${CLR_NC}"
      elif [[ $_tg_res -ne 0 ]]; then
        die "Topgrade failed with exit code $_tg_res."
      fi
    else
      $PKG_CMD -Syu || die "Package manager execution failed. Aborting."
    fi
  else
    printf "\n%bUpdate cancelled by user.%b\n" "${CLR_WARN}" "${CLR_NC}"
    exit 0
  fi
  analyze_reboot_necessity "$_initial_log_line"
  printf "\n%bPress Enter to exit...%b" "${CLR_SUB}" "${CLR_NC}"
  read -r
}

main
