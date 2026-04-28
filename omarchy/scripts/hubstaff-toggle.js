#!/usr/bin/env node

const { execSync } = require('node:child_process');

const CLI = '/home/dh/Hubstaff/HubstaffCLI.bin.x86_64';

function main() {
  try {
    const raw = execSync(`${CLI} status`, { encoding: 'utf8' }).trim();
    const status = JSON.parse(raw);
    status.tracking ? execSync(`${CLI} stop`) : execSync(`${CLI} start`);
  } catch (err) {
    run(`notify-send -t 2000 "Hubstaff" "Error: ${err.message}"`);
  }
}

main();
