#!/usr/bin/env bash

# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

_langs="rus+eng"
_scale="200%"

# ┌─── 2. Dependencies Check ──────────────────────────────────────────────────┐

# [NOTE] Ensure all pipeline components are present to avoid silent failures
_deps=("hyprshot" "convert" "tesseract" "wl-copy")

for _tool in "${_deps[@]}"; do
  if ! command -v "$_tool" &>/dev/null; then
    notify-send "OCR Error" "Missing dependency: $_tool" -u critical
    exit 1
  fi
done

# ┌─── 3. OCR Pipeline ────────────────────────────────────────────────────────┐

# [NOTE] Process: Capture raw region -> Pre-process image -> Tesseract -> Clipboard
# [NOTE] Upscaling and normalizing the image significantly improves recognition accuracy
hyprshot -m region --freeze --silent --raw |
  convert - \
    -scale "$_scale" \
    -colorspace Gray \
    -normalize - |
  tesseract --oem 1 -l "$_langs" stdin stdout 2>/dev/null |
  wl-copy

# ┌─── 4. Validation & Notification ───────────────────────────────────────────┐

# Verify if text was captured by checking the clipboard buffer
if [[ -n "$(wl-paste)" ]]; then
  notify-send "OCR" "Text extracted to clipboard" -i "edit-paste"
else
  # [WARN] Triggered by empty selection, pipeline interrupt, or unreadable fonts
  notify-send "OCR Error" "Extraction failed: No text recognized" -u critical -i "error"
fi
