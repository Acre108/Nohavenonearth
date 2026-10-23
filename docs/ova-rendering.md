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

`art/paint.gdshader` uses a custom `light()` with two or three hard bands. Both N·L and shadow-map attenuation affect the band. Blue-violet fill remains visible without direct light; a hard warm rim comes from view angle. Specular and metallic response are disabled. Vertex wear is quantised into hard shapes. Authored albedo textures are preserved and multiplied by paint, including through workshop recolouring.

The front-culled inverted hull remains in `next_pass`, offset along the projected vertex normal at 1.5 render pixels. Projection and model scale no longer change its thickness. In LaserDisc mode the hull is intentionally upscaled along with the cels.

The post mask uses **constant roughness 0.02** in the Forward+ normal buffer. This is an ID, with no glossy response because mech specular is zero. Environment materials reserve **0.18–0.88**; ordinary paint uses 0.82. New materials must preserve these reservations. Depth rejects sky and naturally excludes mechs hidden by terrain. No duplicate cameras or geometry are required.

This is a buffer mask, rather than native stencil. Godot's stencil is experimental and its main stencil buffer cannot be copied to a post-process texture. The Style Test's **Mech mask** toggle shows the actual ID. Sobel accepts only mech neighbours, leaving silhouettes to the hull. Kuwahara rejects mech samples so ink does not smear into walls. Sensor View fades out interior ink, painterly filtering, rim, LUT and film effects, retaining flat contact fill and faction hulls.

## Wet dock and lighting

`art/environment.gdshader` supplies broad stepped brush washes without normal maps or outlines. A world-space puddle mask adds violet wet patches and varies dock roughness from 0.88 to 0.18. Emissive edge lamps and broken painted streaks suggest reflections without extra lights. Decorative fixtures remain outside the playable envelope and add no collision.

**SSR is off by default.** Enable custom Project Setting `rendering/ova/ssr` to experiment; painted lamp streaks are the cheaper default for the tactical orthographic view. Lighting uses one shadowed directional key, coloured ambient fill and emissive fixtures.

**The static dock now uses baked LightmapGI.** `art/dock/StaticDock.tscn` contains UV2-unwrapped dock meshes and eight baked-only perimeter lamps. `dock.lmbake` and `dock.exr` contain the completed bake. BattlefieldBuilder loads this scene for the standard 36×26 map; other bounds retain the procedural fallback. Scenario cover, wrecks and units remain dynamic and keep their existing rules and collision behaviour.

To rebuild, run the editor binary with `--headless --path . --script res://art/build_static_dock.gd`. This regenerates the scene and resets the bake. Create an empty `artifacts/bake-dock.request` and launch the Godot editor with `--editor --path .`; the included Dock Baker plugin consumes the request, selects the LightmapGI, invokes the editor bake, saves and exits. Run one bake editor at a time. Both generation and baking must be repeated after changing the dock layout or baked lights.

## Animation, effects and trims

`TeamsterAnimator` advances its AnimationPlayer at 12 Hz, holding each rigid-part pose between updates with blends disabled. Accessories follow that cadence. Imported clips remain intact for precise rig sampling; they are not destructively re-keyed. Clip speeds and durations are preserved. Camera, world translation, UI, combat timing and projectiles retain their smooth clocks.

`art/fx_burst.svg` is a four-frame painted atlas. `CelEffects` plays it on camera-facing AnimatedSprite3D cards: bursts at 12 fps, smoke at 8 fps. Weapon flashes, missile smoke, impacts and destruction bursts now use these cards. Beam travel retains its ribbon and bolt. This pass does not add ambient steam or rain to the tactical map.

`art/armour_trim.svg` is a reusable 1024×256 albedo atlas, rasterised by Godot on import. Four 64-pixel strips hold panel seams, stencils (US 01, 317, 02, 09), caution tape and chips, without PBR channels. Map panel UVs to a strip and pass the texture to `ArtPalette.unit_paint(color, faction, texture)`, or assign it to the source material before `paint_model()`.

`ArmourTrims` now generates planar UVs for authored armour surfaces on the four mechs and workshop replacement parts, and applies the panel strip of the shared trim sheet before toon materials are assigned. The UV-mapped meshes are cached and reused; source GLBs, joints, animation tracks and vertex colours remain intact. Existing modelled stencils and quantised wear remain visible. Other atlas strips remain available for further art variation.

## Tuning

| Control | Default | Location |
| --- | --- | --- |
| Cel bands / rim | 3 / 0.16 | `paint.gdshader` |
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

Before images and timings are stored under `artifacts/lighting-pass/before-*`; each task records the equivalent `taskN-*` evidence. These ignored files are local verification evidence, not shipped assets.

## Verification and references

Run `./Test.ps1 -WithUI` for import, rules, workshop, animation, variants, UI, art and GPU checks. `tests/test_ova_rendering.gd` inspects actual mask membership, foreground occlusion and unchanged HUD pixels with film effects and 75% rendering. It also checks held poses, duration, pause and resume. Art tests capture battle, sensor, style and silhouette views.

Technical references: [Godot screen-reading shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/screen-reading_shaders.html), [spatial shaders and stencil limits](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html), [manual AnimationMixer processing](https://docs.godotengine.org/en/stable/classes/class_animationmixer.html).
