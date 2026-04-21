#!/usr/bin/env node

function formatEventTitle(title) {
  return (
    title
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll('-', '')
      .replaceAll('|', '')
      .replaceAll('  ', ' ')
      .replaceAll('&', '&amp;')
      // Special cases
      .replaceAll('Alpha Bravo Development', 'ABD')
      .replaceAll('Innovative Roofing', 'IRI')
      .replaceAll('Bor project', 'BOR')
  );
}

module.exports = { formatEventTitle };
