# Plan: finishing the combat sandbox

**Status: done, 9 November 2026.** Steps 1–7 are built and published as version 11 of the artifact,
from `tabletop/sandbox/combat-sandbox.html` on branch `tabletop-bot-prep`. The page passes 109 built-in
rules checks and every shared test vector it can take (1,629 of 2,382 cases; the rest need fractional
stat bonuses, which the page doesn't have). Rulings the build had to make, for the user to confirm: an
engaged unit must break off before it can withdraw; a pilot who survives losing their mech returns in
a new frame of the same type; each new fight counts as the next mission for Will penalties; help costs
the helper nothing; a bracing target ignores Stagger on a roll at or under its Brace target; an
unaugmented pilot's Reflex counts as 5 in an augmented-only frame (so 4 rises to 5); point defence is a
flat −2 however many defenders cover the target; the hidden-stance forecast highlights the evade
columns when the target's revealed move was more than half its Move. Battery crane, drone command and
shared lock are shown as "Not applied here". The plan below is kept as the record.

Original status: proposed, 9 November 2026. The [combat sandbox](https://claude.ai/artifact/JgqktsdJAv71A8j6XkpviL)
is the GM's stand-in for the Discord bot until Phase 2 of the [Discord plan](discord-ttrpg-plan.md)
is playable, and stays afterwards as the place to settle geometry and test rules. On 9 November it
was brought up to the Frames and Weapons sheet's numbers, the 1–14 pilots, brace and evade, the
planted bonus, the full-Move reroll and the unlimited crit and Brace rolls (version 10). This plan
covers what is still missing.

## What is missing

| Gap | Why it matters |
| --- | --- |
| The numbers were copied in by hand | The next sheet change makes the sandbox wrong again, and only 17 of the sheet's 62 frames are in it |
| Its source lives only in the artifact | No history, no tests in CI, no way to review a change |
| Secret orders and the Declare step | Stances show at once and targets are picked after seeing them, so the brace/evade choice can't be tested properly |
| Attack order is advisory | Units can roll out of order, and a unit destroyed earlier can still attack; there is no target switching |
| Withdrawal and task checks | Two Action-phase options in the Player's Guide can't be taken |
| Ejection, injury and Will across fights | The aftermath rules can't be tested, and Will doesn't carry from one fight to the next |
| Dazzle and Tether on-hit effects; Stagger's bracing clause | Shown as text, not applied |
| Frame specials | Only some are applied; no check against the sheet's tags |
| Squad loadouts differ from the sheet | The Sparrowhawk and Écuyer squads still carry the M30; the sheet's standard loadouts are different |
| Four weapons not on the sheet | The BR-90, AC-30, SG-12 and Twin GSh-6M keep 26 October numbers |

## Steps

Each step ends with a published version the GM can use.

### 1. Put the source in the repo and feed it from the sheet

- Keep the page as `tabletop/sandbox/combat-sandbox.html`, published to the same artifact URL.
- Add `tabletop/sandbox/build.py` (standard library). It writes `tabletop/data/catalogue.json` into the
  page's data block, in place of the hand-copied `F`, `W` and `PROTOS` tables. The pilots, squads,
  presets and terrain stay in the page.
- Every frame on the sheet appears in the Add unit list, sorted by generation and bloc.
- Run the page's 50 built-in rules checks in node from `py -m unittest`, so CI catches a broken page.
- Sheet change → `sheet_export.py` → `build.py` → publish. Nobody copies numbers by hand again.

### 2. Hidden orders and the Declare step

- A **GM screen** mode for one person running both sides. Each side enters its manoeuvres and stances
  behind a cover panel. **Reveal** shows the movement; stances stay hidden.
- After the Action phase, each side declares a target and weapon behind the cover, then **Reveal
  stances** shows them all at once. Before the reveal, the forecast shows evade, full-Move evade and
  brace side by side, as the bot will.
- With players at the table, the GM types in the orders they sent by direct message. The page needs
  no accounts.

### 3. Strict attack order

- Attacks go in initiative order; the page offers only the unit whose turn it is.
- A unit destroyed before its turn loses its attack.
- If the declared target is gone, offer the other legal targets for the same weapon, or **Lose the
  attack**.
- A channelled Protocol takes the unit out of the Declare step.

### 4. The missing actions

- **Withdraw:** available to a unit that ended its move on its own side's map edge. It leaves with
  its damage recorded.
- **Task check:** pick a unit, stat and difficulty; Push and help (+1 from a helper with 6 or more).
  The result goes into the dice log.

### 5. Effects and specials

- Apply Dazzle (no lock rolls next round) and Tether (cannot move next round) on a hit, and Stagger's
  bracing clause.
- Drive frame and weapon specials from the sheet's tags instead of from the page's own code: the
  stealth ranges, countermeasure fields, point defence, front and dug-in cover, damage floor,
  charge reach, shoot and scoot, kneel only, anchor, ignore cover, reach, cooldown and the rest. A
  tag the page doesn't support shows a warning, so a gap is visible.

### 6. Aftermath and missions

- When a mech is destroyed: the ejection roll (pilot Reflex, −2 after a crit or melee hit, Push
  allowed), then the injury table on a failure. Results go to the log and the unit's card.
- **Mission mode:** Structure, Will, magazines and injuries carry from one fight to the next, with a
  **Downtime** button that applies the free field repair, refills Will and restocks magazines.

### 7. Shared test vectors

Run the rebuilt vectors ([tabletop/vectors](../tabletop/vectors/README.md), built 9 November) against
the page's rules code in node, the same way the bot will run them in Python. This includes the dice
scripts, which need the page's attack roll to take its dice from a list in the documented order. A
one-off check on 9 November already found the page's forecast distribution matches
`rules_ref.py`. Then the sandbox, the bot and the
rulebook can't drift apart silently.

## Decisions (made 9 November 2026)

1. **Squad loadouts:** switch the playtest squads to the sheet's standard loadouts, keeping the old
   squads as a named preset. Do it in step 1.
2. **The four weapons not on the sheet** (BR-90, AC-30, SG-12, Twin GSh-6M): drop them from the
   sandbox. Step 1 removes them with the hand-copied tables.
3. **On-foot fights:** stay out of the sandbox; the bot handles them.
4. **Forecast and the lock:** expected damage averages over the lock roll, with the locked and
   unlocked figures shown as well, as the rebuilt vectors define it.

## Order and size

Step 1 first: everything later is easier with the source in the repo and the numbers flowing from
the sheet. Steps 2 and 3 matter most for the next playtest, because they test brace and evade
properly. Steps 4–6 can follow in any order. Step 7 waits for the vectors. Expect about one working
session per step. Step 1 and the GM screen mode are the largest.
