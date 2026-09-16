#!/usr/bin/env node
// biome-ignore-all lint/suspicious/noConsole: we need console here

const { execSync } = require('node:child_process');

const CLI = '/home/dh/Hubstaff/HubstaffCLI.bin.x86_64';

try {
  const raw = execSync(`${CLI} status`, { encoding: 'utf8' });
  const status = JSON.parse(raw);
  const tracking = status.tracking;
  const project = status.active_project;
  const label = tracking ? project?.name ?? '(unknown project)' : '󱄊';
  const time = project?.tracked_today?.slice(0, 4) || '0:00';
  const text = tracking ? `${label} - ${time} ` : `${label} `;
  const tooltip = tracking ? `Tracking: ${label}\nToday: ${time}` : 'Not tracking';
  const cls = tracking ? 'tracking' : 'idle';

  console.log(JSON.stringify({ text, tooltip, class: cls }));
} catch (err) {
  console.log(
    JSON.stringify({
      text: `󱄊  ${err.message}`,
      tooltip: 'Hubstaff not running',
      class: 'err',
    }),
  );
}
