#!/usr/bin/env node
// Runs the combat sandbox's built-in rules checks (runChecks in the page's script) in node.
// Usage: node tabletop/sandbox/run_checks.js [path/to/combat-sandbox.html]
// Prints one line per check and a summary; exits 1 if any check fails or the script cannot run.
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const page = process.argv[2] || path.join(__dirname, 'combat-sandbox.html');

// The page's own script: the inline <script> that holds runChecks.
function pageScript(html) {
  const re = /<script>([\s\S]*?)<\/script>/g;
  let m;
  while ((m = re.exec(html))) if (m[1].includes('function runChecks')) return m[1];
  throw new Error(`No inline <script> with runChecks in ${page}`);
}

function main() {
  const src = pageScript(fs.readFileSync(page, 'utf8'));
  // No DOM: the page only touches `document` and `window` inside start(), which runs when `document` exists.
  const context = vm.createContext({ console });
  vm.runInContext(`${src}\n;globalThis.__results = runChecks();`, context, { filename: path.basename(page) });
  const results = context.__results;
  if (!Array.isArray(results) || !results.length) throw new Error('runChecks returned no results');
  let failed = 0;
  for (const r of results) {
    if (!r.pass) failed++;
    console.log(`${r.pass ? 'PASS' : 'FAIL'}  ${r.name}${r.detail && !r.pass ? `  (${r.detail})` : ''}`);
  }
  console.log(`\n${results.length - failed}/${results.length} rules checks pass`);
  return failed ? 1 : 0;
}

try {
  process.exitCode = main();
} catch (e) {
  console.error(`Could not run the sandbox checks: ${e.stack || e}`);
  process.exitCode = 1;
}
