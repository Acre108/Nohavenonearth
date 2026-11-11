# Project notes for agents

## No Haven on Earth Atlas

Before writing or editing any atlas text (cards, notes, ace cards, Timeline beats, Successors cards, captions), read [docs/atlas-voice-guide.md](docs/atlas-voice-guide.md). It sets the voice, the faction tones, the habits to avoid and the voice-pass status. Also review it whenever a session looks at or reviews the atlas, and flag text that breaks it.

- Atlas source: `docs/atlas/mech-lineage-atlas.html` (page) and `docs/atlas/atlas-data.json` (all setting data, roughly one entry per line; splice lines, never re-serialise the file).
- Tools: `docs/atlas/tools/` (`check.js`, `serve.js`, `apply.js`, `voice-*.js`).
- Plan and open decisions: `docs/atlas-gen-standard-plan.md`.
- `docs/atlas/atlas-redactions.json` is local only: never publish it.
- Other sessions edit the atlas too. Diff against the live artifact before every publish.
