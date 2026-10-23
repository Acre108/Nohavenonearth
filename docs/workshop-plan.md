# Mech workshop proposal

Status: planning only, 18 October 2026. Slot names, costs and condition rules below are proposals.

Implementation update, 18 October 2026: the first playable example now uses **Teamster only**.
Every region is limited to **two components**, with no nested subcomponents. Launching the project
opens `workshop/Workshop.tscn`. It supports owned spares, compatibility checks, repair quotes,
transactional refits, paint presets, local persistence, deployment and hull-damage return. Combat
component damage and campaign income remain later work. The rest of this document records the
original broader proposal.

## Player experience

Open Workshop from the squad, select a mech, inspect its installed equipment, repair damage,
replace components from shared stores, and customise its finish. Preview the complete refit and
its cost before applying it. The frame keeps its identity while its equipment tells its service history.

The workshop should feel like a working depot: a stationary mech on a service stand, readable
technical callouts, inventory labels, worn paint and manufacturer-specific fittings. Use a quiet
technical interface around the model, consistent with the game's existing readable planning UI.

## Screen sketch

```text
 WORKSHOP    Squad / ANCHOR / M9 Teamster           Stores | Funds
 ------------------------------------------------------------------
 SQUAD              SERVICE BAY                    SELECTED PART
 ACE   Kestrel      Front / Rear / Rotate          Left arm assembly
 ANCHOR Teamster                                   Condition / maker
                    Mech with clickable           Effects / mounts
 Readiness          component callouts            Repair | Replace
 and repair bill                                  Compatible stores
 ------------------------------------------------------------------
 Parts | Weapons | Paint & markings     Current -> Proposed stats
 Pending work: repairs, swaps, paint    Cost | Discard | Apply refit
```

Selecting a body region expands its components. A synchronised parts list provides access to
hidden/internal parts and avoids relying on tiny model hotspots. Replacement candidates show
owned quantity, condition, compatibility and resulting whole-mech stat changes. Incompatible
items can be revealed with a specific explanation. Colour is reinforced by text/icons.

Edits form a draft. Switching mechs retains each draft; leaving with drafts offers Apply or
Discard. Apply revalidates and commits inventory, funds and installed parts together. Previewing
a part never spends resources or modifies the live squad.

## Parts and slots

Start with 14 installed components on a typical humanoid frame:

| Region | Components | Main role |
| --- | --- | --- |
| Head | Sensor/control assembly | Gunnery or Precision tradeoffs |
| Left arm | Actuator assembly; armour shell | Handling/melee; protection |
| Right arm | Actuator assembly; armour shell | Handling/melee; protection |
| Left leg | Drive assembly; armour shell | Mobility; protection |
| Right leg | Drive assembly; armour shell | Mobility; protection |
| Torso | Structural/cockpit assembly; armour package | Structure; protection |
| Power | Power plant or battery assembly | Energy capacity and recharge |
| Backpack | Service assembly; mission module | Cooling/support; specialist equipment |

Each frame defines its actual slot tree. Extra arms, left/right wings, auxiliary thrusters,
tail assemblies and similar features are explicit extensions. An AW-3 Lifter can have four arms
without special UI code. Slots have stable IDs, accepted component families, required/optional
status, and dependencies. Optional empty mission mounts differ from missing essential hardware.

Weapons mount onto installed components rather than occupying a second independent equipment
system. A rifle uses a hand mount; wing stores require the relevant wing; backpack weapons need
the correct module. Removing a parent previews all affected equipment and returns detached
items to stores when the refit is applied. Internal components need not change the silhouette.

Compatibility follows mount, scale, frame family and explicit supported interfaces. Adapters
can later make League-style cross-manufacturer refits possible. Sharing a slot type alone does
not make an aircraft-derived leg fit a heavy industrial frame.

## Repair and readiness

- Repair retains the installed component and restores its condition for a quoted cost.
- Replace installs an owned compatible instance and returns the old instance to stores with
  its condition intact. Moving a part from another mech is an explicit transfer, never a silent swap.
- Customise changes paint zones, markings and wear presentation, independently of combat bonuses.
- Repair all quotes the selected mech's work, with a separate explicit squad-wide action.
- Missing required components, destroyed components, or broken dependencies block deployment;
  serviceable damage shows a readiness warning and its exact effects.

Proposed eventual condition model: continuous integrity with readable Serviceable, Damaged,
Disabled and Destroyed labels. Use a small set of stated penalties, rather than multiplying
every stat by condition. Damaged sensors might lose their bonus; a disabled wing removes the
capabilities it supplies. Repairable versus destroyed needs an explicit salvage rule.

The current combat model only tracks whole-mech Structure. First release should persist and
repair that hull damage, while supporting seeded component damage in a workshop demonstration.
Do not invent limb hits from aggregate battle damage. Location damage, disabled weapons,
mobility loss, wreck recovery and component loss need a separate combat design pass. Until
that exists, destroyed battle units should enter a visible recovery-needed state; permanent
loss or automatic component recovery must not be inferred.

## Stats and equipment choices

Parts should create tradeoffs: reinforced arm protection versus lighter handling, a larger
battery versus a lighter pack, or precision sensors versus rugged general-purpose equipment.
Standard installed parts must reproduce today's frame numbers exactly. Define chassis values
and standard component contributions together, so moving to parts never doubles the existing
Armour, Structure or bonuses.

Keep current pilot stat caps and quarter-point rounding. Show capped bonuses in comparisons.
Pilot stats remain separate from hardware; parts do not improve Spirit by default. Replacement
hardware may grant explicit capabilities, but pilot stat thresholds should not gate manoeuvres.
Start with compatibility and bounded stat changes; defer mass, continuous power draw, thermal
simulation, repair timers and crafting until they have a clear gameplay purpose. Use one
provisional repair currency for the prototype; final prices await campaign economy design.

## Implementation boundaries

Keep catalogue definitions immutable. Add definitions for parts and frame slots, plus persistent
instances for owned mechs and individual parts. A part instance records its unique ID, definition,
condition and cosmetic overrides. Squad state owns inventory, funds and installed-slot mappings.

Workshop rules validate refits and quote costs. One loadout resolver derives effective frame
stats, equipment and capabilities for the workshop, deployment and battle. Its results feed the
existing UnitLoadout/UnitState boundary without modifying shared FrameData resources. Battle
results update persistent damage once, keyed by a battle/result ID to prevent repeated charging
or damage application. Version the save format from the beginning.

Reuse UnitModelFactory for previews initially. Add named component anchors and modular meshes
incrementally; the present authored models are not already a library of interchangeable limbs.
UI equipment changes must resolve correctly even when only the callouts and stats can represent
an internal or not-yet-modelled component.

## Build sequence

1. Define Kestrel and Teamster slot layouts, their standard fits, and a small set of meaningful
   alternatives. Agree compatibility, repair and deployment rules using these examples.
2. Build persistent squad/inventory state, save/load, refit transactions and the shared resolver.
   Standard fits must match existing battle stats and equipment exactly.
3. Build the service-bay screen, parts list, compatibility filters, comparison preview, repair
   quotes, Apply/Discard and basic paint zones. Include a damaged demonstration mech.
4. Connect squad deployment and whole-mech battle damage/recovery reporting. Verify repairs and
   equipment survive restart and battle results cannot be applied twice.
5. Add combat component damage, salvage, adapters, extra-slot frames and modular visual assets
   in subsequent passes, each with its own rules and balance checks.

First playable acceptance: select a squad mech, repair its hull, replace an owned compatible
component, see accurate stat/equipment differences, recolour it, save, restart and deploy that
exact configuration. Invalid or unaffordable refits must leave funds and inventory unchanged;
one owned component must never be installed in two places. Keep the existing standalone
skirmish usable, and run battle regression/balance checks when resolved combat values change.
