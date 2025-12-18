#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │            INTERACTIVE MAINTENANCE MENU          │
# └──────────────────────────────────────────────────┘

source "$(dirname "$0")/syslib.sh"

while true; do
  clear
  print_header "SYSTEM MAINTENANCE  "
  echo " [1] System Update (Full Pipeline)"
  echo " [2] Update Mirrors (rate-mirrors/reflector)"
  echo " [3] Create Snapshot (Smart)"
  echo " [4] System Cleanup (Cache, Orphans, Flatpak)"
  echo " [5] Security Scans"
  echo " [6] Check Arch News"
  echo " [Q] Quit"
  echo ""
  read -p " Enter selection: " choice

  case "$choice" in
  1)
    "$(dirname "$0")/sysup.sh"
    continue
    ;;
  2) update_mirrors ;;
  3) create_snapshot ;;
  4) perform_cleanup ;;
  5) perform_scans ;;
  6) check_arch_news ;;
  [Qq]) break ;;
  *) echo -e "\n${C_RED}Invalid option.${C_NC}" ;;
  esac

  echo -e "\n${C_YELLOW}Press Enter to return to menu...${C_NC}"
  read -r
done
