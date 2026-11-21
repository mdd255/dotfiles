#!/usr/bin/env node
// Usage: browser.js [url...]
//   Pick a profile of the default (Chromium-family) browser via omarchy menu, then launch it.
//   Non-Chromium default browser: launch it as-is, no picker.
const { spawn, spawnSync } = require('node:child_process');
const { existsSync, readFileSync, writeFileSync } = require('node:fs');
const { homedir } = require('node:os');
const path = require('node:path');

// binary name -> user-data dir under ~/.config
const CHROMIUM_DIRS = {
  chromium: 'chromium',
  'google-chrome-stable': 'google-chrome',
  'google-chrome': 'google-chrome',
  'brave-browser': 'BraveSoftware/Brave-Browser',
  brave: 'BraveSoftware/Brave-Browser',
  'microsoft-edge-stable': 'microsoft-edge',
  vivaldi: 'vivaldi',
  'vivaldi-stable': 'vivaldi',
};

// Hyprland can't tell Chromium profiles apart (same pid/class/title), so remember
// which window each profile opened through us and focus it next time.
const STATE = path.join(process.env.XDG_RUNTIME_DIR || '/tmp', 'browser-profiles.json');

const run = (cmd, args) => spawnSync(cmd, args, { encoding: 'utf8' }).stdout.trim();

function desktopFile(id) {
  const dirs = [
    path.join(homedir(), '.local/share/applications'),
    '/usr/local/share/applications',
    '/usr/share/applications',
  ];

  return dirs.map(d => path.join(d, id)).find(existsSync);
}

// First Exec= line, minus field codes (%U etc.).
function defaultBrowserCmd() {
  const id = run('xdg-settings', ['get', 'default-web-browser']);
  const file = id && desktopFile(id);
  if (!file) return null;

  const exec = readFileSync(file, 'utf8').match(/^Exec=(.+)$/m)?.[1];
  if (!exec) return null;

  return exec
    .replace(/%[a-zA-Z]/g, '')
    .trim()
    .split(/\s+/);
}

function chromiumProfiles(bin) {
  const dir = CHROMIUM_DIRS[path.basename(bin)];
  if (!dir) return null;

  try {
    const state = JSON.parse(
      readFileSync(path.join(homedir(), '.config', dir, 'Local State'), 'utf8'),
    );

    return Object.entries(state.profile.info_cache).map(([id, p]) => ({ id, name: p.name || id }));
  } catch {
    return null;
  }
}

function launch(cmd, extra) {
  spawn(cmd[0], [...cmd.slice(1), ...extra], { detached: true, stdio: 'ignore' }).unref();
}

function clients() {
  try {
    return JSON.parse(run('hyprctl', ['clients', '-j']));
  } catch {
    return [];
  }
}

function readState() {
  try {
    return JSON.parse(readFileSync(STATE, 'utf8'));
  } catch {
    return {};
  }
}

const sleep = s => spawnSync('sleep', [String(s)]);

// Launch, then record the window that appeared (or that got focus) for this profile.
function launchTracked(cmd, profile, urls) {
  const state = readState();
  const key = `${path.basename(cmd[0])}:${profile.id}`;
  const before = new Set(clients().map(c => c.address));
  const cls = path.basename(cmd[0]).split('-')[0];
  const isBrowser = c => c.class.toLowerCase().includes(cls);

  launch(cmd, [`--profile-directory=${profile.id}`, ...urls]);

  for (let i = 0; i < 20; i++) {
    sleep(0.15);
    const win = clients().find(c => !before.has(c.address) && isBrowser(c));

    if (win) {
      state[key] = win.address;
      writeFileSync(STATE, JSON.stringify(state));

      return;
    }
  }

  // No new window: existing window got a new tab and focus.
  try {
    const active = JSON.parse(run('hyprctl', ['activewindow', '-j']));
    const owned = Object.entries(state).some(([k, a]) => a === active.address && k !== key);

    if (active.address && isBrowser(active) && !owned) {
      state[key] = active.address;
      writeFileSync(STATE, JSON.stringify(state));
    }
  } catch {}
}

function main() {
  const urls = process.argv.slice(2);
  const cmd = defaultBrowserCmd();

  if (!cmd) {
    spawnSync('omarchy', ['osd', '-i', '󰖟', '-m', 'No default browser', '-d', '1500']);
    process.exit(1);
  }

  const profiles = chromiumProfiles(cmd[0]);
  if (!profiles?.length) return launch(cmd, urls);

  let profile = profiles[0];

  if (profiles.length > 1) {
    const labels = profiles.map(p => p.name).sort();

    const picked = spawnSync(
      'omarchy-menu-select',
      ['Select Browser Profile', ...labels, '--', '--width', '400'],
      {
        encoding: 'utf8',
      },
    );

    const name = picked.stdout.trim();
    profile = profiles.find(p => p.name === name);
    if (picked.status !== 0 || !profile) return;
  }

  const addr = readState()[`${path.basename(cmd[0])}:${profile.id}`];

  if (!urls.length && addr && clients().some(c => c.address === addr)) {
    spawnSync('hyprctl', ['dispatch', `hl.dsp.focus({ window = "address:${addr}" })`]);

    return;
  }

  launchTracked(cmd, profile, urls);
}

main();
