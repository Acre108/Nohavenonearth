# Gen 2 QA corrections —28October2026

Current continuation: [29 October corrections and remaining work](gen2-qa-actions-2026-10-29.md). This dated log is historical.

Paused for today at the user's explicit request, to resume tomorrow. No generation is running. The new Tieshan-Kai background and current accepted corrections are saved; individual unresolved items are retained below and in the correction manifests.

## Tieshan-Kai artwork retained for use

- [New outdoor mountain railhead](../output/imagegen/gen2/qa-fixes-2026-10-28/11-type-09a-tieshan-kai-railhead-scene.png): squat corrected chassis, wet loading apron, freight equipment, misty pine hills and smaller workers.
- [Original depot scene](../output/imagegen/11-type-09a-tieshan-kai-scene.png): retained unchanged, explicitly linked as an alternate in the art index and manifest.
- [Corrected depot scene](../output/imagegen/gen2/qa-fixes-2026-10-27/11-type-09a-tieshan-kai-scene.png): also retained.

The outdoor scene is the primary selection; using either depot artwork remains possible. No old artwork was deleted or overwritten.

## Current changes

Approved local editing was used for technical-sheet human references and dimension/label cleanup. Exact operations and input sources are in [precision-plan.json](../output/imagegen/gen2/qa-fixes-2026-10-28/precision-plan.json); [precision-edit.ps1](../output/imagegen/gen2/qa-fixes-2026-10-28/precision-edit.ps1) reproduces the edits. Figures were masked and rescaled; overlapping lance/foot regions were preserved or restored. Heights use a stated head-to-floor image datum; these remain illustrative concept views, not engineering measurements.

- Mamont: maul arm retained, human reference reduced, dimension graphic moved to head datum, six-opening rotary endplates in visible technical views. Back battery geometry still needs clarification.
- Teamster: technical and scene Hornet faces now have three rows of four cells, sampled from the original painted cell texture.
- Bulwark: twelve-cell pods in sheet/scene, right bazooka and shield/left stake after mirroring, smaller technical human. Shoulder serial32 restored upright.
- Osprey: scene mirrored to put crane on its own right and normal hand on left, retaining draft's two spare packs and smaller crew; technical scale reduced.
- Medved: original technical sheet's extra central apertures closed with steel hubs, leaving its six outer mouths; human reduced. Scene rotary geometry still needs a separate correction.
- Medved-N: close-up audit confirms original v2 already had six barrels and a solid hub. Earlier seven-barrel QA finding was wrong and has been withdrawn. Its muzzles were left untouched; only scale/dimension graphics changed.
- Destrier/Falco/Ghibli: scale/label/dimension cleanup of the previously accepted sheets.
- Haboob: saved unreviewed draft inspected and accepted as a turnaround with rear plant and cargo views; human reduced.
- Sirocco: new four-view sheet and turbine/shroud/recoil-damper details; local human reduction and hydraulic rod cap.
- Lantern: new five-view sheet, left forearm sheath, rear battery/stub mounts and consistent two2×2 Fenrir boxes; local human reductions.
- Rigger: new four-view sheet with exactly four arm origins, rear pack, solar hinge, clamp sole and reel studies; astronaut references reduced.
- Other early sheets: human references reduced while preserving their selected chassis design and equipment. Unresolved non-scale issues remain open.

Selections and per-image findings: [28October correction manifest](../output/imagegen/Gen2-QA-Corrections-Manifest-2026-10-28.json). Previous work remains in [27October action log](gen2-qa-actions-2026-10-27.md). Main [Gen2art index](../output/imagegen/Gen2-Art-Index.md) selects current files; source prompts and local-edit provenance are saved beside outputs.

## Remaining work

Latest checkpoint: Rigger Security's new four-view sheet is accepted with its smaller astronaut reference. Tiebi's new hand-held-cannon turnaround is saved as a draft: its local dimension cleanup crossed the left arm edge, so the previous scale-corrected original is restored as the selection. Repair the draft without erasing that edge before selecting it. Pavise's latest turnaround attempt was rejected by the image service; the scale-corrected original remains selected.

Before resuming, inspect `precision-plan.json` and both dated correction manifests. Do not rerun the27October selection helper: it would restore historical selections. Use the28October helper. Original depot and corrected depot Tieshan-Kai scenes remain alternate selections alongside the outdoor railhead image. Local editing approval persists.

Complete remaining view coverage (particularly Kestrel, Harrier, Osprey, Teamster, Bulwark, Haubert, Pavise, Tieshan, Tiebi, Medved and Rigger Security), then finish scene continuity: Kestrel framing, Tieshan rack, Medved/Mamont rotary details, Volk rifle/pose, Lantern boxes and Ghibli feet. Resolve Mamont battery layout and the weaker upgrade/applique details where needed. Final validation and consolidated remaining-item counts are pending this work.
