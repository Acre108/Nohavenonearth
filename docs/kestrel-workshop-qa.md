# Kestrel workshop and artwork QA — 23 October 2026

Initial revision-2 artwork fidelity: **6/10**. This is a subjective visual assessment of that
model against both the [technical profile](../output/imagegen/01-hx-7-kestrel-technical-profile.png)
and [scene artwork](../output/imagegen/01-hx-7-kestrel-scene.png). It rates resemblance
to the concept, separately from whether the asset works in the game. No geometry
was revised during this workshop integration and review.

The subsequent head revision is described below; the table records the original
assessment and its remaining whole-body priorities.

The model is recognisable as a Kestrel from the navy/white/orange scheme, shallow-V
wing binders, single amber visor, canopy chest, flank intakes, four missiles,
battery spine and long rifle. Its curved fairings also distinguish it from the
Teamster. It captures the equipment inventory and colour blocking more closely
than it captures the artwork's proportions and surface design.

| Criterion | Weight | Score | Visual finding |
| --- | ---: | ---: | --- |
| Silhouette and proportions | 30% | 6/10 | Wings identify the frame, but the broad oval chest and short-looking legs lose the concept's tall, narrow fighter-derived stance. |
| Armour forms | 20% | 5/10 | Compound curves are present, but too many shells are rounded capsules. The art combines flowing contours with sharp tapered panel boundaries. |
| Equipment shapes | 20% | 7/10 | Main equipment is present. Rifle receiver and muzzle are too chunky; the paired rails need more open negative space. Wings are simplified slabs. |
| Colour and markings | 10% | 8/10 | Navy, white and orange read correctly. Battery handles are orange rather than the artwork's yellow; aviation stencils and panel-specific markings are sparse. |
| Mechanical construction | 20% | 5/10 | Visible hinges, pistons and fans help. The art has substantially richer layered plates, exposed inner frames, panel breaks and hand construction. |

Weighted result: 6.0/10. Additional fine detail alone will not correct the main
differences. The next modelling pass should prioritise these changes:

1. Replace the rounded helmet with the reference's low, swept wedge, pointed nose
   and recessed visor. Keep curved upper surfaces rather than making the whole
   helmet spherical.
2. Narrow and lengthen the chest profile, with a more pointed canopy nose and
   recessed triangular intake mouths. Restore the visible waist gap and layered
   white lower chest plates.
3. Give the legs a longer visual read: more exposed thigh structure, extended
   tapered white shin plates and distinct calf nacelles. The current bulbous
   calves and broad feet make the frame look squat.
4. Reduce rifle receiver/stock bulk and separate its two long rails visibly.
   Add the reference's skeletal stock and finer muzzle bracing.
5. Refine wing roots, changing thickness, control surfaces and panel segmentation;
   then add selective fasteners, stencils and yellow battery handles.

## Workshop integration

Open the workshop and choose **HX-7 Kestrel** in the top frame selector. Both frames
use the same inspection and service UI, with separate saves and inventories:
`user://teamster_workshop_v1.json` and `user://kestrel_workshop_v1.json`.
Apply or discard pending changes before switching frames.

The Kestrel has eight selectable regions and fourteen component slots. Assembled,
exploded and isolated views, mesh picking, rotation, zoom, frame paint, component
paint, pilot selection, standard replacement components and repairs are supported.
Standard components preserve the existing frame rules. Deployment configures
`blue_kestrel`, and sortie return records its hull damage without altering the
Teamster's saved configuration. The VB-2 is assigned to the right forearm shell,
matching its modelled stowage seam.

The Kestrel now has nineteen mechanical animations, available through the same
Play/Pause/Rest controls as the Teamster. See [animation notes](kestrel-animation.md)
for the clip list, editable source, validation and motion previews. Alternate
weapon kits remain specific to the Teamster.

## Verification and evidence

- Kestrel workshop: **44 checks, zero failures**, including selector behaviour,
  all eight isolated regions, picking, factory paint, component paint, save/load,
  replacement compatibility, deployment and returned damage.
- Existing workshop state: **149 checks, zero failures**.
- Existing rendered Teamster workshop UI: **66 checks, zero failures**.
- Reviewed workshop renders at 1920×1080 and 1440×900. Godot reported its existing
  OS certificate-store warning; no script or test failures remained.

[Assembled workshop](../artifacts/kestrel-workshop/assembled.png) ·
[Front](../artifacts/kestrel-workshop/front.png) ·
[Side](../artifacts/kestrel-workshop/side.png) ·
[Rear](../artifacts/kestrel-workshop/rear.png) ·
[Exploded](../artifacts/kestrel-workshop/exploded.png) ·
[Isolated wings](../artifacts/kestrel-workshop/isolated-wings.png) ·
[1440×900](../artifacts/kestrel-workshop/workshop-1440.png)

Regression entry point: `Test.ps1 -WithUI`. The new rendered suite is
`tests/test_kestrel_workshop.gd`; its test saves stay in `artifacts/kestrel-workshop/`.

## Head revision 3

The head now uses an aircraft-like fore/aft section model, with a thin cambered
navy crown projecting into a pointed brow. A continuous amber slit wraps around
the recessed face beneath it. Independent white swept cheek plates and pointed
face chines replace the small chin beneath the old rounded helmet. Temple
pivots, side vents, fasteners, a neck pitch axle and cables make the lower head
read as mechanical construction. A thin blade antenna sweeps aft from the crown.

Before/after close-ups were rendered at matching camera positions and scales.
The final front, side and three-quarter views were checked for visor occlusion,
plate intersections, loose details and silhouette. The crown-to-visor clearance
and cheek fastener placement were corrected during that review. This pass targets
the focal point; the torso, leg, rifle and wing priorities in the initial review
still apply.

The crown exports an explicit top projection for its runtime armour trim UVs.
This prevents the automatic normal-based projection from changing axes across
the cambered surface and drawing jagged texture triangles. The final Godot asset
passed 44 Kestrel workshop checks and 82 rendered art checks with zero failures.

[Before](../artifacts/kestrel-head/before_three-quarter.png) ·
[After](../artifacts/kestrel-head/after_three-quarter.png) ·
[Front](../artifacts/kestrel-head/after_front.png) ·
[Side](../artifacts/kestrel-head/after_side.png) ·
[Workshop head inspection](../artifacts/kestrel-workshop/isolated-head.png)

## Whole-body proportions revision 4

The hip axle rises from 0.67 to 0.81 and the knee from 0.425 to 0.47 while total
height remains approximately 1.489. The core chest's maximum width reduces from
0.44 to 0.336, with narrower shoulders and a shorter pelvic shell. This moves
more of the silhouette into the legs and leaves a visible mechanical waist.
Thigh and calf fairings taper more strongly, and the feet have smaller insteps
and soles. The swept revision-3 head retains its size and position.

The canopy has a narrower, forward-projecting aircraft-nose profile and layered
white lower cheeks. Its pressure housing connects the glazing and surround to
the chest in side view. The LR-3 receiver and capacitor stock are considerably
slimmer; the long rails are vertically separated as in the technical profile,
with narrow braces rather than solid muzzle blocks filling the channel.

The coordinate pass moves region and component pivots, mesh fittings and the
rifle socket together. It preserves ground placement and keeps joint collars
from stretching with the longer limb fairings. The full export and all eight
independent region exports were rebuilt through the live Blender connection.

Front, side, three-quarter and black silhouette renders were reviewed against
revision 3 at matching camera settings. Workshop views were checked at 1920×1080
and 1440×900. The asset has 14,548 triangles and 277 rigid meshes within its
20,000-triangle budget. The Kestrel workshop and rendered art suites passed
44 and 84 checks respectively, with zero failures.

[Previous proportions](../artifacts/kestrel-proportions/before_beauty.png) ·
[Revised proportions](../artifacts/kestrel-proportions/after_beauty.png) ·
[Previous side](../artifacts/kestrel-proportions/before_side.png) ·
[Revised side](../artifacts/kestrel-proportions/after_side.png) ·
[Workshop](../artifacts/kestrel-workshop/assembled.png)
