# Prototype review, 30 October 2026

A whole-project review taken as the project moves from the Godot prototype to an RPG rulebook,
world building and Discord tools for running games with a group. The prototype is now reference
material: its rules code is the most precise statement of the d10 system we have, so the findings
below are kept even where nobody plans to fix them in Godot.

All ten test suites passed at review time (about 18,700 checks, rendered suites included).

## Repository hygiene (done 30 October)

- The work since 23 October (Kestrel workshop, animator, d10 rules, Guard removal, art QA docs) was
  committed. Every tracked test extends `tests/test_suite.gd`, so it all had to land together.
- Blender sources (`*.blend`) live in Google Drive and are no longer tracked in git.
  `art/source/hx7_kestrel.blend` had grown to 103 MB, over GitHub's 100 MB file limit. Godot never
  reads `.blend` files: it loads the exported `.glb` models in `art/models/`, which stay in git.
  Older, smaller copies remain in history from before 30 October.
- `output/` and `tmp/` have `.gdignore` files. Godot was importing 1.5 GB of QA renders from
  `output/`, which made the import cache about 1 GB. `tmp/` is also git-ignored.
- `docs/atlas/atlas-redactions.json` (unredacted atlas originals, marked local only) is git-ignored.

## Open code findings

"Pivot" says whether the finding still matters for the rulebook or a Discord bot.

| Finding | Where | Pivot |
| --- | --- | --- |
| Red's AI tries to lock the *nearest* enemy, not a lockable one. If the nearest is beyond range 8 or out of sight, the lock fails silently even when another enemy could be locked. Fix: choose from `CombatRules.lockable_targets`. | `battle/state/turn_manager.gd` (ACTION phase) | Prototype only |
| `before_attack` and `when_attacked` events fire before `resolve()` checks the attack is legal, so a rejected attack still triggers them. | `TurnManager.fire` | **Yes**: a bot's ability hooks need validate-then-announce ordering |
| `threat_reach` leaves out the target's base size, so melee threat warnings fall short by up to that radius. | `CombatRules.threat_reach` | Rulebook: state melee reach as edge to edge everywhere |
| Attack effects find the weapon by display name; two same-named weapons would use the first one's muzzle. `AttackResult` should carry a weapon id. | `BattleController.on_attack_resolved` | **Yes**: bot records should use ids, not names |
| F3 ignores key repeat, so holding it toggles the debug panel repeatedly. | `battle/interaction/battle_input.gd` | Prototype only |
| On Windows, save replacement deletes then renames, so it is not atomic, and `load_save` never recovers a leftover `.tmp`. | `WorkshopState.write_state` | **Yes**: any bot persistence needs atomic writes |
| Workshop content is checked with `assert`, which release builds strip. | `WorkshopState._init` | Prototype only |
| The catalogue loader silently ignores unknown JSON keys, so a typo such as `"armor"` loads with no error. | `Catalogue._assign` | **Yes**: if bots load `standard.json`, validate keys |
| Frame-specific details (content path, save path, unit id, starting hull damage, spare seeding) are spread across `workshop_state.gd` and `workshop_session.gd`. | Workshop | Prototype only |
| Withdrawal would discard damage taken during the battle. Unreachable today: only aircraft withdraw. | `WorkshopRuntime.capture_result` | Rulebook: decide what withdrawal costs |
| Stale comment: "all eight stats" (there are seven since Guard was removed). | `data/definitions/frame_data.gd` | No |

## Carry forward

These parts of the prototype are worth reusing as the source of truth for the rulebook and bots:

- `combat/rules/combat_rules.gd`: hit, crit, glance, armour and reroll rules, and an exact
  `forecast` that matches the dice. A bot's `!forecast` can port it directly.
- `units/unit_state.gd`: stat resolution with fractional hardware and frame thresholds.
- `data/catalogues/standard.json` and `costs.json`: frames, weapons, pilots and point weights
  (see the [stat system](stat-system.md) and [points](points-system.md)).
- [tabletop-d10-system.md](tabletop-d10-system.md): the tabletop rules draft.
