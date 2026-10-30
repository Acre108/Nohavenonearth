# OVA rendering — 23 October 2026

Battle, service bay and landing preview now share a 1990s cel treatment. Open `art/StyleTest.tscn` with F6 to compare Sensor View, cels, silhouettes, interior lines, painterly filtering, the mech mask and 75% 3D rendering. Native-resolution 3D remains the default.

## Render path

Desktop uses **Forward+ with 2x MSAA**, requiring a Vulkan/Direct3D 12 capable GPU. An explicitly selected Compatibility renderer retains toon lighting, hulls and the film finish, while skipping the depth/normal composite, HDR glow and SSR. Mobile still defaults to Compatibility.

1. Opaque cels, inverted hulls and soft environment materials.
2. Camera quad: Sobel depth/normal lines inside visible mech pixels; four-quadrant Kuwahara outside them.
3. Transparent effects and tactical ribbons, excluded from the filter and edge pass.
4. WorldEnvironment: high-threshold HDR glow and filmic tonemapping.
5. CanvasLayer **-10**: generated 16³ violet LUT → radial chromatic aberration → 24 Hz grain → vignette.
6. Battle HUD on CanvasLayer **1**, retaining native pixels. Workshop controls sit outside the preview SubViewport.

Godot copies the 3D screen texture before transparency. The scene composite runs before particles to avoid erasing smoke or beams; the canvas finish sees the complete world, including glow and transparency.

## Materials and mask

Armour catches a hard painted half-vector highlight from the key and local lamps. It uses threshold 0.94 and strength 0.35, only appears in a lit band and fades with Sensor View. The added sheen is limited to available headroom below 1.2 HDR; ordinary armour highlights do not trigger the 1.3 glow gate. The shader retains `specular_disabled`, specular zero and mask roughness 0.02.

`art/paint.gdshader` uses a custom `light()` with two or three hard bands. Both N·L and shadow-map attenuation affect the band. Blue-violet fill remains visible without direct light; a hard warm rim comes from view angle. Specular and metallic response are disabled. Vertex wear is quantised into hard shapes. Authored albedo textures are preserved and multiplied by paint, including through workshop recolouring.

The front-culled inverted hull remains in `next_pass`, offset along the projected vertex normal at 1.5 render pixels. Projection and model scale no longer change its thickness. In LaserDisc mode the hull is intentionally upscaled along with the cels.

The post mask uses **constant roughness 0.02** in the Forward+ normal buffer. This is an ID, with no glossy response because mech specular is zero. Environment materials reserve **0.18–0.88**; ordinary paint uses 0.82. New materials must preserve these reservations. Depth rejects sky and naturally excludes mechs hidden by terrain. No duplicate cameras or geometry are required.

This is a buffer mask, rather than native stencil. Godot's stencil is experimental and its main stencil buffer cannot be copied to a post-process texture. The Style Test's **Mech mask** toggle shows the actual ID. Sobel accepts only mech neighbours, leaving silhouettes to the hull. Kuwahara rejects mech samples so ink does not smear into walls. Sensor View fades out interior ink, painterly filtering, rim, LUT and film effects, retaining flat contact fill and faction hulls.

## Wet dock and lighting

`BattleAtmosphere` listens to `TacticalCamera.mode_changed` through BattlePresentation. Overview has no fog, SSR or rain. Close and cinematic modes fade violet-navy exponential fog to density 0.03 over 0.5 seconds; sky affect is zero. Forward+ also enables SSR with 48 steps in those modes. The mechs retain zero PBR specular and their 0.02 mask ID; the review renders retain their painted appearance rather than a mirror finish.

Rain uses 1,500 thin transparent GPU particle quads at 24 simulation fps, lifetime 1.2 seconds and alpha 0.18, emitting in a world-aligned box in front of the camera. It renders after the composite, excluding it from the mech mask and Kuwahara. Leaving perspective mode stops emission and fades the remaining drops. Sensor mix fades the rain and fog; above 0.5 it immediately suppresses fog, rain visibility/emission and SSR. Compatibility retains fog and GPU rain while keeping SSR disabled. No volumetric fog or collision simulation is used.

The environment's custom `light()` writes Lambert diffuse only, eliminating the view-dependent orthographic specular flare. Puddles retain specular 0.65 and roughness 0.18 for screen-space reflection eligibility. Four mast positions drive painted reflections in the wet material: two hard emission steps, 0.35 units across and 3.8 units toward the camera, with peak strength 0.18. Their orientation follows the camera's horizontal view direction. Both puddles and streaks fade with Sensor View. `tests/test_ova_rendering.gd` compares wet/dry rendered luminance at azimuths 0, 1.1, 2.2 and 3.3, requiring fewer than 0.1% of pixels to rise by more than 0.35. Task 3 measured **zero** such pixels at every angle; the GPU averages remained below 8 ms.

`art/environment.gdshader` supplies broad stepped brush washes without normal maps or outlines. A world-space puddle mask adds violet wet patches and varies dock roughness from 0.88 to 0.18. Four 4-unit sodium masts sit outside the playable envelope without collision. Their warm `ffcc8b` spots use energy 0.85, angle 32°, distance attenuation 0.25 and angle attenuation 0.7; shadows and baking are disabled. The same masts serve prebuilt and procedural maps. Small edge housings remain emissive, but the old baked-only OmniLights and fixed streak boxes are removed.

**SSR follows the camera mode.** Overview forces it off, while Forward+ close and cinematic modes enable it. The `rendering/ova/ssr` setting is the environment factory's initial value, before the battle mode policy applies. Lighting uses one shadowed directional key, coloured ambient fill and four unshadowed sodium spots. The live WorldEnvironment and runtime key are always created by `BattlefieldBuilder.build_lighting()`, including on the prebuilt dock. `BattleController.world_environment` exposes those settings to presentation. The saved dock contains geometry and collision only.

**Task 7 decision: remove the LightmapGI bake.** With baked lamps replaced, the remaining indirect key/ambient bake made no clear visual difference. At 1440×900, matched captures measured mean luminance differences of 0.00160 (overview) and 0.00291 (close); only 0.00131% and 0.00193% of pixels changed by more than 0.05. Grain, rain and idle poses were held out of the comparison. The evidence is `artifacts/lighting-pass/lightmap-overview-with.png`, `lightmap-overview-without.png`, `lightmap-close-with.png` and `lightmap-close-without.png`.

The lightmap resources, UV2 unwrap and editor bake plugin are removed. `art/dock/StaticDock.tscn` remains a plain prebuilt geometry scene for the standard 36×26 map. Other bounds use the same procedural geometry and live lighting, with no bake limitation. Scenario cover, wrecks and units retain their existing rules and collision behaviour.

To regenerate the standard dock geometry, run the editor binary with `--headless --path . --script res://art/build_static_dock.gd`. No editor UI automation or bake step is required. Runtime lighting and reflection uniforms are applied by BattlefieldBuilder rather than frozen into this resource.

## Animation, effects and trims

`TeamsterAnimator` advances its AnimationPlayer at 12 Hz, holding each rigid-part pose between updates with blends disabled. Accessories follow that cadence. Imported clips remain intact for precise rig sampling; they are not destructively re-keyed. Clip speeds and durations are preserved. Camera, world translation, UI, combat timing and projectiles retain their smooth clocks.

`art/fx_burst.svg` is a four-frame painted atlas. `CelEffects` plays it on camera-facing AnimatedSprite3D cards: bursts at 12 fps, smoke at 8 fps. Weapon flashes, missile smoke, impacts and destruction bursts now use these cards. Beam travel retains its ribbon and bolt. Rain is confined to perspective views; ambient steam and splash bursts remain optional future art.

`art/armour_trim.svg` is a reusable 1024×256 albedo atlas, rasterised by Godot on import. Four 64-pixel strips hold panel seams, stencils (US 01, 317, 02, 09), caution tape and chips, without PBR channels. Map panel UVs to a strip and pass the texture to `ArtPalette.unit_paint(color, faction, texture)`, or assign it to the source material before `paint_model()`.

`ArmourTrims` generates planar UVs in world units with a 0.5-unit tile size, incorporating the known model scale before building. Dominant-axis projection is retained, along with the `trim_projection: "top"` extra for cambered shells. The shader wraps UVs inside a half-texel-inset `trim_rect`; material caching includes that rectangle. Per-plate phase offsets and a seam-only panel tile replace the repeated dash motif. Replacement parts use the same mapping before workshop recolouring. Source GLBs, joints, animation tracks and vertex colours remain intact.

Pact frames use the yellow/black hazard strip on one pauldron and the opposite knee plate. Small alpha-cutout stencil quads sit beside the existing main tactical number: US 01 for Blue, 317 for Pact. They align with the number's plane, use opaque discard rather than a Decal, and preserve their atlas rectangle through workshop finish changes. Atlas glyphs and tape use explicit vector paths, avoiding SVG font/pattern support differences. The chip strip remains available for later paint variation.

## Tuning

| Control | Default | Location |
| --- | --- | --- |
| Cel bands / rim | 3 / 0.16 | `paint.gdshader` |
| Local threshold / strength | 0.12 / 0.55 | `paint.gdshader`; additive warm cel band |
| Sheen threshold / strength | 0.94 / 0.35 | `paint.gdshader`; painted highlight |
| Lamp streak strength / length / width | 0.18 / 3.8 / 0.35 | `environment.gdshader` |
| Fog density / transition | 0.03 / 0.5 s | `BattleAtmosphere`; perspective only |
| Rain count / alpha / lifetime | 1500 / 0.18 / 1.2 s | `BattleAtmosphere` and `rain.gdshader` |
| SSR steps | 48 | Forward+ perspective only |
| Armour trim tile | 0.5 world units | `ArmourTrims.TRIM_TILE_SIZE` |
| Hull width | 1.5 render pixels | `outline.gdshader` |
| Interior ink / background paint | 0.65 / 0.45 | `cel_composite.gdshader` |
| Glow HDR threshold | 1.3 | `OvaRendering.environment()` |
| Violet LUT strength | 0.55 | `ova_finish.gdshader` |
| Aberration / grain / vignette | 0.45 / 0.012 / 0.18 | `ova_finish.gdshader` |
| LaserDisc | Off; 0.75 when on | `OvaRendering.set_laserdisc()` or custom setting `rendering/ova/laserdisc` |

`OvaRendering.make_grade()` generates and shares the LUT. Supply another texture via `grade_lut` to replace it. Kuwahara's radius is fixed at two render pixels.

## Performance

Measured on the dev RTX 3060 Ti at 1440×900, Forward+, native 3D scale, 2× MSAA. `artifacts/perf_probe.gd` warms each view, caps presentation at 60 fps, then averages 120 rendered frames using RenderingServer viewport GPU and CPU timers. CPU figures cover rendering operations, not game logic. Cinematic samples stay in the cinematic mode by restaging the attack when necessary. The pass budget is **8 ms GPU per view**.

| Checkpoint | Overview GPU / CPU ms | Close GPU / CPU ms | Cinematic GPU / CPU ms |
| --- | --- | --- | --- |
| Task 0 baseline | 5.001 / 3.952 | 3.141 / 2.662 | 2.959 / 2.130 |
| task1 | 4.649 / 3.843 | 3.622 / 2.735 | 5.164 / 2.275 |
| task2 | 5.332 / 4.165 | 4.308 / 3.031 | 4.139 / 1.895 |
| task3 | 5.100 / 3.616 | 3.814 / 2.730 | 5.035 / 2.281 |
| task4 | 5.219 / 3.824 | 5.706 / 2.773 | 5.078 / 2.208 |
| task5 | 5.071 / 3.943 | 3.849 / 3.165 | 4.090 / 2.125 |
| task6 | 5.257 / 3.385 | 3.412 / 2.673 | 4.091 / 2.100 |
| task7 | 5.079 / 3.743 | 4.039 / 2.740 | 4.613 / 2.437 |

Before images and timings are stored under `artifacts/lighting-pass/before-*`; each task records the equivalent `taskN-*` evidence. These ignored files are local verification evidence, not shipped assets.

## Verification and references

Run `./Test.ps1 -WithUI` for import, rules, workshop, animation, variants, UI, art and GPU checks. `tests/test_ova_rendering.gd` inspects actual mask membership, foreground occlusion and unchanged HUD pixels with film effects and 75% rendering. It also checks held poses, duration, pause and resume. Art tests capture battle, sensor, style and silhouette views.

Technical references: [Godot screen-reading shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/screen-reading_shaders.html), [spatial shaders and stencil limits](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html), [manual AnimationMixer processing](https://docs.godotengine.org/en/stable/classes/class_animationmixer.html).
