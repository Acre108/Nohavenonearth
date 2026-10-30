# Harmattan and Elissa art QA — 30 October 2026

**Later direction amendment, 30 October:** Elissa's backpack geometry is not consistently resolved by these scene revisions. The [new canonical Elissa direction](elissa-art-direction.md) supersedes their long-boom/sideways-rack layout: pods tuck beneath the upper backpack, main scene is front-facing, medical key art rear-facing. Existing images remain selected until replacement art is produced; they are not authoritative references for the revised backpack.

Scope: Harmattan's selected prototype scene and its faction key scene, plus all current Elissa selections: technical sheet, harbour scene and “Room for a Medic” key art. The original Elissa harbour scene was also inspected as historical context. Harmattan's no-bay technical sheet supplied mechanical reference. Archived superseded files and Godot import caches are not separate deliverables.

## Findings before correction

| Asset | Findings |
|---|---|
| Harmattan prototype scene, 26 October no-bay version | Closed torso is correct. Shield and rifle arms disagree with the authoritative sheet: shield is under the right-side cannon, while the normal rifle arm is on the opposite side. Two water panniers appear together on the visible hip. Leg contacts are hard to separate. Preserve the rigid blade, two ground supports, camp and ground-level care. |
| Harmattan “People Before Territory” key art | **Still contains the superseded medical bay**, open room/bed and hatch. Its faction brief retains the obsolete description and references the old bay-equipped design. Equipment sides and paired near-hip tanks also need correction. Move care to ground level and use the closed-torso reference. |
| Elissa technical sheet | Main identity, arm sides, four rescue pods and approximate main-view human scale are sound. Two seats facing the same direction plausibly depict tandem seating; this is not established evidence of side-by-side seats. Add a plan to remove ambiguity. The detached deployment inset does not clearly demonstrate the cradle's attachment, clearance past fuel cells or loaded position behind the hips. Clarify empty folded versus loaded deployed configurations. |
| Elissa selected harbour scene | Four pods, separate dark fuel cells, shield/lance and evacuation ferry story are retained successfully. Clarify the two legs and knee/shin contact, human-sized ladder/door, and cradle load path. Occlusion is not proof of a missing limb. Original earlier harbour scene has a larger boarding medic and less explicit grounded knee; it remains historical. |
| Elissa “Room for a Medic” key art | Correct total is four pods, including the open lower pod; do not miscount it as three or add a fifth. Loading platform/supports are present. Improve leg separation, visible arm/stowed rifle, and matching cradle articulation/attachment. Human scale varies with depth and cannot be certified from foreground screen heights. |

## Corrected selections and follow-up QA

| Final image | Rechecked result |
|---|---|
| [Harmattan prototype scene](../output/imagegen/gen3/qa-fixes-2026-10-30/09-qf-6-harmattan-scene.png) | Shield attached on its left, rifle and single damped cannon on its right. Closed torso, two shield supports, ground medic, one grounded shin and opposite planted foot. Only the near hip pannier is exposed; the far side is occluded rather than duplicated on the near hip. |
| [Harmattan “People Before Territory”](../output/imagegen/gen3/qa-fixes-2026-10-30/35-harmattan-people-before-territory.png) | No bay, hatch room, bed in torso or medical platform. Medic works on the ground. Both hip panniers are visible, arm sides match the sheet, and the lowered right knee/backward shin is separated from the planted left foot. Water point, hoses, families, goats and carrier remain. Truck-side people reduced in a follow-up. |
| [Elissa technical sheet](../output/imagegen/gen3/qa-fixes-2026-10-30/12-qt-1-elissa-technical.png) | Four main views, correct arm sides, folded-empty cradle and attached loaded deployment with four pods. Separate dark fuel cells. Side cutaway and fore/aft two-seat plan agree on tandem seating. Main human is approximately 46 px against a 453 px head datum, close to 1.8/17.8. |
| [Elissa harbour scene](../output/imagegen/gen3/qa-fixes-2026-10-30/12-qt-1-elissa-scene.png) | Two humanoid arms, one rifle in the right hand, one left shield with clipped lance. Four sealed pods are carried by separate articulated booms. Grounded shin/opposite flat foot and small boarding medic/ladder remain readable. The coherent first new draft was mirrored locally to correct anatomical sides; ferry is now left and burning inland ridge right. |
| [Elissa “Room for a Medic”](../output/imagegen/gen3/qa-fixes-2026-10-30/22-qt-1-elissa-room-for-a-medic.png) | Four pods: three closed, one lower pod open. Connected cradle booms, separate fuel cells, supported truck/scissor platform and two medics loading one stretcher. Left shield/clipped lance and stowed rifle retained. Some far-side joints remain occluded; no missing limb is inferred from that. |

All five final images were visually inspected. Built-in image generation produced the artwork; the Elissa harbour selection additionally uses the user's previously approved local method for exact equipment-side corrections. Reproduce that mirror with `correct-elissa-scene-sides.ps1` beside the art. Prompts, reference paths, selected generated sources and findings are preserved in [the correction manifest](../output/imagegen/Gen3-QA-Corrections-Manifest-2026-10-30.json).

Rejected drafts are not selected. The first Harmattan scene retained reversed arms. Two Elissa harbour edit attempts introduced an extra rifle, a disconnected shield, then an extra humanoid arm; these were rejected rather than accepted as fixes. The original two-arm harbour draft plus local mirror is the final selection. One Harmattan faction-image edit was rejected by the service's input filter; a fresh illustration from the closed-torso technical reference succeeded. The error is saved alongside the prompts.

The obsolete side-bay language and design reference in `Faction-Origin-Key-Art-Briefs.md` were corrected to ground-level care and the no-bay reference. Active Gen 3/Corrected-and-Tunis indexes and manifests, both affected key-art manifests, and the Elissa key-art gallery now select the new files. Original images and historical generation prompts remain available; no hosted atlas was published or remote export changed.

All measurements remain concept-art design intent, not surveyed engineering dimensions.

Validation passed: five final PNGs and prompt records, all 24 active Gen 3 image/prompt paths, and every image path in both affected key-art manifests resolve. The frame index selects the new main images. Results are saved as `validation.json` beside the new art. [Open all five corrected images](../output/imagegen/Harmattan-Elissa-QA-Index-2026-10-30.md).
