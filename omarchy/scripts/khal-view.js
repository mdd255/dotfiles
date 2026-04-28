#!/usr/bin/env node
const { spawnSync } = require('node:child_process');
const { formatEventTitle, generateCalendar, extractEventLines } = require('./calendar-utils');

function padEndVisual(str, width) {
  const visual = str.replace(/<[^>]+>/g, '').length;
  return str + ' '.repeat(Math.max(0, width - visual));
}

function main() {
  try {
    const raw = spawnSync('khal', ['calendar', '--notstarted'], { encoding: 'utf8' }).stdout;
    const calLines = generateCalendar(3);
    const eventLines = Array.from(new Set(extractEventLines(raw).map(e => formatEventTitle(e))));

    const CAL_COL = 28;
    const maxLines = Math.max(calLines.length, eventLines.length);
    const lines = [];

    for (let i = 0; i < maxLines; i++) {
      const cal = padEndVisual(calLines[i] ?? '', CAL_COL);
      const event = (eventLines[i] ?? '').trimEnd();
      lines.push(event ? `${cal}  ${event}` : cal.trimEnd());
    }

    const body = lines.join('\n');

    spawnSync('notify-send', ['-t', '7000', '-a', 'calendar', 'Event', body]);
  } catch (err) {
    spawnSync('notify-send', [
      '-t',
      '7000',
      '-c',
      'reminder',
      '-a',
      'calendar',
      'Event',
      err.message,
    ]);
  }
}

main();
