#!/usr/bin/env bash

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

PID_FILE="/tmp/cursor_bouncer.pid"
DELAY=0.04

# ┌─── 2. Environment & Safety ────────────────────────────────────────────────┐

_terminate() {
  # [NOTE] Prevent signal recursion during shutdown
  trap - SIGINT SIGTERM

  if [[ -f "$PID_FILE" ]]; then
    local _pid
    _pid=$(cat "$PID_FILE" 2>/dev/null)
    if [[ -n "$_pid" && "$_pid" != "$$" ]]; then
      # [FIX] Aggressive kill to ensure the background loop stops immediately
      pkill -P "$_pid" 2>/dev/null
      kill -9 "$_pid" 2>/dev/null
      notify-send "Automation" "Cursor Bouncer: Stopped" -i "process-stop" -u low
    fi
    rm -f "$PID_FILE"
  fi
  exit 0
}

_check_env() {
  local _deps=("slurp" "hyprctl")
  for _tool in "${_deps[@]}"; do
    if ! command -v "$_tool" &>/dev/null; then
      notify-send "Automation" "Error: $_tool missing" -i "dialog-error" -u critical
      exit 1
    fi
  done
}

# ┌─── 3. Point Acquisition ───────────────────────────────────────────────────┐

_capture_points() {
  notify-send "Automation" "Select points (Press ESC to finish)" -i "input-mouse"
  local _captured=()

  while true; do
    local _raw
    # [NOTE] slurp -p returns single point coordinates
    _raw=$(slurp -p 2>/dev/null) || break

    # [FIX] Strip potential WxH metadata to get clean X,Y
    local _clean
    _clean=$(echo "$_raw" | cut -d" " -f1)
    _captured+=("$_clean")
    echo "Point registered: $_clean"
  done

  if [[ ${#_captured[@]} -eq 0 ]]; then
    _terminate
  fi

  _POINTS=("${_captured[@]}")
}

# ┌─── 4. Execution Loop ──────────────────────────────────────────────────────┐

_execute() {
  notify-send "Automation" "Bouncer: Active" -i "input-mouse" -u critical

  while true; do
    for _point in "${_POINTS[@]}"; do
      local _tx _ty
      IFS="," read -r _tx _ty <<<"$_point"

      # [NOTE] Hyprland coordinate hack:
      # Force cursor to extreme top-left before applying absolute target
      # coordinates to ensure consistent placement.
      hyprctl dispatch movecursor -10000 -10000 >/dev/null
      hyprctl dispatch movecursor "$_tx" "$_ty" >/dev/null

      sleep "$DELAY"
    done
  done
}

# ┌─── 5. Entry Point ─────────────────────────────────────────────────────────┐

# [NOTE] Toggle logic: kill existing session if running, otherwise start new
[[ -f "$PID_FILE" ]] && _terminate

_check_env
echo $$ >"$PID_FILE"
trap _terminate SIGINT SIGTERM

_capture_points
_execute
