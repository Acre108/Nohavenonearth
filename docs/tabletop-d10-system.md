# No Haven on Earth — Tabletop d10 system

**Component: tabletop roleplaying game. It is best played over Discord with a dice-and-rules bot,
and playable on paper.**

**Status: proposed playtest rules, revised 26 October 2026.** These rules follow the digital game's
design. Four features are agreed but not yet built in Godot:

- [Protocols](protocols-plan.md);
- the automatic Target Lock roll;
- [ammunition](ammo-plan.md);
- the evade or brace stance and the frame's Brace stat (§7).

The game measures continuous distances and angles. The tabletop plays on a **hex map** (§6), which
converts them to whole hexes and hexsides. Where the tabletop differs from the digital game, the rule
is marked **Tabletop only**.

Every modifier is a whole number, so the arithmetic is small enough to do at the table. The Discord bot
still does it all, tracks every resource and shows forecasts. The game runs the same d10 rolls, shown
as percentages: a target of 6 is a 60% chance.

## 1. Core roll: roll low on a d10

**Roll a d10 equal to or below the target number to succeed.** Lower is better.

- **A 1 always succeeds and a 10 always fails.** Targets are limited to 1–9 after every modifier.
- Ordinary rolls have no other critical success or fumble. Critical hits use a separate Precision
  roll (§7).

### Task checks (Tabletop only)

For an uncertain task outside the attack and Protocol rules:

**Target = 5 + relevant rating + difficulty modifier**, limited to 1–9.

| Difficulty | Modifier | Target at rating 0 |
| --- | ---: | ---: |
| Easy | +2 | 7 |
| Standard | 0 | 5 |
| Hard | −2 | 3 |
| Very hard | −4 | 1 |
| Exceptional | −6 | 1 (the limit) |

Protocols use the same difficulty names and modifiers.

Use one stat per check, and do not add Gunnery and Precision to the same check. Roll only when the
task is possible and failure matters. The GM states the difficulty and the consequence before the
roll. An impossible task is not rolled, even though a 1 would otherwise succeed.

## 2. Stat ratings

**Every rating is a whole number, and each point adds or subtracts 1 on the target.**

The resolved rating is calculated as follows:

1. Start with the **pilot rating**, a whole number.
2. Add the **whole points** of the frame, fitted parts, wear and active Protocol effects.
3. Add up the **fractions** of all that hardware: the ¼ and ½ on parts. They count only in whole
   points, rounded toward zero.
   - Bonuses and penalties work the same way. +¾ gives nothing, and a lone −¼ costs nothing.
   - A matched set pays out: four +¼ parts give +1. Four −¼ parts cost 1.
   - A part's fraction never eats a whole point: a frame's +1 with a −¼ part is still +1.
4. Limit the total to between 0 and the **frame's threshold** for that stat.

Buffs cannot raise a rating past the threshold, and debuffs cannot take it below 0. The sheet shows
**Pilot / Frame and parts / Effects / Total / Threshold**, and the Frame column shows the fractions
(for example +1¾).

**Thresholds are the only ceiling on a mech.** Gen 4 prototypes and super robots can have thresholds
above 4.

**Spirit is the exception: it belongs to the pilot.** No frame, part or Protocol adds to it, and no
frame threshold limits it. A pilot's Spirit is the same in any cockpit, and on foot.

**Brace is the mirror image: it belongs to the frame.** No pilot rating goes into it. The frame sets
it, and parts and Protocol effects can raise it as far as the frame's Brace threshold (§4).

**Pilot limits** cap the pilot's own rating, before hardware: Gunnery, Melee, Reflex, Systems and
Countermeasures 4, Precision 5, Spirit 6.

**On foot (Tabletop only):** use the pilot rating alone. Mech hardware and Protocols need the mech,
so outside the cockpit Systems is used only for task checks.

## 3. Pilot stats

| Stat | Each point | Pilot limit |
| --- | --- | ---: |
| **Gunnery** | +1 to ranged attacks | 4 |
| **Melee** | +1 to melee attacks | 4 |
| **Precision** | +1 to the crit roll; a crit ignores Armour | 5 |
| **Reflex** | −1 to every attack against you, ranged or melee. Sets initiative. | 4 |
| **Systems** | +1 to Protocol and Target Lock rolls | 4 |
| **Countermeasures** | −1 to hostile Protocols and lock rolls against you. The stat Purge rolls on. | 4 |
| **Spirit** | +1 maximum Will. Pilot only: hardware never changes it. | 6 |

**Tabletop-only task uses:**
- Precision: fine control.
- Reflex: reactions, emergency piloting and keeping your footing.
- Systems: sensor and engineering problems.
- Spirit: resolve against fear, coercion or strain.

### Spirit and Will

**Maximum Will = Spirit.** Start each mission at maximum Will. Will does not come back during the
mission. **Tabletop only:** it is restored after downtime before the next mission.

Every pilot has **Push**: spend 1 Will for +2 on one attack or one Protocol.

## 4. Frame and equipment stats

| Stat | Treatment |
| --- | --- |
| **Structure** | Mech HP. **At 0 the unit is destroyed** (§6.8). |
| **Armour** | Subtracted from each hit's damage, never below 0 |
| **Armour type** | +2 effective Armour against the matching damage type |
| **Move** | Hexes per round for Ground Move, Charge and Cruise, and the frame's manoeuvre list (§6.4) |
| **Energy** | Usable maximum = rated capacity − installed reservations. It pays for advanced manoeuvres, energy weapons, powered weapons and Protocols. |
| **Recharge** | Energy restored at the end of each round, up to the usable maximum |
| **Thresholds** | The frame's ceiling on each stat except Spirit |
| **Brace** | The frame's own rating, with no pilot part. While bracing, +1 to the roll that halves each hit's damage (§7). |
| **Size** | Hit adjustment (§7) and fitting restrictions, as in the game |
| **Altitude access** | The altitude bands the frame can reach (§6.1) |
| **Range and arc** | Counted in hexes and hex arcs (§6.2, §6.3) |
| **Shots and damage** | Listed shots per attack, fixed damage per hit |
| **Aim bonus** | +1 to the attack target per 10 listed (+10 aim = +1) |
| **Armour piercing** | Subtracted from effective Armour, never below 0 |
| **Magazine** | Attacks the weapon can make before reloading (§11) |
| **Spare magazines** | Reloads carried into the mission (§11) |

**Effective Armour = max(0, Armour + 2 if the armour type matches − armour piercing).**

**Brace ratings** follow the frame's build, not its speciality. Each cell is rating / threshold:

| Build | Which frames | Gen 1 | Gen 2 | Gen 3 | Gen 4 (prototypes) |
| --- | --- | --- | --- | --- | --- |
| Heavy | Large or super-heavy frames, and frames with Armour 3 or more, unless built for Reflex; any frame with Reflex below the base | 1 / 3 | 2 / 4 | 3 / 5 | 4 / 6 |
| Line | Everything else | 0 / 2 | 0 / 3 | 1 / 4 | 2 / 5 |
| Agile | Variable, small and zero-g frames, and any frame with Reflex above the base | 0 / 1 | 0 / 2 | 0 / 3 | 0 / 4 |

Each frame's own rating is in the Frames tab of the roleplaying setting doc.

## 5. The round

1. **Planning.** Every player sends their movement order to the bot by DM, or writes it down face
   down. The GM does the same for enemies. Nobody sees anyone else's order. An order names the
   manoeuvre, the path, the final facing and altitude, the target of a Charge, and the unit's
   stance: evade or brace (§7).
2. **Reveal.** All orders are shown together.
3. **Movement**, in initiative order (§6.6).
4. **Action**, in initiative order. Each unit may take **one** action:
   - use a Protocol;
   - reload one weapon;
   - break off from melee (§8).

   Pilot abilities such as Newtype Reflexes are used here too, without using the action.
5. **Attack**, in initiative order. Each unit makes one weapon attack.
6. **End of round.** Energy recharges, Protocol effect durations count down, the Charge bonus ends,
   and the round number advances.

**Initiative:** highest Reflex first. Ties are rolled off at random each round.

## 6. The hex map and movement (Tabletop only)

**One hex is one map unit of the game.** Every distance in these rules (movement, weapon range,
Protocol range and radius, and lock range) is counted in hexes.

The game's skirmish battlefield is 36 × 26 hexes. A squad fight needs about 24 × 18.

### 6.1 Hexes, facing and altitude

- **Facing:** every unit faces one of its hex's six hexsides. A turn of one hexside is 60°.
- **Turns:** the game's turn limits convert at **one hexside per 45°**. A 45° turn is one hexside, 90° is two,
  135° is three, and 180° means any facing.
- **Altitude bands:** **GROUND**, **LOW** and **HIGH**. A frame can reach only the bands in its altitude access:

  | Frame | Bands |
  | --- | --- |
  | Ground mechs and tanks | GROUND |
  | HX-7 Kestrel | GROUND, LOW |
  | Aircraft (F-12 Peregrine) | LOW, HIGH |

- **Stacking:** at most one unit per hex in each band. A unit at LOW can hover over a unit on the
  GROUND in the same hex.

### 6.2 Range

**Count hexes from your hex to the target's, counting the target's hex but not your own.** An adjacent
hex is range 1.

- **Altitude:** add 1 for each band between the attacker and the target. GROUND to HIGH adds 2.
  The game measures this in 3D, so the hex count can be one too long or too short.
- **Half ranges:** a maximum range of 4.5 reaches 4 hexes, and a minimum of 0.5 allows range 1.
- **Melee reach:** melee weapons reach adjacent hexes in the same band only.
- **Target Lock range** is 8 (§9).

### 6.3 Arcs

A target is in arc if the line from your hex's centre to its centre lies inside the arc. A hex the
boundary line runs through counts as inside.

| Game arc | Hex arc | Shape |
| --- | --- | --- |
| 90° | **Narrow** (60°) | The wedge straight ahead, between the lines through your two front corners |
| 120° | **Front** (120°) | Between the hex rows running straight out of your front-left and front-right hexsides |
| 180° | **Half** (180°) | Every hex ahead of the line through your left and right corners |
| 360° | **All** | Every direction |

### 6.4 Manoeuvres

Each frame lists the manoeuvres it can use. Move rounds down to whole hexes, so the OB-12 Medved
and Type-09 Tieshan move 2. Pay the Energy cost when the unit moves.

**Ground mechs and tanks** (GROUND only):

| Manoeuvre | Energy | Movement |
| --- | ---: | --- |
| **Ground Move** | 0 | Up to Move hexes by any path. Turn freely; end with any facing. |
| **Charge** | 1 | Up to Move + 1 hexes toward an enemy, ending adjacent to it (§8.1). |

**Flying mechs** (HX-7 Kestrel) have Ground Move and Charge while on the GROUND. They also have the
vector manoeuvres below, at any band. Every vector manoeuvre moves at least one hex, so a Kestrel
at LOW cannot stand still.

| Manoeuvre | Energy | Movement |
| --- | ---: | --- |
| **Cruise** | 0 | 1 to Move hexes straight ahead. After the first hex, you may turn one hexside, once. |
| **Combat Turn** | 0 | 1 to Move − 1 hexes, with up to two hexside turns in all; at most one before the first hex. |
| **Brake** | 0 | One hex into the front, front-left or front-right hex, then turn up to two hexsides. |
| **Lateral Thrust** | 1 | Two hexes directly to one side: one through the front hexside on that side, then one through the rear hexside. Facing does not change. |
| **Reverse Vector** | 2 | Two hexes straight back, then turn up to two hexsides. |

A vector manoeuvre may also change altitude by one band. Cruise from the GROUND to take off, and
Cruise down to land. Ground Move and Charge start and end on the GROUND.

**Aircraft** fly a fixed path every round and cannot hover. Mirror the left turns for the right.
"Turn" is one hexside.

| Manoeuvre | Energy | Path |
| --- | ---: | --- |
| **Straight 4** / **Straight 5** | 0 | 4 or 5 hexes straight ahead |
| **Bank Left / Right 4** | 0 | 2 straight, turn, 2 straight |
| **Hard Left / Right 3** | 0 | 1 straight, turn, 2 straight, turn |
| **High-G Left / Right 2** | 1 | 1 straight, turn twice, 1 straight, turn (ends facing the way it came) |

An aircraft may change altitude by one band during its path. **An aircraft whose path leaves the map
withdraws**: remove it from the battle. It is not destroyed.

**Newtype Reflexes:** after the unit moves, turn one more hexside, for 1 Will.

### 6.5 Legal paths

A path is illegal if:
- it enters an obstacle hex that blocks its band (§6.7);
- it leaves the map, except for aircraft;
- it is a GROUND path through a hex with an enemy at GROUND.

Units on the GROUND may pass through friendly units. Units at LOW and HIGH pass through any unit.
No unit may end its move in an occupied hex in its band.

### 6.6 Moving in initiative order

Orders are planned before anyone moves, so they can collide. Units move one at a time, in initiative
order:

- **Blocked path:** if a unit that has already moved blocks the path, stop in the last open hex.
  An aircraft that stops keeps the facing of its last hex.
- **Occupied destination:** if the destination is occupied, stop in the last open hex before it.
- **Engaged units do not move.** This includes a unit that a faster unit charged earlier in this
  phase: its order is lost.

### 6.7 Terrain

| Terrain | Example | Effect |
| --- | --- | --- |
| **Light cover** | Barrier, wreck | Cover 1 at GROUND |
| **Heavy cover** | Ruins | Cover 2 at GROUND |
| **Tall cover** | Tall ruin | Cover 2 at GROUND and LOW |
| **Low obstacle** | Low ruin | Blocks movement and line of sight at GROUND. LOW and HIGH fly over. |
| **Tall obstacle** | Comms block, depot | Blocks movement and line of sight at GROUND and LOW. HIGH flies over. |

- **Line of sight** runs from the centre of one hex to the centre of the other. An obstacle blocks it
  only if it blocks the bands of both units. A line that runs exactly along a hexside is blocked only
  if the hexes on both sides block it.
- **Cover:** the target has cover if it stands in a cover hex, or if the line of sight crosses a
  cover hex adjacent to it. An adjacent obstacle that the line runs alongside without being blocked
  gives cover 2 in the bands it blocks. Use the highest cover that applies; cover does not add up.
  A unit at HIGH never has cover.

### 6.8 Destroyed units

**A unit at 0 Structure is destroyed.** Remove it, and end every engagement it was in.

- A destroyed mech or tank leaves a **wreck** in its hex: light cover that does not block movement.
- A destroyed aircraft leaves nothing.

## 7. Attacks

**Ranged target = 5 + Gunnery − target Reflex − cover + aim + size**

**Melee target = 5 + Melee − target Reflex − cover + aim + size + Charge bonus**

The target is limited to **1–9**.

| Target size | Adjustment |
| --- | ---: |
| Small | −1 |
| Medium | 0 |
| Large | +1 |
| Super heavy | +2 |

Cover is 1 or 2 (§6.7), and applies only where terrain protects against that attack. Fully blocked
line of sight prevents the attack.

### Evade or brace

**Every mech either evades or braces, and picks one in secret with its movement order.** The stance
holds for the whole round, against every ranged and melee attack.

- **Evade** is the default, and the formulas above assume it: your Reflex comes off every attack
  against you.
- **Brace** gives that up. Attacks against you ignore your Reflex this round, though it still sets
  initiative. In exchange, each hit or glance that would deal you damage rolls a d10 against your
  Brace target. At or below it, the damage is halved, rounded down. Work out the damage first,
  Armour and crits included, then halve it.

**Brace target = 5 + Brace**, limited to 1–9.

Evading stops hits outright, but only as many as your Reflex turns away. Bracing works on hits you
were never going to dodge, but it only ever saves half. A Kestrel, with Brace 0 and Reflex up to 4,
should almost always evade.

While you brace, Protocols that change your Reflex do nothing to your defence. Damage Protocols are
not attacks, so Brace never halves them.

### Procedure

1. **Legality.**
   - The weapon must be fitted and loaded, and the unit must have the Energy it needs.
   - The target must be within range, arc, line of sight and altitude.
   - An engaged unit can attack only the units it is engaged with (§8.2).
2. **Declare Push** if wanted: 1 Will for +2 to every shot in this attack.
3. **Target Lock roll** (§9).
4. **Pay** one load from the magazine, or the Energy cost, or both for a powered weapon. Pay once per
   attack, not per shot.
5. **Roll one d10 per shot.** A roll at or below the target hits.
6. **Rerolls.**
   - A lock gives 1 reroll. I Can See It adds up to 2 more, for 1 Will.
   - Rerolls add together.
   - Each reroll replaces one **clean miss**, earliest first, and the new result stands.
   - Glances and hits are never rerolled.
7. **Crits.** For each hit, roll a d10. At or below **Precision** is a crit: Precision 2 crits on
   1–2, and Precision 0 never crits. A crit deals full listed damage and ignores Armour. It does not
   double damage.
8. **Damage.** Each hit deals **max(0, damage − effective Armour)**.
9. **Brace.** If the target is bracing, roll a d10 for each hit or glance that deals damage. At or
   below its Brace target, halve that damage, rounded down.

### Heavy weapons and glancing hits

A heavy weapon's failed shot **glances** when the roll is no more than 2 above the target. At
target 6, for example, 1–6 hits, 7–8 glances and 9–10 misses. A 10 never hits, but at target 8 or 9
it can glance.

A glance deals **max(0, floor(damage ÷ 2) − effective Armour)**. It cannot crit and is not rerolled.

## 8. Melee

Melee weapons (hands, blades, rams and the Stake Driver) reach adjacent hexes in the same band (§6.2).
Their game arc is 90°, so Narrow on the map. An engaged unit ignores arcs for melee against the units
it is engaged with.

### 8.1 Charge

Charge is a movement order for frames that list it. It costs 1 Energy.

**When planning,** the target must be:
- an enemy on the GROUND (aircraft and units at LOW or HIGH cannot be charged);
- in the charger's Front arc;
- close enough that the charger could reach an adjacent hex with Move + 1 hexes.

**When it moves,** the charger heads for wherever the target is now, since the target may already
have moved:
1. It moves up to Move + 1 hexes along the shortest path to a hex adjacent to the target. If several
   paths are equally short, the charger chooses.
2. It stops early at an obstacle, the map edge or another unit.
3. It ends facing the target.

If it ends adjacent, **both units are engaged**. For the rest of this round the charger gets
**+2 on melee attacks against that target**: the **Charge bonus**. If it falls short, the
charge fails, and the Energy is still spent.

### 8.2 Engaged units

- **Engaged units cannot move.** Their movement orders are lost.
- **An engaged unit can attack only the units it is engaged with.** It may use any weapon that is
  legal. A ranged weapon can fire at an engaged foe only if its minimum range is below 1 (0 or
  0.5). The AR-40, for example, cannot.
- At the start of each round, an engaged unit turns to face the first unit it is engaged with.
- A unit can be engaged with several enemies at once.
- An engagement ends when either unit is destroyed, when one breaks off, or when the two are no
  longer adjacent in the same band.

### 8.3 Breaking off

Breaking off uses the unit's **action**.

1. **Parting strikes.** Each foe it is engaged with that has a melee weapon and has not yet attacked
   this round attacks it now:
   - with its best legal melee weapon;
   - at **+2**, which does not add to a Charge bonus against this unit (the total is +2 either way);
   - as a normal attack with a lock roll, rerolls and crits, but without Push or I Can See It.

   That attack is the foe's attack for the round.
2. If the unit survives, it moves **one hex** directly away from its foes, keeping its facing. It must
   end in an open hex that is not adjacent to any of them. If there is no such hex, it cannot break off.
3. The engagements end. The unit may still attack in the Attack phase.

## 9. Target Lock

Every attack makes a lock roll first. Lock is not an action and costs nothing. It needs line of sight
and a target within **8 hexes**. Beyond that, there is no lock roll and so no reroll.

**Lock target = 5 + attacker Systems − target Countermeasures**, limited to 1–9.

The result is read the same way as a Protocol (§10):
- **LOCK:** the attack gets 1 reroll.
- **COUNTERED:** the roll would have locked without the target's Countermeasures.
- **NO LOCK.**

Locks are not kept between attacks. A unit hit by **Jam** makes no lock rolls until the end of the
next round.

**Gen 1 frames have no Systems or Countermeasures.** They predate fire-control links and electronic
warfare. A Gen 1 frame makes no Target Lock rolls, carries no Protocols (§10), and defends against
lock rolls and Protocols with Countermeasures 0. The pilot's Systems and Countermeasures still count
for task checks.

## 10. Protocols

Protocols are a mech's electronic and hardware powers. They buff allies, debuff enemies or deal damage.
They come from the frame and fitted parts, not the pilot.

### Using a Protocol

- It uses the unit's **action**. A **channelled** Protocol also uses the unit's attack this round.
- Pay its **Energy in full, whether it succeeds or not**.
- Push can arm a Protocol: 1 Will for +2.

**Target = 5 + Systems + difficulty modifier − target Countermeasures (hostile only)**, limited to 1–9.
Friendly Protocols ignore Countermeasures.

**One roll, three outcomes:**
- **Success:** the roll is at or below the target.
- **Countered:** the roll is above the target, but at or below the target + the defender's
  Countermeasures. The defender is named.
- **Fizzled:** the roll is above both. The user's own Systems failed.

### Effects

- Stat effects add to the resolved rating (§2), within thresholds and never below 0.
- Duration is in rounds. An effect cast in round N with duration 1 lasts until the end of round N + 1.
- Recasting the same Protocol on the same unit refreshes its duration. Different Protocols stack.
- **Damage Protocols ignore Armour and never crit.**
- An area Protocol rolls once for each enemy in its radius, each against that enemy's
  Countermeasures. Its Energy is paid once.
- Hostile and ally-targeted Protocols need line of sight to the target.
- Each effect records its **strength**: the caster's Systems when it was cast.

### Active Countermeasures

- **Purge** removes one effect from a unit in range, friend or foe.
  **Target = 5 + own Countermeasures − effect strength + difficulty modifier.** Purge does not use
  Systems.
- **Countermeasure field** (a frame trait): allies within the radius defend against hostile Protocols
  and lock rolls with the **higher** of their own Countermeasures and the field frame's.

### Starter Protocols

Ranges and radii are in hexes.

| Protocol | Type | Difficulty | Energy | Range / radius | Effect |
| --- | --- | --- | ---: | --- | --- |
| Sensor Link | buff | Easy | 1 | 6 / — | Ally +1 Gunnery, 1 round |
| Ghost Return | buff | Standard | 1 | self | +1 Reflex, 1 round |
| Ammo Relay | buff | Easy | 1 | 4 / — | Ally reloads one weapon from its spares without using its action |
| Target Painter | debuff | Standard | 1 | 8 / — | −1 Reflex, 2 rounds |
| Jam | debuff | Standard | 1 | 8 / — | No lock rolls, 1 round |
| Feed Jam | debuff | Standard | 1 | 6 / — | Target cannot reload, 1 round |
| Power Siphon | debuff | Hard | 2 | 6 / — | Target −2 Energy; user +1 |
| Actuator Lockout | debuff | Very hard | 3 | 6 / — | −1 Move and no advanced manoeuvres, 1 round |
| Overload Spike | damage | Hard | 2 | 6 / — | 6 damage. Channelled. |
| Cascade Burst | damage | Very hard | 3 | 6 / 2 | 4 damage to each enemy in radius. Channelled. |
| Purge | dispel | Standard | 1 | 6 / — | Removes one effect |

The numbers are first guesses for playtesting.

## 11. Ammunition

- Ballistic and explosive ranged weapons, and cartridge melee weapons such as the PB-4 Stake Driver,
  use **magazines**. They cost no Energy.
- Energy weapons use Energy. Powered weapons such as the LR-3 Linear Rifle use both. Hands, blades and
  rams use neither.
- A magazine counts **attacks, not shots**: one attack uses one load.
- **Reload** uses the action. It takes one spare and refills the magazine, and any loads left in the
  old magazine are lost.
- A weapon with an empty magazine and no spares is dry for the rest of the mission.
- **Aircraft carry no spares.** When dry, they withdraw to rearm.
- Between missions, a refit restocks every magazine and spare.

| Weapon | Magazine | Spares | Weapon | Magazine | Spares |
| --- | ---: | ---: | --- | ---: | ---: |
| AR-40 Longhorn Rifle | 4 | 2 | Type-09 Long Cannon | 3 | 2 |
| Type-07 Drum Rifle | 5 | 1 | 125mm Tank Gun | 3 | 2 |
| GSh-6M Rotary Cannon | 3 | 2 | Coaxial Machine Gun | 6 | 1 |
| AC-30 Rotary Cannon | 3 | 2 | AGM-M Wing Stores | 2 | 2 |
| SG-12 Breaching Shotgun | 3 | 2 | Hornet Missile Pod | 2 | 2 |
| BR-90 Marksman Rifle | 3 | 2 | Grad-M Rocket Battery | 1 | 3 |
| LR-3 Linear Rifle (+1 Energy) | 4 | 1 | PB-4 Stake Driver | 3 | 1 |
| Nose Autocannon (aircraft) | 6 | 0 | Guided Missiles (aircraft) | 2 | 0 |

## 12. The Discord bot

The bot is the preferred way to play. Everything above also works on paper.

- **Source of truth.** The bot loads the game's catalogues (`standard.json` and the workshop
  catalogues), so weapon, frame and Protocol numbers match the game exactly.
- **What it tracks:**
  - Structure, Energy and Will;
  - loads and spares per weapon;
  - active effects with their strength and rounds left;
  - engagements and Charge bonuses;
  - each unit's stance;
  - field coverage;
  - initiative and the current round and phase.
- **The map.** Given hex coordinates, facings and altitudes, the bot works out range, arc, line of
  sight, cover and who is inside a field radius. Without a map it reads them from the command.
  Example: `!fire ar40 at BULWARK range 4 cover 1`.
- **Forecast before committing:** `!forecast` shows the hit, lock, crit and glance targets, the
  expected damage and the chance to destroy.
- **Secret orders** are sent to the bot by DM.
- **Agreement with the game:** the Godot rules tests export test vectors (inputs and expected targets,
  forecasts and damage), and the bot must reproduce them. The hex conversions in §6 are tabletop
  only, so test vectors give range and cover directly.

## 13. Workshop pilot sheets

These are **pilot ratings** from [workshop_pilots.json](../data/catalogues/workshop_pilots.json), before
hardware and thresholds. The standalone skirmish roster has different profiles.

| Pilot | Gunnery | Melee | Precision | Reflex | Systems | Countermeasures | Spirit | Will |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sol / ANCHOR | 1 | 1 | 0 | 1 | 0 | 2 | 2 | 2 |
| Mara / KESTREL | 2 | 0 | 1 | 0 | 2 | 0 | 2 | 2 |
| Vale / ROOK | 1 | 0 | 0 | 2 | 1 | 1 | 2 | 2 |

All three have Push and the same seven-point budget:
- **ANCHOR** is hard to lock or hack up close.
- **KESTREL** locks reliably and runs Protocols well, but is easy to lock.
- **ROOK** is even on both.

Before hardware, size, aim, cover or effects:

| Pilot | Ranged target vs Reflex 0 | Melee target vs Reflex 0 | Crits on | Lock target vs CM 0 | Enemy lock vs them (Systems 0) |
| --- | ---: | ---: | --- | ---: | ---: |
| ANCHOR | 6 | 6 | never | 5 | 3 |
| KESTREL | 7 | 5 | 1 | 7 | 5 |
| ROOK | 6 | 5 | never | 6 | 4 |

## 14. Worked examples

### Attack

KESTREL fires an AR-40 Longhorn Rifle: **3 shots, 6 damage, +0 aim, magazine 4**. Her ratings are
Gunnery 2, Precision 1 and Systems 2. The target is 4 hexes away. It is medium, with Reflex 1,
Countermeasures 0, Armour 2 and no matching armour type, and stands behind a barrier (cover 1).

1. **Lock:** target 5 + 2 − 0 = **7**. She rolls 3: **LOCK**, 1 reroll.
2. **Ammo:** the magazine goes to 3 of 4.
3. **Hit:** target 5 + 2 − 1 − 1 = **5**. Shots roll 2, 5 and 8: two hits and one clean miss.
4. **Reroll** the miss: 6, which misses again.
5. **Crits** on 1: the crit dice roll 1 and 6, so one crit and one normal hit.
6. **Damage:** 6 + (6 − 2) = **10 Structure**.

With Push (1 Will), the target is 7. The reroll of 6 would then hit, for three hits.

### A brace

Run the same attack, but the target braced in planning, with Brace 2.

1. **Hit:** its Reflex no longer counts, so the target is 5 + 2 − 1 = **6**. The shots roll 2, 5 and
   8, and the rerolled 6 now hits as well: three hits.
2. **Crits:** the crit dice roll 1, 6 and 7, so one crit and two normal hits. Before bracing, that is
   6 + 4 + 4 = 14.
3. **Brace:** the target is 5 + 2 = **7**. It rolls 4, 8 and 2 for the three hits. That halves the
   crit to 3 and the last hit to 2, and the middle hit gets through whole.
4. **Damage:** 3 + 4 + 2 = **9 Structure**, against 10 had it evaded.

### Charge and breaking off

ANCHOR's M9 Teamster (Move 3, Melee 1) charges BULWARK's OB-12 Medved, which is 4 hexes away in
its Front arc. Charge reach is Move + 1 = 4, enough to reach an adjacent hex.

1. **Movement.** ANCHOR's Reflex is 2: pilot 1 + frame 1. BULWARK's pilot Reflex is 2, but the Medved's
   threshold holds it to 1. ANCHOR moves first: 3 hexes along the shortest path, ending adjacent. The two
   are engaged and ANCHOR pays 1 Energy. BULWARK had planned to step back, but it is now engaged, so
   its order is lost.
2. **Attack.** ANCHOR swings the PB-4 Stake Driver at BULWARK (Reflex 1, Large):
   5 + 1 − 1 + 1 (Large) + 2 (Charge bonus) = **8**.
3. **Next round,** BULWARK breaks off. ANCHOR has not attacked yet, so it takes a parting strike at
   +2: the same target of 8, because the Charge bonus has ended. BULWARK then backs 1 hex away, and
   ANCHOR keeps its action but has used its attack.

### Protocol

An HX-7 Kestrel with Systems 2 uses **Target Painter** (Standard, 1 Energy) on BULWARK, who has
Countermeasures 1.

- The target is 5 + 2 + 0 − 1 = **6**. Without BULWARK's Countermeasures it would be 7.
- The roll is 7: **COUNTERED**, because it is above 6 but within 7. "BULWARK's countermeasures
  counter Target Painter."
- The Energy and the action are spent.

## 15. Playtest scope

This is a rules draft, not a complete RPG. These are still to be designed:
- character advancement within the pilot limits;
- social and exploration skills;
- pilot injury and ejection when a mech is destroyed;
- mission rewards and campaign income.

Start with one squad against a small enemy group. Measure:
- resolution time, with the bot and on paper;
- weapon usefulness against Armour;
- the value of Reflex, Systems and Countermeasures;
- whether matched part sets feel worth chasing;
- whether a reload is ever a hard choice against a Protocol;
- whether anyone runs dry before the fight is decided.

Hex conversions to watch:
- Rounding Move down makes the Medved and Tieshan about 20% slower than in the game.
- The 90° and 120° weapon arcs become 60° and 120°.
- The game's 135° High-G turn becomes a full reversal.
- Altitude adds whole hexes to range rather than measuring in 3D.

**Tabletop only:** task checks, on-foot ratings, Will recovery between missions and the hex map.
**Agreed but not yet built in Godot:** Protocols, the automatic Target Lock, ammunition, and the
evade or brace stance.

References:

- [Protocols plan](protocols-plan.md) and [ammunition plan](ammo-plan.md).
- [Stats, thresholds and fractions](../units/unit_state.gd).
- [Attacks, crits and Armour](../combat/rules/combat_rules.gd).
- [Movement](../movement/rules/movement_rules.gd), [charges and breaking off](../combat/rules/melee_rules.gd)
  and [terrain](../battle/world/terrain_rules.gd).
- [Size adjustments](../data/definitions/size_class.gd).
- [Weapon and frame catalogue](../data/catalogues/standard.json).
- [Workshop pilots](workshop-pilots.md) and [components and Energy](workshop-components.md).
