#! /usr/bin/env node

const { execSync } = require('node:child_process');

try {
  execSync('fcitx5-remote -t');
  const currentInputMethod = execSync('fcitx5-remote -n');
  execSync(`notify-send -c narrow -t 500 Input ${currentInputMethod}`);
} catch (err) {
  execSync(`notify-send input 'Cannot switch input method: ${err.message}'`);
}
