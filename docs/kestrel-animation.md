# Kestrel mechanical animation

The HX-7 Kestrel has nineteen animations, a 19-bone editable Blender control rig,
and 27 rigid animated joints. Armour panels, the rifle and the folding knife stay
rigid. The model retains eight workshop regions and fourteen component roots.

| Clip | Length | Behaviour |
| --- | ---: | --- |
| idle | 2.4 s | Small torso, head and binder adjustments; loop |
| walk | 1.2 s | Opposing steps, knee/ankle articulation and arm swing; loop |
| turn_left / turn_right | 0.8 s each | Torso/head lead and foot pivot gestures |
| ready | 0.8 s | Two-arm weapon-ready gesture |
| fire_rifle | 1.0 s | Aimed LR-3 handling with two recoil pulses |
| fire_missiles | 1.3 s | Brace and binder reaction; four alternating launch cues |
| rifle_reload | 2.0 s | Support-hand service gesture and magazine extraction/reseat |
| knife_deploy | 0.8 s | Folds the right-forearm VB-2 out; enters knife_ready |
| knife_ready | 1.6 s | Holds the deployed knife and an offset rifle; loop |
| knife_stow | 0.8 s | Folds the blade back along its forearm housing |
| fire_knife | 1.2 s | Deploy, forearm slash and recovery |
| melee | 1.0 s | Close-combat forearm/rifle handling without deploying the blade |
| hover | 2.0 s | Suspended leg brace, body bob and binder adjustment; loop |
| flight | 1.6 s | Forward lean, swept binders and folded legs; loop |
| takeoff | 1.2 s | Standing-to-airborne transition |
| land | 1.3 s | Airborne-to-standing transition |
| evade_left / evade_right | 1.0 s each | Short aerial bank and recovery |

In the workshop, select **HX-7 Kestrel**, choose a clip, then use **Play**, **Pause**
or **Rest**. Rest returns to the standing inspection pose with the blade stowed.
Exploded and isolated inspection also restore that pose. The Teamster retains its
own animation list and alternate-equipment clips.

`KestrelAnimator` shares the Teamster's manual 12 Hz cel-pose timing. The source
and export are sampled at 30 fps. Ground movement selects the walking gait;
airborne movement selects forward flight and airborne rest selects hover.
Altitude changes select takeoff or landing. Battle weapon events select the
LR-3, AGM-M or VB-2 clip, and effects originate at the animated weapon sockets.
Missile cues alternate across the two binders and their four hardpoints.

Animations are presentation-only. They do not move authoritative units, change
altitude, consume ammunition/Energy, or resolve attacks. Flight is the humanoid
airborne configuration; this set does not transform the model into an aircraft.
The gait uses a flat-ground two-link solve, with no terrain-aware foot IK. Large
tactical distances can still produce foot sliding. Reload and deployment are
visual gestures rather than new equipment rules. Missile meshes remain on their
hardpoints while launch flashes/smoke illustrate the burst.

## Editing and rebuilding

Open `art/source/hx7_kestrel.blend`, select **Kestrel_Control_Rig**, and choose a
`Controls_*` action. All nineteen actions have persistent users and survive
reopening the source. The rig's `control_actions` custom property maps clip IDs to
their action names. Bone-parented targets drive world-space constraints; muted
NLA node tracks contain the baked game clips. Armour is never skinned.

```powershell
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_kestrel.py
```

`art/models/rig_kestrel.py` creates the controls and animations. The existing
builder exports `art/models/hx7_kestrel.glb` and static region GLBs. Rebuilding
replaces manual edits, so retain a separate source copy for hand-edited work.
Keep the `.glb.import` file: animation optimisation is disabled to preserve short
recoil events. The export normaliser writes idle-frame-zero transforms as the
default node pose, preventing Blender 3.2's last sampled airborne pose from
becoming the imported static pose. Every clip contains neutral reset channels.

## Validation and previews

- Kestrel animation suite: 363 checks, zero failures. Covers all clips, rigid
  meshes, loop closure, foot clearance, shell/drive alignment, muzzle recoil,
  folding blade, magazine travel, interrupted actions and air/ground selection.
- Kestrel workshop: 50 checks, zero failures, including real battle-actor clip
  selection and a check that playback leaves battle state unchanged.
- Existing Teamster animation: 305 checks; alternate parts: 71; Teamster workshop
  UI: 66; battle UI: 114; cel playback: 28; rendered art: 91. All passed.
- Reopened the saved Blender source in a separate process and verified nineteen
  editable actions, nineteen control bones and working bone constraints.
- Visually reviewed all nineteen poses and captured motion previews from Godot.
  Godot emitted its existing OS certificate-store warning.

[Walk](../artifacts/kestrel-animation/walk.gif) ·
[Rifle fire](../artifacts/kestrel-animation/fire_rifle.gif) ·
[Knife strike](../artifacts/kestrel-animation/fire_knife.gif) ·
[Forward flight](../artifacts/kestrel-animation/flight.gif)

The manifest is `artifacts/gen2/kestrel_animation_checks.json`; rendered poses,
preview frames, GIFs and verification logs are in `artifacts/kestrel-animation/`.
`Test.ps1 -WithUI` includes the new animation and workshop suites.
