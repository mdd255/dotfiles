#!/usr/bin/env node
// Usage: editor.js
//   Pick ~/Projects/<workspace>/<project>, open it in the best editor available:
//   neovide -> nvim (in terminal) -> vi (in terminal). Window app id is code-<workspace>-<project>,
//   so an already open project window is focused instead of launching another.
const { spawn, spawnSync } = require('node:child_process');
const { readdirSync } = require('node:fs');
const { homedir } = require('node:os');
const path = require('node:path');

const PROJECTS = path.join(homedir(), 'Projects');

const dirs = dir =>
  readdirSync(dir, { withFileTypes: true })
    .filter(d => d.isDirectory() && !d.name.startsWith('.'))
    .map(d => d.name)
    .sort();

// ~/Projects/<workspace>/<project> -> "workspace/project"
const projects = () =>
  dirs(PROJECTS).flatMap(ws => dirs(path.join(PROJECTS, ws)).map(p => `${ws}/${p}`));

const has = bin =>
  spawnSync('sh', ['-c', 'command -v "$1"', 'sh', bin], { stdio: 'ignore' }).status === 0;

// Command that opens `dir` with the app id `appId`.
function editorCmd(appId, dir) {
  if (has('neovide')) return ['neovide', '--wayland_app_id', appId, '--chdir', dir];

  const tui = has('nvim') ? 'nvim' : 'vi';

  return ['xdg-terminal-exec', `--app-id=${appId}`, `--dir=${dir}`, '--', tui, '.'];
}

const osd = msg => spawnSync('omarchy', ['osd', '-i', '󰈮', '-m', msg, '-d', '1500']);

function existingWindow(appId) {
  try {
    const out = spawnSync('hyprctl', ['clients', '-j'], { encoding: 'utf8' }).stdout;

    return JSON.parse(out).find(c => c.class === appId)?.address;
  } catch {
    return undefined;
  }
}

function main() {
  const list = projects();
  if (!list.length) return osd('No projects in ~/Projects/*');

  const picked = spawnSync(
    'omarchy-menu-select',
    ['Select Project', ...list, '--', '--width', '400'],
    {
      encoding: 'utf8',
    },
  );

  const name = picked.stdout.trim();
  if (picked.status !== 0 || !list.includes(name)) return;

  const appId = `code-${name.replace(/[^\w.-]/g, '-')}`;
  const addr = existingWindow(appId);

  if (addr) {
    spawnSync('hyprctl', ['dispatch', `hl.dsp.focus({ window = "address:${addr}" })`]);

    return;
  }

  const dir = path.join(PROJECTS, name);

  const [bin, ...args] = editorCmd(appId, dir);

  spawn(bin, args, {
    cwd: dir,
    detached: true,
    stdio: 'ignore',
  }).unref();
}

main();
