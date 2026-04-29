#!/usr/bin/env node

const { execSync } = require('node:child_process');

const CLI = '/home/dh/Hubstaff/HubstaffCLI.bin.x86_64';

try {
  const raw = execSync(`${CLI} status`, { encoding: 'utf8' });
  const status = JSON.parse(raw);
  const tracking = status.tracking;
  const project = status.active_project;
  const icon = tracking ? '󱄅' : '󱄊';
  const time = project?.tracked_today?.slice(0, 4) || '0:00';
  const text = tracking ? `${icon} ${time}  ` : `${icon}  `;
  const tooltip = tracking ? `Tracking: ${project.name}\nToday: ${time}` : 'Not tracking';
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
