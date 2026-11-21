#!/usr/bin/env node
// Usage: reminder.js
//   CRUD picker over the built-in `omarchy reminder` (systemd user timers).
//   Add / List / Edit / Delete / Clear all.
const { spawnSync } = require('node:child_process');
const { rmSync } = require('node:fs');
const path = require('node:path');

const MSG_DIR = path.join(process.env.XDG_RUNTIME_DIR || '/tmp', 'omarchy-reminders');

const ACTIONS = ['Add', 'List', 'Edit', 'Delete', 'Clear all'];

const run = (cmd, args) => spawnSync(cmd, args, { encoding: 'utf8' });

// null when the menu was cancelled.
function select(prompt, options) {
  const r = run('omarchy-menu-select', [prompt, ...options, '--', '--width', '500']);
  const out = r.stdout.trim();

  return r.status === 0 && out ? out : null;
}

function input(prompt) {
  const r = run('omarchy-menu-input', [prompt, '--width', '400']);

  return r.status === 0 ? r.stdout.trim() : null;
}

const osd = msg => run('omarchy', ['osd', '-i', '󰢌', '-m', msg, '-d', '1500']);

function reminders() {
  try {
    return JSON.parse(run('omarchy-reminder', ['show', '--json']).stdout).reminders;
  } catch {
    return [];
  }
}

function pick(prompt) {
  const list = reminders();

  if (!list.length) {
    osd('No reminders');

    return null;
  }

  const labels = list.map((r, i) => `${i + 1}. ${r.atTime} (${r.remaining}) ${r.label}`);
  const chosen = select(prompt, labels);

  return chosen ? list[labels.indexOf(chosen)] : null;
}

function remove(r) {
  run('systemctl', ['--user', 'stop', r.timer, `${r.unit}.service`]);
  rmSync(path.join(MSG_DIR, `${r.unit}.message`), { force: true });
  run('omarchy-shell', ['-q', 'omarchy.indicators', 'refresh']);
}

function create(defaultMinutes, defaultMessage) {
  const minutes = input(`Remind in minutes${defaultMinutes ? ` (was ${defaultMinutes})` : ''}`);
  if (!minutes) return false;

  if (!/^[1-9]\d*$/.test(minutes)) {
    osd('Minutes must be a positive number');

    return false;
  }

  const message = input(`Message${defaultMessage ? ` (was: ${defaultMessage})` : ' (optional)'}`);
  if (message === null) return false;

  run('omarchy-reminder', [
    minutes,
    ...(message ? [message] : defaultMessage ? [defaultMessage] : []),
  ]);

  return true;
}

function main() {
  switch (select('Reminder', ACTIONS)) {
    case 'Add':
      return create();

    case 'List':
      return run('omarchy-reminder', ['show']);

    case 'Edit': {
      const r = pick('Edit reminder');
      if (!r) return;

      // Create the replacement first so cancelling mid-edit keeps the original.
      const before = new Set(reminders().map(x => x.unit));
      if (!create(r.minutes, r.message)) return;

      const added = reminders().some(x => !before.has(x.unit));
      if (added) remove(r);

      return;
    }

    case 'Delete': {
      const r = pick('Delete reminder');
      if (!r) return;
      remove(r);

      return osd('Reminder deleted');
    }

    case 'Clear all':
      return run('omarchy-reminder', ['clear']);
    default:
  }
}

main();
