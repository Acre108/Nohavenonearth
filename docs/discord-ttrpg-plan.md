# Plan: No Haven on Earth as a Discord tabletop RPG

**Status: Phase 1 drafted, Phase 2 being prepared, 9 November 2026.** Decided: the bot and tools
are Python; the rulebook is the four shared documents listed in the [rulebook index](rulebook/README.md);
frame, weapon and Protocol numbers come from the Frames and Weapons sheet through
[`tabletop/sheet_export.py`](../tabletop/sheet_export.py); how Godot is used later is decided once the
tabletop rules settle. Game development is paused. This plan turns the Player's Guide and the combat
sandbox into a roleplaying game a group can run on Discord, with a GM, a rules bot and the
[atlas](atlas/) as the setting.

## 1. What each existing piece becomes

| Piece | Today | Role from now on |
| --- | --- | --- |
| [Player's Guide](https://docs.google.com/document/d/1IJHlpCCz_T-9L6Z7k2ux4K3wROiuft49nsZz6LCm01M/edit) | Playtest rulebook, all rules | **What the bot implements.** Where it and anything else disagree, the guide wins. |
| [tabletop-d10-system.md](tabletop-d10-system.md) | First rules draft, combat only | **Superseded** by the Player's Guide, which it was written into. Old stat scale. |
| `combat_rules.gd`, `melee_rules.gd`, `movement_rules.gd`, `unit_state.gd` | Godot rules code with ~18,700 passing checks | **Historical reference.** Its formulas match the guide once stats are shifted (+5), but it lacks stances, the Declare step and the current numbers. Not extended. |
| [Combat sandbox](https://claude.ai/artifact/JgqktsdJAv71A8j6XkpviL) (hex map, Gen 1 and Gen 2 frames, playtest squads) | claude.ai artifact used for the October playtests | **Rules lab and stand-in for the bot.** The GM runs fights in it until the bot exists, and settles disputed geometry with it. Since 9 November it carries the sheet's numbers, the 1–14 pilots, brace and evade, the planted bonus, the full-Move reroll and the unlimited crit and Brace rolls; it does not run secret orders, the Declare step, strict attack order or withdrawal. Godot's F3 debug menu does the same for the continuous game. |
| [Frames and Weapons sheet](https://docs.google.com/spreadsheets/d/1-5qpooUhSsjcMrzQWp6DiSxTNM7Y1OZav0AaZKeT00E/edit) | Every tabletop number, with IDs, Protocol lists and tags since 9 November | **The bot's data.** `tabletop/sheet_export.py` checks it strictly and writes `tabletop/data/catalogue.json`. |
| `standard.json`, `costs.json`, workshop catalogues | Game data, older numbers | **Not used by the bot.** `catalogue_check.py` still checks them for the Godot prototype. |
| Teamster and Kestrel workshops | Mech fitting UI | **Model for the mech sheet:** regions, two components per region, Frame / Pilot / Total / Threshold. |
| Atlas and NPPL briefs | Lore | **The setting chapter** and campaign hooks. |

One limit matters: Protocols, the automatic Target Lock, ammunition and evade/brace are agreed but
**not built in Godot**, and the Phase 0 vectors use the old stat scale and the old numbers. The bot's
vectors were rebuilt on 9 November ([plan and record](test-vector-rebuild.md),
[files](../tabletop/vectors/README.md)): a reference engine written from the Player's Guide,
hand-worked anchors and dice scripts, the old cases moved to the new scale, and generated cases for
the sheet's weapons, locks, Protocols and stats.

## 2. Phases

### Phase 0 — Freeze the prototype and extract the truth (about a week)

1. Tag the current commit `prototype-final` so the reference never drifts.
2. Add a test-vector exporter to `tests/test_rules.gd`: for a spread of attacker, defender, weapon,
   range, cover, size and Push cases, write inputs plus expected hit, lock, crit and glance targets,
   `forecast` output and damage per outcome to `tabletop/vectors/*.json`. Use weapon and frame
   **ids**, not display names. Give range and cover directly, since hexes are tabletop only.
   *Done:* `tests/export_vectors.gd`, 505 attack cases and 392 stat cases.
3. Write a JSON schema for `standard.json` and the workshop catalogues, so the bot rejects typos such
   as `"armor"`. *Done:* `tabletop/catalogue_check.py` (standard library only), with tests.
4. Fix nothing else in Godot. The two "Prototype only" AI and input findings stay open.

**Done when:** the vectors exist, the schema passes on every catalogue, and the tag is pushed.

### Phase 1 — Rulebook to a playable first session (2–3 weeks, overlaps Phase 2)

Split the single draft into three documents:

- **Player's guide:** core roll, task checks, pilot stats, mech sheet, the round, hex movement,
  attacks, melee, Target Lock, Protocols, ammunition, plus a "how to play on Discord" page.
- **GM's guide:** running the round, enemy squads and their orders, difficulty setting, scenario
  building on a 24 × 18 hex map, pacing, and what the bot does versus what the GM decides.
- **Setting guide:** 2186, the blocs, frame lineages and organisations, drawn from the atlas and the
  NPPL briefs; Third World War fronts as campaign starting points.

Fill the gaps listed in §15 of the rules, smallest first:

1. **Rulings already owed** by the prototype review: melee reach is measured edge to edge; decide
   what withdrawal costs.
2. **Pilot creation:** eight stats on the 1–14 scale, every stat from 4 with 15 points, background
   and bloc. ANCHOR, KESTREL, ROOK, KITE, BULWARK and RAZOR are the pregenerated Regulars.
3. **Pilot injury and ejection** when a mech is destroyed.
4. **Between missions:** repair, refit and Will recovery, using the workshop's repair funds as the
   model for campaign income.
5. **Advancement** within pilot thresholds.
6. **Social and exploration play:** use the existing task-check rule with a short list of on-foot
   ratings rather than a new skill system.

Use the sandbox whenever a rule question is about combat geometry or dice: reproduce it with F3,
then write the answer into the rulebook as an example.

**Done when:** a new player can build a pilot, read the Player's guide and play one fight without
asking the GM how a rule works.

*Status, 30 October:* the Player's Guide and GM's Guide are written as Google Docs (see
[rulebook](rulebook/README.md)), with items 1–6 above drafted as **Proposed** rules. The setting
guide already existed as the Roleplaying Setting Claude Doc, which stays where it is and is linked
from both guides. Next: play one fight from the guides and settle the proposed rules.

*Status, 9 November:* items 1–6 are all drafted, along with the 1–14 stat scale, brace and evade,
the Declare step and on-foot rules. Solo playtests ran on 4 November. The rulings the bot needed
(unlimited crit and Brace rolls, Countered wording, attacks one at a time, aircraft stance,
initiative timing and others) went into the guides as Proposed on 9 November.

### Phase 2 — Bot, minimum playable (3–4 weeks)

Build order, each step usable at the table on its own:

1. **Dice:** `/roll`, `/check <stat> <difficulty>` with the 1-always/10-never limits (crit and
   Brace rolls excepted).
2. **Sheets:** `/pilot` and `/mech` create and show units from `tabletop/data/catalogue.json`; IDs
   everywhere, with autocomplete on frame, weapon and target names.
3. **Attacks:** `/forecast` and `/fire`, following the Player's Guide; Push and Will; Armour, crits,
   glances, rerolls, brace halving, the planted bonus and the full-Move reroll. Before stances are
   revealed, the forecast shows evade, full-Move evade and brace side by side. Must reproduce every
   rebuilt vector.
4. **The round:** initiative by Reflex set at the start of the round, random ties, phase tracking,
   two secret steps by DM (movement order with stance and hexes moved, then the Declare step), then
   reveal; attacks one at a time; Energy recharge and effect countdown at end of round.
5. **Resources and effects:** Structure, Energy, Will (none for unnamed enemies), magazines and
   spares, Protocol effects, engagements and Charge bonuses, stance, and the frame and weapon tags.
6. **Protocols and Target Lock** from the Protocols tab and the hand-written vectors.

Range, arc, line of sight and cover come from the command in this phase
(`/fire ar40_longhorn_rifle at BULWARK range 4 cover 1`; range includes altitude), with the GM
keeping the map in a shared image or a virtual tabletop. Orders carry the hexes moved, and the GM
confirms them after collisions, because the full-Move reroll, the bracing move limit and the
planted bonus depend on it.

Technical choices (recommended):

- **Python with discord.py, slash commands and buttons.** Slash commands give autocomplete and need
  no privileged Message Content intent; buttons and select menus collect secret orders by DM.
- **SQLite** for persistence. It gives the atomic writes the workshop save lacked.
- **Validate, then announce:** an action is checked for legality before any ability hook or message
  fires (the `before_attack` ordering bug in the review).
- **CI runs the test vectors** on every change.

**Done when:** a full fight runs through the bot, and the bot's numbers match the vectors.

### Phase 3 — First playtests (ongoing from the end of Phase 2)

Use the Gen 1 playtest package agreed on 26 October (Pact frame up, Gen 1 weapons +2, kneel-only
Type-01, LR-1 Front arc 1 Energy; write it into the rulebook first): one squad against a small enemy
group, US, CU and Pact frames only. Record what §15 of the rules asks for: resolution time with the bot and
on paper, weapon usefulness against Armour, the value of Reflex, Systems and Countermeasures, whether
reloads compete with Protocols, and whether anyone runs dry. Watch the hex conversions listed there,
especially the slower Medved and Tieshan.

Balance from table feedback, not from `balance_run.gd`.

### Phase 4 — Map and campaign (after playtests settle the rules)

- **Hex map in the bot:** store coordinates, facing and altitude per unit; compute range, arc, LOS,
  cover and field coverage; post a rendered map image each phase. Port terrain from
  `terrain_rules.gd`.
- **Campaign layer:** persistent pilots and mechs, mission rewards, repair and refit between missions,
  a mission log per campaign channel.
- **Content:** a starter campaign set on one Third World War front, enemy squad lists by bloc and
  generation, and scenario maps.

## 3. Discord server shape

- `#rules` and `#setting`: pinned links to the three guides.
- One channel per campaign for play, plus a thread per fight so the bot log stays readable.
- Secret orders and private sheets by DM to the bot.
- A GM-only channel for enemy sheets and orders.

## 4. Decisions

Made on 30 October: Python for the bot; the rulebook in shared Google Docs; Godot's later role
decided once the tabletop is settled.

Still open:

1. **Hosting.** A small always-on host is recommended; a home PC works for early playtests.
2. **Map approach for Phase 2:** shared image, or an existing virtual tabletop alongside Discord.

## 5. Risks

- **Rule drift** between the rulebook, the bot and the prototype. Mitigation: vectors in CI, and any
  rule change updates the rulebook first.
- **Bot scope creep** delaying the first session. Mitigation: playtest with dice and sheets after
  Phase 2 step 3; the map waits for Phase 4.
- **Combat-only game.** The RPG needs things to do between fights. Mitigation: Phase 1 items 3–6
  before the first campaign, not after.
