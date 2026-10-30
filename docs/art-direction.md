# No Haven on Earth ? Art Direction: OVA Battlefield ? updated 23 October 2026

This is the canonical art direction for the project. It replaces the online draft (claude.ai artifact), which agents cannot open.

**23 October direction update:** Sensor View is retired from the player-facing battle flow. Orders, targeting and resolution share the full-colour OVA battlefield. Tactical overview and cinematic shots change camera and information density, not the world's rendering style. This document specifies the intended direction; existing sensor shaders and runtime transitions have not been removed by this documentation update.

[OVA rendering setup](ova-rendering.md) records the implemented render path. Its Sensor View references describe legacy behaviour; the unified direction here takes precedence.

## Vision and pillars

The player gives orders and watches the results on the same full-colour, cel-shaded battlefield, like a 1996 OVA. Tactical overview keeps the camera stable and information clear; cinematic playback brings the camera close for weight and drama. Painted terrain, military colours and unit materials remain consistent throughout.

The touchstone is *Mobile Suit Gundam: The 08th MS Team*. We take its grounded field-war tone, its jungle and monsoon settings, its hovertruck sound-sensor scenes, and mobile suits that read as worn military equipment, not heroes. The factions and machines are our own; only the tone and the technology level come from the One Year War.

**Pillars**

1. **Readability first.** If a choice between mood and clarity comes up during planning, clarity wins. Keep the OVA atmosphere while reducing effects that obscure decisions.
2. **Grounded weight.** Mechs are heavy machines. They sink into the ground, splash, throw up dust and shake the camera. Nothing floats unless it is flying.
3. **Sensors as drama.** Information arrives the way it does for a field crew: pings, sweeps, contacts resolving out of noise. Reveals are events.
4. **90s OVA heart.** Hand-drawn values, hard sunsets, painted skies, film grain. It should look like a cel, not a modern anime game.

## Setting and tech level

Two original factions fight with One Year War-level technology. No Gundam designs are copied. We borrow the era's engineering logic and the 08th tone, so the machines feel like the first generation of mobile suits: heavy, exposed and mostly armed with shells.

| Faction | Inspired by | Shape language | Paint | Sensor eye |
| --- | --- | --- | --- | --- |
| Blue | Federation | Boxy, flat armour plates, squared shoulders, utilitarian, mass-production simple | Off-white, blue-grey, small red accents | Visor for line units; twin eyes for the ace only |
| Red | Zeon | Rounded, curved armour, exposed power pipes, heavy shoulder guards, more menacing | Olive, dark green, purple-grey accents | Single lens on a track, glowing |

**What the tech level means for the art**

- **Beam weapons are rare.** Only the ace and a few elite units carry them, so beams should look exceptional. Most fire is solid ammunition: machine guns, bazookas, cannons, railguns and missiles. Effects lean on tracers, muzzle smoke, shell casings and ricochet sparks.
- **Radar is unreliable.** Interference keeps fights short-range and visual. Sensors work by sound and heat, represented by brief sound-sensor sweeps and contact cues over the battlefield rather than a separate display mode.
- **Early-generation machinery.** Exposed hydraulics and joints, visible bolts and hatches, cockpit hatches in the chest, and dated CRT cockpit displays.
- **Nothing later than the era.** No transforming mechs, remote weapons or psychic-tech glow. Newtype effects stay subtle (see Transitions, cues and HUD).
- **Support vehicles match the era too:** hovertrucks, tanks, jeeps and chunky jet fighters.

## One battlefield, two camera contexts

**The OVA battlefield stays visible throughout the round.** Planning, locks, Newtype rotation and attack selection use the tactical overview with full-colour terrain, textured units and clear overlays. Movement, attacks, enemy actions and round end may use short cinematic shots with the same materials and palette.

1. Plan hidden movement, altitude and facing in tactical overview.
2. Commit and reveal with a brief sensor-ping cue over the painted world.
3. Play movement in short cinematic cuts, lowest Reflex first.
4. Return to the saved tactical camera for locks, rotation and attack selection.
5. FIRE plays the attack shot, then returns to overview for the next choice. Consecutive enemy actions can share one cinematic sequence.
6. Round end shows recharge over the final shot, then returns to planning.

Camera changes preserve colour, textures and lighting. Return to the saved overview position and zoom. Offer skip and tactical-camera-only playback; both retain the OVA world rendering. Reveal cues must respect the rules for hidden units and orders.

## Tactical overview and orders

A stable overview presents the painted battlefield with the complete order HUD. Readability comes from value separation, silhouettes, bases and restrained overlays.

- Keep cel-shaded unit materials, painted environmental textures and the map's lighting preset during orders.
- Keep terrain muted and low contrast beneath units. Do not replace it with contour-only or wireframe geometry.
- Reduce rain, fog, grain and bloom when they obscure units, labels, paths or cover. No depth of field during orders; keep HUD pixels sharp.
- No scanline wipe, static burst or world-shader transition when entering or leaving orders.
- Keep base discs, facing chevrons, faction rings and status pips fully readable during orders. Airborne units retain tethers, altitude ticks and ground markers.
- Keep order meanings: amber draft, cyan confirmed Blue orders, salmon revealed Red orders, pale gold selection and distinct legal-target rings.
- Arcs and ranges use a thin bright edge and soft fill under 15% opacity. Show only relevant overlays; limit simultaneous saturated overlay hues to four where possible.
- Out-of-arc targets show the angle needed, such as "+15?", and a Newtype icon when Will can bring them in. See [mock-battle-feedback.md](mock-battle-feedback.md).
- Line of sight is dashed and breaks or turns grey where blocked. Preserve terrain occlusion cues.
- No text smaller than 12 px at 1080p.

## Cinematic mode

The shared world style is a 1990s OVA cel brought into 3D: flat colour, crisp ink, painted skies and a hard key light. Cinematic playback changes framing and reduces HUD density while the rules resolve. The shading below also applies during orders.

**Shading**

- Two-tone cel shading on units: a lit tone and one shadow tone with a hard edge. A third, darker tone is allowed for deep crevices and under-armour.
- Shadow tones shift cool (toward blue-violet), never just a darker version of the base colour. This is the single biggest cue for a hand-painted look.
- A thin, sharp specular highlight on armour edges, painted as a shape rather than a glossy blob.
- Ink outlines: about 1.5 px at 1080p on silhouettes, thinner on interior panel lines. Line colour is a dark version of the local colour, not pure black.
- Rim light in a warm colour on the side opposite the key light, to separate units from busy backgrounds.

**Lighting and time of day**

- One hard key light. Prefer low sun angles: late afternoon, sunset, overcast monsoon light, and night lit by flares.
- Shadows are hard-edged and cast in a colour, not grey.
- Each map picks one lighting preset and keeps it all battle.

**Sky and backgrounds**

- Painted skybox in the style of OVA background art: towering cumulus, layered haze, distant blue ridgelines.
- Distant terrain fades into a coloured atmospheric haze that matches the sky.

**Weather and effects**

- Rain as streaks with occasional splash sprites, fog bands at mid-height, and heat shimmer on hot maps.
- Effects are drawn shapes: cel-style explosions with two or three flat colours and black smoke shapes, beam shots as solid cores with a soft halo, and smear frames on fast motion.
- Footfalls throw dust or water. Landings shake the camera briefly.

**Camera**

- Short cuts, 1–3 seconds each: a low angle looking up at a mech as it moves, a follow shot behind a shoulder, a cut to the target as it is hit.
- Use the static "held frame" OVA trick for big moments: freeze on a detailed frame for half a second at the moment of impact.
- Always offer a skip, and a setting for "tactical camera only" playback.

**Post-processing**

- Light film grain, slight colour bleed at the edges, and a gentle bloom on beams and explosions only.
- An optional 4:3 safe frame or letterbox during cuts for a period feel.

## Colour and value system

Each colour carries one meaning throughout battle, and the brightest values are reserved for what the player acts on. In order from quietest to loudest: terrain, then unit paint, then faction marks, then overlays.

**Value rules**

- Terrain sits in the middle of the value range with low saturation throughout battle.
- Unit paint has more contrast than terrain but stays below overlay saturation.
- Only overlays and faction marks are fully saturated.
- Test every screen in greyscale. Units must separate from terrain and overlays must separate from units.

**Tokens.** "Current" is what the prototype uses today. "Proposed" values are starting points to tune in the style test.

| Token | Meaning | Current | Proposed | Where |
| --- | --- | --- | --- | --- |
| `faction.blue` | Blue faction units, confirmed orders | `57d5ef` / `63d8ed` | `57d5ef` (unify) | All battle views |
| `faction.red` | Red faction units, revealed orders | `f48478` | `e8735f` | All battle views |
| `overlay.draft` | Current draft path and ghost | `f3c378` | `f3c378` | All battle views |
| `overlay.select` | Selected unit | `f3c378` | `fff1c9` (pale gold, thicker ring) | All battle views |
| `overlay.target` | Legal target ring | `f48478` | `ff4fa3` (magenta) | All battle views |
| `overlay.invalid` | Illegal move | `ff586b` | `ff3b3b` with a hatched pattern | All battle views |
| `overlay.arc` | Weapon arc and range | `66d9f2` approx. | `d8ffe8` (pale white-green) | All battle views |
| `paint.blue` | Blue faction armour | — | off-white `d9d4c4`, blue-grey `5b6d82`, red accent `a8483a` | All battle views |
| `paint.red` | Red faction armour | — | olive `5f6e3f`, dark green `3b4630`, purple-grey accent `5a4f63` | All battle views |

Where the current values live: faction colours in [units/presentation/unit_actor.gd](../units/presentation/unit_actor.gd) (line 26), [movement/presentation/movement_preview.gd](../movement/presentation/movement_preview.gd) (line 5) and [ui/battle_ui.gd](../ui/battle_ui.gd) (lines 4–7); selection and target rings in `units/presentation/unit_actor.gd` (lines 39–40); draft and invalid colours in `movement/presentation/movement_preview.gd` (line 7); arc colours in [combat/presentation/targeting_overlay.gd](../combat/presentation/targeting_overlay.gd) (lines 22–28); background in [battle/interaction/battle_controller.gd](../battle/interaction/battle_controller.gd) (line 56).

**Clashes in the current build**

- The Red faction colour and the legal-target ring are the same `f48478`. A targeted Red unit looks no different from an untargeted one. The target ring needs its own hue; magenta is proposed.
- The arc overlay is close to the Blue faction cyan, so a Blue unit's arc and a Blue order read as the same thing. Arcs move to a neutral pale white-green.
- Draft and selection share the same gold. Selection becomes paler and thicker.

**Faction paint throughout battle**

Unit armour uses muted military paint, not the faction marks. The Blue faction is off-white and blue-grey; the Red faction is olive and dark green. The saturated cyan and red stay on the base rings and the overlays. This keeps the 08th look and stops the jungle turning into a colour soup.

## Units and models

One model and material treatment per unit serve every battle camera. Keep mesh, silhouette, paint and base consistent between orders and playback.

**Silhouette**

- Every unit must be identifiable as a solid black shape from the default tactical camera. Test this before texturing.
- Each role gets a distinct outline: the Blue ace has a tall head fin, twin eyes and a large backpack, ground mechs have wide shoulders and a squat stance, aircraft are flat delta shapes, tanks are low and long.
- Exaggerate heads, shoulders and weapons by 10–20% beyond realistic proportions, as tabletop miniatures do. Weapons should stick out past the body outline so facing reads from the model alone.
- Avoid thin parts under about 4 px at default zoom. They shimmer and disappear.

**Bases**

The base disc is the information panel. It remains consistent between overview and playback.

- Outer ring in the faction colour.
- A facing chevron at the front edge, larger than you think it needs to be.
- Status pips around the rim for Structure, Energy and Will. Locks show as a small reticle icon.
- Selection and target rings sit outside the faction ring so they never cover it.
- During cinematic playback the base fades to about 30% opacity, and back to full when the camera returns to tactical.

**Altitude**

Three cues together, so no single cue has to carry it:

1. The existing vertical tether from model to base.
2. A ground shadow that gets smaller and softer at Low and smaller again at High.
3. A band marker on the tether: one tick for Low, two for High. This replaces the need to read the caption.

**Weathering and detail**

- Paint chips, mud splashes up to the knees, stencilled unit numbers and a faded faction emblem on the shoulder.
- Weathering is generated, not hand-painted: a mud gradient from the feet up and edge wear from baked vertex colour, both applied in the Godot shader (see Model production). It stays as flat shapes so it survives cel shading.
- Keep panel lines few and bold. Fine detail turns into noise at tactical zoom.

**Model production (Blender, built by Codex)**

Codex builds every model in Blender. The specs below are written so each one can be generated by a script and checked by a script rather than by eye.

- **Scripted builds.** Each model is a Blender Python script in the repo that builds the scene and exports a `.glb`. Rebuilds are repeatable and changes review as diffs.
- **Hard-surface kitbash.** Bevelled boxes, cylinders and wedges, with a 1–2 segment bevel so the cel shader catches the edges. No sculpting.
- **Rigid parts.** Torso, head, arms, legs and weapons are separate named objects in a parent hierarchy, with no skinning. Godot animates them procedurally.
- **Flat albedo and named slots.** Keep `armour_primary`, `armour_secondary`, `accent`, `frame` (joints), `sensor` (eye, emissive) and `weapon` for recolouring. Use albedo trim sheets for panel lines, stencils, caution tape and hard chips; avoid PBR detail channels. Existing models retain their modelled markings alongside automatically mapped panel trims. See [the starter trim atlas](ova-rendering.md).
- **Baked vertex colour.** Bake curvature and ambient occlusion into vertex colour in Blender. The shader uses them for edge wear and crevice shadow.
- **Origin and scale.** Origin at the centre of the base on the ground. Match the heights of the current primitive models in [units/presentation/unit_actor.gd](../units/presentation/unit_actor.gd).
- **Facing.** The prototype models face −Z. Godot treats +Z as the front of imported glTF models, so either model facing Blender +Y or rotate the imported scene 180°. Decide on the first test export and record it here.
- **Budget.** Mobile suits 3–8k triangles; vehicles and aircraft 1.5–4k. No normal maps.
- **Automated checks per model.** A black-silhouette render from the tactical camera plus three other angles, the triangle count, the material slot names, and origin and facing. Renders are saved to `artifacts/` for review.

## Terrain and environment

Terrain is a stage, not a character: it supports the units and must never compete with them. Every piece of terrain has a rules meaning, and its look should say which one.

**Biomes, in rough priority order**

| Biome | 08th reference | Lighting preset | Signature props |
| --- | --- | --- | --- |
| Jungle river valley | The Southeast Asian front | Humid late afternoon, haze | Broad-leaf canopy, river, rope bridges |
| Ruined town | Village and outpost fights | Overcast, rain | Collapsed concrete, power poles, rusted vehicles |
| Mountain pass | Snow and high-altitude episodes | Cold, low sun | Rock spires, fog banks, snow patches |
| Red faction base perimeter | The final assault on a fortified mountain base | Night, floodlights, flares | Bunkers, fuel tanks, searchlights |

**Cover readability**

- Low cover (walls, wrecks, rubble) stays below mech waist height. Heavy cover (buildings, rock spires) is clearly taller than a mech.
- In every view, cover keeps its silhouette clean: no foliage hanging over the top edge of blocking terrain.
- Wrecks get a scorched decal and the existing "+1 cover" label.
- Decorative props that have no rules effect stay small and low and never match the shape of cover.

**Foliage**

- Trees and jungle are painted cards and clusters in two or three flat tones, in the style of OVA background art.
- Foliage near units fades or cuts away when it would hide a model from the tactical camera.

**Ground**

- Hand-painted ground textures with large, simple shapes: mud, grass, gravel, puddles. No noisy photo textures.
- Mechs leave footprints and wet tracks during Cinematic; they fade after a round.

**Demo battlefield: wet industrial dock**

- Muted slate concrete paving, warm-grey concrete cover and weathered blue-grey steel. Keep broad painted wear below unit and overlay contrast.
- The generated [demo dock texture set](../art/textures/demo-dock/README.md) supplies albedo assets and repeat-scale guidance. Wetness, reflections and lamp lighting remain shader-driven.
- The runtime environment shader and saved dock use these assets with world-scale projection: 7 units for paving, 3.5 for concrete cover and 2.5 for steel roofs. Both prebuilt and procedural dock paths retain shader-driven wetness and lamp reflections.

## Transitions, cues and HUD

Camera transitions are short and preserve spatial orientation. Return to the exact saved tactical framing after a shot. The world retains its colour, textures and lighting; no Sensor View scanline or static transition is required.

**Signature cues**

- **Order reveal (the sound-sensor ping):** a radial sweep ring expands from each Blue unit. Hidden enemy contacts resolve into their models and orders as the ring passes them, with a sonar ping for each. This cue plays over the full-colour battlefield without changing its materials.
- **Lock acquired:** a reticle closes on the target with a short two-tone beep.
- **Newtype Reflexes:** a single white flash outline on the ace and a short, high chime, used only for Will powers.
- **Unit destroyed:** a held frame on the explosion during cinematic playback; in tactical-camera-only playback, keep the impact and wreck readable in place.

**HUD**

- The HUD is the field crew's monitor bezel throughout battle: dark panels, monospaced labels in capitals, thin rules, and small status lamps.
- During orders the HUD is fully visible. During cinematic playback it shrinks to the initiative bar and a one-line telemetry ticker, so the shots have room.
- Dice results appear as a printed readout strip, like a teleprinter, with rerolled dice marked as now.
- Fonts: a condensed monospace for numbers and labels, and a plain sans for longer text. All UI text at least 12 px at 1080p.

## Godot 4 implementation notes

These notes specify the intended unified presentation. See [OVA rendering setup](ova-rendering.md) for the current render path and buffer reservations.

- Orders and playback use the same unit shaders, environment textures and map lighting. Camera context may change effect intensity and HUD density.
- The existing `sensor_mix` path is legacy. The intended order flow retains the full-colour endpoint (`sensor_mix = 0`). Removing runtime callers is a separate implementation task.
- Keep hard cel bands and cool shadow fill on units, with silhouette hulls and masked interior ink as recorded in the rendering setup.
- Environment textures use broad painted albedo shapes. Preserve environment roughness 0.18?0.88; avoid normal maps, metallic noise and baked directional lighting.
- Grid, path and range information belongs to optional tactical overlays, without replacing terrain textures or changing the world shader.

**Render order and layers**

- Overlays (arcs, paths, rings) render unshaded, with no depth test against terrain, on their own visual layer. They must never be fogged, tone-mapped or outlined.
- Labels use `Label3D` with `no_depth_test` and fixed screen size, as now.

**Performance targets**

- 60 fps at 1080p on a mid-range GPU with six units, one map and rain on.
- Keep the inverted hull to units only. Environment shapes and textures stay soft and free of unit-style ink.

## Readability checklist and next steps

Run this checklist on every new unit, map and overlay before it ships.

**Checklist**

- [ ] The unit is identifiable as a black silhouette from the default camera.
- [ ] Facing reads from the model and from the base chevron, each on its own.
- [ ] Altitude band reads without the caption (tether ticks plus shadow size).
- [ ] The screen passes a greyscale test: terrain < units < overlays.
- [ ] No terrain or paint uses a reserved overlay or faction colour.
- [ ] Relevant overlays remain distinct over the full-colour battlefield.
- [ ] All text is at least 12 px at 1080p.
- [ ] Cinematic playback can be skipped, and the tactical-only setting works.

**Do and don't**

| Do | Don't |
| --- | --- |
| Put information on bases and overlays | Hide information in model detail or texture |
| Cool, coloured shadows | Grey or black shadows |
| Flat painted weathering | Physically based roughness grime |
| One hard key light per map | Several competing light sources |
| Muted paint, saturated marks | Saturated armour colours |
| Short, skippable cuts | Long camera moves the player must sit through |

**Next steps**

1. Update runtime orders to retain OVA materials and retire sensor-mode transitions.
2. Validate targets, paths, facing, altitude and cover over the textured battlefield at default tactical zoom.
3. Extend the integrated demo dock texture set to new environment props with consistent world scale and restrained contrast.
4. Verify skip and tactical-camera-only playback retain the full-colour world and readable HUD.

**Decisions**

- **23 October 2026: Sensor View removed from orders.** Planning, locks, Newtype rotation and attack choice all use the full-colour OVA battlefield. Cinematic shots are camera changes within that style.
- **Original setting:** Original factions with One Year War-level technology and the grounded tone of 08th MS Team.
- **Model production:** Models built in Blender by Codex.
