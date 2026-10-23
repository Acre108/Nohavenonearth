// Applies @@@OLD/@@@NEW/@@@END blocks to a file; each OLD must occur exactly once.
// An empty replacement can be written as "@@@NEW\n@@@END".
// Then converts relative years (Y−N) to absolute years, with the present at 2186.
const fs = require("fs");
const [, , target, editsFile] = process.argv;
let src = fs.readFileSync(target, "utf8");
const raw = fs.readFileSync(editsFile, "utf8").replace(/\r\n/g, "\n");
const blocks = raw.split("@@@OLD\n").slice(1);
let failed = 0;
blocks.forEach((b, i) => {
  const m = b.match(/^([\s\S]*?)\n@@@NEW\n([\s\S]*?)\n?@@@END/);
  if (!m) { console.error(`Edit ${i + 1}: malformed block`); failed++; return; }
  const [, oldPart, newPart] = m;
  const count = src.split(oldPart).length - 1;
  if (count !== 1) {
    console.error(`Edit ${i + 1}: expected 1 match, found ${count}\n  ${oldPart.slice(0, 120)}`);
    failed++;
    return;
  }
  src = src.replace(oldPart, () => newPart);
});
if (failed) { console.error(`${failed} edit(s) failed; nothing written.`); process.exit(1); }
let years = 0;
src = src.replace(/Y−(\d+)/g, (_, n) => { years++; return String(2186 - Number(n)); });
if (src.includes("Y−")) { console.error("Relative years remain."); process.exit(1); }
fs.writeFileSync(target, src);
console.log(`Applied ${blocks.length} edits; converted ${years} relative years.`);
