#!/usr/bin/env bash

# ┌─── 1. Configuration & Constants ───────────────────────────────────────────┐

# [NOTE] Resolve absolute path to ensure sub-scripts are found regardless of CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTER_PID="/tmp/clicker_master.pid"

# Mapping of automation modules to their respective script arguments
declare -A TARGETS=(
  ["left"]="mouse.sh left"
  ["right"]="mouse.sh right"
  ["middle"]="mouse.sh middle"
  ["keyboard"]="keyboard.sh"
)

# ┌─── 2. Internal Process Management ─────────────────────────────────────────┐

# [NOTE] Aggressive cleanup logic to ensure all child processes are terminated
_kill_module() {
  local _type="$1"
  local _pid_file="/tmp/clicker_${_type}.pid"

  if [[ -f "$_pid_file" ]]; then
    local _pid
    _pid=$(<"$_pid_file")
    # [FIX] Kill children (ydotool) and the parent loop shell
    pkill -P "$_pid" 2>/dev/null
    kill -9 "$_pid" 2>/dev/null
    rm -f "$_pid_file"
  fi
}

# ┌─── 3. Execution Controller (Master Toggle) ────────────────────────────────┐

if [[ -f "$MASTER_PID" ]]; then
  # --- Global Deactivation ---
  for _type in "${!TARGETS[@]}"; do
    _kill_module "$_type"
  done

  rm -f "$MASTER_PID"
  notify-send "Automation" "Master Controller: OFF" -i "process-stop" -u low -t 1000
else
  # --- Global Activation ---

  # [NOTE] Pre-flight cleanup ensures we start from a clean state without duplicates
  for _type in "${!TARGETS[@]}"; do
    _kill_module "$_type"
  done

  # Spawn all registered modules in background
  for _key in "${!TARGETS[@]}"; do
    read -r _script _arg <<<"${TARGETS[$_key]}"
    _full_path="$SCRIPT_DIR/$_script"

    if [[ -x "$_full_path" ]]; then
      "$_full_path" "$_arg" >/dev/null 2>&1 &
    else
      notify-send "Automation" "Error: Module $_script not found" -u critical -i "error"
    fi
  done

  touch "$MASTER_PID"
  notify-send "Automation" "Master Controller: ALL ON" -i "weather-storm" -u critical -t 1000
fi
