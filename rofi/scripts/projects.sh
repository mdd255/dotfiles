#!/bin/bash
vi "$(ls -d ~/Projects/*/* | rofi -dmenu -i -p "Project: ")"
