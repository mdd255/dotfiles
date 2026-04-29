#!/usr/bin/env node

const { execSync } = require('node:child_process');

execSync('hyprctl dispatch movecursortocorner 2');

const pos = execSync('hyprctl cursorpos');

const [x, y] = pos.split(',').map(Number);

execSync(`hyprctl dispatch movecursor ${x - 20} ${y + 20}`);
execSync('ydotool click 0xC0');
