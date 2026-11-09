# Plan: rebuilding the test vectors

**Status: done, 9 November 2026.** Built as planned: [`rules_ref.py`](../tabletop/rules_ref.py),
[`build_vectors.py`](../tabletop/build_vectors.py) and the files described in
[tabletop/vectors/README.md](../tabletop/vectors/README.md). Every hand-worked anchor and dice script
passed on the first run. The engine matches all 505 converted Godot cases, and matched the combat
sandbox's own distribution code on 400 random cases with bracing, full moves and I Can See It. The
forecast averages over the lock roll and also gives the locked and unlocked figures (decided by the
user). The plan below is kept as the record of the design. Test vectors are worked cases (inputs and the exact results
the rules give) that the Discord bot, and later the combat sandbox, must reproduce. They are how the
[Discord plan](discord-ttrpg-plan.md) stops the bot, the sandbox and the Player's Guide from drifting
apart.

## What exists now

- `tabletop/vectors/attacks.json`: 505 cases exported from the Godot prototype by
  `tests/export_vectors.gd`. Each gives an attacker, a weapon and a defender by ID, the cover and
  whether the attacker has a lock, Push and I Can See It. Each also gives the expected hit, crit and
  glance targets, damage per outcome, expected damage, chance of damage and chance to destroy.
- `tabletop/vectors/stats.json`: 392 cases of pilot rating plus hardware and fractions, limited by
  the frame cap.
- `tabletop/test_vectors.py` checks that the targets follow from the cases and the old
  `standard.json`.

## Why they can't be used as they are

- **Old stat scale:** stats are 0–9 ratings instead of 1–14, and totals are limited to 0, not 1.
- **Old numbers and IDs:** weapons come from `standard.json` (`ar40_rifle`, `lr3_rifle`), not the
  sheet (`ar40_longhorn_rifle`).
- **Missing rules:** no bracing, full-Move reroll, planted bonus, lock roll (a lock is given, not
  rolled), Protocols, on-hit effects or the 9 November rulings.
- **Not self-contained:** a case's damage depends on looking up the weapon by ID in data that has
  since changed.

## The rebuild

### 1. A reference rules engine

Write `tabletop/rules_ref.py` (standard library) straight from the Player's Guide. It computes exact
results, not simulated ones:

- targets: hit, lock, crit, glance, Brace and Protocol targets, with the 1–9 limit where the guide
  applies it, and no limit on crit and Brace rolls;
- the full chance distribution of one attack: the lock roll, lock and I Can See It rerolls (one clean
  miss each, earliest first), the full-Move reroll of the first hit, glances, crits, Armour and armour
  type, brace halving, Push, cover, aim, size, Charge and planted bonuses;
- expected damage, chance of any damage, chance to destroy, and whether an on-hit effect triggers.

It goes through the shots one at a time, carrying the rerolls left and whether the full-Move reroll
is spent. That stays exact and fast even for the 7-shot Grad-M. It is also a fixed, readable
statement of the rules that the bot's own code is checked against.

### 2. A self-contained case format (version 2)

Each case carries everything it needs: the attacker's totals (Gunnery or Melee, Precision, Systems),
the weapon's full profile and ID, and the defender's Reflex, Countermeasures, Armour, armour type,
Size, Brace and Structure. The situation covers range, cover, stance, whether the defender moved its
full Move, planted, Charge, Push, I Can See It, and the lock (rolled, given or jammed). Expected
results are the targets and the distribution summary. A case still passes after the sheet changes,
because its numbers are inside it.

### 3. Four sets of cases

| Set | Source | What it checks |
| --- | --- | --- |
| **Anchors** | Written by hand: the Player's Guide's worked examples and the edge cases | That the reference engine follows the guide. Includes targets at the limits, a crit target of 0, a Brace target of 0 or less, a 10 glancing at targets 8 and 9, Countered when Countermeasures is above Systems, the full-Move reroll landing on a rerolled die, Push not touching the lock, kneel-only, and planted plus Charge. |
| **Dice scripts** | Written by hand | Given rolls in order, the exact outcome of each die and the damage. This tests the bot's `/fire` and the sandbox's roll, not just their forecasts. |
| **Converted** | The 505 old cases, every stat +5, with the old weapon numbers written into each case | An independent check from the prototype. Targets must match exactly, because `5 + yours − theirs` doesn't change when both stats rise by 5, and crit targets also match. Any difference in damage figures must be explained by a known rule change, and each one is listed in the file. |
| **Catalogue** | Generated from `tabletop/data/catalogue.json`: the sheet's frames and weapons × the pregenerated pilots × situations including stances | Coverage of real kit. Expected values come from the reference engine, so the anchors are what keep these honest. |

Add Protocol cases (hostile and friendly targets, the three outcomes, Purge) and new stat cases
(pilot plus hardware and fractions, limited to 1 up to the Frame limit; Spirit with no limit).
On-foot cases can follow once those rules settle.

### 4. Tests and the old files

- Rewrite `tabletop/test_vectors.py` to check every version 2 file against `rules_ref.py`. The
  committed catalogue cases must match a fresh build, so a sheet change shows up as a reviewable diff.
- Run the same files against the sandbox's rules code in node (step 7 of the
  [sandbox plan](combat-sandbox-plan.md)).
- Move the old files to `tabletop/vectors/legacy/` with a note. `export_vectors.gd` stays for history.

## Decisions needed

1. **What the forecast's expected damage assumes about the lock.** Recommended: average over the lock
   roll, and also show the result with and without a lock, because the guide's forecast lists the
   lock target alongside the hit target.
2. **How far to go with the converted set.** Recommended: keep it, even though it uses old numbers.
   It's the only check that doesn't come from the same author as the reference engine.

## Size

About two working sessions. The reference engine and the anchors take one; conversion, the catalogue
set and the test rewrite take the other. It should come before Phase 2 step 3 (`/forecast` and `/fire`),
because the bot's attack code is written against these vectors.
