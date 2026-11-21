#!/usr/bin/env node
// biome-ignore-all lint/suspicious/noConsole: we need it
// Usage: vpn.js status | toggle
//   status  bar JSON (text/tooltip/class) for current OpenVPN state
//   toggle  down if running; else pick ~/Projects/*/client.ovpn via omarchy menu, connect, report via OSD
const { spawnSync } = require('node:child_process');
const { existsSync, readdirSync } = require('node:fs');
const { homedir } = require('node:os');
const path = require('node:path');

const PROJECTS = path.join(homedir(), 'Projects');
const PID_FILE = '/run/openvpn-dh.pid';
const LOG_FILE = '/tmp/openvpn-dh.log';

const profiles = () =>
  readdirSync(PROJECTS, { withFileTypes: true })
    .filter(d => d.isDirectory() && existsSync(path.join(PROJECTS, d.name, 'client.ovpn')))
    .map(d => d.name)
    .sort();

// Running openvpn started by us: parse its --config arg for the profile name.
function running() {
  const out = spawnSync('pgrep', ['-a', '-x', 'openvpn'], { encoding: 'utf8' }).stdout;
  const line = out.split('\n').find(l => l.includes('client.ovpn'));
  if (!line) return null;
  const cfg = line.match(/--config\s+(\S+)/)?.[1] ?? '';
  return path.basename(path.dirname(cfg)) || 'vpn';
}

function tunIp() {
  const out = spawnSync('ip', ['-4', '-br', 'addr'], { encoding: 'utf8' }).stdout;
  const line = out.split('\n').find(l => l.startsWith('tun'));
  return line?.trim().split(/\s+/)[2]?.split('/')[0] ?? null;
}

function status() {
  const name = running();

  if (!name) {
    console.log(
      JSON.stringify({ text: '󰦞', tooltip: 'VPN: disconnected', class: 'disconnected' }),
    );

    return;
  }

  const ip = tunIp();

  console.log(
    JSON.stringify(
      ip
        ? { text: ` ${name}`, tooltip: `VPN: ${name}\nIP: ${ip}`, class: 'connected' }
        : { text: ` ${name}…`, tooltip: `VPN: ${name} (connecting)`, class: 'connecting' },
    ),
  );
}

const osd = msg => spawnSync('omarchy', ['osd', '-i', '󰦝', '-m', msg, '-d', '1500']);

// pkexec shows a graphical polkit prompt only when auth is needed; no terminal.
function down() {
  const rc = spawnSync('pkexec', ['pkill', '-x', 'openvpn']).status;
  osd(rc === 0 ? 'VPN disconnected' : 'VPN stop failed');
}

function up(profile) {
  const cfg = path.join(PROJECTS, profile, 'client.ovpn');
  osd(`VPN connecting: ${profile}`);

  const rc = spawnSync('pkexec', [
    'openvpn',
    '--config',
    cfg,
    '--cd',
    path.dirname(cfg),
    '--daemon',
    '--writepid',
    PID_FILE,
    '--log',
    LOG_FILE,
  ]).status;

  if (rc !== 0) return osd('VPN start failed');

  for (let i = 0; i < 40; i++) {
    if (tunIp()) return osd(`VPN connected: ${profile}`);
    spawnSync('sleep', ['0.5']);
  }

  osd('VPN connect timed out');
}

function toggle() {
  if (running()) return down();
  const list = profiles();
  if (!list.length) return osd('No client.ovpn in ~/Projects/*');

  const picked = spawnSync('omarchy-menu-select', ['Select VPN', ...list, '--', '--width', '400'], {
    encoding: 'utf8',
  });

  const profile = picked.stdout.trim();
  if (picked.status === 0 && profile) up(profile);
}

if (process.argv[2] === 'toggle') toggle();
else status();
