#!/bin/bash
vi "$(cat ~/.config/rofi/scripts/dotfiles | rofi -dmenu -i -p "Dotfile: " | awk '{ print $NF }')"
