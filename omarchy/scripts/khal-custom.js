#!/usr/bin/env node
// biome-ignore-all lint/suspicious/noConsole: we need it
const { formatEventTitle } = require('./calendar-utils');
const { execSync } = require('node:child_process');

const MAX_EVENT_LEN = 24;
const MAX_TOTAL_LEN = 40;
const SEP = '   ';

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
        return title.length > MAX_EVENT_LEN
          ? `${title.slice(0, MAX_EVENT_LEN - 1)}…`
          : title;
      })
      .filter(Boolean);

    const unique = Array.from(new Set(nextEvents));
    const shown = [];
    let len = 0;

    for (const ev of unique) {
      const add = ev.length + (shown.length ? SEP.length : 0);
      if (shown.length && len + add > MAX_TOTAL_LEN) break;
      shown.push(ev);
      len += add;
    }

    const hidden = unique.length - shown.length;
    nextEvents = shown.join(SEP);
    if (hidden > 0) nextEvents += `${SEP}+${hidden}`;
    if (!nextEvents) nextEvents = '[No event]';

    const payload = { text: nextEvents, tooltip: unique.join('\n') };
    console.log(JSON.stringify(payload));
  } catch (err) {
    console.log(JSON.stringify({ text: 'Khal error', tooltip: err.message }));
    execSync(`notify-send "khal-custom" "${err.message}"`);
  }
}

main();
