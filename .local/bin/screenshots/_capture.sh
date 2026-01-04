#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │           SCREENSHOT - CAPTURE ENGINE            │
# └──────────────────────────────────────────────────┘
# [INFO] This is a library script. It is not meant to be called directly.
# [INFO] It handles the screen freeze, selection, and saves a cropped image to a temporary file.

# --- Initialization ---
# [CONFIG] Define temporary file paths.
TMP_FROZEN="/tmp/screenshot_frozen.png"
TMP_CROPPED="/tmp/screenshot_cropped_$(date +'%s').png"
trap 'rm -f "$TMP_FROZEN"' EXIT # [INFO] Clean up the full screenshot on exit.

# --- Main Logic ---
# [INFO] 1. Take a fullscreen shot to "freeze" the screen.
grim "$TMP_FROZEN"

# [INFO] 2. Start imv in background
imv -f "$TMP_FROZEN" &
IMV_PID=$!

# [FIX] Wait until imv actually appears in Hyprland clients list
# We check every 0.05s. Usually takes 1-2 checks.
TIMEOUT=20 # 1 second max (20 * 0.05)
COUNT=0
while ! hyprctl clients -j | jq -r '.[].class' | grep -q "imv"; do
  sleep 0.05
  ((COUNT++))
  if [ $COUNT -ge $TIMEOUT ]; then
    notify-send "Screenshot Error" "Overlay failed to launch."
    kill $IMV_PID
    exit 1
  fi
done

# [INFO] 3. Use 'slurp' to select the desired geometry.
GEOMETRY=$(slurp)
kill $IMV_PID

# [INFO] 4. If selection was cancelled, exit gracefully.
if [ -z "$GEOMETRY" ]; then
  exit 1
fi

# [INFO] 5. Convert slurp's output to a format 'convert' understands.
CROP_GEOMETRY=$(echo "$GEOMETRY" | sed -E 's/([0-9]+),([0-9]+) ([0-9]+x[0-9]+)/\3+\1+\2/')

# [INFO] 6. Crop the frozen screen image and save it to a new temporary file.
convert "$TMP_FROZEN" -crop "$CROP_GEOMETRY" "$TMP_CROPPED"

# [CRITICAL] Output the path to the final, cropped temporary file.
echo "$TMP_CROPPED"
