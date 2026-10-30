# Protocols — plan, 23 October 2026

**Status: design agreed, not yet implemented.** Mech abilities, driven by Systems and Countermeasures, are called **Protocols**.

Systems and Countermeasures are currently stored, capped and shown, but marked reserved
(`UnitState.RESERVED_STATS`). This plan gives them their job:

- **Protocols** are a mech's "spells": electronic and hardware powers that buff, debuff or
  deal damage. **Systems** decides how reliably a frame can use bigger abilities.
- **Target Lock** becomes an automatic Systems roll made with every attack (§3), so Systems matters on
  every shot.
- **Countermeasures** always defends against abilities and locks aimed at the frame. Some frames can
  also use it actively, to strip effects or protect an area.

The existing pilot abilities (Push, Newtype Reflexes, I Can See It) stay as they are. They are paid
with Will and come from the pilot. Protocols are paid with Energy and come from the frame
and its parts.

## 1. Design rules

1. **One roll per ability use**, as with shots. Every point of Systems or Countermeasures moves the
   chance by 10 percentage points, following the stat-system rule that each point has one fixed effect.
2. **Difficulty is the ability's size.** Bigger effects have harder difficulty, so they need more
   Systems to be reliable.
3. **Countermeasures is passive and always on.** No decision or resource is needed to resist a
   hostile ability or a lock.
4. **Abilities belong to hardware.** Frames and workshop components grant them. Pilots do not.
5. **Energy pays.** Abilities compete with weapons and advanced manoeuvres for the same Energy. Using
   one is the unit's action, and Target Lock no longer uses the action.

## 2. Resolution

### Activation chance

**Chance = 50 + 10 × Systems + difficulty modifier − 10 × target Countermeasures (hostile only)**,
clamped to 10–90%: on the d10 every roll uses, a 1 always succeeds and a 10 always fails.

The difficulty table matches the tabletop task-check table, so both rulesets read the same:

| Difficulty | Modifier | Example at Systems 2, target CM 0 / CM 1 |
| --- | ---: | --- |
| Easy | +20 | 90% / 80% |
| Standard | 0 | 70% / 60% |
| Hard | −20 | 50% / 40% |
| Very hard | −40 | 30% / 20% |
| Exceptional | −60 | 10% / 10% |

Friendly abilities (buffs on yourself or an ally) skip the Countermeasures term.

### Reading the roll: success, countered, fizzle

The ability rolls d100 once. Compare the result with two chances: the full chance, and the chance
**without** the target's Countermeasures.

- **Roll ≤ chance:** success.
- **Roll is between the two chances:** **Countered.** The ability would have worked, but the
  target's Countermeasures stopped it. The log names the defender: "BULWARK's countermeasures
  counter Power Siphon."
- **Roll is above both chances:** **Fizzled.** The user's own Systems check failed.

This is the same idea as the glancing-hit window.

**Energy is spent in full and the action is used, whatever the outcome.**

### Ability data

New resource `ProtocolData`, separate from the pilot `AbilityData`:

| Field | Meaning |
| --- | --- |
| `id`, `display_name`, `description` | As elsewhere |
| `kind` | `buff`, `debuff`, `damage`, `dispel`, `utility` |
| `difficulty` | `easy`, `standard`, `hard`, `very_hard`, `exceptional` |
| `energy_cost` | Quarter-point steps allowed, like reservations |
| `target` | `self`, `ally`, `enemy`, `any`, `point` |
| `range`, `needs_los` | Range is measured between range positions, including the altitude spacing. |
| `radius` | 0 for a single target. Above 0, it affects every valid unit within the radius of the target or point. |
| `duration` | Rounds. 0 means instant. |
| `uses_attack` | Big abilities also use the unit's attack this round (channelled) |
| `effects` | A list of effect entries: `{"stat": "reflex", "amount": -1}`, `{"energy": -2}`, `{"damage": 6}`, `{"no_lock": true}`, `{"move": -1}`, ... |

The catalogue gets a top-level `protocols` array. `FrameData` gets `protocols: Array[String]`.
Workshop components get an optional `grants_abilities` list. Their abilities are added when the
component is fitted, and removed when it is destroyed or removed.

## 3. Target Lock: automatic, rolled on fire

Taking a lock as an action adds nothing, because you would always lock the target you meant to shoot.
Instead, **every attack makes a lock roll first.**

- **Lock chance = 50 + 10 × (attacker Systems − target Countermeasures)**, clamped to 10–90%. That is a
  Standard-difficulty hostile check, read the same way as an ability: **LOCK**, **COUNTERED** or
  **NO LOCK**.
- **A lock gives one reroll of a missed shot** in that attack, the same as today's `LOCK_REROLLS`.
  I Can See It's Will rerolls still add on top.
- **It is free.** It costs no Energy and no action, and it applies to every weapon, melee included, as
  the lock does today. Push adds to the hit chance only, not the lock chance.
- **Countermeasure fields** (§5) protect against lock rolls too. That makes a field frame a real
  defensive asset against high-Systems shooters.
- The lock roll happens before the shots, so the cinematic can show LOCK or COUNTERED before the
  volley.

What goes away:

- Persistent lock state: `UnitState.locks`, `LOCK_CAPACITY`, `LOCK_RANGE`, `take_lock()`,
  `lock_error()` and `lockable_targets()`.
- The ACTION-phase lock choice in `TurnManager` and the AI.
- The "Locked on" inspector line and the old help text.

The ACTION phase becomes the place for abilities, breaking off and Newtype Reflexes.

**Forecast:** the attack preview stays exact. Compute the damage distribution with and without the
lock reroll, then mix the two by the lock chance. The preview shows the lock chance next to the
hit chance. `expected_damage()` for the AI weights the reroll term by the lock chance in the same way.

## 4. Effects in play

`UnitState` gets `effects: Array[ActiveEffect]`. Each entry holds the ability id, the source unit id,
the faction, **strength** (the caster's Systems when it was cast), rounds left and the effect entries.

- **Stat effects** add into `stat()`: `pilot + bonus + effects`, in whole points (hardware fractions count once they add up to one), then the frame
  threshold, as now. **Buffs cannot go past a frame's threshold.** Debuffs cannot take a stat below 0.
- **Stacking:** recasting the same ability on the same unit refreshes its duration instead of stacking.
  Different abilities stack.
- **Ticking:** durations count down in the END phase, next to Energy recharge. An effect cast in round
  N with duration 1 lasts until the end of round N + 1, so it always gets a full round of use.
- **Damage ignores Armour but cannot crit.** It goes through the same destroy, wreck, melee-cleanup
  and victory path as weapon fire. Pull that out of `TurnManager.fire()` into a shared helper first.
- Effects are included in `to_dict()` and copied by `copy_stats_to()`, so AI previews see them.

## 5. Active Countermeasures

Every frame gets passive Countermeasures from §2. Selected frames get more through abilities or traits:

- **Purge** (ability, `dispel`): removes one effect from a unit in range. This can be an enemy buff on
  an enemy, or an enemy debuff on an ally.
  **Chance = 50 + 10 × (own Countermeasures − effect strength) + difficulty modifier.** Countermeasures
  is the acting stat here, so Purge does not take a Systems roll.
  Area versions (`radius` > 0) roll once per effect.
- **Countermeasure field** (frame trait `cm_field_radius`): allies within the radius resist hostile
  abilities and lock rolls with **the higher of their own Countermeasures and the field frame's**. It is
  passive and free, and it is the frame's role, not a spell. The forecast shows which frame's field
  applies.
- **Intercept** (optional ability, readied in the ACTION phase): spend the action and Energy. Until the
  end of the round, the first hostile ability that targets anything within the radius takes an extra
  −20 to its chance. Build this only if the field alone is not enough of a counter-role.

## 6. Turn integration

- **When:** abilities are used in the **ACTION** phase, as the unit's action. `uses_attack` abilities
  also mark `attacked = true`. Reloading also uses the action (see [the ammunition plan](ammo-plan.md)),
  so a unit picks one of: a Protocol, a reload, or breaking off.
- **TurnManager:** add `use_protocol(ability, target)` next to `break_off()`. The AI uses the same call.
- **`CombatRules.has_action_choice()`** returns true when any ability can be used, and no longer
  checks for locks.
- **New rule events** for `AbilityRules` hooks: `before_protocol`, `when_targeted_by_protocol`,
  `after_protocol`, `when_effect_expires`.
- **Push extension:** Push may arm an ability as well as an attack: +20 for 1 Will. This gives Will a
  role in electronic play without a new resource.
- Melee engagement: units locked in melee can still use self-targeted and `ally` abilities, but not
  hostile ones on a non-engaged enemy. This is the same restriction as weapons.

## 7. Starter set (first playtest)

The set is small enough to balance, and it covers each kind once or twice. Numbers are first guesses.

| Ability | Kind | Difficulty | Energy | Range / radius | Effect |
| --- | --- | --- | ---: | --- | --- |
| Sensor Link | buff | Easy | 1 | 6 / — | Ally +1 Gunnery, 1 round |
| Ghost Return | buff | Standard | 1 | self | +1 Reflex, 1 round |
| Target Painter | debuff | Standard | 1 | 8 / — | −1 Reflex, 2 rounds |
| Jam | debuff | Standard | 1 | 8 / — | The target's attacks get no lock roll, 1 round |
| Power Siphon | debuff | Hard | 2 | 6 / — | Target −2 Energy; user +1 |
| Actuator Lockout | debuff | Very hard | 3 | 6 / — | −1 Move and no advanced manoeuvres, 1 round |
| Overload Spike | damage | Hard | 2 | 6 / — | 6 damage, ignores Armour, no crit. Uses attack. |
| Cascade Burst | damage | Very hard | 3 | 6 / 2 | 4 damage to each enemy in radius. Uses attack. |
| Purge | dispel | Standard | 1 | 6 / — | Removes one effect (§5) |

Assign them by role: the HX-7 Kestrel gets Sensor Link, Ghost Return and Target Painter. The Tieshan
on Red gets Jam and Power Siphon. One OB-12 Medved variant gets Purge and a field of radius 3. The
two damage abilities belong to a dedicated EW frame or component, not a line frame.

## 8. Build order

Each step ends with `Test.ps1` green.

1. **Target Lock rework** (first, because it stands alone and changes balance).
   - Add the lock roll to `CombatRules.resolve()`, with an `AttackResult.lock` outcome.
   - Make `forecast()` mix with and without the lock, and weight `expected_damage()` by the lock chance.
   - Remove the persistent lock state, the ACTION-phase lock and the AI lock-taking.
   - Update the lock UI and help text.
   - Remove the two stats from `RESERVED_STATS`.
   - Run `balance_run.gd`. Locks used to be near-certain against anyone in range, so expect a shift.

   *Tests:* lock chance and clamps, the countered band, the reroll only on a lock, forecast matching
   a Monte Carlo of `resolve()`, and the action phase being skipped when there is nothing to do.
2. **Data.** Add `ProtocolData`, catalogue loading, and `CatalogueValidator` checks (difficulty
   names, costs ≥ 0, effect keys known, ids referenced by frames and components exist). Add the frame
   and component fields and the starter content.
   *Tests:* load, validate, reject bad entries.
3. **Core rules.** Add `combat/rules/protocol_rules.gd`:
   - `chance()`, `uncountered_chance()`, `use_error()` (range, LOS, Energy, action, engagement) and
     `resolve()`, using the battle's seeded RNG.
   - A `ProtocolResult`, similar to `AttackResult`.
   - `ActiveEffect`, `UnitState.effects`, the `stat()` integration and the END-phase tick.

   *Tests:* each difficulty, the countered and fizzle bands, full Energy spent on failure, the
   threshold cap on buffs, refresh-not-stack, expiry timing, and damage ignoring Armour through to
   destruction.
4. **Turn flow.** Add `TurnManager.use_protocol()`, the shared damage helper, the `has_action_choice()`
   change, the new events and the Push extension.
   *Tests:* phase gating, using the action and attack, and battle-over from ability damage.
5. **Active Countermeasures.** Add Purge, the field trait (covering abilities and lock rolls) and the
   forecast's choice of best defender.
   *Tests:* dispel chance against strength, field radius in and out, and field vs own CM.
6. **AI.** `TacticalAI.choose_action()` scores each option:
   - A debuff or buff is worth the hit-chance change × expected incoming or outgoing damage.
   - Damage is chance × damage, compared against the attack it gives up.
   - Purge targets the highest-value effect.

   The AI uses an ability only when it beats doing nothing, and never below a 25% chance.
   *Tests:* seeded choices.
7. **UI and presentation.**
   - Ability buttons in the action bar, with a forecast showing the chance breakdown (Systems,
     difficulty, target CM, field source).
   - Effect badges and rounds left on unit panels, and the full-stats window showing effect totals.
   - Log lines for success, countered and fizzled, and new meanings for Systems ("+10% to use
     abilities and lock on") and Countermeasures ("−10% to enemy abilities and locks") in
     `unit_panels.gd`.
   - Simple beam or pulse VFX in `attack_fx.gd`.
   - Workshop: abilities granted by fitted parts appear in the right-hand panel.
8. **Points, balance and docs.**
   - Re-price Systems and Countermeasures in `point_costs.gd`. They are cheap now because they did
     nothing, and Systems now matters on every attack. Price abilities like weapons.
   - Run `balance_run.gd` for 300 seeds. The target is still 45–55% Blue, with abilities used on at
     least 1 in 4 actions by units that have them.
   - Update `stat-system.md`, the README and the tabletop doc's §7.

## 9. Tabletop alignment

The tabletop draft's electronic formula, 50 + 10 × (Systems − CM), is this plan with a Standard
difficulty. Replace tabletop §7 with the following:

- The automatic lock roll on each attack, instead of the **Acquire lock** action.
- This ability list.
- The countered and fizzle reading.

Jam carries over in its new form.

## 10. Decisions

| Question | Decision |
| --- | --- |
| One roll with a "countered" band, or a separate counter roll | One roll |
| Failed ability still costs full Energy | Yes |
| Damage abilities ignore Armour | Yes, with low damage and no crits |
| Buffs can go past frame thresholds | No |
| Target Lock | Automatic Systems roll on every attack (§3) |
| Name | Protocols |
