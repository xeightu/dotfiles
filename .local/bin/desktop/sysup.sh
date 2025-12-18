#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │       INTERACTIVE UPDATE & SCAN PIPELINE         │
# └──────────────────────────────────────────────────┘

# --- Configuration ---
export PACMAN_LOG="/tmp/pacman_update.log"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/syslib.sh"

# --- Lock File Mechanism ---
LOCK_FILE="/tmp/system_update.lock"
if [ -f "$LOCK_FILE" ]; then
  OLD_PID=$(cat "$LOCK_FILE")
  if [ -n "$OLD_PID" ] && ps -p "$OLD_PID" >/dev/null 2>&1; then
    notify-send "System Update" "Already running (PID: $OLD_PID)." -u critical
    echo "Process already running."
    exit 1
  else
    echo "Removing stale lock file..."
    rm -f "$LOCK_FILE"
  fi
fi
echo $$ >"$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# --- Execution ---

print_header "PRE-UPDATE CHECKS"

# 1. Internet
if ! check_internet; then
  notify-send "System Update" "No internet connection" -u critical
  exit 1
fi

# 2. News
check_arch_news

# 3. Snapshot
create_snapshot

# 4. Mirrors
if ask_user "Update Mirrorlist?"; then
  update_mirrors
fi

# 5. Update
if ask_user "Start System Update (Pacman/Yay)?"; then
  sudo -v
  perform_update
else
  echo "Update skipped."
fi

# 6. Cleanup
if ask_user "Perform System Cleanup?"; then
  perform_cleanup
fi

# --- Finalization & Reboot Check ---

CRITICAL_REGEX="(linux|linux-lts|linux-zen|nvidia|systemd|wayland|mesa|intel-ucode|amd-ucode|linux-firmware|dkms)"
CRITICAL_COUNT=$(grep -E "upgraded $CRITICAL_REGEX" "$PACMAN_LOG" 2>/dev/null | wc -l)

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  notify-send "System Update" "Reboot required (Kernel/Drivers updated)." -u critical -i system-reboot
  printf "\n${C_RED}!!! CRITICAL UPDATES DETECTED (Kernel/Drivers) !!!${C_NC}\n"

  if ask_user "Reboot system now?"; then
    systemctl reboot
  fi
else
  notify-send "System Update" "Update complete." -u normal
  printf "\n${C_GREEN}System is up to date. No reboot required.${C_NC}\n"
fi

[ -f "$PACMAN_LOG" ] && sudo rm -f "$PACMAN_LOG"

echo -e "\n${C_BLUE}Done.${C_NC}"
read -p "Press Enter to exit..."
