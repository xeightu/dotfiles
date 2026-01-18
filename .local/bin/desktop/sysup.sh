#!/usr/bin/env bash
# ┌────────────────────────────────────────────────────────────────────────────┐
# │ AUTOMATED UPDATE PIPELINE                                                  │
# └────────────────────────────────────────────────────────────────────────────┘

# [INFO] Resolve absolute path to load library safely
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/syslib.sh"

# ┌─── Configuration ──────────────────────────────────────────────────────────┐

LOCK_FILE="/tmp/sysup.lock"
LOG_FILE="/var/log/pacman.log"

# [CONFIG] Regex for packages requiring reboot
# Includes kernel, microcode, systemd, and filesystem drivers
CRITICAL_REGEX="(linux|nvidia|systemd|wayland|mesa|.*-ucode|linux-firmware|cryptsetup|btrfs-progs)"

# ┌─── Process Safety ─────────────────────────────────────────────────────────┐

acquire_lock() {
  if [[ -f "$LOCK_FILE" ]]; then
    local pid
    pid=$(cat "$LOCK_FILE")

    # [CHECK] Is the process actually alive?
    if ps -p "$pid" >/dev/null 2>&1; then
      die "Update is already running (PID: $pid)"
    else
      # [FIX] Stale lock detected
      rm -f "$LOCK_FILE"
    fi
  fi
  echo $$ >"$LOCK_FILE"
}

cleanup_trap() {
  sudo -k # [SEC] Revoke sudo token
  rm -f "$LOCK_FILE"
}
trap cleanup_trap EXIT INT TERM

# ┌─── Logic: Reboot Analysis ─────────────────────────────────────────────────┐

analyze_reboot() {
  [[ ! -f "$LOG_FILE" ]] && return

  # [LOGIC] Compare log size before/after update
  # $START_LINE is captured in main()
  local changes
  changes=$(tail -n +$((START_LINE + 1)) "$LOG_FILE" | grep -E "\[ALPM\] upgraded $CRITICAL_REGEX")

  if [[ -n "$changes" ]]; then
    printf "\n%b[CRITICAL] Core components updated:%b\n" "${C_RED}" "${C_NC}"

    # [VISUAL] Format output nicely
    echo "$changes" | awk '{print "   " $4 " " $5}' | sed 's/upgraded//'
    echo ""

    if ask "Reboot system now?" "Y"; then
      systemctl reboot
    fi
  else
    printf "\n%bSystem up to date. No reboot required.%b\n" "${C_GREEN}" "${C_NC}"
  fi
}

# ┌─── Main Execution ─────────────────────────────────────────────────────────┐

main() {
  # 1. Initialization
  acquire_lock
  require_network

  # [HACK] Capture log position *before* any transaction
  START_LINE=$(wc -l <"$LOG_FILE" 2>/dev/null || echo 0)

  # 2. Intelligence Layer (Bash)
  # Tasks that Topgrade cannot perform interactively
  check_news
  smart_snapshot

  # 3. Execution Layer (Rust/Topgrade)
  # Topgrade handles: Mirrors, Updates, Cleanup
  banner "SYSTEM UPDATE"
  if ask "Start full system update?" "Y"; then
    topgrade
  else
    echo ""
    printf "%b[INFO] Update skipped by user.%b\n" "${C_YELLOW}" "${C_NC}"
    exit 0
  fi

  # 4. Analysis Layer (Bash)
  analyze_reboot

  echo ""
  read -r -p "Press Enter to exit..."
}

main
