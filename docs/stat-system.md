# Stat system — 18 October 2026, revised 26 October 2026

Every stat has one effect, and every point of it does the same amount. No stat opens or closes a
movement option: a frame's manoeuvre list is always available, and Energy cost is the only limit.
The rules live in `units/unit_state.gd` (totals and thresholds) and `combat/rules/combat_rules.gd`
(attack resolution). Numbers live in `data/catalogues/standard.json`.

**23 October 2026: every roll is a d10.** Hit, crit and glance chances stay in percent for the UI
and forecasts, but every modifier is a multiple of 10. Shots roll a d10, so 60% hits on 1–6. The
[tabletop rules](tabletop-d10-system.md) use the same dice, as whole-number targets (60% is a
target of 6). They play on a hex map, and convert the game's distances and angles to hexes.

## Pilot stats

Totals are whole points:

1. Take the pilot rating, a whole number.
2. Add the whole points of the frame and its parts (`stat_bonuses`).
3. Add the fractions on parts, summed separately in `stat_fractions`. They count only in whole
   points, rounded toward zero, for bonuses and penalties alike. A matched set of four +0.25 parts
   gives +1; four −0.25 parts cost 1. A part's −0.25 never eats a frame's whole bonus.
4. Cap the result at the frame's threshold (`stat_max`).

Thresholds are the only ceiling on a mech's totals, and every frame must list one for each stat
except Spirit. The old global caps remain as **pilot limits** on the pilot's own rating.

**Spirit is pilot-only** (`UnitState.PILOT_ONLY`): frames have no Spirit bonus or threshold, so it is
the pilot rating, capped at the pilot limit of 6.

There is no Guard (removed 23 October 2026): Reflex defends against melee and ranged attacks alike.
Pilots' Guard points moved into Reflex.

| Stat | Each point | Pilot limit |
| --- | --- | ---: |
| Gunnery | +10% to hit with ranged weapons | 4 |
| Melee | +10% to hit with melee weapons | 4 |
| Precision | +10% chance that a hit is a crit | 5 |
| Reflex | −10% to be hit by any attack, ranged or melee; moves and fires earlier | 4 |
| Systems | +10% to Protocol and Target Lock rolls | 4 |
| Countermeasures | −10% to hostile Protocols and lock rolls against you; Purge rolls on it | 4 |
| Spirit | +1 maximum Will; pilot-only | 6 |

**Systems and Countermeasures are agreed but not yet built.** The game stores them, but
`UnitState.RESERVED_STATS` still marks them reserved, and the workshop shows "no combat rule yet".
Their rules are in the [tabletop rules](tabletop-d10-system.md) (§9 Target Lock, §10 Protocols) and the
[Protocols plan](protocols-plan.md). Lock and Protocol rolls use the same scale as attacks:
50% + 10% × (Systems − target Countermeasures), with a difficulty modifier for Protocols.

## Frame stats

| Stat | Effect |
| --- | --- |
| Structure | HP. At 0 the unit is destroyed. A destroyed mech or tank leaves a wreck (+1 cover, does not block movement); aircraft leave nothing |
| Armour | Subtracted from every hit's damage, never below 0; crits ignore it |
| Armour type | +2 Armour against weapons of the matching damage type |
| Thresholds | The frame's ceiling on each pilot stat total |
| Move | Base distance for free moves and base flight-path length; Reflex does not add to it |
| Energy / recharge | Pays for advanced manoeuvres, Charge and some weapons. Usable capacity is the rated capacity minus installed reservations |

## Attack resolution

1. **Hit chance** = 50% + 10% × (Gunnery or Melee − target Reflex − cover) + aim +
   size, +20% when Pushed, +20% for a melee attack after a Charge that connected this round,
   clamped to 10–90%. A d10 roll of 1 always hits and a 10 always misses. Cover is 1 or 2.
2. **One d10 per shot.** Each hit deals `damage − effective Armour`, where effective Armour is
   Armour, +2 if the armour type matches, minus armour piercing, never below 0.
3. **Crit**: each hit rolls a d10 and crits at or below Precision. A crit deals full damage that
   ignores Armour.
4. **Glancing hit** (heavy weapons only): a miss within 20 points of the hit chance deals
   `floor(damage / 2) − Armour`. It cannot crit.
5. **Rerolls** apply to misses only: a target lock gives one; I Can See It gives up to two.
6. **Melee range** is measured base edge to base edge, so melee can reach adjacent units but not
   another altitude band.

## Melee

The rules live in `combat/rules/melee_rules.gd`.

- **Charge** is a movement order:
  - It costs 1 Energy and reaches Move + 1.
  - The target must be an enemy on the Ground, inside the ±60° cone ahead, and not an aircraft.
  - The charge homes on where the target is when the charger moves.
  - If it ends in base contact, both units are **engaged**, and the charger gets +20% on melee
    against that target for the rest of the round.
- **Engaged units** cannot move, and can attack only the units they are engaged with. Melee against
  an engaged foe ignores the weapon's arc.
- **Breaking off** uses the action:
  - Every engaged foe with a melee weapon that has not yet attacked makes its attack now, as a
    **parting strike** at +20% that does not stack with its Charge bonus.
  - Then the unit backs away up to 1.5, keeping its facing.

Many small shots are consistent but are stopped by Armour; one big shot gets through Armour but is
swingy. Glancing hits soften that swing. Precision is how volume weapons beat Armour.

## Will

Spirit sets maximum Will; Will never refills. Every pilot has **Push** (+20% to hit, 1 Will). The
ace also has Newtype Reflexes and I Can See It. The AI pushes when it raises the chance to destroy
by at least 10 points, or adds a quarter of the target's remaining Structure in expected damage.

## Roster

Pilot ratings, before frame bonuses:

| Pilot | Frame | Gunnery | Melee | Precision | Reflex | Systems | Countermeasures | Spirit |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| ACE | HX-7 Kestrel | 2 | 2 | 2 | 2 | 1 | 1 | 4 |
| ANCHOR | M9 Teamster | 1 | 1 | 0 | 1 | 0 | 0 | 2 |
| KITE | F-12 Peregrine | 1 | 0 | 1 | 1 | 1 | 0 | 2 |
| BULWARK | OB-12 Medved | 1 | 0 | 1 | 2 | 0 | 1 | 2 |
| WRAITH | Type-09 Tieshan | 1 | 1 | 2 | 1 | 2 | 1 | 3 |
| RAZOR | F-12 Peregrine | 0 | 0 | 1 | 1 | 0 | 1 | 2 |
| ANVIL | Type-99 Tank | 1 | 0 | 0 | 0 | 0 | 0 | 2 |

The workshop has its own three pilots, in `data/catalogues/workshop_pilots.json`, on a seven-point
budget (raised from five on 26 October 2026 to give them Systems and Countermeasures):

| Pilot | Role | Gunnery | Melee | Precision | Reflex | Systems | Countermeasures | Spirit |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sol / ANCHOR | Brawler | 1 | 1 | 0 | 1 | 0 | 2 | 2 |
| Mara / KESTREL | Marksman | 2 | 0 | 1 | 0 | 2 | 0 | 2 |
| Vale / ROOK | Skirmisher | 1 | 0 | 0 | 2 | 1 | 1 | 2 |

| Frame | Structure | Armour | Reflex bonus | Move | Energy |
| --- | ---: | ---: | ---: | ---: | --- |
| HX-7 Kestrel | 60 | 1 | 2 | 4 | 5 / +2 |
| M9 Teamster | 72 | 2 | 1 | 3 | 3 / +1 |
| F-12 Peregrine | 14 | 0 | 2 | 5 | 3 / +1 |
| OB-12 Medved | 90 | 3 | 0 | 2.5 | 4 / +2 |
| Type-09 Tieshan | 72 | 2 | 1 | 2.5 | 3 / +1 |
| Type-99 Tank | 20 | 3 | 0 | 3 | 2 / +1 |

| Weapon | Shots × damage | Range | Arc | Energy | Traits |
| --- | --- | --- | --- | ---: | --- |
| LR-3 Linear Rifle | 2 × 8 | 2–4 | 90° | 1 | heavy |
| AGM-M Wing Stores | 4 × 4 | 2–6 | 120° | 1 | — |
| VB-2 Vibro Knife | 3 × 8 | edge 0.5 | 90° | 1 | melee |
| AR-40 Longhorn Rifle | 3 × 6 | 1–6 | 180° | 0 | — |
| Hornet Missile Pod | 4 × 4 | 2–6 | 120° | 1 | — |
| PB-4 Stake Driver | 1 × 18 | edge 0.5 | 90° | 0 | heavy, melee |
| Grad-M Rocket Battery | 5 × 4 | 2–6 | 120° | 2 | — |
| GSh-6M Rotary Cannon | 8 × 3 | 0–3 | 90° | 0 | — |
| Type-09 Long Cannon | 1 × 13 | 2–7 | 90° | 0 | heavy |
| Type-07 Drum Rifle | 4 × 4 | 0.5–4.5 | 120° | 0 | — |
| 125mm Tank Gun | 1 × 15 | 1–6 | 360° | 0 | heavy |
| Coaxial Machine Gun | 8 × 2 | 0–3.5 | 360° | 0 | — |
| Nose Autocannon | 5 × 3 | 0–5 | 90° | 0 | — |
| Guided Missiles | 2 × 6 | 2–6 | 120° | 1 | — |
| Molot Hydraulic Ram | 2 × 10 | edge 0.5 | 90° | 0 | heavy, melee |
| Type-11 Dao Blade | 3 × 6 | edge 0.5 | 90° | 0 | melee |
| BR-90 Two-Handed Marksman Rifle | 2 × 11 | 2–8 | 90° | 1 | heavy |
| AC-30 Rotary Cannon | 6 × 4 | 0–4.5 | 120° | 1 | — |
| SG-12 Breaching Shotgun | 5 × 4 | 0–2.5 | 120° | 0 | — |
| Hands (small / medium / large / super heavy) | 2 × 3 / 4 / 5 / 7 | edge 0.5 | 90° | 0 | melee |

## Tuning log

AI-vs-AI on both sides, via `tests/balance_run.gd`. Target: Blue near 49% (the pre-redesign
result) and battles near the previous ~17 rounds.

| Change | Blue wins | Seeds | Avg rounds |
| --- | ---: | ---: | ---: |
| First conversion | 8% | 60 | 13.6 |
| AR-40 5→6 damage, Long Cannon 16→14, Grad-M 6→5 shots | 67% | 60 | 13.1 |
| Vibro Knife 9→8 damage | 37% | 60 | 13.5 |
| All Structure +20% | 39% | 150 | 15.8 |
| Tank Structure 24→20 | 43% | 150 | 15.6 |
| **Long Cannon 14→13 damage (current)** | **49%** | 150 | 15.7 |
| Current, fresh seeds 151–300 | 51% | 150 | 15.9 |

Win rate moves sharply with single weapon changes: 60-seed runs carry roughly ±6% noise, so confirm
changes over 150 seeds.

## Pricing workshop parts

At typical hit chances, one point of each stat is worth about:

| Point | Value |
| --- | --- |
| Gunnery / Melee | +20% damage from every weapon of that type |
| Precision | +10% of hits ignore Armour; worth most for volume weapons against heavy Armour |
| Reflex | −10 points on every incoming hit chance, ranged or melee; also sets initiative |
| Armour | −1 damage per incoming hit; large against volume fire, small against heavy guns |
| Structure | 1 damage absorbed; parts should give +3 to +5 to be noticeable |

Melee is rarer than ranged fire, so Melee parts should be cheaper than Gunnery parts.
