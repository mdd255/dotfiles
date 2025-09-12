#!/usr/bin/env bash

PIDFILE="/tmp/xbanish.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "xbanish" "Cursor hiding disabled" -t 1000
else
    /usr/bin/xbanish -a &
    echo $! > "$PIDFILE"
    notify-send "xbanish" "Cursor hiding enabled" -t 1000
fi
