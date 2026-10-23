# Stat system — 18 October 2026

Every stat has one effect, and every point of it does the same amount. No stat opens or closes a
movement option: a frame's manoeuvre list is always available, and Energy cost is the only limit.
The rules live in `units/unit_state.gd` (totals and caps) and `combat/rules/combat_rules.gd`
(attack resolution). Numbers live in `data/catalogues/standard.json`.

## Pilot stats

Total = pilot + bonus (frame `stat_bonuses`; workshop parts add to the same place), rounded to
quarter points and capped. Quarter-point rounding stops float error from losing a step when
fractional parts are added together.

| Stat | Each point | Cap |
| --- | --- | ---: |
| Gunnery | +10% to hit with ranged weapons | 4 |
| Melee | +10% to hit with melee weapons | 4 |
| Precision | +10% chance that a hit is a crit | 5 |
| Guard | −10% to be hit by melee | 4 |
| Reflex | +0.5 move; moves and fires earlier | 4 |
| Spirit | +1 maximum Will (whole points only) | 6 |

Fractions apply directly to every stat except Spirit: +0.25 Gunnery is +2.5% to hit.

## Frame stats

| Stat | Effect |
| --- | --- |
| Structure | HP |
| Armour | Subtracted from every hit's damage, never below 0; crits ignore it |
| Evade | −10% per point to be hit by any attack |
| Move | Base distance for free moves and base flight-path length |
| Energy / recharge | Pays for advanced manoeuvres and some weapons |

## Attack resolution

1. **Hit chance** = 50% + 10% × (Gunnery or Melee − Evade − cover − Guard if melee), +20% when
   Pushed, clamped to 10–90%.
2. **One roll per shot.** Each hit deals `damage − Armour`.
3. **Crit**: each hit has Precision × 10% to crit, dealing full damage that ignores Armour.
4. **Glancing hit** (heavy weapons only): a miss within 20 points of the hit chance deals
   `floor(damage / 2) − Armour`. It cannot crit.
5. **Rerolls** apply to misses only: a target lock gives one; I Can See It gives up to two.
6. **Melee range** is measured base edge to base edge, so melee can reach adjacent units but not
   another altitude band.

Many small shots are consistent but are stopped by Armour; one big shot gets through Armour but is
swingy. Glancing hits soften that swing. Precision is how volume weapons beat Armour.

## Will

Spirit sets maximum Will; Will never refills. Every pilot has **Push** (+20% to hit, 1 Will). The
ace also has Newtype Reflexes and I Can See It. The AI pushes when it raises the chance to destroy
by at least 10 points, or adds a quarter of the target's remaining Structure in expected damage.

## Roster

| Pilot | Frame | Gunnery | Melee | Precision | Guard | Reflex | Spirit |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| ACE | HX-7 Kestrel | 2 | 2 | 2 | 1 | 3 | 4 |
| ANCHOR | M9 Teamster | 1 | 1 | 0 | 1 | 1 | 2 |
| KITE | F-12 Peregrine | 1 | 0 | 1 | 0 | 2 | 2 |
| BULWARK | OB-12 Medved | 1 | 0 | 1 | 2 | 0 | 2 |
| WRAITH | Type-09 Tieshan | 1 | 1 | 2 | 1 | 1 | 3 |
| RAZOR | F-12 Peregrine | 0 | 0 | 1 | 0 | 2 | 2 |
| ANVIL | Type-99 Tank | 1 | 0 | 0 | 0 | 1 | 2 |

| Frame | Structure | Armour | Evade | Move | Energy |
| --- | ---: | ---: | ---: | ---: | --- |
| HX-7 Kestrel | 60 | 1 | 2 | 4 | 5 / +2 |
| M9 Teamster | 72 | 2 | 1 | 3 | 3 / +1 |
| F-12 Peregrine | 14 | 0 | 3 | 5 | 3 / +1 |
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
| Evade / Guard | −10 points on every incoming (melee) hit chance |
| Armour | −1 damage per incoming hit; large against volume fire, small against heavy guns |
| Structure | 1 damage absorbed; parts should give +3 to +5 to be noticeable |
| Reflex | 0.5 move and initiative order |

Melee is rarer than ranged fire, so Melee and Guard parts should be cheaper than Gunnery parts.
