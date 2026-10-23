# Teamster mechanical animation

The Teamster has an editable 18-bone control armature in `art/source/m9_teamster.blend` and
26 rigid joints in its game export. Armour is never skinned or bent. Duplicate hinge pivots
let a component's protective shell follow its actuator while preserving the eight region
roots and fourteen component roots used by the workshop.

## Clips

The alternate-equipment pass adds paired rifle handling and two new weapon clips, bringing the
total to eighteen. See [alternate parts and weapon notes](teamster-alternate-parts.md). The table
below lists the original nine; idle/walk/turn/ready requests select their paired versions when
the BR-90 and support arm are equipped.

| Clip | Length | Behaviour |
| --- | ---: | --- |
| idle | 2.4 s | Looping weight/torso/head adjustments |
| walk | 1.2 s | Looping opposing steps, knee/ankle articulation and body weight shift |
| turn_left / turn_right | 0.8 s each | Foot and torso pivot gestures |
| ready | 0.6 s | Weapon-ready gesture |
| fire_rifle | 0.9 s | Three recoil pulses through wrist, elbow and torso |
| fire_missiles | 1.1 s | Braced launches and missile-cradle reaction |
| fire_stake | 0.9 s | Left-arm thrust, extending stake and revolver reindex gesture |
| melee | 0.8 s | Mechanical close-combat strike without a powered stake stroke |

These are a first animation pass. The walk uses a planar two-link leg solve and a flat-ground
foot trajectory. It has no terrain-aware IK, obstacle stepping or per-foot contact events.
Stride cadence follows tactical movement speed within a bounded range; extreme tactical
distances can still show foot sliding. Turning is a pivot gesture, not physical locomotion.

## Game integration

`TeamsterAnimator` owns playback, transitions back to idle, weapon sockets, and brief firing
flashes/smoke. Battle movement starts the walk and ends in idle. The visual movement hold gives
the heavy gait time to complete before the next automatic movement activation. Attack results
select the clip using the equipped weapon ID; projectile effects originate at the moving muzzle
socket. The clips illustrate a weapon burst rather than changing or resolving its damage rolls.
Death stops playback. All animation remains presentation-only; it does not move authoritative
units, spend Energy, roll attacks or alter equipment.

The [23 October OVA pass](ova-rendering.md) holds the rendered pose at 12 fps with no blends,
using manual AnimationPlayer advancement. The 30 fps source export remains intact for editing.
Camera motion, world translation and battle clocks continue smoothly; pause/resume preserves
the selected clip speed. Flashes and smoke now use painted flipbook cards.

In the workshop, choose a clip in the animation dropdown, then **Play**. **Pause** toggles
playback and **Rest** restores the neutral inspection pose. Exploded/isolated inspection also
restores rest pose. A recovery fit cannot preview a missile launch from a removed pod.

## Editing and rebuilding

In Blender, select `Teamster_Control_Rig` and choose a `Controls_*` action in the Action Editor.
The bone-parented control targets and world-space constraints drive the rigid geometry. The
baked node NLA tracks are muted in the editable source to avoid playing both representations.
The source animation script is `art/models/rig_teamster.py`, called by the existing Teamster
builder. Regenerating the model replaces hand edits, so keep a separate source copy when editing
animations manually.

```powershell
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_teamster.py
```

The exporter samples local joint transforms at 30 fps and merges matching NLA track names into
eighteen glTF clips. Only geometry/joint nodes are exported; the Blender control armature remains
in the source. Separate region GLBs remain static inspection assets. Every clip includes neutral
channels so interrupting a firing animation cannot leave the stake extended or the arm recoiled.

The Teamster's Godot import disables animation optimisation because it removed the short stake
and recoil peaks during verification. Godot documents this option under the
[advanced animation import settings](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/advanced_import_settings.html).
Retain the asset's `.glb.import` configuration when reimporting.

`tests/test_teamster_animation.gd` verifies imported clips, rigidity, knee/shell alignment, foot
lift, loop closure, muzzle recoil, stake travel and playback selection. The rendered workshop
suite checks Play/Pause/Rest alongside refit and deployment flows. Run `Test.ps1 -WithUI` for
animation and existing battle regressions.
