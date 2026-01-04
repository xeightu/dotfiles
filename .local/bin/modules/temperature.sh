#!/bin/bash

for dir in /sys/class/hwmon/hwmon*; do
  if [ -f "$dir/name" ] && read -r name <"$dir/name"; then
    if [ "$name" = "k10temp" ]; then
      if [ -f "$dir/temp1_input" ] && read -r temp_raw <"$dir/temp1_input"; then
        temp_c=$((temp_raw / 1000))

        if [ "$temp_c" -ge 80 ]; then
          icon=""
        elif [ "$temp_c" -ge 60 ]; then
          icon=""
        else
          icon=""
        fi

        printf '{"text": "%s %d°C", "tooltip": "CPU Temperature (k10temp): %d°C"}\n' "$icon" "$temp_c" "$temp_c"
        exit 0
      fi
    fi
  fi
done

echo '{"text": " ??", "tooltip": "Sensor k10temp not found"}'
