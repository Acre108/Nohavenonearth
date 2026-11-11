# Tone pass brief (shared by every agent)

You are doing a faction-tone pass on one part of the No Haven on Earth Atlas, a lore dossier for a mecha setting. A kicker pass has already been done. This pass is about register and rhythm.

## Read first
1. `c:\Users\vlexa\Documents\Codex Projects\Mecha\docs\atlas-voice-guide.md`: the style guide. Sections 1 (base voice), 2 (habits to avoid), 4 (faction tones) and 5 (field notes) are your rules.
2. The user's own prose, which the base voice is drawn from. Two short examples of how they write:
   - "There is a huge, exciting amount of variety in Megagame designs - supported by a diverse community of players that have joined from a number of different hobbies. ... There is no design that can provide everything each different player type would want to see, but the best designs can provide something for every type of player."
   - "It's boring, unglamorous work, but if you cannot map a process step-by-step, you'll struggle to change it."

   Plain, considered, British; context first; clauses that build; the occasional spaced hyphen ( - ); honest hedges; warm rather than sardonic.

## The data
- File: `c:\Users\vlexa\Documents\Codex Projects\Mecha\docs\atlas\atlas-data.json`. **Do not edit it.** Other agents are working from it at the same time.
- Make a private copy for testing: `cp` it to `<scratchpad>/tone/<yourtab>-copy.json`. The scratchpad is `C:/Users/vlexa/AppData/Local/Temp/claude/bb3d34fa8973f91b/3a0000b5-a685-42d0-ba07-f1cf6605f157/scratchpad`.
- To see your cards with their faction tone and ending code (run from `docs/atlas`):
  `node tools/voice-tags.js atlas-data.json <tab> <scratchpad>/tone/<tab>-cards.json`
  then `node tools/voice-show.js atlas-data.json <tab> 0 999 <scratchpad>/tone/<tab>-cards.json`
  Each card prints as `## id [tone/ending] name — t: tagline`, followed by `x:` (text) and `z:` (line-end note). The tone code is the faction voice to use (usa, tau, chn, eas, afc, unl, co1, cst, mrd, cps, umj, ash, com, none). The ending code (P plain, L long, O open, K turn allowed) is a nudge.

## What to do
- Rewrite cards so each one reads in its faction's tone (guide section 4), on top of the user's base voice. A Union card should feel like committee rooms and conditions, a Colony One card short and practical, a Communion card slow and liturgical, a Syndicate card wry about money, and so on. The tone should colour the card, not turn it into pastiche.
- Vary density and rhythm across the tab: some cards looser and longer, some short and dry. Two neighbouring cards shouldn't sound alike.
- You don't have to rewrite every card. Spec-like cards (weapons stats, early pre-mech roots) can stay terse. Aim to touch most cards with real prose (roughly half to two thirds of the tab), and leave alone any card that already reads well in its tone.
- Fix any kicker you still find, but **don't add new ones**. No aphorisms, no "X calls it A; Y calls it B", no sardonic one-line closers, no "nobody/never" endings for drama. Keep a turn only where the turn is the point of the card; the guide lists examples.
- Don't reuse a distinctive phrase that already appears on another card or tab.

## Hard rules
- Never change facts, names, numbers, dates, designations, ids or links. Don't add new facts, people, places or events. If a rewrite seems to need a new fact, leave the sentence as it is.
- Never change, move, add or remove redaction bars (█). The text around them may change.
- No em dashes (—). The spaced hyphen ( - ) at most once per card, in a minority of cards. En dashes in ranges like 2158–2231 stay as they are.
- British spelling. Keep fictional characters' established pronouns.
- Taglines (`t`) stay short sentence-case phrases with no full stop. Only change one if it is a kicker or clashes with the tone. Line-end notes (`z`) stay in the "When · what happens" form.

## Output
1. Write your edits to `<scratchpad>/tone/<tab>.json`.
   - **Tree tabs:** an object `{"<node id>": {"x": "full new text"}}`. Add `"z"` or `"t"` only if you change them. Give the full new value of each field you change, and leave out unchanged cards.
   - **The non-tree agent:** an array of `[["exact old text", "new text"], ...]`. Each old text must be a full string value, or a run of text found exactly once in the file.
2. Validate against your private copy, from `docs/atlas`:
   `node tools/voice-apply.js <scratchpad>/tone/<tab>-copy.json <scratchpad>/tone/<tab>.json`
   It must print `applied N` with no errors. It rejects changed redaction bars, em dashes and ambiguous matches. Fix any problems and re-validate on a fresh copy.
3. Your final reply goes to the coordinating agent, not the user. Keep it under 250 words:
   - the number of cards changed;
   - five short before/after examples from different factions;
   - anything you deliberately left alone, or any fact you were unsure about.
