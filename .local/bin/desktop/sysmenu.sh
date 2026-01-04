#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │                       Interactive Maintenance Menu                         │
# └────────────────────────────────────────────────────────────────────────────┘

script_dir="$(dirname "$0")"
source "$script_dir/syslib.sh"

while true; do
  clear
  banner "SYSTEM MAINTENANCE"

  echo " [1] System Update (Full Pipeline)"
  echo " [2] Update Mirrors"
  echo " [3] Create Snapshot"
  echo " [4] System Cleanup"
  echo " [5] Security Scans"
  echo " [6] Arch News"
  echo " [Q] Quit"
  echo ""

  read -r -p " Enter selection: " choice

  case "$choice" in
  1)
    "$script_dir/sysup.sh"
    continue
    ;;
  2) optimize_mirrors ;;
  3) smart_snapshot ;;
  4) sys_cleanup ;;
  5) sys_security ;;
  6) check_news ;;
  [Qq]) break ;;
  *) echo -e "\n${C_RED}Invalid option.${C_NC}" ;;
  esac

  echo -e "\n${C_YELLOW}Press Enter to return to menu...${C_NC}"
  read -r
done
