#!/usr/bin/env node
// Usage: editor.js
//   Pick a project (any dir under a root, up to 3 levels deep, containing .git), open it in the best editor available:
//   neovide -> nvim (in terminal) -> vi (in terminal). Window app id is code-<workspace>-<project>,
//   so an already open project window is focused instead of launching another.
const { spawn, spawnSync } = require('node:child_process');
const { existsSync, readdirSync } = require('node:fs');
const { homedir } = require('node:os');
const path = require('node:path');

// Roots to search: PROJECT_DIRS (colon-separated, ~ allowed), default ~/Projects.
const ROOTS = (process.env.PROJECT_DIRS || '~/Projects:~/.config')
  .split(':')
  .filter(Boolean)
  .map(r => path.resolve(r.replace(/^~(?=$|\/)/, homedir())));

const dirs = dir =>
  readdirSync(dir, { withFileTypes: true })
    .filter(d => d.isDirectory() && d.name !== 'node_modules')
    .map(d => d.name)
    .sort();

const MAX_DEPTH = 3;
const MIN_WIDTH = 300;

// A project is any dir holding a .git entry. Dirs without one are containers: search inside them.
// Returns absolute paths.
function findProjects(dir, depth = 0) {
  if (depth >= MAX_DEPTH) return [];

  let names;

  try {
    names = dirs(dir);
  } catch {
    return [];
  }

  return names.flatMap(name => {
    const child = path.join(dir, name);

    return existsSync(path.join(child, '.git')) ? [child] : findProjects(child, depth + 1);
  });
}

// label -> absolute path. Label is relative to its root; on a clash it becomes the ~-abbreviated path.
function projects() {
  const map = new Map();
  const clashes = new Set();
  const seen = new Set();

  // Roots may overlap (e.g. ~ and ~/Projects): keep each project once, from the first root that finds it.
  const found = ROOTS.flatMap(root =>
    findProjects(root).map(abs => ({ abs, rel: path.relative(root, abs) })),
  ).filter(({ abs }) => !seen.has(abs) && seen.add(abs));

  for (const { rel } of found) if (found.filter(f => f.rel === rel).length > 1) clashes.add(rel);

  for (const { abs, rel } of found) {
    const label = clashes.has(rel) ? abs.replace(homedir(), '~') : rel;
    map.set(label, abs);
  }

  return map;
}

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
  const map = projects();
  const list = [...map.keys()];

  if (!list.length) return osd('No git projects found');

  // Menu width fits the longest entry: ~10px per char plus padding, never below MIN_WIDTH.
  const width = Math.max(MIN_WIDTH, Math.max(...list.map(p => p.length)) * 10 + 100);

  const picked = spawnSync(
    'omarchy-menu-select',
    ['Select Project', ...list, '--', '--width', String(width)],
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

  const dir = map.get(name);
  const [bin, ...args] = editorCmd(appId, dir);

  spawn(bin, args, {
    cwd: dir,
    detached: true,
    stdio: 'ignore',
  }).unref();
}

main();
