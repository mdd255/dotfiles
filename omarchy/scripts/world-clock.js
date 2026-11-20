#!/usr/bin/env node
// biome-ignore-all lint/suspicious/noConsole: we need it
// Usage: world-clock.js LABEL=Zone/Name [LABEL=Zone/Name ...]
const args = process.argv.slice(2);

const ZONES = args.length
  ? args.map(a => {
      const [label, tz] = a.split('=');
      return { label, tz };
    })
  : [{ label: 'NYC', tz: 'America/New_York' }];

const fmt = tz =>
  new Intl.DateTimeFormat('en-GB', {
    timeZone: tz,
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(new Date());

const text = ZONES.map(z => `${z.label} ${fmt(z.tz)}`).join('  ');
const tooltip = ZONES.map(z => `${z.label} (${z.tz}): ${fmt(z.tz)}`).join('\n');
console.log(JSON.stringify({ text, tooltip }));
