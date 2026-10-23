# Component compatibility and Energy reservations

The Teamster is the first implemented frame. Regions remain flat, with at most two installed
components each. Its manufacturer is `brannock_hale` and its size class is `medium`, matching
the existing frame-size rules. Manufacturer names come from the local Gen 2 art briefs. The
linked Claude atlas could not be fetched during this pass; its latest contents were not verified.

## Compatibility

Each component definition has a manufacturer tag, size class, mount family and Energy reservation.
Installation requires all of the following:

- The manufacturer is accepted by the frame. By default this is its own manufacturer; an explicit
  `compatible_manufacturers` list can represent a licensed interface later.
- The component size exactly matches the frame size. Weapon rules allowing smaller weapons do
  not apply to structural components.
- The mount family matches the selected slot.
- The complete proposed fit stays within its power plant's rated Energy capacity.

The inspector displays manufacturer, size and reservation for installed components and spares.
Incompatible candidates can be revealed with the existing toggle; they explain the failed gate
and cannot be fitted. Apply validates the full transaction again. Manufacturer/size/mount failures
are also checked when loading saves, and readiness checks prevent invalid deployment.

## Equipment sheet and customisation

Fourteen equipment icons surround the model. A single right-hand table shows Frame, Pilot,
Total and Threshold, with equipped weapon profiles underneath. Threshold is the effective frame
stat cap; Total is the capped sum of pilot and resolved hardware. The bottom bar selects the
assigned pilot from three portraits. Visible Assembled, Exploded and Isolate region buttons
above the model control inspection. Clicking
a slot opens a compact picker with equipped and spare icons. Selecting an icon shows that
part's condition, manufacturer, size, reserved Energy, hardware bonuses and weapon profile.
Spare inspection includes the resolved stat changes before **Equip** adds it to the draft.

Definitions declare `rarity`: `standard` (green), `uncommon` (blue), or `rare` (red). Rarity is
display metadata and does not change fitting rules or stats. Current assignments are provisional.
Customisation is independent: an individual component finish produces a moving border highlight,
while its rarity colour stays intact. Repair and replacement drafts use an amber corner dot.

Drafts and saves store `part_finishes` by unique inventory ID. **Factory** removes that override,
so the component inherits the frame finish. Custom paint follows the item back into stores and
only colours its `Component_*` subtree in the workshop and deployed model. It costs no credits.
Old saves without this optional field load with factory finishes. Both unknown item IDs and
unknown finishes are rejected before a transaction is saved.

## Energy

Reservations are fixed Energy amounts, in increments of 0.25. They are continuously unavailable
while the component is installed, rather than a per-turn payment or a percentage multiplier.

`available maximum = rated capacity, including plant upgrades and damage effects − reservations`

For example, the Teamster's standard plant supplies 3 Energy. The precision rangefinder reserves
0.5, leaving a usable maximum of 2.5. The mech begins battle at 2.5; spending 2 leaves 0.5. Its
normal +1 recharge is capped at 2.5. Recharge rate itself is unchanged by the reservation.

The first balance values are:

| Component | Reservation |
| --- | ---: |
| SC-9P Rangefinder | 0.5 |
| HA-9F Fine-Control Servo, per arm | 0.5 |
| LD-9M March Drive, per leg | 0.75 |
| CS-9X High-Flow Pack | 0.75 |
| Standard components and passive protection | 0 |

These values are provisional. Standard fits retain their existing usable Energy. A fit that
reserves exactly the rated capacity is legal and has no Energy for weapons or advanced moves;
one that exceeds it cannot be applied or deployed. A larger plant can make the same fit legal.
Damaged components retain their reservation until repaired/replaced; a worn plant may lower the
capacity available to support the fit. Existing saves store component instances, so the new
metadata resolves from the catalogue without changing their ownership or save version.

## Region model contract

The rebuilt Teamster has eight `Region_*` nodes and fourteen `Component_*` pivots whose exported
`slot_id` metadata matches the workshop slots. Geometry, weapon attachments and decoration sit
under those component roots. The component limit concerns installed hardware, not the number
of meshes used to draw it.

The workshop supports assembled, exploded and isolated-region inspection. Picking follows the
region meshes and their transforms, including exploded positions. Region highlighting uses the
explicit hierarchy. The recovery attachment follows the backpack mission component.

The full assembly is `art/models/m9_teamster.glb`; separate region exports are in
`art/models/teamster_regions/`. They retain assembly coordinates so they can be reassembled
without manual alignment. Editable source is `art/source/m9_teamster.blend`.

Rebuild with:

```powershell
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_teamster.py
```

`Test.ps1 -WithUI` checks fractional Energy, recharge limits, rejected refits, metadata, save
round trips, deployment, region hierarchy, isolated/exploded inspection and the existing battle
rules and rendering.
