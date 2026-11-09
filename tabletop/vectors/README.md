# Test vectors

Worked cases that the Discord bot, and the combat sandbox, must reproduce. The rules are the
Player's Guide (playtest edition, 9 November 2026); [`rules_ref.py`](../rules_ref.py) is the
reference engine written from it.

| File | Made by | Holds |
| --- | --- | --- |
| `anchors.json` | Hand | Attack forecasts, locks, Protocols, Purges, stats and task checks worked out by hand from the guide, including its five worked examples and the edge cases. Only the fields under `expected` are checked. |
| `dice.json` | Hand | Scripted attacks: given rolls in a fixed order, the exact result of every die and the damage. |
| `converted.json` | `build_vectors.py` | The 505 Godot prototype cases on the 1–14 scale, with the prototype's own results. The engine matches all of them (targets exactly, damage figures within the old 2-decimal rounding). |
| `catalogue_attacks.json` | `build_vectors.py` | 440 attacks with the sheet's 55 weapons, fired by KESTREL (ranged) or ANCHOR (melee) from a frame that carries them, at BULWARK in a Garrison, Kestrel, Medved or Peregrine, across evade, brace, full move, cover and Push, and planted with I Can See It. |
| `protocols.json` | `build_vectors.py` | Lock targets for Systems and Countermeasures 3–14, every non-Purge Protocol at several Systems and Countermeasures with and without Push, and Purges, each with the result of every roll from 1 to 10. |
| `stats.json` | `build_vectors.py` | 1,000 stat totals: pilot + whole bonuses + fractions, held to 1..limit. |
| `legacy/` | Godot | The old-scale files from `tests/export_vectors.gd`, kept for history. `converted.json` is built from them. |

```powershell
py tabletop/build_vectors.py          # after a sheet export (sheet_export.py) or a rules change
py -m unittest discover -s tabletop   # checks every file
```

The generated files must match a fresh build, so a rules or sheet change shows up as a diff to
review. The hand files never change unless the guide does.

## Attack case format

```json
{"attacker": {"attack": 7, "precision": 6, "systems": 7},
 "weapon": {"shots": 3, "damage": 6, "ap": 0, "aim": 0, "heavy": false, "melee": false,
            "damage_type": "Ballistic", "on_hit": null, "ignore_cover": 0, "kneel_only": false},
 "defender": {"reflex": 6, "countermeasures": 5, "armour": 2, "armour_type": "None", "size": "Medium",
              "brace": 5, "structure": 50, "stance": "evade", "full_move": false},
 "situation": {"cover": 1, "lock": "roll", "push": false, "see_it": false, "planted": false,
               "charged": false, "modifier": 0}}
```

- Stats are **totals** (pilot + hardware, held to the frame's limits). `attack` is Gunnery for a
  ranged weapon and Melee for a melee one.
- `lock`: `roll` (a lock roll is made), `locked` (a lock is given, no roll) or `none` (jammed, out of
  lock range or no line of sight).
- `see_it`: the attacker has I Can See It and the Will for it. `planted`: the attacker braced and did
  not move. `charged`: the attacker charged this target (melee only). `modifier`: anything else,
  such as +2 for a parting strike or Tag.
- `full_move`: the defender evaded and moved its full Move by Ground Move or Cruise. An aircraft
  always has it unless it flew a High-G turn.
- The hand files leave out inputs at their defaults: everything in the example above that is 0,
  false, null, `None`, `Medium`, `Ballistic`, `evade` or `roll`, and `brace` 5.

The forecast's `expected_damage` **averages over the lock roll**: `p_lock × expected_damage_locked
+ (1 − p_lock) × expected_damage_unlocked`. Both halves are given so the bot can show them too.
`p_on_hit` is the chance at least one shot hits (glances don't count). `p_will_see_it` is the chance
I Can See It is actually spent. `illegal` names a rule that forbids the attack.

## Dice order

Scripted attacks use the d10s in this order, and the bot and the sandbox must use the same order:

1. The lock roll, only if `lock` is `roll`.
2. One die per shot, in order.
3. Lock and I Can See It rerolls: each replaces one clean miss, earliest first. A die is rerolled at
   most once this way. I Can See It is spent only if there are more clean misses than the lock's
   reroll covers.
4. The full-Move reroll: the first die that is a hit after step 3, even a rerolled one, is rolled
   again. The new roll stands. Glances are never rerolled.
5. A crit die for each hit, in shot order, only if the crit target (Precision − 5) is 1 or more.
6. A Brace die for each hit or glance that deals damage, in shot order, only if the defender braces
   and its Brace target (Brace − 2) is 1 or more.

Every die in a script is used; too few or too many is an error.

## Not covered yet

Damage Protocols' damage, area Protocols, frame specials driven by tags (stealth range, point
defence, damage floor, cover bonuses), Stagger, Dazzle and Tether effects after the hit, and
on-foot attacks. Add them as the bot reaches them.
