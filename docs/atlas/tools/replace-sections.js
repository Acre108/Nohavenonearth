// Replaces whole "### <heading>" sections in a Markdown brief file, and optionally inserts new text before an anchor.
// Sections file format:
//   @@@SECTION <exact heading text after "### ">   (replace that section with the body that follows)
//   @@@BEFORE <exact anchor line>                   (insert the body that follows before the anchor's first occurrence)
//   ...body...
//   @@@END
// A section runs from its heading to the next "### " heading or "---" rule. CRLF files keep CRLF.
const fs = require("fs");
const [, , target, sectionsFile] = process.argv;
const raw = fs.readFileSync(target, "utf8");
const crlf = raw.includes("\r\n");
let src = raw.replace(/\r\n/g, "\n");
const spec = fs.readFileSync(sectionsFile, "utf8").replace(/\r\n/g, "\n");
const blocks = [...spec.matchAll(/^@@@(SECTION|BEFORE) (.+)\n([\s\S]*?)\n@@@END$/gm)];
let failed = 0;
for (const [, kind, key, body] of blocks) {
  if (kind === "SECTION") {
    const head = `### ${key}\n`;
    const start = src.indexOf(head);
    if (start < 0 || src.indexOf(head, start + 1) >= 0) { console.error(`Section not found once: ${key}`); failed++; continue; }
    const ends = [src.indexOf("\n### ", start + 1), src.indexOf("\n---\n", start + 1)].filter(i => i >= 0);
    const end = ends.length ? Math.min(...ends) : src.length;
    src = src.slice(0, start) + body + "\n" + src.slice(end);
  } else {
    const at = src.indexOf(key);
    if (at < 0) { console.error(`Anchor not found: ${key}`); failed++; continue; }
    src = src.slice(0, at) + body + "\n" + src.slice(at);
  }
}
if (failed) { console.error(`${failed} block(s) failed; nothing written.`); process.exit(1); }
fs.writeFileSync(target, crlf ? src.replace(/\n/g, "\r\n") : src);
console.log(`Applied ${blocks.length} blocks to ${target}`);
