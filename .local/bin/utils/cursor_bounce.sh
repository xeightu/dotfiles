#!/bin/bash

PIDFILE="/tmp/cursor_bouncer.pid"
X1=1192
Y1=398
X2=884
Y2=441
DELAY=0.04

if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    rm "$PIDFILE"
    notify-send "AutoCursor" "Выключен 🛑"
    exit 0
  else
    rm "$PIDFILE"
  fi
fi

echo $$ >"$PIDFILE"
notify-send "AutoCursor" "Включен 🟢"

move_absolute() {
  TX=$1
  TY=$2

  hyprctl dispatch movecursor -9999 -9999
  hyprctl dispatch movecursor $TX $TY
}

while true; do
  move_absolute $X1 $Y1
  sleep $DELAY

  move_absolute $X2 $Y2
  sleep $DELAY
done
