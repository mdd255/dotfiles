#!/usr/bin/env node
// Pick a Hubstaff project via the omarchy menu and switch to it.

const { execFileSync } = require('node:child_process');

const HUBSTAFF = '/usr/bin/hubstaff';

const notify = message => execFileSync('notify-send', ['-t', '2000', 'Hubstaff', message]);

function main() {
  execFileSync('omarchy', ['osd', '-i', '', '-m', 'Loading hubstaff projects', '-d', '500']);

  try {
    const { projects } = JSON.parse(execFileSync(HUBSTAFF, ['projects'], { encoding: 'utf8' }));

    // "<glyph>\t<label>\t<subtext>": two fields would read the name as the icon glyph.
    // The menu returns "<label>\t<subtext>", so the id rides along as the stable key.
    const options = projects.map(p => `󱄊\t${p.name}\t${p.id}`);
    let picked;
    try {
      picked = execFileSync(
        'omarchy-menu-select',
        ['Hubstaff project', ...options, '--', '--width', '520'],
        {
          encoding: 'utf8',
        },
      ).trim();
    } catch {
      return; // menu dismissed
    }

    const id = picked.split('\t').pop();
    execFileSync(HUBSTAFF, ['start_project', id]);
  } catch (err) {
    notify(`Error: ${err.message}`);
  }
}

main();
