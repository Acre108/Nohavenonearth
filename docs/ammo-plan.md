# Ammunition — plan, 23 October 2026

**Status: design agreed, not yet implemented.**

There is no ammunition today. Weapons are limited only by `energy_cost`, and most ballistic weapons
cost 0, so they fire every round for free. This plan gives physical weapons a supply limit:

- **Ballistic and explosive ranged weapons use magazines instead of Energy.**
- **Energy weapons keep drawing Energy.** That gives the two weapon families different supply
  problems, and leaves more Energy free for manoeuvres and [Protocols](protocols-plan.md).
- **Reloading uses the unit's action**, so it competes with Protocols and breaking off.
- **Spare magazines are a sortie resource**, carried from the workshop and restocked there between
  sorties.

## 1. Rules

### Magazines

- A weapon's `magazine` is how many **attacks** (volleys) it holds, not how many shots. One attack
  uses one load whatever its shot count, the same way Energy is paid once per attack today.
- A weapon with an empty magazine cannot fire: `target_error()` returns "Magazine empty."
- A weapon starts each sortie with a full magazine and `spare_magazines` spares.
- `magazine: 0` means the weapon has unlimited use and no ammunition. This covers hands, blades, the
  Molot ram and other melee weapons.

### Reload

- **Reload** is an ACTION-phase choice for one weapon. It uses the unit's action, takes one spare and
  refills that weapon's magazine. Rounds left in the old magazine are lost. Keep it simple, with no
  partial top-ups.
- The action comes before the attack in each round. A unit that ran dry last round can reload and
  fire this round, but it gives up its Protocol or break-off to do so.
- A weapon with no spares left cannot reload. It is dry for the rest of the sortie.
- Units locked in melee can still reload. A unit with nothing else to do in the action phase is no
  longer skipped when it has a reload available.

### Which weapons use what

| Weapon family | Supply |
| --- | --- |
| Ballistic and explosive, ranged | Magazine. `energy_cost` becomes 0. |
| Energy weapons (vibro knife, Dao blade) | Energy, as now |
| Physical melee (hands, Molot ram) | Neither |
| Cartridge melee (PB-4 Stake Driver) | Magazine. Each cartridge is one strike. |
| Powered ballistic (LR-3 Linear Rifle, a railgun) | Both: a magazine plus 1 Energy per attack |

### Aircraft

Aircraft carry **no spare magazines**. When they are dry, they withdraw to rearm. This reuses the
existing withdrawal rule, scores as "withdrawn" rather than destroyed, and gives fighters a natural
time on the field.

## 2. Starter numbers

Battles currently last about 14–16 rounds. Most units are in range for fewer than that. These
numbers aim for supply to start to matter around round 8–10 for volume weapons, and earlier for big
guns. They are first guesses to tune with `balance_run.gd`.

| Weapon | Magazine (attacks) | Spares | Total attacks | Energy now → after |
| --- | ---: | ---: | ---: | --- |
| AR-40 Longhorn Rifle | 4 | 2 | 12 | 0 → 0 |
| Type-07 Drum Rifle | 5 | 1 | 10 | 0 → 0 |
| GSh-6M Rotary Cannon | 3 | 2 | 9 | 0 → 0 |
| AC-30 Rotary Cannon | 3 | 2 | 9 | 1 → 0 |
| SG-12 Breaching Shotgun | 3 | 2 | 9 | 0 → 0 |
| BR-90 Marksman Rifle | 3 | 2 | 9 | 1 → 0 |
| LR-3 Linear Rifle | 4 | 1 | 8 | 1 → 1 (powered) |
| Type-09 Long Cannon | 3 | 2 | 9 | 0 → 0 |
| 125mm Tank Gun | 3 | 2 | 9 | 0 → 0 |
| Coaxial Machine Gun | 6 | 1 | 12 | 0 → 0 |
| Nose Autocannon (aircraft) | 6 | 0 | 6 | 0 → 0 |
| AGM-M Wing Stores | 2 | 2 | 6 | 1 → 0 |
| Hornet Missile Pod | 2 | 2 | 6 | 1 → 0 |
| Grad-M Rocket Battery | 1 | 3 | 4 | 2 → 0 |
| Guided Missiles (aircraft) | 2 | 0 | 2 | 1 → 0 |
| PB-4 Stake Driver | 3 | 1 | 6 | 0 → 0 |

## 3. Data and state

- `WeaponData` gets `magazine: int = 0` and `spare_magazines: int = 0`.
- `UnitState` gets `ammo: Dictionary` (weapon id → loads left) and `spares: Dictionary`, filled from
  the loadout in `_init()`. Both are included in `to_dict()`.
- `CatalogueValidator`: magazine ≥ 0 and spares ≥ 0, spares 0 when magazine is 0, and no ranged
  ballistic or explosive weapon with `magazine: 0`, unless flagged `unlimited` on purpose.
- If a unit carries two copies of the same weapon, key ammunition by mount, not weapon id. Check
  whether any loadout does this before choosing.

## 4. Workshop and between sorties

- **Restock** is part of **Apply refit**. It refills magazines and spares to the fitted maximum. It
  is free for now. When a campaign economy exists, restocking costs supply.
- A sortie's remaining ammunition is saved with hull damage when the battle completes or the player
  returns. A unit sent out again without a refit starts with what it brought back.
- Components can change supply:
  - an **ammo rack** (torso or back slot) adds +1 spare to every magazine weapon on the frame;
  - an **extended magazine** variant adds +1 to that weapon's magazine at a small cost, such as −5 aim
    or extra reserved Energy;
  - an **autoloader** lets a reload happen without using the action, once per sortie.
- The right-hand panel shows magazine × spares for each weapon, next to the existing weapon profile.

## 5. Build order

Do this after step 1 of the Protocols plan (the Target Lock rework). Both change what the ACTION
phase offers, so the action-choice logic is only rewritten once. Ammunition does not depend on
Protocols otherwise, and can land before them.

Each step ends with `Test.ps1` green.

1. **Data.** Add the weapon fields, catalogue values from §2, validator checks and `energy_cost`
   changes.
   *Tests:* load, validate, reject bad entries.
2. **Rules.**
   - Add ammunition state to `UnitState`, and spend a load in `CombatRules.resolve()`, including
     parting strikes.
   - Add the "Magazine empty." check to `target_error()`, so `has_legal_attack()` follows
     automatically.
   - Add `CombatRules.reload()`, and a `reload_error()` for no spares, action used or not a magazine
     weapon.
   - Include reload in `has_action_choice()`.
   - Implement aircraft withdrawal when dry.

   *Tests:* one load per attack whatever the shot count, dry weapons cannot fire, reload uses the
   action and one spare, no spares means no reload, powered weapons need both, melee and energy
   weapons are unaffected.
3. **Turn flow.** Add `TurnManager.reload(weapon)` next to `break_off()`, with log lines ("ANCHOR
   reloads the AR-40 (1 spare left).") and the empty-weapon hold message.
4. **AI.**
   - Reload when the best weapon is dry and a spare exists.
   - Reload when it is low and nothing better is available.
   - Prefer a Protocol or break-off when another loaded weapon is in range.
   - When choosing a weapon, stop spending the last loads of a big gun on low-value shots: subtract
     a small conservation cost from its score when its load count is low.

   *Tests:* seeded choices, and no unit sitting dry with spares when it has nothing better to do.
5. **UI.**
   - Ammo pips on each weapon in the inspector and the attack picker.
   - A **Reload** button in the action bar.
   - Dry weapons greyed out, with the reason shown.
   - The reload animation clips already exist for the Teamster and Kestrel: trigger them on reload.
6. **Workshop.** Restock on refit, ammunition carried over in the save (bump the save version and
   migrate old saves to full ammunition), ammo rack and extended-magazine components, and the panel
   display.
7. **Points, balance and docs.**
   - Weapon point costs should value magazine and spares, and stop charging for the Energy that
     ballistic weapons no longer use.
   - Run `balance_run.gd` for 300 seeds. The target is still 45–55% Blue. Also record how often units
     run dry and how many rounds battles last. If volume weapons never run dry, cut their magazines.
   - Update `stat-system.md`, the README and the tabletop doc: track loads per weapon on the sheet,
     and a reload uses the action.

## 6. Decisions

1. **Aircraft carry no spares and withdraw to rearm when dry.** Agreed.
2. **Protocols can affect ammunition.** Agreed: add a reload-jamming debuff and an ally-reload buff
   to the Protocols starter set once both systems are in.
