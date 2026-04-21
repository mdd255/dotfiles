#!/usr/bin/env node

const MONTH_NAMES = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const DAY_NAMES = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

function generateCalendar(numMonths = 3) {
  const now = new Date();
  const today = { year: now.getFullYear(), month: now.getMonth(), day: now.getDate() };
  let year = today.year;
  let month = today.month;

  const lines = [`     ${DAY_NAMES.join(' ')}`];

  for (let m = 0; m < numMonths; m++) {
    if (m > 0) lines.push('');

    const firstDow = (new Date(year, month, 1).getDay() + 6) % 7; // 0=Mo…6=Su
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    const slots = [
      ...Array(firstDow).fill(null),
      ...Array.from({ length: daysInMonth }, (_, i) => i + 1),
    ];
    while (slots.length % 7 !== 0) slots.push(null);

    for (let w = 0; w < slots.length / 7; w++) {
      const week = slots.slice(w * 7, w * 7 + 7);
      const prefix = w === 0 ? `${MONTH_NAMES[month]} ` : '    ';

      const cells = week.map(d => {
        if (d == null) return '  ';
        const isToday = year === today.year && month === today.month && d === today.day;
        return isToday ? ' ●' : String(d).padStart(2);
      });

      lines.push(prefix + cells.join(' '));
    }

    month++;
    if (month > 11) {
      month = 0;
      year++;
    }
  }

  return lines;
}

// Extract the right-column events from `khal calendar` output (position 29+),
// rejoining lines where khal wrapped a long title across a calendar grid row.
function extractEventLines(khalOutput) {
  const CAL_WIDTH = 29;
  const lines = [];

  for (const line of khalOutput.split('\n')) {
    const right = line.slice(CAL_WIDTH);

    if (right.trimStart().startsWith('|') && lines.length > 0) {
      lines[lines.length - 1] += ` ${right.trim()}`;
    } else {
      lines.push(right);
    }
  }

  while (lines.length > 0 && !lines[lines.length - 1].trim()) lines.pop();
  return lines;
}

function formatEventTitle(title, onlyTileFormat = false) {
  const formatedTitle = title
    .replaceAll('|', '')
    .replaceAll('Alpha Bravo Development', 'ABD')
    .replaceAll('Innovative Roofing', 'IRI')
    .replaceAll('&', '&amp;')
    .replaceAll(' Bor project', 'BOR');

  if (onlyTileFormat) return formatedTitle;

  return formatedTitle
    .replaceAll('[', '')
    .replaceAll(']', '')
    .replaceAll('-', '')
    .replaceAll('  ', ' ');
}

module.exports = { formatEventTitle, generateCalendar, extractEventLines };
