# Variant frame art visual review — 21 October 2026

Reviewed all 50 selected PNGs against [Variant-Frame-Art-Briefs.md](../Variant-Frame-Art-Briefs.md). All pairs were inspected on side-by-side review sheets; suspected anatomy, equipment and variant-detail failures were checked at full image size. The findings below describe the initial selection before the correction pass. The live [selected-images.json](../output/imagegen/variants/selected-images.json) now points to the revised selection.

## Correction pass completed — 21 October 2026

Generated corrections for every frame with an identified issue, preserving earlier versions. The final 25 scene/technical pairs were inspected together again. Corrected selections and exact edit prompts are saved under `output/imagegen/variants/review-fixes/`; the art index and selection manifest have been updated.

- Repaired Longstride's extra arm and established longer shins and broad splayed feet.
- Corrected asymmetric equipment on both Siroccos, Workshop Garrison and the House Rigger; restored Teague's four-arm technical silhouette after an edit obscured one grapple.
- Replaced Alpine Tundra's rotary weapon with a single-barrel M30; added Tunis Falco's joint boots, waist filters and cooling-fin shields.
- Matched Arbalète's rounded electronic-warfare hump and head between views; added Dragan's rounded donor armour and handled battery spine.
- Improved human scale references, test markings, Selva's camouflage and reformer details, Vigie's tank arrangement, the Steppe Tieniu's rear tow connection, the Tieshan-Dao knee guard and the Type-15K mast hinge.
- Revised the commercial mine's mismatched guards, HX-6 transformation, HX-7C sea-ice setting and hardpoints, Husarz framing/lance, export Medved battery-swap background, Raider fuel bladders, Teague's canopy slit and Mwale's convoy number.

The technical format is a single perspective concept study with detached equipment where helpful. It is not a full orthographic turnaround. Human figures provide approximate visual scale, not calibrated engineering dimensions. Fine mechanical details and occluded attachment geometry remain interpretive; use the written briefs as the authority for modelling.

Corrected comparison sheets: [01–05](../artifacts/variant-art-review/review-fixed-01.jpg), [06–10](../artifacts/variant-art-review/review-fixed-02.jpg), [11–15](../artifacts/variant-art-review/review-fixed-03.jpg), [16–20](../artifacts/variant-art-review/review-fixed-04.jpg), [21–25](../artifacts/variant-art-review/review-fixed-05.jpg).

## Assessment

The rendering, weathering and maker identities are cohesive, and many scenes communicate the intended story well. The set is useful as illustration, but it needs another correction pass before it can serve as a dependable design reference. Completion of generation did not mean completion of visual QA: the earlier delivery understated the remaining errors.

The most consequential problems are an extra Longstride arm, reversed shoulder equipment, missing desert conversion features, the wrong M30 gun, and scene/technical hardware mismatches. Several errors were inherited from base-frame references and survived the previous edits.

## Priority 1 — resolve before accepting the affected designs

### 01 M6 Longstride — technical anatomy; both images' proportions

The technical illustration has THREE arms: a rifle-holding arm reaching image-left, a second stake-bearing arm descending on image-left, and a normal hand-bearing arm on image-right. The stake arm is not a detached equipment study; it connects into the body. Remove the extra arm and establish exactly two shoulder-to-hand chains.

The scene and technical illustration also do not strongly sell the exceptionally long shins and broad, splayed duck-foot pads. The feet remain close to heavily armoured Garrison boots, especially in the scene. Make the longer lower legs and wider lateral pads unmistakable while retaining the tank hull, cupola, trial bands and stripped side armour. The river, stuck Garrison and engineers are successful.

### 07 VK-4 Arbalète — technical image disagrees with corrected scene

The scene now has the right direction: a rounded dorsal jamming hump, small raised panels and a rounded mono-eye helmet. The selected technical image still carries a large upright Pavise-style rectangular panel, a different head shape and a different backpack arrangement. It is not a consistent depiction of the corrected scene.

Use the corrected scene as the design authority for a new technical image. Keep the compact conventional rifle and German flash; make the dishes flush to the hump and the folding panels small. Reduce the oversized human reference.

### 10 CA-3 Falco (Tunis) — desert conversion incomplete in both images

The Tunisian flash, palm emblem, left-shoulder sensor and sandy convoy scene work. However, the hips and knees still expose the standard Falco's mechanical joints rather than the specified sealed rubber boots. Waist sand filters and heat shields over the cooling fins are not clearly established; the pack still reads as exposed standard cooling fins.

Add legible joint boots, waist filter housings and separate heat-shield plates over the fins. Retain the visor shutter and shoulder sensor. These are defining conversion details, not optional surface decoration.

### 11 BD-2A Tundra Alpine — wrong gun in both images

The weapon has a multi-barrel rotary cluster. The M30 is explicitly a stubby SINGLE-BARREL 30 mm chain gun with pistol grip, shoulder brace and box magazine; the Gen 1 brief explicitly excludes rotary guns. Replace both the carried gun and detached technical weapon.

Keep the left forearm winch, cable, grapnel, quilted covers and crampons. Those identify the Alpine conversion well. Reduce the technical human figure, which is much too tall relative to the 17 m frame.

### 19 QF-4Q Sirocco — cannon on wrong shoulder in both images

The tank gun is on the mech's OWN LEFT shoulder, the image-right side in the front-biased view. The brief specifies its OWN RIGHT shoulder, with the machine visibly heavier on that side.

Move the entire cannon, mounting cradle and yellow recoil-damper assembly to the right shoulder. Do not simply flip the whole image and inadvertently reverse other equipment. The current gun is also very short and howitzer-like compared with the long Tieniu tank gun; revise its proportions using that weapon reference. Keep the open hatches, extra filters, standing firing pose and recoil dust.

### 20 Sesay's Sirocco — shoulder weapons reversed in both images

The Western missile pod sits on the mech's OWN RIGHT shoulder and the crude Pact rack on its OWN LEFT. The brief specifies the opposite. Establish a clearly countable 12-cell Western pod on the left and the crude rack on the right, and keep the sponsor paint blocks attached to their respective equipment.

The final scene no longer has the obvious dangling extra hand seen in earlier drafts. Retain the camp, mechanic and pickup. The two separate fire-control boxes are useful and should remain visually independent.

### 21 Dragan's Lantern — distinctive armour and battery not established

Both images still look largely like the standard angular Lantern Custom. The specified rounded Haubert donor plates over chest and shoulders, in a visibly different grey, are not convincingly readable. The backpack is a stack of box modules rather than an unmistakable Kestrel battery spine with quick-swap handles.

Define the rounded donor armour and a recognisable removable battery spine. Keep the wing stubs, mono-eye, sonic blade, compact conventional rifle and charcoal finish. The rain-soaked gas-plant scene is strong. Do not introduce a turbine or exhaust.

### 22 Workshop Garrison — shoulder gun reversed; left tool unresolved

Both images put the Tieniu gun on the mech's OWN RIGHT shoulder, above the breaker arm. It belongs on the OWN LEFT shoulder. The right breaker arm is correctly placed and should stay there.

The left mining arm terminates in a bare-looking attachment/coupler rather than a clearly resolved working end; finish that assembly consistently. The boiler-plate protection around the cupola is also weak: it still reads as an exposed rectangular sensor box. Keep the yellow mining hydraulics and workshop setting.

### 24 AW-5L Rigger — tether reel changes sides between images

The scene places the additional large reel on the mech's OWN RIGHT heavy forearm, image-left. The final technical image correctly places it on the OWN LEFT forearm, image-right, alongside the chest reel. Correct the scene to match the brief and technical image.

Both images retain four arms and twin bubble canopies successfully. The scene crops the outer part of one enlarged solar wing; give it more margin. Preserve the crossing tethers, family tender and cargo.

## Priority 2 — consistency, scale and shot corrections

### Human scale across the technical set

Several figures imply machines much smaller than the stated heights. The clearest cases are 02 commercial Garrison, 04 HX-7C, 05 Vigie, 06 Selva, 07 Arbalète, 11 Alpine Tundra, 12 Caribou and 17 Rys. Vigie, Selva and Arbalète are especially conspicuous.

On the Vigie technical image, compare the human with the BODY height, excluding the mast: the figure is approximately one fifth of the frame body rather than about one tenth. On Selva and Arbalète the figures likewise read roughly twice as tall as intended. These are approximate visual ratios, not calibrated measurements.

For a 1.8 m person, the target human/frame height ratios are 9.2% for Longstride, 10.5% for a 17.2 m frame, 15.7% for the 11.5 m Lifter, and 13.8% for the 13 m Rigger. Do not apply a universal one-tenth rule to the smaller industrial machines. Use the ground datum and body height consistently; scene figures at different depths cannot be assessed with the same simple pixel ratio.

### Technical presentation

Most technical images are three-quarter perspective studies, not true side elevations. This is already acknowledged in the art index, but it remains a mismatch with the saved profile prompts. The briefs originally ask for turnarounds; this set supplies neither full turnarounds nor consistent orthographic profiles. Decide on the intended technical format before regenerating sheets.

Separate weapon studies are helpful. In several sheets the weapon remains carried and is also shown separately; this is acceptable for concept art, but the detached study must match the carried version. Back equipment, undersides and joint sealing are often hidden by the current angle.

### Other frame-specific observations

- **02 Commercial Garrison:** mining colours, removed foreground missile pods, laptop access panel, floodlights and sandbags work. The three background guards are very similar rather than clearly mismatched frames. Technical human scale needs correction.
- **03 HX-6:** strong prototype instrumentation, checker markings, cable-fed rifle and fixed pack. The scene reads as a walking mech with wings spread, rather than an unmistakable intermediate transformation. Make the transformation mechanics explicit if the precise shot matters.
- **04 HX-7C:** retains the correct Kestrel family and avoids a Harrier turret. The scene reads as a snowy mountain landing rather than clearly establishing Svalbard sea ice. The revised battery and reinforced hips should be more distinct from the base Kestrel, and the three hardpoints per binder should be legible as separate stations.
- **05 Vigie:** both selected images now show three tanks, the tall mast and Dutch flash. Tank packaging differs: the scene adds a low side-mounted third tank, while the technical image uses an offset rear cluster. Standardise the mount locations. Correct the human scale before using the sheet to judge the six-metre mast extension.
- **06 Selva:** the corrected technical machete is now on the left forearm, matching the scene. The scene does not clearly expose the reformer and filler hose as well as the technical image. Keep the joint boots, mesh-wrapped mast and splayed feet; strengthen the green/brown camouflage, which remains quite pale.
- **08 Husarz:** the two metal emitter vanes, lighter shield and pennant read well. The scene crops the tops of the signature vanes. The lance also reads short for 15 m relative to the mech; use the technical image to establish the intended length rather than relying on foreshortening. Preserve the unfeathered construction.
- **09 Falco no. 1:** among the stronger pairs. The reinforced right mount, left-hip rifle, insignia and Arctic aftermath are readable. Refine human scale and make the detached lance's connection to the forearm mount mechanically clear.
- **12 Lantern Caribou:** a strong desert conversion after repainting: flat feet, fabric covers, filters, cargo and lantern emblem agree. Technical human scale is the main remaining issue.
- **13 Steppe Tieniu:** the living cage, stove, blue silk and steppe story work. The tow cable is held in a hand rather than clearly connected to the specified heavy rear tow hook. Show the rear attachment and make the bunk/periscope felt wrap identifiable.
- **14 Tieshan-Dao:** the extended blade is much more convincing now, with twin sooty stacks and the short parrying blade retained. The steel guard over the right knee still resembles ordinary rounded knee armour; distinguish it as a bolted dozer-steel addition. Keep the chipped blade and exposed arm rams.
- **15 Type-15K:** one of the strongest brief matches: four racks, radar mast, removed cannon, second hatch and trench stores are visible. Verify that the mast actually has a folding joint if the technical image is used for modelling.
- **16 Export Medved:** removed rockets, blank mounting plate, shrouded stacks and tan-over-winter finish read well. The background jets do not clearly demonstrate open battery spines at a swap pit. This is a scene storytelling refinement, not a reason to redesign the Medved.
- **17 Rys:** final images now agree on a single stack, exposed frame and grey finish. Reduce the technical human figure and make the white calibration markings more explicit; red tally marks alone do not demonstrate test calibration.
- **18 Raider Haboob:** a successful pair: absent cannon, drum rifle, added storage and night convoy fit the brief. Distinguish the flexible fuel bladders from the rigid water tank more clearly. Preserve the engine-off atmosphere.
- **23 Teague's Lifter:** both images have the intended four arms, upper rivet guns and lower grapples. The scene's bracing and disabled pods work. Make the narrow slit in the scrap canopy plate explicit, and check the 11.5 m scale rather than borrowing a larger frame's figure size.
- **25 Mwale's walker:** among the stronger pairs; the construction cab, huge hydraulic rams, breaker, grapple and mine setting read clearly. Add a visible convoy number if desired, without introducing typography overlays. Keep its civilian rig identity.

## Recommended correction order

1. Repair Longstride anatomy.
2. Fix equipment sides on both Siroccos, Workshop Garrison and the Rigger scene.
3. Replace Alpine Tundra's gun; complete Tunis Falco's sealing and Dragan's donor armour/battery.
4. Bring Arbalète's technical design into agreement with its corrected scene.
5. Correct technical human scale, then standardise the remaining scene/technical equipment locations.
6. Address cropping and shot-specific refinements.

Preserve the successful scene compositions where a local edit can solve the issue. Do not treat a broad whole-image mirror as a substitute for moving one asymmetric part.

## Review sheets

Each sheet places scenes on the left and selected technical images on the right, in brief order.

- [01–05](../artifacts/variant-art-review/review-01.jpg)
- [06–10](../artifacts/variant-art-review/review-02.jpg)
- [11–15](../artifacts/variant-art-review/review-03.jpg)
- [16–20](../artifacts/variant-art-review/review-04.jpg)
- [21–25](../artifacts/variant-art-review/review-05.jpg)

For full-size selected images, use the [art index](../output/imagegen/Variant-Art-Index.md).

