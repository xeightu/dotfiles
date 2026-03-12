#!/usr/bin/env bash

# ┌─── 1. Sensor Discovery & Parsing ──────────────────────────────────────────┐

# [NOTE] Specifically targeting k10temp driver for AMD CPU monitoring
for _dir in /sys/class/hwmon/hwmon*; do
  if [[ -f "$_dir/name" ]]; then
    read -r _name <"$_dir/name"

    if [[ "$_name" == "k10temp" ]]; then
      if [[ -f "$_dir/temp1_input" ]]; then
        read -r _temp_raw <"$_dir/temp1_input"
        _temp_c=$((_temp_raw / 1000))

        # ┌─── 2. Icon Logic & UI Output ──────────────────────────────┐

        if ((_temp_c >= 80)); then
          _icon=""
        elif ((_temp_c >= 60)); then
          _icon=""
        else
          _icon=""
        fi

        # [NOTE] Output JSON structure for Waybar compatibility
        printf '{"text": "%s %d°C", "tooltip": "CPU Temperature: %d°C"}\n' \
          "$_icon" "$_temp_c" "$_temp_c"
        exit 0
      fi
    fi
  fi
done

# ┌─── 3. Fallback ────────────────────────────────────────────────────────────┐

# [NOTE] Triggered if the k10temp module is not loaded or path differs
echo '{"text": " ??", "tooltip": "Sensor k10temp not found"}'
