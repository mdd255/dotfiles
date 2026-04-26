#!/usr/bin/env node

import { execSync } from 'node:child_process';

const CLI = '/home/dh/Hubstaff/HubstaffCLI.bin.x86_64';

function run(cmd) {
  return execSync(cmd, { encoding: 'utf8' }).trim();
}

try {
  const raw = run(`${CLI} status`);
  const status = JSON.parse(raw);

  if (status.tracking) {
    run(`${CLI} stop`);
  } else {
    run(`${CLI} resume`);
  }
} catch (err) {
  run(`notify-send -t 2000 "Hubstaff" "Error: ${err.message}"`);
}
