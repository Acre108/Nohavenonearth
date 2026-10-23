# Code structure

The project groups each feature's rules separately from its presentation. Scenes are stored next
to their scripts. The default Godot entry point is `ui/menu/Landing.tscn`, which opens the workshop or battle demo. The standalone
battle scene is `battle/world/Battlefield.tscn`, whose script is `battle/interaction/battle_controller.gd`.

## Battle state and execution

`BattleState` and `UnitState` hold runtime state. `Catalogue` creates typed Resource definitions
from a scenario and its referenced shared catalogue. Pilot/frame debug overrides are copied into
the unit state, keeping source definitions reusable.

`TurnManager` owns phases, initiative, confirmed orders, activations and battle results. It calls
`MovementRules`, `CombatRules`, `AbilityRules` and `TacticalAI`. Rules operate on state and can run
without a rendered scene tree. Keep UI controls and visual effects out of this layer.

The turn manager emits phase, state, movement and attack signals. `BattleController` connects those
signals to the visible battlefield and HUD. The controller owns selection, weapon and target
choices; it supplies an initial attack target before refreshing the views.

## Player interaction

`BattleInput` handles picking, mouse projection, shortcuts and movement gestures. It translates
input into controller/session commands and leaves rule validation to the rule classes.

`PlanningSession` owns the draft order, altitude, destination/facing step, aircraft alternatives
and per-unit plan memory. Selecting a unit saves the previous draft and restores that unit's plan.
The controller retains short command methods used by UI controls, while planning state is accessed
explicitly through `controller.planning`.

## Battlefield presentation

`BattlefieldBuilder` constructs the table, lighting and picking surface using scenario bounds.
`BattleOverlayRenderer` draws orders, movement envelopes, arcs, LOS and enemy threats. Draft drawing
and enemy threat drawing use separate roots, preserving the existing hover behaviour.

`UnitActor` synchronises a unit model, markers, health and animations with its state.
`UnitModelFactory` selects authored models using `MODEL_SCENES` and builds procedural fallbacks and
wrecks. Add authored frame models to that registry. Preview ghosts use the same factory.

`BattlePresentation` controls Sensor/Cinematic visuals and their saved preference. It does not
advance the rules. `art/` also contains the palette, shaders and geometry helpers.

## HUD sections

`BattleUI` creates the layout, attaches its sections and coordinates refreshes. Each section owns
its widget references rather than storing every control on the HUD shell.

| Location | Owns |
| --- | --- |
| `ui/panels/battle_header.gd` | Round, phase, initiative, waiting status and view controls |
| `ui/panels/unit_panels.gd` | Roster, selected-unit inspector and full-stat window |
| `ui/panels/battle_telemetry.gd` | Combat log formatting |
| `ui/panels/battle_results.gd` | Victory/defeat overlay |
| `ui/commands/battle_commands.gd` | Command area, preview feedback, forecasts and dice |
| `ui/commands/planning_commands.gd` | Planning controls |
| `ui/commands/action_commands.gd` | Locks and Action-phase powers |
| `ui/commands/attack_commands.gd` | Weapon, target, firing and reroll controls |
| `ui/widgets/flight_radial.gd` | Aircraft path buttons and screen positioning |
| `ui/widgets/battle_ui_section.gd` | Shared widget builders and section context |
| `ui/widgets/battle_theme.gd` | HUD theme construction |
| `ui/debug/battle_debug_panel.gd` | Debug window and live battle overrides |

Gameplay controls call controller or turn-manager commands. Target defaults are chosen by the
controller, so rebuilding the attack panel does not change target selection. Debug controls remain
an explicit exception: they edit live overrides and notify `TurnManager.debug_changed()`.

## Workshop and owned loadouts

The landing screen opens `workshop/Workshop.tscn`; the battlefield scene remains directly
runnable. `WorkshopState` owns the flat region/slot contract, unique inventory instances, condition,
compatibility, costs, detached frame resolution and versioned saves. Content lives in
`data/catalogues/teamster_workshop.json`. Regions may contain at most two components.

`WorkshopUI` keeps an unapplied draft separate from owned state. `WorkshopPreview` renders the
existing Teamster asset in a separate 3D world, with region picking and rotation.
`WorkshopAppearance` applies paint and mission-module presentation to both bay and battle models.
`TeamsterAnimator` plays imported rigid-joint clips on the Teamster, with sockets and weapon flashes.
`UnitActor` starts locomotion/firing from presentation events; `WorkshopPreview` exposes explicit clip
playback and restores neutral pose for exploded/isolated inspection. The Blender control skeleton
is baked into node transforms, preserving the workshop region/component hierarchy.
The revised asset exposes eight `Region_*` roots and fourteen `Component_*` pivots for assembled,
exploded and isolated inspection. Manufacturer, exact size and mount-family checks live in
`WorkshopState.compatibility`; reservations are summed into the detached frame's `energy_reserved`.
`FrameData.energy_available()` supplies the fractional battle maximum and recharge ceiling.
See [component rules](workshop-components.md) for the complete contract.

The `WorkshopSession` autoload (`WorkshopRuntime`) bridges explicit workshop deployments to the
battle. It resolves a fresh catalogue before `TurnManager.setup`, then records Teamster hull
damage on battle completion/return with an idempotent result ID. Direct standalone battle loads
keep the original catalogue and never consume workshop inventory. `UnitLoadout.starting_structure`
and `workshop_finish` carry the detached deployment snapshot; shared FrameData remains unchanged.

Save commits write a temporary file before replacing the previous save. Invalid drafts, insufficient
funds and save failures retain the old owned state. An unreadable save blocks writing to protect
the original file. `tests/test_workshop.gd` exercises ownership/resolution/save invariants;
`tests/test_workshop_ui.gd` exercises the rendered bay and deployment/return flow with an isolated save.

## Adding features

| Change | Start here |
| --- | --- |
| Weapon, pilot or frame stats | `data/catalogues/standard.json`; formulas in [stat-system.md](stat-system.md), check balance with `tests/balance_run.gd` |
| New map/deployment | Copy `data/scenarios/skirmish.json`, then pass its resource path to `Catalogue.new(path)` |
| New definition field | Corresponding Resource in `data/definitions/`, then loader/validation if needed |
| Movement behaviour | `movement/rules/movement_rules.gd`; add planning/AI handling for a new movement family |
| Combat behaviour | `combat/rules/combat_rules.gd` |
| Pilot power | Catalogue entry and `AbilityRules`; wire its invocation and controls where needed |
| New authored model | `UnitModelFactory.MODEL_SCENES` |
| HUD change | Relevant section above; shared appearance belongs in the theme/widgets |

Ability event signals are extension hooks, not an automatic ability execution framework. New effects
still require explicit handlers and invocation; this reorganisation preserves the existing rules.

## Verification

Run `powershell -ExecutionPolicy Bypass -File .\Test.ps1 -WithUI` from the project directory.
It imports the project, runs deterministic headless rules, and exercises rendered UI/art, a complete
battle and restart. Logs and screenshots go to ignored `artifacts/`.
