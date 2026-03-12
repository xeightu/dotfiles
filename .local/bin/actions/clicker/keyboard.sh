#!/usr/bin/env bash

# ┌─── 1. Configuration & Constants ───────────────────────────────────────────┐

_pid_file="/tmp/clicker_keyboard.pid"

# [NOTE] Tick rate: 0.02s results in ~50Hz (approx 1300 CPM)
_sleep_time="0.02"

# ┌─── 2. Internal Helpers ────────────────────────────────────────────────────┐

# [NOTE] Verifies that the ydotool daemon is ready for IPC
_check_env() {
  if ! pgrep -x "ydotoold" >/dev/null; then
    notify-send "Automation" "Error: ydotoold not running" -u critical -i "error"
    exit 1
  fi
}

# [NOTE] Generates ydotool codes for QWERTY rows (Q-P, A-L, Z-M)
_generate_alpha_payload() {
  local _keys=""
  for _code in {16..25} {30..38} {44..50}; do
    _keys+="$_code:1 $_code:0 "
  done
  echo "$_keys"
}

# ┌─── 3. Execution Controller (Toggle) ───────────────────────────────────────┐

if [[ -f "$_pid_file" ]]; then
  _pid=$(<"$_pid_file")

  # [FIX] Aggressive termination: kill the child process and the parent loop
  # [NOTE] pkill -P targets the 'ydotool' command running inside the subshell
  pkill -P "$_pid" 2>/dev/null
  kill -9 "$_pid" 2>/dev/null
  rm -f "$_pid_file"

  notify-send "Automation" "Keyboard Clicker: OFF" -i "process-stop" -u low -t 800
  exit 0
fi

# ┌─── 4. Activation & Background Loop ────────────────────────────────────────┐

_check_env
_payload=$(_generate_alpha_payload)

# [WARN] Intensive keyboard simulation starts immediately
notify-send "Automation" "Keyboard Clicker: ON (Alpha)" -i "input-keyboard" -u critical -t 1000

(
  # [NOTE] Ensure the PID file is removed if the subshell is externally killed
  trap 'rm -f "$_pid_file"' EXIT INT TERM

  while true; do
    # [NOTE] Passing the entire row as unquoted arguments for word splitting
    # shellcheck disable=SC2086
    ydotool key $_payload 2>/dev/null || break
    sleep "$_sleep_time"
  done
) &

# Save the background subshell PID for the toggle logic
echo $! >"$_pid_file"
