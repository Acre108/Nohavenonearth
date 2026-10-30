# Gen 2 QA corrections — 29 October 2026

Continued from the [28 October checkpoint](gen2-qa-actions-2026-10-28.md). Fourteen revised images across ten frames are now selected in the [art index](../output/imagegen/Gen2-Art-Index.md). Generation and local editing are finished for this batch; no requests are running. The complete QA queue is **not yet closed**.

## Selected in this batch

| Frame | Accepted changes |
|---|---|
| Kestrel | Wider highway scene with both wing tips in frame. Four-view technical sheet plus flight mode, battery, fan and knife studies; front, rear and flight views show four missiles. |
| Osprey | Four-view sheet with right crane, left normal arm, rear plant, two spare packs and stabilizer studies. Extra rear pack column removed; humans reduced locally. |
| Bulwark | Four-view sheet, rear turbine/radiators, twelve-cell shoulder pods and shield/stake mount studies. Humans reduced. Shield visibility in main views and explicit six-chamber PB-4 evidence remain weak. |
| Haubert | Reused the saved four-view draft. Retained bullpup and rear module/rail studies; removed double-ended lance, invented calibre, embedded scene and bad scale diagram. Rebuilt lower studies and small human locally. |
| Tieshan | New four-view sheet with three-finger hands and twin-stack rear plant. Corrected invented cannon calibre to 200 mm, removed unsupported dimensions/weight and replaced erroneous three-stack inset. Scene now has one shoulder rack per frame. |
| Tiebi | Repaired saved turnaround masks, including foot-edge restoration. Four views clearly show two hands holding a separate portable cannon, rear plant and heel-spade studies. |
| Medved | Locally corrected both scene muzzle endplates to six openings around solid hubs. Retained two rocket banks and Tieshan followers. Technical view coverage still pending. |
| Mamont | Right integral maul retained. Technical sheet and scene now share two forward-pointing rocket banks; visible faces corrected locally to four rows of five. Rear sheet shows closed covers, and rotary muzzle centres are solid. Shoulder/elbow/raised-maul studies retained. |
| Volk | Scene rifle raised with visible elbow articulation and one muzzle opening. Technical sheet's repeated three-quarter view replaced with a true front view. |
| Lantern Custom | Scene now has two four-cell Fenrir boxes. Far face locally corrected using the painted near-box cell texture; left blade and rooftop-port composition retained. |

All original files remain available. Small exact-count faceplates are local paint-over details; these are illustrative concept sheets, not dimensionally verified engineering drawings.

## User decisions retained

- **Ghibli:** user rejected this batch's new feet. The original scene, `27-ca-5m-ghibli-scene.png`, remains selected. The rejected scene is saved only as a draft. Do not replace or retry its feet. The technical selection predating this batch is unchanged.
- **Tieshan-Kai:** the outdoor railhead remains primary; both original and corrected depot scenes remain indexed alternatives.
- **Mamont:** the right arm is a single integral maul. Do not restore the removed cannon or ammunition drum.
- Existing permission for local exact corrections remains in effect.

## Remaining main corrections — four frames

| Frame | Remaining work | This batch's result |
|---|---|---|
| Harrier | Full front/side/rear/three-quarter and flight-mode coverage, preserving six missiles and left shoulder turret. | Service rejected generated output: `moderation_blocked`, category `violence`, request `a8abcfe2-0883-4349-ad4b-57f670720c30`. Existing scale-corrected sheet retained. |
| Teamster | Complete turnaround and clear six-chamber PB-4 detail, retaining twelve-cell right pod. | Same output-filter rejection, request `03a67803-2ebe-4616-a1f7-d253d87c5a6b`. Existing corrected pod/scale sheet retained. |
| Pavise | Complete turnaround, rear plant/heel braces and rifle-length comparison on common scale. | Same output-filter rejection, request `acd0c939-16a3-47ce-a8a2-071d749f00b8`. Existing scale-corrected sheet retained. |
| Medved | Complete technical turnaround with two twenty-tube banks, four stacks and six-barrel muzzles. | Same output-filter rejection, request `eb51fb8a-12a5-4281-be18-231c1c0443bc`. Existing corrected technical sheet retained; scene muzzles corrected locally. |

These are image-service rejections, distinct from successful images failing visual QA. Prompts and exact errors are in [rejected-attempts.json](../output/imagegen/gen2/qa-fixes-2026-10-29/rejected-attempts.json). The service did not identify a precise visual trigger.

## Smaller reservations still open

- Kestrel: antenna remains more prominent than the short single blade in the brief.
- Bulwark: show the right forearm shield clearly in main views and demonstrate all six PB-4 chambers.
- Shiden: make HF-1 stowage explicit; existing turnaround/rear instrumentation is retained.
- Original pass/minor reservations remain for Caribou's hood, Wolverine's height datum/rifle wrapping, and Mistral's partner-state marking. They were not regenerated in this batch.

Thus **four main corrections** remain, plus smaller reservations on **six other frames**. Ghibli's old scene is a deliberate user preference, not an outstanding correction.

## Files and reproduction

- [29 October correction manifest](../output/imagegen/Gen2-QA-Corrections-Manifest-2026-10-29.json): selected/draft status and per-image findings.
- [Output folder](../output/imagegen/gen2/qa-fixes-2026-10-29/): accepted images, source bases, prompts, local edit plan and scripts.
- [Precision plan](../output/imagegen/gen2/qa-fixes-2026-10-29/precision-plan.json) and `precision-edit.ps1`: exact scale/count operations.
- Haubert first runs `recompose-haubert.ps1`; Tieshan's final inset runs `repair-tieshan-inset.ps1` after the precision plan. Run `write-provenance.cjs` to refresh sidecars.
- Use this batch's `apply-selections.cjs` for selections. Do not rerun the historical 27/28 October selection helpers, which can roll back newer choices.

Validation: all 27 manifest records, 54 selected PNGs, their prompt paths, index selections and both Tieshan-Kai alternatives passed file/path checks. The original Ghibli scene selection is explicitly asserted. Results are saved in `validation.json` beside the scripts.

