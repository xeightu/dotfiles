#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │            Dunst Notification History            │
# └──────────────────────────────────────────────────┘

if ! command -v fzf &>/dev/null; then
  echo "Error: 'fzf' is not installed."
  read -p "Press Enter to exit..."
  exit 1
fi

HISTORY_DATA=$(dunstctl history -j | jq -r '.data[0] | reverse | .[] | "\(.appname.data) >> \(.summary.data) ;;\(.body.data)"')

if [ -z "$HISTORY_DATA" ]; then
  echo -e "\n   📭  No notification history found.\n"
  read -p "   Press Enter to close..."
  exit 0
fi

echo "$HISTORY_DATA" | fzf \
  --delimiter=';;' \
  --with-nth=1 \
  --preview='echo -e {2}' \
  --preview-window=down:40%:wrap \
  --border=rounded \
  --margin=1 \
  --header="ESC: Close | Enter: Copy Body" \
  --prompt="Search History > " \
  --bind "enter:execute(echo {2} | wl-copy)+abort"
