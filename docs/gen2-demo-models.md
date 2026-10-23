# Gen 2 demo models

## Teamster revision 2

The Teamster now uses `art/models/build_teamster.py`, with shared helpers from the original
builder. It has 13,690 triangles and 251 rigid meshes, with eight explicit region roots and
fourteen component pivots matching the workshop. Its dedicated budget is 20,000 triangles;
the other models retain their 8,000-triangle budgets. Named region GLBs are exported into
`art/models/teamster_regions/` in assembly coordinates. The full GLB and editable Blender file
retain the same paths used by battle rendering.

The revision adds layered/sloped glacis armour, recessed cupola cameras, side vision blocks,
joint collars, exposed drive assemblies, rivets, hatches, grip fingers, tread details, cooling
hardware, fuel lines, tools and a tow cable. The depot supports assembled, exploded and isolated
inspection. See [the component contract](workshop-components.md) for the hierarchy and rebuild command.

The Teamster now also contains eighteen mechanical animation clips, baked from an editable 18-bone
Blender control rig into 26 rigid joint nodes. Its region/component roots remain available to
the workshop. See [animation notes](teamster-animation.md) for playback, source editing and limits.

The remaining notes describe the original four-model pass; the earlier Teamster triangle counts
and source-build description are superseded by this revision.

The four demo mechs now load their own Blender-built GLBs through
`units/presentation/unit_model_factory.gd`. The two fighter aircraft keep their
existing procedural models. Frame rules and loadouts are unchanged.

| Demo unit | Model | Visible equipment |
| --- | --- | --- |
| 01 / ACE | HX-7 Kestrel | Twin-rail LR-3, four AGM-M wing stores, stowed VB-2 knife seam |
| 02 / ANCHOR | M9 Teamster | AR-40 with grenade launcher, 12-cell Hornet, six-charge PB-4 stake driver |
| 04 / BULWARK | OB-12 Medved | Two six-barrel GSh-6M forearm cannons, 40-tube Grad-M battery |
| 05 / WRAITH | Type-09 Tieshan | Long Cannon with muzzle brake and folded bipod, Type-07 drum rifle stowed behind the left shoulder |

Source references are [the Gen 2 brief](../Gen2-Frame-Art-Briefs.md) and the
`01-hx-7-kestrel`, `04-m9-teamster`, `13-ob-12-medved`, and
`10-type-09-tieshan` technical profiles in `output/imagegen/`.
The requested demo loadouts take precedence over extra equipment in those sheets.
The models are deliberately simplified hard-surface tabletop assets, rather than
high-detail reproductions of the concept illustrations.

## Assets and rebuilding

Editable sources are `art/source/{frame_id}.blend`; runtime exports are
`art/models/{frame_id}.glb`. Each source includes a review camera. The source
folder is excluded from Godot import. The older `blue_line` template is retained
but no longer supplies the Kestrel.

```powershell
& 'C:\Program Files\Blender Foundation\Blender 3.2\blender.exe' --background --factory-startup --python art/models/build_gen2.py
```

The build creates all four models, GLBs, editable sources and inspection evidence.
Each has six semantic material slots, named rigid parts grouped under torso,
head, limbs and equipment pivots, and no textures, skinning or collision data.
Blender +Y converts to Godot -Z. The root is at ground centre. Heights use the
existing tabletop scale, with the Kestrel approximately 1.46 units tall and the
Medved taller and wider. Kestrel is the flight-capable humanoid configuration;
there is no transformation animation or separate fighter configuration.

Vertex colour `Col` contains short-range ray-cast ambient occlusion, restrained
edge wear and broad foot dirt. The cinematic shader multiplies those baked tones
into cel paint. Sensor shading retains the existing clean contact fill and faction
outline. Paint uses manufacturer colours from the brief; bases and outlines carry
faction information.

## Review and verification

Open `art/StyleTest.tscn` and run it with F6 for the lineup and shading controls,
or launch the demo normally. Per-frame beauty views, front/back/side/tactical
renders, four black silhouettes and JSON manifests are in `artifacts/gen2/`.
The manifests check triangle budgets, material slots, bounds and ground origin.
The art test additionally checks runtime instantiation, imported triangle counts,
vertex colours and ground placement for every model.

```powershell
powershell -ExecutionPolicy Bypass -File .\Test.ps1 -WithUI
```

The Blender build is scripted locally because this session did not expose a
callable Blender MCP tool. Rebuilding does not require MCP or external services.

Validation on 18 October 2026: Godot imported all four GLBs; the rendered art
suite passed 49 checks with zero failures. Triangle counts are 3,688 / 4,926 /
6,812 / 4,512 respectively. The broader rules/UI suites currently encounter
scenario assumptions outside this art change: the scenario includes units such
as `red_tank`, while tests still expect six units and a fixed six-unit ID table.
