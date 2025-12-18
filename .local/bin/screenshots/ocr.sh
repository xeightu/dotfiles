#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │                 SCREENSHOT - OCR                 │
# └──────────────────────────────────────────────────┘
# [INFO] Updated to use the new capture engine.

# --- Main Logic ---
# [INFO] 1. Call the capture engine to get a temporary file path.
TMP_FILE=$(~/.local/bin/screenshots/_capture.sh)
trap 'rm -f "$TMP_FILE"' EXIT # [FIX] Ensure the temp file is deleted even if OCR fails.

# [INFO] 2. If a file was created, process it.
if [ -n "$TMP_FILE" ]; then
  # [INFO] 3. Preprocess and pipe the image to Tesseract for OCR.
  convert "$TMP_FILE" -scale 200% -colorspace Gray -normalize - |
    tesseract --oem 1 -l rus+eng stdin stdout |
    wl-copy &&
    notify-send "Text Copied" "Text from selected area has been copied." -i "edit-copy"
fi
