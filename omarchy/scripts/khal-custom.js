#!/usr/bin/env node
// biome-ignore-all lint/suspicious/noConsole: we need it
const { formatEventTitle } = require('./calendar-utils');
const { execSync } = require('node:child_process');

function main() {
  try {
    const raw = execSync(
      'khal list --format "{calendar}:::{start-time} {title}" now eod',
    ).toString();

    let nextEvents = raw
      .split('\n')
      .filter(line => line.includes(':::'))
      .map(line => {
        const sep = line.indexOf(':::');
        const eventText = line.slice(sep + 3).trim();
        const title = formatEventTitle(eventText);
        const truncated = title.length > 50 ? title.slice(0, 35) : title;
        return truncated;
      })
      .filter(Boolean);

    nextEvents = Array.from(new Set(nextEvents.slice(0, 4))).join('   ') || '';
    nextEvents = nextEvents.length ? `${nextEvents}` : '[No event]';

    const payload = { text: nextEvents, tooltip: '' };
    console.log(JSON.stringify(payload));
  } catch (err) {
    console.log(JSON.stringify({ text: 'Khal error', tooltip: err.message }));
    execSync(`notify-send "khal-custom" "${err.message}"`);
  }
}

main();
