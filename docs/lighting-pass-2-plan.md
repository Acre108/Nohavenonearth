# Lighting pass 2: execution plan

**For:** Codex, executing in this repository.
**Goal:** Close the gap to the night-dock concept art. Warm sodium lamps should light the mechs, wet ground should reflect them, and armour should catch a highlight. The close view and attack cinematics also get the atmosphere that the table view deliberately skips.
**Builds on:** the 23 October OVA pass (`docs/ova-rendering.md`). Keep its look: cel bands, ink, Kuwahara background, film finish. This pass adds lighting; it doesn't replace that style.

Work through the tasks in order. Each task ends in a working, tested state. Commit after each task: `git add` only the files you changed, with a message that names the task.

---

## Ground rules (apply to every task)

1. **Roughness IDs are reserved.** Mechs write `ROUGHNESS 0.02` as the composite mask. Environment materials must stay within `0.18–0.88`. Don't change either range.
2. **Sensor View must still work.** Every new colour, emission, light contribution or effect fades out with the global `sensor_mix`, the way the existing terms in `paint.gdshader` and `environment.gdshader` do.
3. **Compatibility renderer must not break.** Forward+-only features (SSR, glow, normal-roughness buffer) stay behind `RenderingServer.get_current_rendering_method() == "forward_plus"`, as in `OvaRendering.environment()`. Compatibility allows 8 lights per object: keep the local lights within that.
4. **Presentation only.** No changes under `battle/state`, `combat/rules`, `movement/rules`, `ai`, or the cinematic and camera logic in `battle/world/tactical_camera.gd`, `camera_shot.gd` and `attack_cinematic.gd`. Task 5 only *listens* to `TacticalCamera.mode_changed`.
5. **Tests stay green.** `./Test.ps1 -WithUI` must pass at the end of every task. Add the checks listed in each task to `tests/test_art.gd` or `tests/test_ova_rendering.gd`.
6. **Visual proof.**
   - Before Task 1, render a baseline with `artifacts/camera_review.gd` and `artifacts/lighting_probe.gd`. Rename the outputs with a `before-` prefix.
   - Re-render after each task and compare against the baseline.
   - Both scripts run with: `& 'C:\Program Files (x86)\Godot\Godot.exe' --path . --script res://artifacts/<name>.gd`.
   - `artifacts/` is gitignored. Renders are evidence, not deliverables.
7. **Docs.** Update `docs/ova-rendering.md` (Wet dock and lighting, Materials, Tuning table) as you go. Remove statements that stop being true.

---

## Task 0: Performance baseline

The OVA doc says no frame budget has been measured, and this pass adds lights and effects on top. Measure first.

- Add `artifacts/perf_probe.gd`. It opens the battle at 1440×900, turns on `RenderingServer.viewport_set_measure_render_time` for the root viewport, and records the average GPU time (`viewport_get_measured_render_time_gpu`) and CPU time over 120 frames in each of:
  - the overview;
  - the close view (`camera.toggle_close()`, then wait 1 s);
  - a running attack cinematic (emit a staged `attack_resolved`, as `artifacts/camera_review.gd` does).
- Record the numbers in a new **Performance** section of `docs/ova-rendering.md`.
- Re-run at the end of every task. **Budget:** at 1440×900 on the dev GPU (RTX 3060 Ti), no state may exceed 8 ms GPU, leaving room for weaker hardware. If a task breaks the budget, fix it before moving on.

---

## Task 1: Move the environment and key light out of the baked dock

**Problem:**
- `art/dock/StaticDock.tscn` contains a frozen copy of the `WorldEnvironment` and `DirectionalLight3D`.
- For the standard 36×26 map, `BattlefieldBuilder.build()` loads that scene and returns early.
- So `OvaRendering.environment()` changes and the `rendering/ova/ssr` setting never reach the main map.

**Do:**
1. In `battle/world/battlefield_builder.gd`, split lighting out of `build_procedural()` into `static func build_lighting(parent: Node3D) -> WorldEnvironment`. It creates the environment from `OvaRendering.environment()` and the shadowed key light, and returns the `WorldEnvironment`.
2. `build()` always calls `build_lighting()` first. It then either instances `StaticDock.tscn` (geometry only) or builds the procedural geometry.
3. Expose the environment to the battle: `BattleController.build_table()` stores the returned node as `var world_environment: WorldEnvironment`. Task 5 needs it.
4. In `art/build_static_dock.gd`, before packing:
   - Delete the `WorldEnvironment`.
   - Turn the directional light into a bake-only copy: `editor_only = true`, bake mode left at Dynamic. The bake keeps its indirect light, and the runtime key from `build_lighting()` provides the direct light without being counted twice.
5. Regenerate and rebake the dock (procedure in `docs/ova-rendering.md`).

**Acceptance:**
- On the standard map, setting `rendering/ova/ssr=true` in `project.godot` turns SSR on (temporarily; set it back to false).
- Add a test: `game.world_environment.environment.ssr_enabled == ProjectSettings.get_setting("rendering/ova/ssr")`.
- Exactly one non-editor-only `DirectionalLight3D` exists in the running battle (test this).
- The overview render matches the baseline: lighting must not change in this task.

---

## Task 2: Real-time warm lamps that light the mechs

**Problem:**
- The eight sodium lamps are `editor_only` and bake-only, so they appear only in the dock's lightmap.
- `paint.gdshader` ignores lightmaps and ambient light.
- Its `light()` combines lights with `max()`, so even a real-time lamp would lose to the key.
- Mechs therefore only ever receive one cool light. In the concept, warm floodlights put orange highlights on every mech.

**Do:**
1. **Lamp masts.** In `BattlefieldBuilder` (shared by the dock and procedural paths, so not baked):
   - Place 4 masts just outside the playable area: the midpoints of the two long edges, plus two opposite corners. They must be clear of the deployment aprons and add **no collision**.
   - Each mast is a thin box pole about 4 units tall, with an emissive lamp head (`emission_strength` about 3.5, as the existing lamps use).
   - Each mast carries one real-time `SpotLight3D` aimed down and inward at the table centre.
   - Colour `ffcc8b`; `shadow_enabled = false`; `light_bake_mode = BAKE_DISABLED`. Range and angle must together cover roughly a third of the table each. Tune energy against the render.
   - Keep visible local lights ≤ 8 in total.
2. **Remove the old baked lamps.** Remove the eight bake-only perimeter `OmniLight3D`s from `build_static_dock.gd`, and the emissive streak boxes from `build_dock_lamps()`; Task 3 replaces the streaks. Keep or restyle the small lamp housings as you see fit.
3. **`paint.gdshader` `light()`:** directional and local lights need different handling.
   - **Directional (`LIGHT_IS_DIRECTIONAL`):** keep the current hard bands exactly as they are.
   - **Local lights:** *add*, don't `max`. Add a single hard band: `step(local_threshold, max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION)` × `painted_color` × `LIGHT_COLOR / PI` × `local_strength`.
   - New uniforms: `local_threshold` (start at 0.12) and `local_strength` (start at 0.55).
   - Multiply by `(1.0 - sensor_mix)`.
   - The warm band must read as a lit edge on the side facing the lamp, not wash the whole mech orange.
4. Ground and cover use `environment.gdshader` with standard lighting, so the lamps light them automatically. Check the pools of light on the deck read as soft and broad, not as hard spotlight cones. If needed, widen `spot_angle_attenuation`.

**Acceptance:**
- In `camera-6-shoulder` and `camera-7-reaction`, mechs show a warm lit edge on the lamp side and the cool key on the other.
- In the overview, units on the lamp-lit half look visibly warmer than units in the dark centre, but faction readability is unchanged. Compare with the greyscale capture in `test_art.gd`.
- Test: in Sensor View (`sensor_mix = 1`), a mech pixel next to a lamp has the same colour as the same pixel with the lamps hidden.
- Performance is within budget.

---

## Task 3: Wet-ground reflections without the angle-dependent flare

**Problem:**
- Puddles use real specular (`SPECULAR 0.65`, `ROUGHNESS 0.18`) lit by the directional key.
- The table camera is orthographic, so the view direction is identical everywhere. At some orbit angles whole puddles flare white, and glow blows them out further.
- Proof: compare `artifacts/probe-wet-2.2.png` with `probe-dry-2.2.png` from `artifacts/lighting_probe.gd`. Every flare disappears when only the puddle mask is switched off.

**Do:**
1. **Kill the key-light highlight, keep the reflectivity.**
   - Give `environment.gdshader` a custom `light()` that writes Lambert diffuse only: `DIFFUSE_LIGHT += max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION * LIGHT_COLOR / PI`. Don't write `SPECULAR_LIGHT`.
   - Keep the puddle `SPECULAR` / `ROUGHNESS` values, so SSR can still use the puddles in Task 5.
2. **Painted lamp reflections.**
   - Add uniforms `lamp_positions` (`vec3[4]`), `lamp_count` and `lamp_color`, set by `BattlefieldBuilder` on the wet-dock material from the Task 2 mast positions.
   - In `fragment()`, for each lamp, compute the offset from this fragment to the lamp's ground point. Measure it in two directions: **along** the camera's horizontal view direction (from `INV_VIEW_MATRIX`) and **across** it.
   - Build an elongated streak: narrow across, about 0.35 units; long along the view direction, about 3–4 units on the camera side.
   - Quantise it into 2 hard steps (cel style). Multiply by the `puddle` mask, and add `lamp_color × steps × strength` to `EMISSION`.
   - The streaks follow the camera as it orbits, the way real wet reflections do, but never flash the whole table.
3. Fade everything with `(1.0 - sensor_mix)`.

**Acceptance:**
- Extend `artifacts/lighting_probe.gd` into a test, either in `tests/test_art.gd` or as a new GPU test run by `Test.ps1 -WithUI`:
  - Render the HUD-hidden overview at azimuths 0, 1.1, 2.2 and 3.3, then again with `wet_ground = false`.
  - The number of pixels where the wet luma exceeds the dry luma by **> 0.35** must be **< 0.1 %** of the frame at every azimuth.
  - Note: lamp streaks are emissive, so keep their peak luma rise under 0.35, or exclude a mask around the lamps' ground points.
- In close view, puddles near a mast show a short warm streak pointing toward the camera.

---

## Task 4: Hard specular highlight on armour

**Problem:** `specular_disabled` plus `SPECULAR 0` means armour never catches a highlight. The concept relies on wet-metal glints.

**Do:**
1. In `paint.gdshader` `light()`, for the directional key and local lights, add a cel highlight: `step(sheen_threshold, dot(NORMAL, normalize(LIGHT + VIEW))) * ATTENUATION * band_is_lit`.
   - Add it to `DIFFUSE_LIGHT`. `ALBEDO` is white in this shader, so it adds directly as colour.
   - Colour: `LIGHT_COLOR / PI * sheen_strength`, tinted toward the light colour.
   - Uniforms: `sheen_threshold` (start at 0.94) and `sheen_strength` (start at 0.35).
2. Keep `specular_disabled`, `SPECULAR 0` and `ROUGHNESS 0.02`. The highlight is painted, and the roughness mask ID is unchanged.
3. Keep the highlight below the glow threshold (1.3 HDR). It should be a crisp band, not bloom.
4. Fade with `sensor_mix`.

**Acceptance:**
- In close view and the shoulder shot, flat armour plates facing between the light and the camera show a small, hard-edged highlight.
- In the overview it is barely visible. That's acceptable.
- The existing mask tests in `tests/test_ova_rendering.gd` still pass unchanged.

---

## Task 5: Atmosphere for the close view and cinematics

The table view stays clean, as Codex intended. Fog, SSR and rain belong to the perspective views, which now exist.

**Do:**
1. **A listener on the camera mode.** In `BattlePresentation.setup()` (or `BattleController`), connect to `controller.camera.mode_changed`.
   - `OVERVIEW`: atmosphere off.
   - `CLOSE` or `CINEMATIC`: atmosphere on.
   - Tween the transition over 0.5 s, the length of the camera's blend (`TacticalCamera.BLEND` / `RETURN_BLEND`).
2. **Depth fog** on `world_environment.environment` (from Task 1), Forward+ and Compatibility:
   - `fog_enabled`, with a violet-navy `fog_light_color` close to the background `111323`.
   - Exponential density around 0.03, tuned so the far table edge fades but a target 10 units away stays readable.
   - `fog_sky_affect = 0`.
   - Tween the density from 0 to the target value; don't toggle it on.
3. **SSR**, Forward+ only:
   - Turn on `ssr_enabled` in CLOSE/CINEMATIC; `ssr_max_steps` about 48, `ssr_fade_in`/`ssr_fade_out` at default.
   - Check that mechs (roughness 0.02, specular 0) do **not** turn mirror-like. If they do, report it; don't change the mask ID.
   - Puddles should now reflect mechs and lamps. The Task 3 streaks may need slightly reduced strength while SSR is on.
4. **Rain:**
   - A `GPUParticles3D` child of the camera, emitting in a box in front of the lens.
   - About 1,500 particles of thin stretched quads, unshaded, pale violet-white with low alpha.
   - Falling with a slight wind angle; visible only in CLOSE/CINEMATIC (`emitting` toggled, existing drops allowed to finish).
   - It must sit outside the composite's mask and Kuwahara, as other transparent effects do (see "Render path" in the OVA doc).
   - Optional, cheap: a few small splash bursts on the deck near the camera using `CelEffects` smoke frames.
5. Sensor View overrides all of it: no fog tint, no rain, no SSR while `sensor_mix > 0.5`.

**Acceptance:**
- Tests:
  - entering close view turns fog and SSR on within 0.6 s;
  - leaving them off restores `fog_enabled == false` (or density 0) and `ssr_enabled == false`;
  - rain is emitting only in CLOSE/CINEMATIC.
- Re-render `artifacts/camera_review.gd`: frames 3, 6 and 7 show fog depth, rain and puddle reflections; frames 1 and 8 (overview) look like the Task 4 result.
- Performance: the close view and cinematic stay within budget **with** SSR, fog and rain on.

---

## Task 6: Armour trims at world scale, with stencils and hazard tape

**Problem:**
- `art/armour_trims.gd` stretches one 239×55 px strip over each mesh's whole bounding box.
- Seam size therefore varies from mesh to mesh, and every plate shows the same short dashes (visible in `camera-7-reaction`).
- The stencil strip (US 01, 317, 02, 09) and caution-tape strip are never used.

**Do:**
1. **World-scale panel UVs.**
   - Write UVs in metres: local position ÷ `trim_tile_size` (start at 0.5 m), multiplied by the model scale where known. Keep the per-vertex dominant-axis projection and Codex's new `trim_projection: "top"` extra for cambered shells.
   - In `paint.gdshader`, add `uniform vec4 trim_rect` (the atlas sub-rectangle) and sample `texture(albedo_texture, trim_rect.xy + fract(UV) * trim_rect.zw)`. The panel strip then tiles inside its own atlas rectangle.
   - Inset by half a texel to avoid bleed, as now.
   - `ArtPalette.unit_paint()` must pass `trim_rect` and stay cached per key.
2. **Hazard tape on Red frames.**
   - Apply the caution-tape strip to the shoulder armour and knee shields of Pact frames (OB-12 Medved, Type-09 Tieshan), matching the concept's yellow and black on the Red mechs.
   - Select meshes by name (`Shoulder_armour`, `Knee_shield`, or their equivalents in those GLBs).
   - Keep it to one or two plates per frame.
3. **Stencils.**
   - Where a frame has a `Tactical_number_*` mesh or `number_mark`, add a stencil from the stencil strip next to it (unit ID, e.g. "US 01" for Blue).
   - Use a small quad slightly offset from the plate with the paint material; Compatibility has no `Decal`.
   - Stencils must survive workshop recolouring.

**Acceptance:**
- In `camera-7-reaction` and the workshop close-up, seam spacing looks consistent across plates of different sizes, and no identical dash pattern repeats plate to plate.
- Red frames show hazard tape.
- Workshop tests (`test_workshop*.gd`, `test_kestrel_workshop.gd`) pass, including per-component paint finishes.

---

## Task 7: Decide whether to keep the lightmap bake

Task 2 replaced the baked lamps with real-time ones. The remaining bake only adds indirect key and ambient light to the dock floor, through an editor plugin that searches the UI for a button labelled "Bake Lightmaps". That breaks under a different editor language or a UI change.

**Do:**
1. Render the overview and close view with `LightmapGI` present, then with it removed at runtime (`queue_free()` the `DockLightmap` node before the first frame).
2. **If the difference is not clearly visible:**
   - Remove `LightmapGI`, `dock.lmbake`, `dock.exr`, `addons/dock_baker/` (and its `project.godot` registration) and the UV2 unwrap.
   - Keep `StaticDock.tscn` as a plain prebuilt geometry scene, or drop it and always use `build_procedural()` if load-time cost is negligible.
3. **If the difference is visible:**
   - Keep the bake, but make it robust. Godot 4 exposes no public script API for baking `LightmapGI`, so either harden the plugin (find the bake control by class or tooltip, not by English button text, and fail loudly with instructions) or remove the plugin and document the manual editor bake steps.
   - Extend the bake to every scenario size, or note the limitation clearly.
4. Record the decision and the before/after images' file names in `docs/ova-rendering.md`.

---

## Finish

- Run `./Test.ps1 -WithUI`, all suites green, and `artifacts/perf_probe.gd` within budget.
- Update `docs/ova-rendering.md` to match the shipped state. In particular, the "Wet dock and lighting" section and the Tuning table gain `local_strength`, `local_threshold`, `sheen_*`, the fog density and the rain count.
- Write a short summary at the bottom of this file: what shipped, the final tuning values, the performance numbers, and anything deferred.

## Execution summary — 23 October 2026

Tasks 0–7 completed in order, with a tested commit for each task. The shipped pass separates live environment/key lighting from dock geometry, adds four collision-free sodium masts and additive warm cel bands, removes wet-ground flare, adds bounded painted lamp streaks and armour glints, and enables fog/SSR/rain only for perspective views. Sensor View overrides atmosphere; Compatibility keeps fog and rain without SSR. Armour now uses world-scale trims, selective Pact hazard tape and stencil cards preserved by workshop recolouring, including the existing cambered-shell projection option.

Final tuning: local threshold **0.12**, local strength **0.55**; sheen threshold **0.94**, sheen strength **0.35**; streak strength **0.18**, length **3.8**, width **0.35**; trim tile **0.5** world units; fog density **0.03** with a **0.5 s** transition; **1,500** rain particles; SSR **48** steps. Mech roughness ID remains **0.02** and environment roughness remains **0.18–0.88**.

The remaining LightmapGI bake had no clear visual benefit: A/B mean luminance differences were **0.00160** overview and **0.00291** close. The bake, unwrap and editor plugin were removed; the plain prebuilt dock remains. Comparison evidence is recorded in `docs/ova-rendering.md` under Task 7's decision.

At 1440×900 on the RTX 3060 Ti, the final 120-frame averages were **5.079 / 3.743 ms GPU / CPU** overview, **4.039 / 2.740 ms** close and **4.613 / 2.437 ms** cinematic. All views meet the **8 ms GPU** budget. Per-task timings and before/after evidence are recorded in the OVA rendering document and ignored `artifacts/lighting-pass/` files. The four-angle flare test reports zero pixels above the specified wet/dry brightness threshold.

The full `./Test.ps1 -WithUI` regression suite is run at every task checkpoint. Optional splash bursts remain deferred; rain, fog, SSR, trims, tape and stencils are implemented. Existing unrelated workshop and model edits are retained outside these task commits.
