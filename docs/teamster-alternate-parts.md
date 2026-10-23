# Teamster alternate components and paired weapons

All eight regions now have visible alternatives. These are prototype workshop fittings and weapon
designs, tagged Brannock-Hale and medium size; they are not claims about equipment already listed
in the atlas. Manufacturer, exact-size, mount-family and Energy restrictions still apply.

| Region | Modelled alternatives |
| --- | --- |
| Head | Wider SC-9P rangefinder bridge, protected optical pods and survey antenna |
| Torso | Recovery cage and lifting fittings; separate assault cheek plates and applique |
| Each arm | Fine-control rails/cuffs; reinforced shoulder and forearm shells |
| Each leg | March-drive pumps and hydraulic manifolds; reinforced knees, shin braces and wide heel spades |
| Power | Buffered capacitor canisters, protective clamps and busbar |
| Backpack | High-flow cooling towers; winch drum, cable wraps and folded recovery boom |

Each component still occupies one of the existing slots. The addon mesh groups attach to the
appropriate upper, elbow, wrist, knee or ankle pivot, so the fittings follow the animation.
The stock body supplies the shared underlying chassis; upgrades add or replace visible equipment.

## New arm weapons

| Component | Mount | Weapon | Reserved Energy |
| --- | --- | --- | ---: |
| HA-9C Rotary Cannon Arm | Right actuator | AC-30 five-barrel rotary cannon | 0.75 |
| HA-9B Breaching Shotgun Arm | Left actuator | SG-12 twin-barrel breacher | 0.25 |
| HA-9M Marksman Arm | Right actuator | BR-90 two-handed marksman rifle | 0.5 |
| HA-9S Extended Support Arm | Left actuator | Support grip, replacing the stake driver | 0.25 |

The marksman arm requires the support assembly in the left actuator slot. Incomplete kits can
be previewed while assembling a draft, but cannot be applied or deployed. Side-specific mounts
also prevent fitting a cannon or support assembly to the wrong arm. The paired rifle replaces
the Longhorn and stake-driver attack options; hands and the backpack weapon follow the normal
loadout rules. Weapons, stats, visuals and reservations resolve from the same selected components.

Open **Weapons** in the workshop and choose **Preview two-handed rifle kit** to preview both
owned components together. Apply the quoted refit to use it in battle. Other parts are available
through each region's replacement cards. Existing version-1 saves receive the new prototype
spares and second matching limb kits once through content revision 2; installed equipment,
condition, hull damage and funds are retained.

## Animation

The BR-90 has supported idle, walking, turning, aim, firing and reload-preview clips. A two-link
arm solve positions both wrists on the weapon grips; the special actuators supply the additional
reach. The support target is a socket on the right-hand weapon chain, so torso motion and recoil
move both hands together. Reload deliberately releases the support hand toward the magazine and
returns it to the foregrip. Magazine movement is visual: there is no ammunition/reload rules system.

The rotary cannon has a firing clip, spinning barrel cluster and its own muzzle socket. The
breacher has a distinct left-arm recoil clip, cycling slide and muzzle socket. Battle attack
events select the correct animation by weapon ID. Workshop preview refuses firing clips for
weapons that are not fitted. Paired carry and walk poses are chosen automatically.

Current weapon statistics and reservations are starting values, not a completed balance pass.
The flat-ground gait limitations from the original animation pass remain.

## Assets and rebuilding

- `art/models/teamster_parts/`: eighteen independent variant assets, stored in assembly coordinates.
- `art/source/teamster_parts.blend`: editable parts laid out on a workbench.
- `art/source/m9_teamster_marksman.blend` and `m9_teamster_assault.blend`: assembled editable examples with the control rig and selected parts.
- `art/models/build_teamster_parts.py`: repeatable hard-surface part builder.
- `art/models/rig_teamster.py`: eighteen animation clips, including the paired rifle arm solve.
- `workshop/teamster_parts.gd`: variant loading, joint attachment and stock-weapon visibility.

```powershell
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_teamster_parts.py
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_teamster.py
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_teamster_refit_sources.py
```

`tests/test_teamster_variants.gd` checks all region visuals, side/dependency restrictions, weapon
resolution, deployment, Energy gates, save migration and hand-to-foregrip distance throughout the
paired clips. Run `Test.ps1 -WithUI` for these and the existing animation/battle regressions.
