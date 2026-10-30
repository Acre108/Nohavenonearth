# Gen 3 frame art QA — 25 October 2026

**Action record, 26 October 2026:** See [correction actions](gen3-qa-actions-2026-10-26.md) and [selected-art index](../output/imagegen/Gen3-Art-Index.md). Ten frames have replacements; Marlinspike's scale graphic is pending image-service rejections. Harmattan's bay was removed at the user's request, superseding the bay-placement recommendations below.

## Scope and verdict

Visually reviewed scenes and technical sheets for the eleven Gen 3 frames other than SKYLINE: 22 selected images. Also inspected the two older Raijin images to distinguish the superseded design, and Mamont's scene and technical image for Russian family resemblance. No artwork was regenerated or changed during this review.

Design authority: `Gen3-Prototype-Art-Briefs.md`, including its revised Raijin brief; `Gen2-Frame-Art-Briefs.md` for Mamont lineage. Saved generation prompts and the corrected-art manifest identify the intended versions, but earlier QA statements are not treated as proof that a correction succeeded.

**Tsar and Pamir need another pass.** Both technical sheets contain badly oversized human comparison figures. Both also lose some of Mamont's massive, hunched silhouette. Tsar needs shorter, heavier legs and a larger siege torso; Pamir needs more of Mamont's chest, pillar legs and protected tiny head beneath the reactor equipment. Merely enlarging the machines within the canvas would not fix those proportions.

Scene perspective prevents a trustworthy numerical height measurement. The technical-sheet comparison insets provide much stronger evidence of incorrect scale than foreground people in the scenes. Mass is a silhouette judgment, not something the images can verify numerically.

## Priorities

| Frame | Verdict | Main correction |
|---|---|---|
| OB-21 Tsar | High priority: sheet and scene | Human scale, siege proportions, mortar shoulder and ammunition scale |
| OB-X Pamir | High priority: sheet and scene | Human scale and Mamont-derived bulk; lower, more shielded reactor silhouette |
| M15 Vanguard | High priority: sheet and scene | Human scale; stake-driver side changes; scene is crouching rather than clearly kneeling |
| AWX-1 Marlinspike | High priority: sheet scale inset | Four-arm/no-leg anatomy works; human and comparative machine sizes do not |
| PT-X Raijin, revised | Targeted correction | Sheet human scale; scene should read as immediately after firing |
| Type-20 Tianyan, v2 | Targeted correction | Escorts appear too small relative to their command-frame chassis |
| CA-X Saetta | Mostly sound | Modest scale-inset correction and complete scene framing |
| QF-6 Harmattan, v2 | Mostly sound, clarify mechanisms | Shield proportions across views; flank-bay placement remains visually ambiguous |
| BD-X Polaris, v2 | Mostly sound | Reconcile giant cabin opening with human-sized interior fittings |
| NK-X Ashvin, v2 | Mostly sound | Technical-sheet link-pod orientation still differs from scene |
| QT-1 Elissa | Mostly sound | Scene boarding scale and unambiguous grounded knee |

## Russian frames

### OB-21 Tsar — 21.0 m, 138 t

Files: `output/imagegen/gen3/04-ob-21-tsar-{scene,technical}.png`.

- **Scale inset fails.** The technical sheet's bottom-right human is several times too large relative to the machines. A 1.8 m person should be about **8.6% of the 21 m frame's height**, using a consistent body-height datum. The crane and raised gun must not be used to disguise an undersized chassis.
- **Too much conventional humanoid leg.** The upright sheet views have relatively long thighs/shins and a distinct waist. The brief calls for an enormous slab torso on short, massive legs: a walking self-propelled gun, heavier than Mamont. The deployed scene improves the bracing but retains the same basic chassis problem.
- **Mortar is on the wrong side.** In the front-biased sheet and scene, the mortar sits on image-right, the machine's own left. The brief specifies its own right shoulder. Correct the actual arrangement; horizontally flipping the whole scene would also move other equipment.
- **Mortar and shell are over-scaled for 305 mm.** The enormous bore, hoisted shell and ammunition held by the support mech suggest a much larger calibre relative to the body. Keep a heavy cradle and hoist, but distinguish the barrel's exterior bulk from its 305 mm bore and use matching ammunition.
- **Deployment needs a clearer drawing.** Multiple spades are visible, which is good, but their attachment and the separate rear outrigger are difficult to trace across views. Show four leg-mounted spades and the rear outrigger explicitly, with a consistent deployed arrangement.
- **Keep:** winter splinter, low protected head, twin stacks, forearm cannons, shell-handling support mech, dusk ridge and fortified city. The Iskra equipment callouts are useful; the scene correctly uses the mortar rather than a particle beam.

Correction direction: establish a front/side chassis drawing with a 1.8 m person and a common-scale Mamont first. Preserve the 21 m specification while moving visual volume into the torso, shoulders, hips and short pillar legs. Then rebuild the firing scene from that design with people and trucks near the mech's feet at comparable depth.

### OB-X Pamir — 20.4 m, 124 t

Files: `output/imagegen/gen3/05-ob-x-pamir-{scene,technical}.png`.

- **Scale inset fails.** The bottom-right person is much too tall beside both machine silhouettes. The target is **8.8% of Pamir's stated height**, with the same datum rule as Tsar. Its reactor and radiator tips should be dimensioned separately if they extend above that datum.
- **Mamont family resemblance is weakened.** Pamir's narrow middle, relatively straight upright posture and articulated long legs read lighter than the parent. Compare Mamont's huge forward chest, hanging tusk-like plates and bowed pillar legs: the prototype should retain that weight-bearing structure beneath the new power plant.
- **Reactor dominates vertically.** A large exposed-looking cylindrical tower rises well above the shoulders. The brief calls for a squat, heavily shielded vessel in a boxy armoured back housing, with thickened rear shielding. Lower and integrate the housing; retain a cylindrical vessel in the cutaway rather than making the entire exterior a tall drum.
- **Scene scale is less conclusive than the inset.** Foreground NBC crew are closer to the camera, so their pixel height cannot directly establish a 20.4 m measurement. The truck, crew, hatch and machine nevertheless do not provide a sufficiently clear common-depth scale check. Include one distant crew member beside a foot and a truck on the same ground plane.
- **Keep:** no diesel stacks, two flat radiators, coolant loops, radiation markings, right-shoulder cannon and left rocket bank, exclusion-zone scene, NBC crew and melted snow. No reactor glow is present, which is correct.

Correction direction: use Mamont as the chassis reference, retain its massive chest and legs, then replace its diesel machinery with the low shielded reactor and radiators. Do not inflate the reactor or raise the radiator tips merely to meet the nominal height.

## Other frames

### M15 Vanguard — 17.8 m, 66 t

Files: `output/imagegen/gen3/02-m15-vanguard-{scene,technical}.png`.

The capacitor-over-turbine arrangement, orange cables, cupola head, yellow bands and electrothermal rifle identify the prototype well. The firing effect reads as a muzzle flash rather than a sustained beam.

The technical inset's human is far too large: the intended ratio is **10.1%**. In the scene, engineers and their trailer also make the chassis read smaller, although foreground perspective contributes. The six-blank stake-driver unit is on the visible image-left arm (the mech's right), whereas the front technical drawing puts it on the specified left. Resolve that mismatch. The pose is a deep two-footed crouch rather than a clearly grounded kneeling brace; show a knee contacting the ground. Keep the rifle power connection readable independently of the stake driver.

### CA-X Saetta — 18.5 m, 45 t

Files: `output/imagegen/gen3/03-ca-x-saetta-{scene,technical}.png`.

The slim Falco body, heavier braced arms, red/gold scheme, fin pack, emitter rings and hip rifle are coherent between sheet and scene. Two arms and two legs are readable; the opponent's damaged shoulder and the rain/steam setting match the shot.

The inset human is still somewhat too large for the specified **9.7%** ratio. The scene crops the foreground foot and relies on distant people for scale, so it is attractive action art but less useful as a full-body design reference. A future composition should include the complete foot and a clearer vehicle scale cue. Lower priority than the heavy frames.

### PT-X Raijin — 18.0 m, 44 t

Selected revised files: `output/imagegen/g3-06-pt-x-raijin-scene-v2.png` and `output/imagegen/g3-06-pt-x-raijin-technical-profile.png`.

The redesign succeeds at the main brief: binocular sensor bar, no face or V-fin, enlarged right shoulder, left cooling hump, forearm-supported instrument-like emitter, cartridge rack and stabilising feet. The sheet comparison human is oversized relative to the intended **10.0%** ratio. The scene shows a strong continuous beam and bright impact rather than a fading afterglow; dim the beam if matching the specified post-shot instant. Coolant is present. Keep the revised design.

**Version issue:** `output/imagegen/gen3/Gen3-Art-Manifest.json` still selects `gen3/06-pt-x-raijin-*`, the old V-fin/face/red-feet design. Those two images conflict with the revised brief and should not be the reference for another generation pass. This review records the issue without changing asset selection.

### AWX-1 Marlinspike — 15.5 m, 31 t

Files: `output/imagegen/gen3/07-awx-1-marlinspike-{scene,technical}.png`.

The four arms, two distinct upper weapons, shorter lower grapples, headless cockpit pod and tapered thruster tail are present. There are no accidental legs. The catapult launch, folded main solar arrays and Earth backdrop work.

The sheet's astronaut and bottom-right machine comparison are not a credible common-scale presentation. A person should be **11.6% of the specified 15.5 m body length**; the small Marlinspike silhouette is also disproportionately short beside the standing comparison frame. Define cockpit-to-tail length independently of weapon reach and redraw that inset. Scene astronauts are foreground figures and cannot settle the scale numerically. Preserve the successful anatomy.

### Type-20 Tianyan — 16.8 m, 71 t

Files: `output/imagegen/g3-08-type-20-tianyan-{scene,technical-profile}-v2.png`.

The corrected scene contains six individually visible headless escorts and one domed-head command frame. Long escort cannons, short escort sensors and a command-only tall node/mast are all present. The technical human is much better scaled than the earlier sheets, and folded/raised mast states are included.

The escorts' torso and shoulder volumes appear much smaller than the command machine's, despite being closer to the camera. Kneeling explains lower head height, but not the whole body-volume difference. Match the shared chassis dimensions before applying the kneeling pose and command backpack. Avoid making the escorts miniature drones. The command tent/truck scale is improved; it does not need a wholesale scene rebuild.

### QF-6 Harmattan — 17.6 m, 64 t

Files: `output/imagegen/g3-09-qf-6-harmattan-{scene,technical-profile}-v2.png`.

Single-barrel shoulder cannon, grounded knees, broad planted shelter blade, water panniers, blue hoses and sheltered families are present. Human scale is substantially better than the Russian technical insets.

The main standing sheet views make the shield appear narrower relative to shoulder width than the deployed inset and scene; fix its dimensions once and use them across views. The open bay lies at the rear-right torso edge, making its distinction from a rear-centre bay ambiguous in the scene. A side elevation should show the right lateral hatch and platform clearly, with the central back closed. These are consistency/clarity issues rather than a repeat of the original multi-tube-cannon failure.

### BD-X Polaris — 16.4 m, 50 t

Files: `output/imagegen/g3-10-bd-x-polaris-{scene,technical-profile}-v2.png`.

The rear entrance, continuous ramp, overhead winch, sled, two work arms, quilted joints and unarmed rescue identity are clear. The rear scene now communicates a large machine, and its small crew and knee-height tractor are effective scale cues.

The giant rear opening and broad ramp imply a much larger interior than the recognisably human-sized seats and two bunks in the cutaway. Reconcile door, bunk, seat and sled dimensions on one cabin plan before treating this as a resolved walking habitat. No urgent exterior regeneration is needed.

### NK-X Ashvin — 18.6 m, 78 t each

Files: `output/imagegen/g3-11-nk-x-ashvin-{scene,technical-profile}-v2.png`.

The scene has the mirrored outer rifles/inner rotary cannons, one link pod on each inner shoulder, short protected heads, white/black stripes and a detached harness handover. People beside the feet communicate scale reasonably well.

The sheet's lower paired inset still shows conspicuous front-facing link-pod lens windows, rather than the inward-facing relationship of the scene. Recheck the previous rotation edit and draw a top-view link arrangement. Its human reference remains a little large, though much closer than Tsar/Pamir. Preserve the scene and use it to resolve the pod orientation.

### QT-1 Elissa — 17.8 m, 56 t

Files: `output/imagegen/g3-12-qt-1-elissa-{scene,technical-profile}.png`.

Four separate white rescue capsules, a lowered industrial cradle, separate dark fuel cells, raised shield toward the burning inland ridge and ferry evacuation are readable. The sheet's human scale is broadly credible.

The medic at the side hatch reads larger relative to the chassis than the sheet's scale figure. Check the ladder, door and tandem-seat dimensions together. The scene's folded pose is plausible, but the grounded knee is not as explicit as the brief requests; expose one knee contact if revisiting it. Keep all four pods and the distinct cradle/fuel-cell arrangement.

## Recommended correction sequence

1. Resolve Tsar and Pamir technical designs with Mamont and a 1.8 m person on a shared baseline. Fix proportions, equipment sides and height datum before remaking scenes.
2. Regenerate their scenes from those approved designs, including a person and vehicle at approximately the mech's depth. Preserve the frozen siege and exclusion-zone stories.
3. Correct Vanguard's scale, stake-driver side and kneeling pose; repair Marlinspike's comparison inset without disturbing its anatomy.
4. Resolve Raijin asset selection, then make the smaller scale/consistency fixes above.

All findings are visual concept-art QA. These sheets contain perspective views, not dimensionally validated orthographic drawings. A proposed correction is not a completed fix; the selected outputs must be inspected again after editing.
