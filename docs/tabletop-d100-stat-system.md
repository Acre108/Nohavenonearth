# No Haven on Earth — Tabletop d100 stat system

**Component: tabletop roleplaying game, including play over Discord.**

**Status: proposed playtest rules, 22 October 2026.** This percentile draft replaces the previous tabletop d20 draft. It is separate from the Godot game: no digital rules, catalogues or saves are changed.

The aim is to preserve the existing eight pilot stats, machine characteristics and percentage-based combat while providing a consistent roll-under procedure for tabletop play. New RPG rules are labelled as proposals.

## 1. Core roll: roll low

**Roll d100 equal to or below the final success chance to succeed.** A chance of 65% succeeds on 01–65. Lower is better.

Use results 1–100. With percentile dice, read a double zero as 100, never zero. In Discord, use `1d100` and compare the result to the announced chance. Ordinary rolls have no automatic critical success or fumble; critical hits use the separate Precision rule below.

Build the chance from the relevant formula, then round once to the nearest whole percentage point, with .5 rounded upward. Apply the stated limits after rounding. Keep fractional ratings and bonuses on the sheet; do not round each part independently.

### Proposed task checks

For an uncertain non-attack task:

**Chance = 50 + (10 × relevant resolved rating) + difficulty modifier**, limited to **5–95%**.

| Task difficulty | Modifier | Chance at rating 0 |
| --- | ---: | ---: |
| Easy under pressure | +20 percentage points | 70% |
| Standard | +0 | 50% |
| Difficult | −20 percentage points | 30% |
| Very difficult | −40 percentage points | 10% |
| Exceptional | −60 percentage points | 5% after the limit |

Use one relevant stat. Do not add Gunnery and Precision to the same check. Equipment and conditions can adjust the chance where their rules explicitly say so. Roll only when the task is possible and failure matters; the GM states the final chance and consequence before the roll. Impossible tasks do not get a 5% chance just because this formula has a minimum.

These task rules are new tabletop proposals. The eight stats remain specialised pilot ratings; a complete social, exploration and unmounted skill system is still to be designed.

## 2. Keep the original stat ratings

**Each original stat point contributes 10 percentage points to the relevant chance.** There is no conversion to a d20 modifier or D&D-style ability score.

Resolve each rating by adding pilot, frame, installed equipment and wear effects, rounding to the nearest quarter point, then clamping between zero and the lower of the frame threshold and global cap. Use the existing **Pilot / Frame and Parts / Total / Threshold** sheet breakdown.

| Resolved rating | Percentage contribution |
| ---: | ---: |
| 0 | 0 points |
| 0.25 | 2.5 points |
| 0.5 | 5 points |
| 0.75 | 7.5 points |
| 1 | 10 points |
| 1.5 | 15 points |
| 2 | 20 points |
| 2.5 | 25 points |
| 3 | 30 points |
| 4 | 40 points |
| 5 | 50 points |
| 6 | 60 points |

A contribution is not a standalone success chance: Gunnery 1.5 adds 15 points to the attack formula. Quarter-point ratings can produce half-percentage final chances; whole-number d100 rounding changes those by at most 0.5 percentage points. For example, 62.5% becomes 63%.

Use the resolved total while piloting a mech. On foot, use the pilot rating without mech hardware or frame thresholds, subject to the global cap. Hardware bonuses require the relevant machine and equipment.

## 3. Pilot stats

| Stat | Tabletop function | Rating cap |
| --- | --- | ---: |
| **Gunnery** | Adds 10 percentage points per point to ranged attack chance. | 4 |
| **Melee** | Adds 10 percentage points per point to melee attack chance. | 4 |
| **Precision** | Each point gives successful hits a 10% chance to bypass Armour. Proposed task use: fine control and deliberate precision work. | 5 |
| **Reflex** | Subtracts 10 percentage points per point from incoming physical attack chance; determines initiative. Proposed task use: reactions and emergency piloting. Does not increase Move. | 4 |
| **Guard** | Subtracts another 10 percentage points per point from incoming melee attack chance. Proposed task use: resisting forced movement or being knocked down. | 4 |
| **Systems** | Proposed: adds 10 percentage points per point to sensor, diagnostic and electronic-action checks. | 4 |
| **Countermeasures** | Proposed: subtracts 10 percentage points per point from incoming hostile electronic-action chance. | 4 |
| **Spirit** | Maximum Will equals the whole rating. Proposed task use: adds 10 percentage points per point to resolve checks against fear, coercion or mental strain. | 6 |

Systems and Countermeasures are reserved stats in the current digital game. Their functions here, and the task uses of the other ratings, are proposed tabletop additions.

### Spirit and Will

**Maximum Will = floor(resolved Spirit rating).** Spirit 2 grants 2 Will; Spirit 2.75 still grants 2 Will. Its percentage contribution to a resolve check remains 27.5 points before final rounding.

Start a mission at maximum Will. Will does not recharge during that mission. Proposed campaign recovery: restore it at the beginning of the next mission after downtime.

## 4. Frame and equipment stats

| Stat | Tabletop treatment |
| --- | --- |
| **Structure** | Keep as mech HP. At 0 the mech is disabled; pilot survival, ejection and salvage need separate rules or a GM ruling. |
| **Armour** | Keep as damage reduction per hit, not a penalty to attack chance. |
| **Armour type** | Add 2 effective Armour against the matching damage type. |
| **Move** | Keep the listed frame distance and manoeuvre restrictions. One map unit is one tabletop distance unit; retain half-unit measurement where needed. |
| **Energy capacity** | Keep the existing rated resource value. |
| **Energy reservation** | Subtract installed reservations from rated capacity to find usable maximum Energy. Keep quarter-point amounts. |
| **Recharge** | Restore the listed Energy at the end of each round, up to usable maximum. |
| **Stat thresholds** | Keep frame-specific ceilings and global caps. Apply them to resolved ratings. |
| **Size, altitude, range and arcs** | Keep their current tactical meanings and fitting restrictions. |
| **Shots and damage** | Keep listed shot counts and fixed damage per hit for the first playtest. |
| **Aim bonus** | Keep the listed percentage-point adjustment directly. A +10 aim bonus adds 10 points to attack chance. |
| **Armour piercing** | Subtract the listed amount from effective Armour, never below zero. |

**Effective Armour = max(0, Armour + damage-type protection − armour piercing).** Damage-type protection is +2 for a matching armour type and otherwise zero.

The current code uses Reflex for avoidance and frame-only Move. The older [stat-system.md](stat-system.md) lists a separate Evade stat and Reflex movement bonus; do not apply those older entries on top of these rules.

## 5. Attack chance

**Ranged chance = 50 + 10 × (Gunnery − target Reflex − cover) + aim + target size adjustment + other explicit bonuses.**

**Melee chance = 50 + 10 × (Melee − target Reflex − target Guard − cover) + aim + target size adjustment + other explicit bonuses.**

Cover is measured in its existing rating points: cover 1 subtracts 10 percentage points. Apply it only where terrain protects against that attack. Fully blocked line of sight prevents an attack.

| Target size | Adjustment to attack chance |
| --- | ---: |
| Small | −10 percentage points |
| Medium | 0 |
| Large | +10 percentage points |
| Super heavy | +20 percentage points |

Calculate all contributions, round once, then **limit attack chance to 10–90%**. These limits apply to physical attacks, not ordinary task checks. There is no separate Armour Class or defence roll.

### Attack procedure

1. Check the weapon is fitted, the target is legal, and range, arc, line of sight and altitude permit the attack. Melee uses base-edge distance and requires the same altitude band.
2. Declare Push or other pre-attack abilities. Pay the weapon's Energy cost once for the whole weapon attack, not once per shot.
3. Calculate the final attack chance. Roll one d100 per listed shot. Each result equal to or below the chance hits.
4. Resolve any allowed rerolls of failed shots, replacing the original outcomes.
5. For each successful hit, roll a separate critical d100 against **10 × Precision**, rounded once to a whole percentage. Precision 0 cannot crit; Precision 2 means 01–20 crits. No attack-die result automatically crits.
6. A normal hit deals **max(0, listed damage − effective Armour)**. A critical hit deals full listed damage, ignoring Armour. It does not double damage.

The critical percentage is conditional on a hit: a 50% hit chance with Precision 2 gives a 10% overall critical chance per shot before rerolls. Push improves hit chance, not the conditional critical chance.

### Heavy weapons and glancing hits

A heavy weapon's failed shot glances when its roll is **greater than the final hit chance but no more than 20 above it**, up to a maximum result of 100. At a 60% hit chance, 01–60 hits, 61–80 glances and 81–100 misses. At 90%, 91–100 glances.

A glance deals **max(0, floor(listed damage / 2) − effective Armour)** and cannot crit. There is no additional natural-100 fumble rule: 100 can glance if it is inside the heavy weapon's window.

For reroll eligibility, a glance counts as a failed shot. The player may keep it or spend an eligible reroll; a reroll replaces the result even if it becomes a complete miss.

### Push and rerolls

**Push:** spend 1 Will before rolling a weapon attack to add **20 percentage points to all its shots**, before the 10–90% limit. Push may be used once per weapon attack and does not stack with itself.

A Target Lock allows one failed shot to be rerolled per weapon attack against the locked target. An ability granting up to two rerolls instead allows up to two failed shots to be rerolled. Proposed tabletop restriction: use the highest allowance rather than adding allowances, reroll any given shot at most once, and keep the replacement. Successful hits and critical-check dice cannot be rerolled by these effects.

## 6. Initiative and simultaneous orders

Use **highest resolved Reflex first**, retaining the existing deterministic ordering. Proposed tie-breaker: tied units roll d100 once per encounter; lowest acts first among those units, rerolling further ties. Retain that tie order for the encounter.

If using simultaneous movement, everyone commits orders before any are revealed. Reveal them together, then resolve movement and subsequent activations in initiative order. Reflex does not add distance or unlock manoeuvres.

## 7. Proposed electronic actions

These additions give Systems and Countermeasures a testable tabletop purpose. They replace automatic lock acquisition for this draft.

**Electronic chance = 50 + 10 × (acting Systems − target Countermeasures) + explicit electronic modifiers**, rounded once and limited to **5–95%**. Roll d100 equal to or below it. Physical cover, size, Reflex and Guard do not modify this chance unless a specific rule says so.

- **Acquire lock:** spend the unit's action. The target must be within 8 map units and line of sight. Success establishes one lock; each unit can maintain only one. It lasts until replaced, either unit is disabled, or range/line of sight is lost. It provides the attack reroll above while maintained. Failure spends the action and leaves any existing lock unchanged.
- **Jam:** spend the unit's action against a target within 8 units and line of sight. Success removes one lock maintained by that target. It does not otherwise prevent attacks. Failure spends the action.
- **Technical task:** use Systems with the ordinary task-check formula for a discrete sensor or engineering problem. A successful check does not create missing equipment or bypass fitting restrictions and repair costs.

Each unit has one action in the action phase, so locking and jamming compete for that action. Neither replaces the later weapon attack. Systems does not also add to Gunnery; Countermeasures does not also improve physical avoidance.

## 8. Workshop pilot sheets

These are **pilot ratings**, not final attack percentages. They come from [workshop_pilots.json](../data/catalogues/workshop_pilots.json); resolve hardware and thresholds before calculating actual chances. The standalone skirmish roster has different pilot profiles, including a different ANCHOR.

| Pilot | Gunnery | Melee | Precision | Reflex | Guard | Systems | Countermeasures | Spirit | Will |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sol / ANCHOR | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 2 | 2 |
| Mara / KESTREL | 1.5 | 0 | 1 | 0 | 0.5 | 0 | 0 | 2 | 2 |
| Vale / ROOK | 0.5 | 0.5 | 0 | 1 | 1 | 0 | 0 | 2 | 2 |

All retain Push and the existing five-point source budget. As a quick reference, without hardware, size, aim or cover modifiers:

| Pilot | Ranged chance vs Reflex 0 | Melee chance vs Reflex 0 / Guard 0 | Critical chance per hit | Incoming physical penalty from Reflex | Extra incoming melee penalty from Guard |
| --- | ---: | ---: | ---: | ---: | ---: |
| ANCHOR | 60% | 60% | 0% | 0 points | −10 points |
| KESTREL | 65% | 50% | 10% | 0 points | −5 points |
| ROOK | 55% | 55% | 0% | −10 points | −10 points |

These are reference chances, not fixed weapon accuracies. Actual targets and circumstances modify them.

## 9. Worked attack

KESTREL has no hardware bonuses and fires a Longhorn Rifle: **three shots, 6 damage each, +0 aim, 0 Energy**. Her Gunnery is 1.5 and Precision is 1. The target is medium, has Reflex 1, Armour 2, no matching damage-type protection and cover 1.

- Attack chance is **50 + 10 × (1.5 − 1 − 1) = 45%**.
- Her attack dice are **21, 45, 82**: two hits. The Longhorn is not heavy, so the miss cannot glance.
- Critical chance is **10 × 1 = 10% per hit**. Her critical dice are **07 and 64**: one critical and one normal hit.
- Damage is **6 + (6 − 2) = 10 Structure**.

Declaring Push beforehand would cost 1 Will and raise hit chance to **65%**. With those same attack dice, there would still be two hits; other rolls from 46–65 would now hit. Precision remains 10% per hit.

## 10. Playtest scope and references

This is a stat and resolution draft, not a complete RPG. Character advancement, social skills, injury, ejection, mission rewards, campaign income and comprehensive turn/ability rules remain to be designed. Existing fitting, weapon and movement rules supply the tactical baseline where this document does not replace them.

Start with per-shot attacks to preserve the current relationship between volume fire, Armour and Precision. Batch rolls in Discord where possible. **One roll per volley with margin-based hit counts is a future experiment, not a rule in this draft**: it would require separate weapon and balance testing.

First playtest one squad against a small enemy group. Measure resolution time, weapon usefulness against Armour, the value of Reflex and Guard, and whether electronic actions offer worthwhile choices. Digital balance results do not validate the new task or electronic rules.

Source references:

- [Current stats, caps and totals](../units/unit_state.gd).
- [Attacks, criticals and Armour](../combat/rules/combat_rules.gd).
- [Size adjustments](../data/definitions/size_class.gd).
- [Frame-only movement](../movement/rules/movement_rules.gd).
- [Weapon and frame catalogue](../data/catalogues/standard.json).
- [Workshop pilot profiles](workshop-pilots.md) and [component and Energy rules](workshop-components.md).
- [Older stat design notes](stat-system.md), where consistent with current code.

Task difficulty, general task uses, electronic actions, initiative tie-breaking, the reroll-stacking restriction and between-mission Will recovery are proposed tabletop decisions rather than implemented digital features.
