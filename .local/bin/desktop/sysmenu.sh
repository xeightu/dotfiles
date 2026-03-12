#!/usr/bin/env bash

# ┌─── 1. Global Environment & Initialization ─────────────────────────────────┐

# [NOTE] Ensure absolute path resolution for library sourcing
_script_dir="$(dirname "$(realpath "$0")")"

if [[ -f "$_script_dir/syslib.sh" ]]; then
  source "$_script_dir/syslib.sh"
else
  echo "Error: syslib.sh not found in $_script_dir" >&2
  exit 1
fi

# [NOTE] Pre-flight validation of system dependencies defined in syslib
_check_requirements

# ┌─── 2. Interface Logic ─────────────────────────────────────────────────────┐

_pause() {
  printf "\n%bPress Enter to return to menu...%b" "${CLR_SUB}" "${CLR_NC}"
  read -r
}

_render_menu() {
  clear
  render_banner "SYSTEM MAINTENANCE"

  # [NOTE] Primary automated pipeline
  printf " %b[1]%b  System Update %b(Auto-Pilot)%b\n" "${CLR_PANEL}" "${CLR_NC}" "${CLR_SUB}" "${CLR_NC}"
  echo ""

  # [NOTE] Granular maintenance modules for manual intervention
  printf " %b[2]%b  Update Mirrors\n" "${CLR_PANEL}" "${CLR_NC}"
  printf " %b[3]%b  Create Snapshot\n" "${CLR_PANEL}" "${CLR_NC}"
  printf " %b[4]%b  System Cleanup\n" "${CLR_PANEL}" "${CLR_NC}"
  printf " %b[5]%b  Security Audit\n" "${CLR_PANEL}" "${CLR_NC}"
  printf " %b[6]%b  Arch Linux News\n" "${CLR_PANEL}" "${CLR_NC}"
  printf " %b[7]%b  System Health Check\n" "${CLR_PANEL}" "${CLR_NC}"

  echo ""
  printf " %b[Q]%b  Quit\n" "${CLR_ERR}" "${CLR_NC}"
  echo ""
}

# ┌─── 3. Main Event Loop ─────────────────────────────────────────────────────┐

while true; do
  _render_menu

  printf " Select option: "
  read -r _choice
  echo ""

  case "$_choice" in
  1)
    # [NOTE] Execution transfer to the sequential update pipeline
    if [[ -x "$_script_dir/sysup.sh" ]]; then
      "$_script_dir/sysup.sh"
    else
      die "sysup.sh not found or not executable"
    fi
    _pause
    ;;

  2)
    optimize_mirrors
    _pause
    ;;

  3)
    smart_snapshot
    _pause
    ;;

  4)
    sys_cleanup
    _pause
    ;;

  5)
    # [WARN] Security audit may require elevated privileges for deep inspection
    run_security_audit
    _pause
    ;;

  6)
    check_arch_news
    _pause
    ;;

  7)
    run_health_report
    _pause
    ;;

  [Qq])
    clear
    # [NOTE] Graceful exit from the maintenance environment
    break
    ;;

  *)
    printf "%bInvalid option: %s%b\n" "${CLR_ERR}" "$_choice" "${CLR_NC}"
    sleep 1
    ;;
  esac
done
