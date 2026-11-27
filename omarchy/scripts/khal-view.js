#!/usr/bin/env node
// biome-ignore-all lint/suspicious/noConsole: we need it
// Bar click opens a floating terminal (matched by Hyprland on its app-id) that
// runs this same script with --print, then closes on any key or after 15s.
const { spawn, spawnSync } = require('node:child_process');
const { formatEventTitle, generateCalendar } = require('./calendar-utils');

const APP_ID = 'dh.calendar';
const CAL_COL = 28;

const visualLength = str => str.replace(/<[^>]+>/g, '').length;

// Pango-style <span color="#rrggbb"> markup -> 24-bit ANSI.
const toAnsi = str =>
  str
    .replace(
      /<span color="#(..)(..)(..)">/g,
      (_, r, g, b) => `\x1b[38;2;${parseInt(r, 16)};${parseInt(g, 16)};${parseInt(b, 16)}m`,
    )
    .replaceAll('</span>', '\x1b[0m')
    .replaceAll('&amp;', '&');

// "start:::end:::[Org] Title" -> "start - end [Org] Title"; other lines (day headers) pass through.
function formatLine(line) {
  const m = line.match(/^\s*(.*?):::(.*?):::(.*)$/);
  if (!m) return formatEventTitle(line);
  const [, start, end, title] = m;
  const org = title.match(/^\s*\[(.*?)\]\s*(.*)$/);
  const label = org ? `[${formatEventTitle(org[1]).trim()}] ${formatEventTitle(org[2]).trim()}` : formatEventTitle(title).trim();
  return `${start} - ${end} ${label}`;
}

function print() {
  const raw = spawnSync('khal', ['list', '--notstarted', '--format', '{start-time}:::{end-time}:::{title}'], { encoding: 'utf8' }).stdout;
  const calendar = generateCalendar(3);
  const events = [...new Set(raw.split('\n').map(formatLine))];

  const rows = Array.from({ length: Math.max(calendar.length, events.length) }, (_, i) => {
    const cal = calendar[i] ?? '';
    const event = (events[i] ?? '').trimEnd();
    return event ? `${cal + ' '.repeat(Math.max(0, CAL_COL - visualLength(cal)))}  ${event}` : cal;
  });

  console.log(`\n${toAnsi(rows.join('\n'))}`);
}

function open() {
  spawn(
    'uwsm-app',
    [
      '--',
      'xdg-terminal-exec',
      `--app-id=${APP_ID}`,
      '-e',
      'bash',
      '-c',
      `node "${__filename}" --print; read -rsn1 -t 15`,
    ],
    { detached: true, stdio: 'ignore' },
  ).unref();
}

process.argv.includes('--print') ? print() : open();
