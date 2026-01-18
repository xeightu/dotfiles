#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │ INTERACTIVE MAINTENANCE DASHBOARD                                          │
# └────────────────────────────────────────────────────────────────────────────┘

# [INFO] Resolve absolute path to load library safely
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/syslib.sh"

# ┌─── Interface Logic ────────────────────────────────────────────────────────┐

pause() {
  echo ""
  printf "%bPress Enter to return to menu...%b" "${C_GREY}" "${C_NC}"
  read -r
}

show_menu() {
  clear
  banner "SYSTEM MAINTENANCE"

  # [VISUAL] Grid alignment for readability
  # Option 1 delegates to the Hybrid Pipeline (sysup.sh)
  printf " %b[1]%b  System Update %b(Auto-Pilot)%b\n" "${C_BLUE}" "${C_NC}" "${C_GREY}" "${C_NC}"

  echo ""

  # Options 2-6 delegate to granular bash functions in syslib.sh
  printf " %b[2]%b  Update Mirrors\n" "${C_BLUE}" "${C_NC}"
  printf " %b[3]%b  Create Snapshot\n" "${C_BLUE}" "${C_NC}"
  printf " %b[4]%b  System Cleanup\n" "${C_BLUE}" "${C_NC}"
  printf " %b[5]%b  Security Scans\n" "${C_BLUE}" "${C_NC}"
  printf " %b[6]%b  Arch Linux News\n" "${C_BLUE}" "${C_NC}"

  echo ""
  printf " %b[Q]%b  Quit\n" "${C_RED}" "${C_NC}"
  echo ""
}

# ┌─── Main Loop ──────────────────────────────────────────────────────────────┐

while true; do
  show_menu

  read -r -p " Select option: " choice
  echo ""

  case "$choice" in
  1)
    # [EXEC] Hand over control to the main pipeline
    "$SCRIPT_DIR/sysup.sh"
    ;;
  2)
    optimize_mirrors
    pause
    ;;
  3)
    smart_snapshot
    pause
    ;;
  4)
    sys_cleanup
    pause
    ;;
  5)
    sys_security
    pause
    ;;
  6)
    check_news
    pause
    ;;
  [Qq])
    clear
    break
    ;;
  *)
    printf "%bInvalid option selected.%b\n" "${C_RED}" "${C_NC}"
    sleep 1
    ;;
  esac
done
