#!/bin/bash
# ┌───────────────────────────────────┐
# │    WAYBAR - SMART WINDOW TITLE    │
# └───────────────────────────────────┘

update_title() {
  ACTIVE_WINDOW_INFO=$(hyprctl activewindow -j)
  WINDOW_CLASS=$(echo "$ACTIVE_WINDOW_INFO" | jq -r '.class')

  if [ "$WINDOW_CLASS" = "null" ] || [ -z "$WINDOW_CLASS" ]; then
    echo ""
  else
    WINDOW_TITLE=$(echo "$ACTIVE_WINDOW_INFO" | jq -r '.title')
    FINAL_TEXT="$WINDOW_TITLE"

    case "$WINDOW_CLASS" in
    "kitty") FINAL_TEXT="Kitty" ;;
    "obsidian") FINAL_TEXT="Obsidian" ;;
    "com.ayugram.desktop") FINAL_TEXT="AyuGram" ;;
    "zen") FINAL_TEXT="Zen Browser" ;;
    "discord") FINAL_TEXT="Discord" ;;
    "spotify") FINAL_TEXT="Spicetify" ;;
    "steam") FINAL_TEXT="Steam" ;;
    "thunar") FINAL_TEXT="Thunar" ;;
    esac

    jq -n -c --arg text "$FINAL_TEXT" '{"text": $text}'
  fi
}

update_title

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
  if [[ "$line" == "activewindow>>"* ]]; then
    update_title
  fi
done
