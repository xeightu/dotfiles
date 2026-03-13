#!/usr/bin/env bash

# ┌─── 1. Configuration & Initial Guards ──────────────────────────────────────┐

# [FIX] Immediate exit if source image is missing or hyprshot was aborted
if [[ -z "$1" || ! -f "$1" ]]; then
  exit 1
fi

readonly TMP_FILE="$1"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
_sorted_dir="$SCREENSHOT_DIR/$(date +'%Y-%m')"

# Menu Labels
OPT_COPY="  Copy"
OPT_SAVE_AS="  Save As"
OPT_SAVE_QUICK="  Quick Save"
OPT_EDIT="  Edit"
OPT_DELETE="  Delete"

# UI Settings
ROFI_CMD="rofi -dmenu -i -fixed-num-lines true -theme-str"
# [NOTE] Focused UI geometry for post-capture action selector
THEME_BASE="window {width: 240px;} listview {lines: 5;} entry {enabled: false;} element {children: [\"element-text\"];} element-text {horizontal-align: 0.0;}"

# ┌─── 2. Interactive Selection ───────────────────────────────────────────────┐

mkdir -p "$_sorted_dir"

_options="$OPT_COPY\n$OPT_SAVE_AS\n$OPT_SAVE_QUICK\n$OPT_EDIT\n$OPT_DELETE"
_choice=$(echo -e "$_options" | $ROFI_CMD "$THEME_BASE" -p "Capture")

# ┌─── 3. Action Handling ─────────────────────────────────────────────────────┐

case "$_choice" in
"$OPT_COPY")
  wl-copy --type image/png <"$TMP_FILE"
  # [WARN] Delete volatile buffer file immediately after successful copy
  rm "$TMP_FILE"
  notify-send "Screenshot" "Copied to clipboard" -i "dialog-information" -t 2000
  ;;

"$OPT_EDIT")
  # [NOTE] Pass execution to Satty for annotations and final saving
  satty --filename "$TMP_FILE" --output-filename "$_sorted_dir/$(date +'%H-%M-%S').png"
  rm "$TMP_FILE"
  ;;

"$OPT_SAVE_QUICK")
  _target="$(date +'%Y-%m-%d_%H-%M-%S').png"
  mv "$TMP_FILE" "$_sorted_dir/$_target"
  notify-send "Screenshot" "Saved: $_target" -i "folder-screenshots" -t 2000
  ;;

"$OPT_SAVE_AS")
  # [NOTE] Spawn an input-only Rofi box for custom filename entry
  _input=$(echo "" | $ROFI_CMD "window {width: 400px;} listview {lines: 0;}" -p "Filename")

  # Sanitize input: replace unsafe filesystem characters with underscores
  _safe_name="${_input//[^a-zA-Z0-9._-]/_}"
  [[ -z "$_safe_name" ]] && _safe_name="capture_$(date +%s)"

  mv "$TMP_FILE" "$_sorted_dir/${_safe_name}.png"
  notify-send "Screenshot" "Saved: ${_safe_name}.png" -i "folder-screenshots" -t 2000
  ;;

"$OPT_DELETE" | *)
  # [NOTE] Catch-all handles both explicit Delete and ESC/Abort
  rm -f "$TMP_FILE"
  ;;
esac
