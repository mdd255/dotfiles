#!/bin/bash
function unmute() {
   amixer -q set Master unmute
   amixer -q set Headphone unmute
   amixer -q set Speaker unmute
  notify-send "Volume control" "Unmute" --expire-time=1000
}

function mute() {
   amixer -q set Master mute
   notify-send "Volume control" "Mute" --expire-time=1000
}

unmuteVal=$(amixer get Master | grep "\[on\]" | wc -l)

if [ $unmuteVal -gt 0 ]
   then
      mute
   else
      unmute
fi
