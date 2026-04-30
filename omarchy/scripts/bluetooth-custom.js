#!/usr/bin/env node
/** biome-ignore-all lint/suspicious/noConsole: really need this */

const { execSync } = require('node:child_process');

function main() {
  try {
    const devicesRaw = execSync('bluetoothctl devices Connected | grep mdd').toString().trim();

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
      const info = execSync(`bluetoothctl info ${mac}`).toString();

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
  } catch {
    console.log(JSON.stringify({ text: '' }));
  }
}

main();
