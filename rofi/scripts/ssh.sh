#!/bin/bash
ssh $(cat ~/.config/rofi/scripts/ssh-hosts | rofi -dmenu -i -p "SSH: " | awk '{ print $NF }')
