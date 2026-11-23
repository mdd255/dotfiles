#! /usr/bin/env node

const { execSync } = require('node:child_process');

try {
  execSync('hyprctl switchxkblayout all next');
  const { keyboards } = JSON.parse(execSync('hyprctl devices -j').toString());
  const keyboard = keyboards.find(k => k.main) || keyboards[0];
  execSync(`omarchy osd -i keyboard -m "${keyboard.active_keymap}" -d 500`);
} catch (err) {
  execSync(`notify-send input 'Cannot switch keyboard layout: ${err.message}'`);
}
