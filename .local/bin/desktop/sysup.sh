#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │                    Automated Update Pipeline                               │
# └────────────────────────────────────────────────────────────────────────────┘

source "$(dirname "$(realpath "$0")")/syslib.sh"

trap 'echo ""; read -p "Press Enter to exit..."' EXIT

# --- Lock Mechanism ---
LOCK_FILE="/tmp/system_update.lock"
if [ -f "$LOCK_FILE" ]; then
  printf "%b[ERROR] Update is already running!%b\n" "${C_RED}" "${C_NC}"
  exit 1
fi
echo $$ >"$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"; echo ""; read -p "Press Enter to exit..."' EXIT

# --- Execution Flow ---

banner "PRE-UPDATE CHECKS"
if ! require_network; then exit 1; fi

check_news
smart_snapshot
optimize_mirrors

if ask "Start System Update?"; then
  sys_update
fi

if ask "Run System Cleanup?"; then
  sys_cleanup
fi

# --- Reboot Logic (System Log Analysis) ---
CRITICAL_REGEX="(linux|nvidia|systemd|wayland|mesa|intel-ucode|amd-ucode)"

# [FIX] Read the REAL system log instead of a temp file.
# We verify if any critical package was upgraded in the last 100 log entries.
if tail -n 100 /var/log/pacman.log | grep -E "\[ALPM\] upgraded $CRITICAL_REGEX" &>/dev/null; then
  printf "\n%b[CRITICAL] Kernel/Drivers updated.%b\n" "${C_RED}" "${C_NC}"
  if ask "Reboot now?"; then
    systemctl reboot
  fi
else
  printf "\n%bSystem up to date.%b\n" "${C_GREEN}" "${C_NC}"
fi
