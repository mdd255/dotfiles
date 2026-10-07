#! /usr/bin/env node

const { execSync } = require('node:child_process');

try {
  execSync('fcitx5-remote -t');
  const currentInputMethod = execSync('fcitx5-remote -n').toString().trim();
  execSync(`omarchy osd -i keyboard -m "${currentInputMethod}" -d 500`);
} catch (err) {
  execSync(`notify-send input 'Cannot switch input method: ${err.message}'`);
}
