#!/bin/bash

# Repo updates (pacman)
repo_updates=$(checkupdates 2>/dev/null)
repo_count=$(echo "$repo_updates" | sed '/^\s*$/d' | wc -l)

# AUR updates
aur_updates=$(yay -Qua 2>/dev/null)
aur_count=$(echo "$aur_updates" | sed '/^\s*$/d' | wc -l)

total=$((repo_count + aur_count))

if [ "$total" -gt 0 ]; then
  tooltip=$(printf "Repo updates:\n%s\n\nAUR updates:\n%s" \
    "$repo_updates" "$aur_updates" |
    sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

  echo "{\"text\": \" $total\", \"tooltip\": \"$tooltip\"}"
else
  echo "{\"text\": \"\", \"tooltip\": \"System is up to date\"}"
fi
