#!/usr/bin/env node
const { formatEventTitle } = require('./calendar-utils');
const { execSync } = require('node:child_process');

const CALENDAR_COLORS = {
  abd: '#6bcbff',
  aa: '#606060',
  mdd: '#c5c5c5',
};

try {
  const raw = execSync('khal list --format "{calendar}:::{start-time} {title}" now eod').toString();

  let nextEvents = raw
    .split('\n')
    .filter(line => line.includes(':::'))
    .map(line => {
      const sep = line.indexOf(':::');
      const cal = line.slice(0, sep).trim();
      const eventText = line.slice(sep + 3).trim();
      const title = formatEventTitle(eventText);
      const truncated = title.length > 50 ? title.slice(0, 35) : title;
      const color = CALENDAR_COLORS[cal] ?? '#ffffff';
      return `<span color="${color}">${truncated}</span>`;
    })
    .filter(Boolean);

  nextEvents = Array.from(new Set(nextEvents)).join(' | ') || '';
  nextEvents = nextEvents.length ? `󱑑 ${nextEvents}` : '󱑑 [No event for today]';

  const payload = { text: nextEvents, tooltip: '' };
  console.log(JSON.stringify(payload));
} catch (err) {
  console.log(JSON.stringify({ text: '󱑑 khal error', tooltip: err.message }));
  try {
    execSync(`notify-send "khal-custom" ${JSON.stringify('Error: ' + err.message)}`);
  } catch {}
}
