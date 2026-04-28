#!/usr/bin/env node
/** biome-ignore-all lint/suspicious/noConsole: really need this */

const { execSync } = require('node:child_process');

function run(cmd) {
  return execSync(cmd, { encoding: 'utf8' }).trim();
}

function main() {
  // Get connected devices
  const devicesRaw = run('bluetoothctl devices Connected | grep mdd');
  const batteryLevels = ['󰁺', '󰁻', '󰁼', '󰁽', '󰁾', '󰁿', '󰂀', '󰂁', '󰂂', '󰁹'];

  if (!devicesRaw) {
    return console.log(JSON.stringify({ text: '' }));
  }

  const devices = devicesRaw.split('\n');
  let output = '';

  for (const device of devices) {
    const parts = device.split(' ');
    const mac = parts[1];
    const name = parts.slice(2).join(' ');
    let info;

    try {
      info = run(`bluetoothctl info ${mac}`);
    } catch {
      continue;
    }

    const batteryPercentMatch = info.match(/Battery Percentage:\s+(0x[0-9a-fA-F]+)/);
    output += `󰂯 ${name} `;

    if (batteryPercentMatch) {
      const hex = batteryPercentMatch[1];
      const batteryPercent = parseInt(hex, 16);
      const batteryIdx = Math.min(Math.max(Math.floor(batteryPercent / 10), 1), 10);
      output += `${batteryLevels[batteryIdx - 1]}  `;
    }
  }

  console.log(JSON.stringify({ text: output }));
}

main();
