#!/usr/bin/env bash
set -euo pipefail

PIDFILE="/tmp/xbanish.pid"

if [[ -f "$PIDFILE" ]]; then
  pid=$(cat "$PIDFILE")
  if ps -p "$pid" -o comm= | grep -q '^xbanish$'; then
    kill "$pid"
    rm -f "$PIDFILE"
    notify-send "xbanish" "Cursor hiding disabled" -t 1000
    exit 0
  else
    rm -f "$PIDFILE" # stale PID
  fi
fi

# Start xbanish
if ! command -v xbanish >/dev/null; then
  notify-send "xbanish" "Not installed" -t 1000
  exit 1
fi

xbanish -a &
echo $! >"$PIDFILE"
notify-send "xbanish" "Cursor hiding enabled" -t 1000
