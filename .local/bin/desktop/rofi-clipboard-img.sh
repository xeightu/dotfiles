#!/usr/bin/env bash

# ┌─── 1. Environment & Cache ─────────────────────────────────────────────────┐

CACHE_DIR="/tmp/cliphist_thumbs"
mkdir -p "$CACHE_DIR"

# ┌─── 2. Data Processing & Formatting ────────────────────────────────────────┐

# [FIX] Using IFS=$'\t' is mandatory to preserve the ID-Content separator
cliphist list | while IFS=$'\t' read -r _id _content; do

  # --- Binary / Image Detection ---
  if [[ "$_content" == *"[[ binary data"* ]]; then
    _file="$CACHE_DIR/$_id.png"

    # [NOTE] Generate thumbnail only if it doesn't exist in cache
    if [[ ! -f "$_file" ]]; then
      # [FIX] printf ensures the exact tab character is sent to the decoder
      printf "%s\t%s" "$_id" "$_content" | cliphist decode >"$_file" 2>/dev/null

      # Validate generated file integrity
      if [[ ! -s "$_file" ]] || ! file "$_file" | grep -q "PNG"; then
        rm -f "$_file"
        _file=""
      fi
    fi

    # Inject Rofi metadata (\0icon\x1f) if image is valid
    if [[ -n "$_file" ]]; then
      echo -en "$_id\t$_content\0icon\x1f$_file\n"
    else
      echo -en "$_id\t$_content\n"
    fi
  else
    # --- Standard Text Entry ---
    echo -en "$_id\t$_content\n"
  fi

  # ┌─── 3. UI Layer & Execution ────────────────────────────────────────────────┐

done | rofi -dmenu -i -show-icons -p "Clipboard" \
  -theme-str "window {width: 800px;} element {padding: 10px;}" |
  cliphist decode | wl-copy
