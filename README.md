# No Haven on Earth

A playable native Godot 4 tactical skirmish prototype. A United States detachment (HX-7 Kestrel, M9 Teamster, fighter) faces three Eurasian Pact AI units (OB-12 Medved, Type-09 Tieshan, fighter) on a continuous 3D tabletop. The frames are early Gen 2 designs from the No Haven on Earth Atlas. Built and tested with **Godot 4.7.2**, using the installation at `C:\Program Files (x86)\Godot\Godot.exe`. No plugins, third-party libraries, or downloaded assets.

## Play

Double-click **Play.cmd** or press **F5** in Godot to open the **landing screen**. Choose **Open workshop** for the Teamster service bay, or **Play battle demo** for the original standalone battle. From the workshop, **Deploy** uses your saved Teamster fit; **Main menu** returns to the landing screen. You can also press **F6** with `battle/world/Battlefield.tscn` open for the standalone battle.

### Teamster workshop

The M9 Teamster is the example owned frame: eight regions, fourteen components, and a hard limit of **two components per region**, with no deeper nesting. Equipment icons flank the central model. One right-hand panel lists hull, power and movement, then a **Frame / Pilot / Total / Threshold** table and equipped weapon profiles. Frame includes fitted hardware and wear; Total is pilot + whole hardware points (part fractions count once they add up to a point), capped at the frame's Threshold. Click a slot or the model to open its equipment picker; select a spare icon to inspect its stats and choose **Equip**. Drag the model to rotate and scroll to zoom. **All parts** includes incompatible equipment for the selected mount, with its fitting restriction shown.

The bottom bar offers three illustrated pilots: **Anchor** (brawler), **Kestrel** (marksman), and **Rook** (skirmisher). Clicking a portrait previews the pilot's contribution immediately; **Apply refit** saves the assignment and **Discard** restores it. The selected pilot and callsign carry into deployment. All three have the same five-point base stat budget and Push ability. See the [pilot roster and portrait sources](docs/workshop-pilots.md).

Equipment borders are **green / Standard**, **blue / Uncommon**, and **red / Rare**. A moving highlight indicates a customised component. In an equipped part's picker, choose a **Finish** swatch to paint that individual component; **Factory** restores the frame finish. Custom finishes are free, remain with that inventory item when it is removed, and persist into battle. The small strip inside each icon shows condition; an amber dot marks a pending change.

Components carry a manufacturer tag and size class. The medium Brannock-Hale Teamster accepts matching manufacturers, exact-size components and compatible mounts. Intensive hardware reserves fractional Energy: a 0.5 reservation reduces a 3-Energy plant to 2.5 usable Energy, including its recharge ceiling. The inspector shows rated, reserved and available Energy; refits exceeding the plant budget are rejected. See [component rules](docs/workshop-components.md).

The revised Teamster has explicit region and component assemblies, more detailed mechanical fittings, and separate region exports. The visible **Assembled**, **Exploded**, and **Isolate region** buttons above the model switch inspection modes. Exploded inspection stays selected while changing pilot, parts or paint. Playing an animation returns the model to Assembled.

The Teamster is animated: idle, walk, left/right turns, weapon ready, rifle bursts, missile launches, stake-driver firing and melee. Choose a clip in the workshop's animation dropdown and use **Play**, **Pause**, or **Rest**. Movement and attacks select animations automatically in battle. See [animation and Blender rig notes](docs/teamster-animation.md) for the editable skeleton, rebuilding and current flat-ground gait limits.

The workshop's frame selector also opens the **HX-7 Kestrel**, with its own saved
fit and nineteen animations: ground locomotion, weapon handling, folding knife,
hover/flight, takeoff/landing and evasive banks. Its Blender control rig is editable,
and battle movement and weapon events select the matching clips. See
[Kestrel animation notes and previews](docs/kestrel-animation.md).

The demonstration starts with 1,800 repair credits, 14 hull damage and a worn left-arm actuator. Repair the hull or a component individually, or queue **Repair all**. Below 60% condition, components apply the displayed wear penalties; zero condition or a destroyed hull blocks deployment. Replacements cost 40 credits to fit and return the old component to stores. Inventory items are unique: the same spare cannot occupy both arms.

Equipment slots, **Weapon kits**, and **Paint** expose the pending fit. The recovery mission module replaces the Hornet carrier, removing the missile weapon and changing the visible equipment. Four paint presets recolour armour, secondary panels and markings. All regions have modelled alternate fittings. New arm options include a rotary cannon, breaching shotgun and paired two-handed marksman rifle; open **Weapon kits** and choose **Preview two-handed rifle kit** to try the paired components. Animation controls sit below the model. See [alternate equipment](docs/teamster-alternate-parts.md).

**Apply refit** commits repairs, replacements and paint together; **Discard** restores the installed configuration. Deployment requires applied changes. Saves live in Godot's `user://teamster_workshop_v1.json` in Godot's application data directory. Workshop deployments carry the resolved stats, weapons, hull and paint into the existing squad skirmish. Use **Workshop** in battle to end the sortie and return, or return from the results screen. Hull damage is saved on battle completion or return; individual component damage is currently a seeded workshop demonstration, not a combat hit-location system. Closing a running battle does not save its progress.

The **Skirmish demo** uses the original full-health catalogue units and does not change workshop ownership. Repair prices and starting funds are provisional; there is no campaign income or shop yet.

1. Select a Blue unit using its model or roster entry.
2. **Mechs:** pick a manoeuvre and altitude, hover the field to preview, then **click a destination**. Move the mouse to aim the ghost and its weapon sector, then **click again to lock and confirm**. Facing stays inside the manoeuvre's turn limit; **Esc** picks a new destination. The command panel shows the two steps with the current one lit.
3. **Aircraft:** a ring of flight-path buttons surrounds the selected aircraft (S4 = Straight 4, BL4 = Bank Left 4, HL3 = Hard Left 3, GL2 = High-G Left 2, and so on; hover for the full name and cost). Every path is drawn as a faint line on the map; hovering a button brightens its line. No ghost models are drawn for aircraft drafts. Click a path to select it and **click it again** (or **CONFIRM MOVE**) to confirm. The next unordered friendly unit is selected automatically. **Suggest** creates a legal draft using the same AI as Red; review and confirm it yourself.
4. When all living Blue units have confirmed orders, click **COMMIT ORDERS**. Enemy movement is then revealed. Units move from highest to lowest Reflex.
5. In **ACTION**, optionally acquire a target lock (any unit can), use the ace's **Newtype Reflexes**, then **END ACTION** for each Blue unit. Red acts automatically.
6. In **ATTACK**, units with no legal target for any equipped weapon automatically skip firing. Eligible Blue units start with a weapon that can fire. Choose a weapon, then a highlighted enemy or the target dropdown, and **FIRE**. Arm **Push** (+20% to hit, 1 Will; every pilot has it) or the ace's **I Can See It** (reroll misses) before firing. **HOLD FIRE** passes an eligible activation. Attacks resolve highest Reflex first; destroyed units lose their activation. If everyone lacks a legal target, the round proceeds directly to End after actions.
7. Energy recharges at the end of each round. Will does not. Eliminate the enemy detachment to win; restart from the result screen or debug menu.

The game pauses for your actions and attacks. Movement resolution otherwise advances automatically. Initiative appears across the top of the screen, and the telemetry panel records movement, collisions, locks, attacks, cover, damage, and destroyed units. The last attack's shots appear in the command panel (● hit, ◆ crit, ◐ glancing, ○ miss); ↻ marks a rerolled shot.

### Camera and feedback

| Input / marker | Meaning |
| --- | --- |
| WASD / arrow keys | Pan |
| Middle mouse drag | Pan |
| Mouse wheel | Zoom |
| Right mouse drag / Q / E | Orbit |
| R / Reset view | Restore tactical camera (also leaves close view) |
| V / Close view, or wheel in past the closest table zoom | Perspective close view orbiting the unit under the cursor (else the selected unit). Planning works as normal; wheel out fully, V or R returns |
| Any key or click during a cinematic | Skip to the end and return to the previous view |
| F3 / Debug | Open rules sandbox |
| Amber path and ghost | Current draft |
| Cyan / salmon path | Confirmed Blue / revealed Red order |
| Magenta draft / × INVALID | Illegal movement; reason shown in command panel. Magenta also marks blocked LOS and "cannot fire" |
| Ivory corner brackets | Selected unit |
| Ivory rotating crosshair | Legal target for the displayed weapon |
| Pale neutral sector and solid boundary | Usable weapon range inside the firing arc |
| Magenta wedge inside a sector | No line of sight there: sight-blocking terrain hides that part of the arc (same check as the rules, for the target altitude shown) |
| `+N COVER` above terrain or a wreck | −N×10% to hit a unit sheltering behind it |
| Inner boundary | Minimum range; targets inside it are too close |
| Dashed outer circle | Maximum range around the unit; firing still requires the solid arc |
| Numbered range badge / target ruler | Weapon limits, target altitude band, and exact target distance |
| One / two tether ticks, shrinking shadow, `· LOW` / `· HIGH` caption | Low / High altitude; no tether means Ground |
| F8 / Sensor view | Toggle optional Sensor View without advancing the battle |

The battlefield uses normal cel shading throughout planning and resolution. Sensor View is off by default; abilities can temporarily enable it with `presentation.show_sensor_for(seconds)`.

The battle has one camera with three modes (`battle/world/tactical_camera.gd`): the orthographic **table view**, the perspective **close view**, and **attack cinematics**. Switching between orthographic and perspective is a dolly zoom: the lens starts nearly orthographic and widens as the camera moves in, so the frame never jumps. In close view, Q/E or right-drag orbit (right-drag up/down tilts), WASD or middle-drag pan away from the unit, and selecting a unit glides back to it. Leaving close view keeps its heading.

Each attack can play a short cinematic: the camera swings in over the attacker's shoulder as it fires, then cuts to the target for the hit, drain and any destruction. The HUD, overlays, captions and health bars are hidden behind letterbox bars, and the turn waits for the cinematic. Shots are chosen from several angles so cover never blocks either unit; if none is clear, the attack plays in the normal view. **Cinematics ▾** in the header switches them on or off separately for Blue and Red attacks. Both are on by default, and the choice is saved in `user://battle_settings.cfg`. Rules, AI and results are unaffected. `artifacts/camera_review.gd` renders review frames of every mode.

The [23 October OVA graphics pass](docs/ova-rendering.md) uses Forward+ on desktop: scene-lit three-band mechs, blue-violet shadows, warm rims, hull outlines and masked interior ink over a softly painted wet dock. High-threshold glow, violet LUT grading and film effects sit beneath the crisp HUD. The Teamster holds poses at 12 fps. Open `art/StyleTest.tscn` to inspect the mask and try 75% LaserDisc rendering. Armour uses world-scale trims, stencil cards and selective Pact hazard tape. Four sodium masts provide warm lighting; fog, SSR and rain are confined to perspective views. The standard dock uses prebuilt geometry with live lighting; the redundant lightmap bake was removed after comparison.

The [17 October art pass](docs/art-pass-2026-10-17.md) adds Sensor/Cinematic materials, clearer silhouettes, contour terrain, a Blender-built Blue mech, and `art/StyleTest.tscn` for review. That model (`art/models/blue_line.glb`) predates the Gen 2 roster and stands in for the HX-7 Kestrel until a Kestrel model is built. Other frames retain procedural models pending later Blender builds.

Click weapon buttons in the inspector to inspect their arcs outside the Attack phase. Scroll the side panels for all weapons, manoeuvres, and powers. Hover previews are guidance; final rules are rechecked on confirmation, commit, movement, and attack.

During planning, the weapon overlay follows the valid destination/facing ghost. The overlay carries no text of its own (weapon name, range and arc are in the inspector and weapon dropdown); with a target chosen, a ruler shows the distance to it. During an attack, choosing a target adjusts the range footprint for that target's altitude; the ruler uses exact three-dimensional rule distance. Range overlays are projected onto the ground to align with base markers and terrain. The sector shows geometric range; actual target eligibility also checks facing, LOS, and Energy, and uses ivory crosshairs.

## Rules implemented

### Longer-battle tuning

The current skirmish uses a **36×26** battlefield (previously 22×16), with opposing mechs deploying **22 units apart** instead of 10. The camera overview, zoom/pan limits, table geometry, and mouse-picking surface follow the scenario bounds in `data/scenarios/skirmish.json`. Low ruins block ground movement while Low/High flight can cross them, creating faster aerial routes through the expanded approach area.

| Side | Frame | Type | Structure / Armour | Weapons |
| --- | --- | --- | --- | --- |
| Blue | HX-7 Kestrel | Flying | 60 / 1 | LR-3 Linear Rifle, AGM-M Wing Stores, VB-2 Vibro Knife (all draw Energy) |
| Blue | M9 Teamster | Ground | 72 / 2 | AR-40 Longhorn Rifle, Hornet Missile Pod, PB-4 Stake Driver |
| Red | OB-12 Medved | Ground | 90 / 3 | Grad-M Rocket Battery, GSh-6M Rotary Cannon, Molot Hydraulic Ram |
| Red | Type-09 Tieshan | Ground | 72 / 2 | Type-09 Long Cannon, Type-07 Drum Rifle, Type-11 Dao Blade |
| Red | Type-99 Main Battle Tank | Ground (tank) | 20 / 3 | 125mm Tank Gun, Coaxial Machine Gun (both 360° turret) |
| Both | F-12 Peregrine fighter | Aircraft | 14 / 0 | Nose Autocannon, Guided Missiles |

The Gen 2 roster replaced the prototype frames (RX-style Gundam, M-04, H-09, VX). The Tieshan is new; Red no longer has a flying mech, because the Pact fields none in early Gen 2.

Red fields four units to Blue's three. The stat redesign of 18 October 2026 re-tuned every number; Blue wins **49%** (seeds 1–150) and **51%** (seeds 151–300) of AI-vs-AI battles, averaging about 16 rounds. **The melee prototype (charge, engagement, break off) has since moved this to Blue 74% (seeds 1–150, about 14 rounds) and has not been re-tuned**; with the Charge manoeuvre removed from every frame, it is back to 47%. Run `--script res://tests/balance_run.gd -- --seeds 150 --start 1` to reproduce. See [the stat system](docs/stat-system.md) for every formula, unit breakdown and the tuning log.

Before the redesign, the tank was tuned over the same AI-vs-AI runs:

| Red addition | Blue wins | Seeds |
| --- | ---: | ---: |
| None | 93% | 60 |
| Second F-12 fighter | 77% | 60 |
| Tank, 15 Structure, 4-dice gun | 22% | 60 |
| Tank, 9 Structure, 3-dice gun | 38% | 150 |
| Tank, 6 Structure, 3-dice gun | 58% | 150 |
| **Tank, 7 Structure, 3-dice gun (pre-redesign)** | **49%** | 150 |

Battles averaged about 17 rounds. These are AI-vs-AI results; a human Blue player using Newtype Reflexes and target locks deliberately should do better than the AI. Energy costs and recharge still permit sustained routine shooting; the longer duration creates more turns for resource decisions but does not itself create an Energy deficit. See [the tuning results](docs/longer-battle-tuning.md).

### Core rules

- Six phases plus battle-over, seeded random initiative ties, and a replaceable tactical AI that chooses its hidden orders before Blue plans.
- Seven pilot stats — Gunnery, Melee, Precision, Reflex, Systems, Countermeasures, Spirit. The first six are each a whole-point total: pilot rating + the whole points of frame/part bonuses, with part fractions counting once they add up to a point, capped at the frame's threshold. Spirit is the pilot's own: no frame adds to it or limits it. Every roll is a d10 shown as a percentage, so each point is 10%. Every point has one fixed effect, and no stat opens or closes a manoeuvre. The **Full stats…** window (beside the unit name in the inspector) shows pilot, bonus and total with the per-point effect; the inspector itself shows only what is needed to play; debug overrides never change the source definitions.
- Ground destination movement, forward-cone flying-mech vectors, lateral and reverse thrust, takeoff/landing, and eight sampled aircraft curves. Frame support, Energy, altitude, obstacles, and endpoint collisions are checked centrally. Reflex adds 0.5 per point to free moves and aircraft path length.
- Ground movement passes through friendlies but not enemies or blocking terrain. Units at different altitude bands can overlap horizontally. Revealed endpoint conflicts stop the later mover immediately before contact, without damage.
- Range, 90/120/180/360-degree arcs, centre-to-centre LOS, directional nearby low/heavy cover, and three altitude bands.
- One d10 roll per shot at 50% + 10% × (Gunnery or Melee − target Reflex − cover), clamped 10–90%. Reflex defends against ranged and melee alike. Each hit deals weapon damage minus Armour (never below 0). Precision gives 10% per point for a hit to crit, ignoring Armour. Heavy weapons turn a miss within 20% of the hit chance into a glancing hit for half damage, then Armour. Melee range is measured base edge to base edge.
- Energy spending for advanced manoeuvres and weapons; capped Energy recharge; persistent non-regenerating Will.
- **Melee (prototype)** — `combat/rules/melee_rules.gd`:
  - **Charge** (Ground mechs at Ground altitude, 1 Energy): pick Charge, then click an enemy that is inside the ±60° cone ahead and within move + 1 + Reflex bonus. Click it again or press **CONFIRM MOVE**. Reachable enemies show ivory crosshairs.
  - The charge homes on the target's position when it resolves, so it follows a target that moved first. It stops at terrain, other units or the table edge. If it ends in base contact, both units are **engaged**, and the charger gets +20% melee to hit that unit this round.
  - A slower unit that is charged before it moves loses its own move.
  - **Engaged** units cannot move and can only attack the units they are engaged with. Melee between them ignores the firing arc. They face their foe at the start of each round. Other units can still shoot into the melee.
  - An amber tie with a cross links each engaged pair, and the caption reads `· MELEE`.
  - **Break Off** is an Action-phase choice that uses the unit's action. Each foe with a melee weapon takes its attack for the round early, as a **parting strike** at +20% (not stacked with the charge bonus). The unit then backs about 1.5 out of reach, keeping its facing, and may fire normally in the Attack phase.
  - Engagements end when a unit breaks off or a foe is destroyed.
- Target locks: any unit holds one. Acquiring it uses the unit's action and replaces any older lock. The next shot at the locked target rerolls one miss and consumes the lock; otherwise it persists until the target is destroyed.
- **Push**: every pilot; arm before firing for +20% to hit on that attack. 1 Will. Spirit sets maximum Will.
- **Newtype Reflexes**: one Will for up to ±45° additional facing during the post-movement Action phase. Repeated adjustment buttons spend Will only once that round.
- **I Can See It**: arm before firing; automatically reroll up to two misses that have not already been rerolled. One Will is spent only if an eligible miss remains beyond the target-lock reroll. Each shot is rerolled at most once.

## Debug sandbox

**F3** exposes restart, AI toggle, secret-order reveal, pause automatic resolution, single-step advancement, LOS/arcs/movement-range toggles, live pilot stats, live frame limits, Structure/Energy/Will, forced altitude, damage, and destroy. Select the unit before opening the menu. Stat/resource edits persist only in the current battle. Restart reloads the JSON definitions.

Manual step advances one unit or phase, and passes a Blue action/attack when waiting for player input. Stat changes during an already revealed round do not reorder the published initiative queues; the next reveal uses the new values. Force altitude deliberately bypasses frame restrictions for debugging.

## Project layout

| Directory | Responsibility |
| --- | --- |
| `battle/state/` | Mutable battle state and authoritative turn sequencing |
| `battle/interaction/` | Battle coordination, input, selection, movement planning session |
| `battle/world/` | Battlefield scene, table construction, terrain, camera, overlay drawing |
| `movement/rules/`, `combat/rules/` | Orders, results, validation and rule resolution |
| `movement/presentation/`, `combat/presentation/` | Preview scenes, targeting/threat overlays and attack effects |
| `units/` | Mutable unit state; `presentation/` contains actor scene, animation and model factory |
| `data/definitions/` | Typed Resource definitions for pilots, frames, weapons and powers |
| `data/catalogues/`, `data/scenarios/` | Reusable game definitions; battlefield setup and deployments |
| `ui/` | HUD shell; `panels/`, `commands/`, `widgets/` and `debug/` own their sections |
| `ai/` | Tactical movement and legal attack selection |
| `art/` | Models, shaders, palette, visual presentation and style-review scene |
| `tests/` | Rules, rendered UI/art checks and automatic battle runner |
| `docs/` | Architecture guide, art direction and tuning notes |

See [the architecture guide](docs/architecture.md) for the execution flow and where to add features.
Scenes live alongside their scripts. Edit reusable stats in `data/catalogues/standard.json`; edit
deployment, terrain and board dimensions in `data/scenarios/skirmish.json`. The scenario references
its catalogue, so additional scenarios can share the same units and weapons. Loading checks duplicate
IDs, content references and basic scenario structure before creating Resources.

Rules use `RefCounted` state and `Resource` definitions, not model transforms or physics bodies. Rendering follows state. Unit picking uses Godot physics raycasts; rule LOS uses equivalent mathematical segment/AABB intersections so it runs without a scene tree. `BattleState.to_dict()`, `UnitState.to_dict()`, and `MovementOrder.to_dict()` mark a future serialisation boundary; battle save/load is not implemented; workshop ownership has its own versioned save.

`TurnManager.rule_event` exposes `before_movement`, `after_movement`, `before_attack`, `after_attack_roll`, `when_attacked`, `when_damaged`, `when_destroyed`, and `end_of_round`. `AbilityData` declares the trigger, effect, magnitude, and Will cost. New effect handlers belong in `AbilityRules`, while new static content belongs in the catalogue.

## Deliberate prototype decisions / TODO

- **Aircraft crossing the table edge withdraw and are removed from battle.** The draft warns before confirmation. AI strongly avoids this. This prevents an aircraft trapped near an edge from permanently blocking planning. TODO: choose the final disengagement/return rule.
- Ground movement uses a direct segment. To go around a building, move to a clear intermediate position this round, then continue next round. TODO: optional multi-waypoint paths, using total path length for the movement budget.
- Altitude changes take the destination band for the whole movement path; visuals interpolate vertically. Physical flight and ascent trajectories are intentionally abstract. Range uses band spacing of 1.5 rule units; the render uses 1.7 world units. Melee cannot reach another band: its 0.5 range runs from the base edge. Arc overlays use the chosen target's altitude, or the shooter's own band when no target is selected; target highlights use exact rule checks.
- Terrain taller than the travel band blocks movement. Non-blocking cover can be crossed. Cover is the highest bonus from terrain within 1.1 units toward the attacker, never stacked. Low units need tall cover; High units gain none.
- Destroyed mechs (ground or flying) leave **wreckage**: low, non-blocking +1 cover for Ground units, like a barrier. It never blocks movement or LOS. Destroyed aircraft leave visual debris only; withdrawn aircraft leave nothing. Reviving a unit in the debug sandbox removes its wreck.
- Lock acquisition uses LOS and an 8-unit range.
- Newtype rotation is chosen in the Action phase after all movement. The reroll ability uses automatic blank selection, not a separate dice-selection modal.
- On a conflicting endpoint, an aircraft can be stopped by the shared collision fallback; this is the explicit collision exception to aircraft minimum movement. There is no ramming or collision damage.
- AI samples legal candidate moves and picks estimated damage/range/facing/cover. It does not predict hidden orders, coordinate formations, or use advanced pilot powers. It is intentionally replaceable.
- No campaign economy, construction, combat limb damage, multiplayer or progression. The Teamster workshop has a local inventory, repair funds and versioned persistence; battle progress itself is not saved.

## Verification

Run **`powershell -ExecutionPolicy Bypass -File .\Test.ps1 -WithUI`** from this directory. It imports the project, runs deterministic rules tests, then runs the native renderer through a complete battle and restart. Omit `-WithUI` for headless rules, workshop, animation and variant checks. Logs and screenshots are written to ignored `artifacts/`.

Standalone suites share assertion, frame-wait, screenshot and exit handling in `tests/test_suite.gd`. GPU checks, including the wet/dry lighting regression, live in `tests/test_ova_rendering.gd`. Each suite can still be run individually.

Direct commands:

```powershell
& 'C:\Program Files (x86)\Godot\Godot.exe' --headless --path . --editor --import --quit
& 'C:\Program Files (x86)\Godot\Godot.exe' --headless --path . --script res://tests/test_rules.gd
& 'C:\Program Files (x86)\Godot\Godot.exe' --path . --script res://tests/test_ui.gd
```

The rules suite covers stat totals, hardware fractions, thresholds and data isolation, initiative direction, all movement families, Energy gates, collisions, altitude overlap, withdrawal, terrain/LOS/cover, arcs/range, hit chance, crits, glancing hits, armour, melee reach, exact forecasts, one attack per activation, destroyed-unit exclusion, locks, Will abilities, recharge, and eight seeded battles reaching victory. The UI suite exercises rendered actors, picking, camera reset, debug, planning/confirm/commit, every phase, abilities, full-battle resolution, victory, and restart.

Godot may print `Failed to read the root certificate store` in this restricted Windows environment. The prototype is offline; this engine-level diagnostic does not affect play or the tests.
