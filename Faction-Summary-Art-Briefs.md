# Faction Summary Art Briefs

**Published, 18 November 2026 (atlas version 146):** All 37 selected images are live. The seven frames are in `ART` (fd2, fp1, fe2, fs2, fu2, fj1, fw2) and the 23 scenes are in `SCENES` under the atlas entries listed below, with captions.

**QA corrections completed, 18 November 2026:** All 37 illustrations are saved locally and all eight QA findings have been addressed. The [action report](docs/faction-summary-art-qa-actions-2026-11-18.md) records the selected revisions, tile checks and exact exports. Originals, prompts and failed attempts remain available; hosted publication has not been performed.

Art briefs for the example tiles on the atlas's faction summaries (the Frame, Ship and Key person shown when a faction card is opened on the landing screen). There are 39 tiles, three for each of the thirteen factions. Nine already have art the page uses, and these briefs cover the other **30**: 7 frames (a scene and a turnaround each) and 23 key-art scenes (11 ships and 12 people).

Written 11 November 2026 for Codex to generate. The picks follow the user's rule: Earth powers draw on Gens 1 to 5 and space factions on Gen 6 onwards, and the key person can be an ace or a person of interest.

**Production pass, 14 November 2026:** All 37 illustrations have been attempted by two Codex agents using built-in image generation. The [local review gallery](output/imagegen/faction-summaries/index.html), [manifest](output/imagegen/faction-summaries/manifest.json) and [review notes](output/imagegen/faction-summaries/README.md) record selected versions, corrections and service-blocked turnarounds. These records distinguish generated art from unresolved items; atlas placement and hosted publication have not been performed.

**QA pass, 14 November 2026:** [Independent review](docs/faction-summary-art-qa-2026-11-14.md) records five available images needing correction, four requiring further review, and the two missing turnarounds. The gallery flags the affected selections.

## How to use this file (instructions for Codex)

- Generate one image per request with the built-in image tool, using each **Prompt** exactly as written. Every prompt already includes the series style and its own Avoid lines.
- Attach the named reference image when there is one (paths are relative to `output/imagegen/`). References are **design reference only**: copy the machine's design, not the reference's weather, lighting or setting.
- The briefs are the source of truth. If a prompt and a brief disagree, follow the brief.
- **Scale:** a person is about 1.8 m, roughly one tenth of a normal frame. Ships are far larger again.
- No readable text anywhere: flags, ledgers, boards, screens and hull markings show shapes and colours only.
- All people are adults. Give them expressive, specific faces and practical clothes; nobody is a villain.
- Save the prompt beside each image as `<name>-prompt.txt`, as in the other sets, and write a `manifest.json` in the output folder.
- Medical rule (30 October 2026): never a red cross, red crescent or red crystal, or anything close to one. The line is already in every prompt.

**Output:** `output/imagegen/faction-summaries/`.
- Frames: `<desig>-<name>-scene.png` and `<desig>-<name>-technical-profile.png` (for example `dw-3-ironback-scene.png`).
- Scenes: `key-<nn>-summary--<slug>.png`, numbered 63 to 85 after the last key art (62).

## Atlas placement

The summary tiles pick art up automatically once it is in `docs/atlas/atlas-data.json`:

- **Frames:** add `"<id>":"<stem>"` to `ART` and publish `art/<stem>-scene.jpg`, `art/<stem>-tech.jpg` and `thumb/<stem>-scene.jpg`, converted the same way as the existing `ART` entries. The art then also appears on the frame's tree card and detail sheet.
- **Ships and people:** add `"<id>":{"f":"key-<nn>-summary--<slug>","h":"<short title>","c":"<one-sentence caption>"}` to `SCENES` and publish `art/key-<nn>-summary--<slug>.jpg` at 1600×900. The art then also appears on the entry's detail sheet, and for an ace on the ace card.
- Captions follow [docs/atlas-voice-guide.md](docs/atlas-voice-guide.md): short, plain, no kicker endings, no em dashes.
- Splice lines into atlas-data.json, never re-serialise it, and diff against the live artifact before publishing. Never publish `docs/atlas/atlas-redactions.json`.

## Index

| Faction | Frame | Ship | Key person |
|---|---|---|---|
| United States of the Americas | HX-7 Kestrel · has art | HCV-1 Rookery · has key art 14 | **Captain Priya Raman-Cole** · key 74 |
| Transatlantic Union | VK-3 Haubert · has art | **Dreadnought** · key 63 | **Commandant Hélène Marchetti** · key 75 |
| China | Type-09 Tieshan · has art | **BZhD-9 Fortress Belt Railway** · key 64 | **Chen Baoyu** · key 76 |
| Eurasian Ascendancy | OB-21 Tsar · has art | **PKA-1 Tsitadel** · key 65 | **Senior Lieutenant Kira Voronova** · key 77 |
| African Commonwealth | QF-6 Harmattan · has art | QS-1 Safina · has key art 13 | Hawa Abdelrahman · has key art 23 |
| United Nations of Earth and Luna | LW-X Earthrise · has art | **Providence-class Transport** · key 66 | **Major Luíza Ferraz** · key 78 |
| Colony One | **DW-3 Ironback** · new | **Lifeline-class Transport** · key 67 | **Captain Sable Calder** · key 79 |
| Constitutionalists | **NP-1 Charter** · new | **Resolute-class Battleship** · key 68 | **Ada McLarin Garza** · key 80 |
| Martian Research Directorate | **VW-5 Theorem** · new | **Axiom-class Battleship** · key 69 | **Dr Lene Halden** · key 81 |
| Celestial Prosperity Syndicate | **SK-5 Ledgerman** · new | **Ledger-class Dreadnought** · key 70 | **Han Zhuo** · key 82 |
| Umoja | **GV-3 Kith** · new | **Lifetide-class Dreadnought** · key 71 | **Keeper Baraka Osei** · key 83 |
| Ashva Compact | **GW-1 Ashvin-E** · new | **The Hakobune at Europa** · key 72 | **Rider Darya Arsenyeva** · key 84 |
| Communion | **HW-3 Vigil** · new | **Habitat-ships** · key 73 | **Mirrorwright Tomas Vey** · key 85 |

---

## Frames

Each frame needs a scene and a turnaround sheet, like every other frame in the atlas.

### DW-3 Ironback · Colony One

**Atlas entry:** fd2 · Gen 7 · 2312 · 17.4 m · 64 t · Dustline Works, north Mars. **Stem:** `dw-3-ironback`.

**What it must say:** Colony One's first frame of its own, built for a war against the MRD and then carried into the partisan war: armoured, cold-rated and repairable in a tunnel.

**Reference:** 04-m9-teamster-scene.png (family resemblance through the Teamster-S and Dust Teamster).

**Hammer correction, 14 November 2026:** The right-forearm breaching hammer is a compact short-stroke hydraulic ram on a bolted outboard forearm mount, with a protected piston and small rectangular striking head. It leaves the normal wrist and hand free to grip the rifle. The head, mount, scale and anatomical side must agree in every view and detail inset; no hanging block or replacement hand. Selected technical sheet v3 establishes this correction.

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. DW-3 Ironback, 17.4 metre mech, a squat, broad-shouldered heavy frame descended from the American M9 Teamster, with the Teamster's boxy torso and cab grown heavier: thick bolt-on slab armour that can be unbolted by hand, insulated joint boots and heated actuator shrouds for the Martian night, a sealed cab with a small armoured canopy and twin air tanks, a hammer-headed breaching tool on the right forearm inherited from the Dust Teamster, a heavy coil rifle carried two-handed, a backpack fuel-cell stack with stubby radiators that fold flat, rust-red dust packed into every seam, faded Colony One ochre and grey paint patched with mismatched panels. Scene: a rough-cut maintenance tunnel under north Mars, lit by work lamps strung along the rock. The Ironback kneels in a repair bay while three crew in patched pressure suits swap an armour slab with a chain hoist; a second Ironback stands further down the tunnel in shadow. Frost on the tunnel walls, cables and pipes along the ceiling, a sense of a long war fought on rationed parts. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
DW-3 Ironback, 17.4 metre mech, a squat, broad-shouldered heavy frame descended from the American M9 Teamster, with the Teamster's boxy torso and cab grown heavier: thick bolt-on slab armour that can be unbolted by hand, insulated joint boots and heated actuator shrouds for the Martian night, a sealed cab with a small armoured canopy and twin air tanks, a hammer-headed breaching tool on the right forearm inherited from the Dust Teamster, a heavy coil rifle carried two-handed, a backpack fuel-cell stack with stubby radiators that fold flat, rust-red dust packed into every seam, faded Colony One ochre and grey paint patched with mismatched panels. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### NP-1 Charter · Constitutionalists

**Atlas entry:** fp1 · Gen 8 · 2313–2326 · 17.6 m · 60 t · New Philadelphia Arsenal, Mars. **Stem:** `np-1-charter`.

**What it must say:** An American design built under the charter on Mars, with a deployment lock that only Washington can release. The lock is the point: a promise that no Martian war starts without Washington.

**Reference:** 04-m9-teamster-scene.png (American Teamster lineage through the Dropguard).

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. NP-1 Charter, 17.6 metre mech, a clean, upright American-pattern frame descended from the Teamster line through a drop frame, neater and newer than anything Colony One flew: smooth sealed armour, a rounded cab with a wide armoured canopy, a prominent armoured lock housing on the centre of the back where the weapon mounts and the actuator power runs through it, with a visible sealed interlock collar and status lamps, rifle stowed in a locked rack on the hip, civic colours of off-white and deep blue with a thin gold trim line, fresh paint and only light red dust on the feet. Scene: the forecourt of the New Philadelphia assembly on Mars under a pale butterscotch sky. Two Charters stand at rest either side of the steps with their rifles locked in their hip racks, while citizens in light pressure gear walk past them to the doors; a guard officer checks a handheld unit beside one frame's foot. Calm, orderly and hopeful, a young settlement proud of its law. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
NP-1 Charter, 17.6 metre mech, a clean, upright American-pattern frame descended from the Teamster line through a drop frame, neater and newer than anything Colony One flew: smooth sealed armour, a rounded cab with a wide armoured canopy, a prominent armoured lock housing on the centre of the back where the weapon mounts and the actuator power runs through it, with a visible sealed interlock collar and status lamps, rifle stowed in a locked rack on the hip, civic colours of off-white and deep blue with a thin gold trim line, fresh paint and only light red dust on the feet. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### VW-5 Theorem · Martian Research Directorate

**Atlas entry:** fe2 · Gen 7 · 2312 · 17.8 m · 48 t · Vesta Works. **Stem:** `vw-5-theorem`.

**What it must say:** The MRD's first original design, built on Ana Lubov's metallic-hydrogen cell, with every drawing published for the panels. It fights at range, the way the MRD prefers to.

**Reference:** 08-vk-5-pavise-scene.png (family resemblance through the Pavise-S and Proof).

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. VW-5 Theorem, 17.8 metre mech, a long-legged precise frame descended from the Union's VK-5 Pavise sniper, with the Pavise's tall sensor mast grown into a stabilised array on the left shoulder, slim armour with exposed calibration marks and survey targets on the plates, an insulated cryogenic cell housing on the back with frost on its pipes and a vent stack, a long coil rifle with a folding bipod, sealed cockpit with a narrow visor slit, pale grey and teal paint with small panel numbers, everything tidy and documented. Scene: a ridge above a dust plain in the Martian south during the 2312 civil war. The Theorem lies prone along the ridge line with its rifle on its bipod and its sensor array raised, two technicians in pressure suits crouched beside it with a portable instrument case. Far below, tiny dust plumes mark a column moving across the plain. Thin cold light, a dusty pink sky, careful and patient. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
VW-5 Theorem, 17.8 metre mech, a long-legged precise frame descended from the Union's VK-5 Pavise sniper, with the Pavise's tall sensor mast grown into a stabilised array on the left shoulder, slim armour with exposed calibration marks and survey targets on the plates, an insulated cryogenic cell housing on the back with frost on its pipes and a vent stack, a long coil rifle with a folding bipod, sealed cockpit with a narrow visor slit, pale grey and teal paint with small panel numbers, everything tidy and documented. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### SK-5 Ledgerman · Celestial Prosperity Syndicate

**Atlas entry:** fs2 · Gen 7 · 2312 · 15.0 m · 34 t · Skycut Foundry, Pallas. **Stem:** `sk-5-ledgerman`.

**What it must say:** Skycut's first combat design: a small, silent boarding frame for the houses' stop-and-search campaign against American shipping, running on cheap Arsia lithium packs.

**Reference:** 21-aw-5-rigger-scene.png (Rigger worker-frame lineage through the Tallyman).

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. SK-5 Ledgerman, 15.0 metre mech, a compact, low-profile vacuum boarding frame grown from the Ascension AW-5 Rigger worker frame, smaller than most combat frames, with a hunched torso, long grasping arms with magnetic grapples and cutting tools, a docking-collar clamp on the left forearm, a short coil carbine, quick-swap battery packs racked along the back like ledger drawers, cold-gas manoeuvring thrusters at the shoulders and hips, matt black with a single band of Syndicate gold and red on one shoulder, no exhaust glow. Scene: open space beside the long hull of an American cargo ship in the Belt. Two Ledgermen have clamped onto the freighter's airlock ring; one holds the hatch while the other's pilot, in a sealed suit, floats across to the lock with a document case on a tether. A Syndicate corvette hangs in the distance with its running lights on. Hard sunlight from one side, deep shadows, a business-like boarding rather than a fight. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
SK-5 Ledgerman, 15.0 metre mech, a compact, low-profile vacuum boarding frame grown from the Ascension AW-5 Rigger worker frame, smaller than most combat frames, with a hunched torso, long grasping arms with magnetic grapples and cutting tools, a docking-collar clamp on the left forearm, a short coil carbine, quick-swap battery packs racked along the back like ledger drawers, cold-gas manoeuvring thrusters at the shoulders and hips, matt black with a single band of Syndicate gold and red on one shoulder, no exhaust glow. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### GV-3 Kith · Umoja

**Atlas entry:** fu2 · Gen 7 · 2312 · 16.4 m · 44 t · Ganymede Vatworks. **Stem:** `gv-3-kith`.

**What it must say:** The first frame Umoja grew from the start: its frame is printed and its muscle grown alongside it, so the frame and its power were never separate things, and the keepers tend it as one body.

**Reference:** monsoon/03-the-hafun-frame-scene.png (distant ancestor through the Kinsman; keep only a faint resemblance).

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. GV-3 Kith, 16.4 metre grown mech, a lean, upright frame whose printed pale ceramic skeleton is visible at the joints and ribs, with dense layered grown muscle in deep green and russet bands under translucent protective sheathing, as clearly engineered as it is alive: sealed seams, access ports and fluid lines, a compact armoured cockpit pod in the chest, a smooth head with a wide sensor band, broad feet, no weapons in hand but a folded cutting tool on the forearm, healthy and well kept rather than monstrous. Scene: a warm, humid tending hall inside a Ganymede habitat, lit by grow lamps. The Kith kneels in a support cradle while keepers in light work clothes check its sheathing and fluid lines, one resting a hand on the muscle of its forearm as a nurse would. Children watch from a gallery. Calm, caring and collective, nothing clinical or horrific. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
GV-3 Kith, 16.4 metre grown mech, a lean, upright frame whose printed pale ceramic skeleton is visible at the joints and ribs, with dense layered grown muscle in deep green and russet bands under translucent protective sheathing, as clearly engineered as it is alive: sealed seams, access ports and fluid lines, a compact armoured cockpit pod in the chest, a smooth head with a wide sensor band, broad feet, no weapons in hand but a folded cutting tool on the forearm, healthy and well kept rather than monstrous. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### GW-1 Ashvin-E · Ashva Compact

**Atlas entry:** fj1 · Gen 6 · c. 2190–2311 · 18.6 m · 76 t, built as a pair · Garuda Works, Europa. **Stem:** `gw-1-ashvin-e`.

**What it must say:** Garuda Works begins by rebuilding the Nashik pilots' paired frames at Europa, with actuators from the Mitsurugi exiles and ice-water fuel cells. The pairs who ride them are sworn to the Oath, just as the first Ashvins were.

**Reference:** g3-11-nk-x-ashvin-scene-v2.png (design reference for the paired Ashvin; this is the same pair rebuilt for vacuum and ice).

**Cockpit correction, 14 November 2026:** The boarding hatch and compact cockpit belong in the upper chest, below the sensor head and above the waist joint. No cockpit in the pelvis, groin or thigh. The access ladder must reach the chest hatch. The selected scene v3 applies the user's correction to the original marked composition.

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. GW-1 Ashvin-E, 18.6 metre mech, TWO matching paired frames, the NK-X Ashvin rebuilt for Europa: the original's heavy monsoon-frame shoulders and paired-frame link fittings kept, now sealed for vacuum with seal lines round the cockpits, finer Japanese-built actuators visible at the knees and elbows, ice-water fuel-cell tanks slung on the back, spiked crampon feet for ice, a broad-bladed polearm on one and a coil rifle on the other, saffron and deep red paint faded by radiation with oath marks painted as simple shapes on each chest. Scene: the fractured white ice of Europa under the vast banded disc of Jupiter. The two Ashvin-E stand back to back on a pressure ridge, one watching each horizon, while a rider in a sealed suit climbs a ladder into the nearer one. A domed settlement and the long hull of a carrier lie on the ice behind them. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
GW-1 Ashvin-E, 18.6 metre mech, TWO matching paired frames, the NK-X Ashvin rebuilt for Europa: the original's heavy monsoon-frame shoulders and paired-frame link fittings kept, now sealed for vacuum with seal lines round the cockpits, finer Japanese-built actuators visible at the knees and elbows, ice-water fuel-cell tanks slung on the back, spiked crampon feet for ice, a broad-bladed polearm on one and a coil rifle on the other, saffron and deep red paint faded by radiation with oath marks painted as simple shapes on each chest. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### HW-3 Vigil · Communion

**Atlas entry:** fw2 · Gen 7 · 2312 · 16.0 m · 46 t · The Hearthwrights, the far dark. **Stem:** `hw-3-vigil`.

**What it must say:** The Hearthwrights' first new frame in a century, made to sleep for years on a trickle of power through the long cold and to wake ready when it is called.

**Reference:** g3-10-bd-x-polaris-scene-v2.png (Polaris lineage through the Polaris-S and Ember).

**Scene prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. HW-3 Vigil, 16.0 metre mech, a hooded, heavily insulated frame descended from the Boreal BD-X Polaris, its silhouette softened by quilted thermal blankets over the shoulders and thighs, a deep cowl over a small sensor head with a single dim amber standby lamp, a small isotope heat source in an armoured housing on the back, folded radiator vanes, long arms folded across the chest in its sleeping pose with a long coil lance stowed down its back, dark charcoal and frost-white colours with a thin line of dull gold, frost on every surface. Scene: a niche cut into the ice cliff of a dark outer-system moon, lit only by a distant pinpoint sun and the faint lamps of a Communion habitat-ship docked far below. The Vigil kneels asleep in the niche, frost thick on its blankets, while a single figure in a hooded pressure suit stands before it holding a small lantern, as if keeping a watch. Still, reverent and very cold. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. grounded real-robot mecha concept art, believable hardware, visible joints and panel lines, realistic weathering, clear scale reference with the people, cinematic lighting. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

**Turnaround prompt**

```text
HW-3 Vigil, 16.0 metre mech, a hooded, heavily insulated frame descended from the Boreal BD-X Polaris, its silhouette softened by quilted thermal blankets over the shoulders and thighs, a deep cowl over a small sensor head with a single dim amber standby lamp, a small isotope heat source in an armoured housing on the back, folded radiator vanes, long arms folded across the chest in its sleeping pose with a long coil lance stowed down its back, dark charcoal and frost-white colours with a thin line of dull gold, frost on every surface. mechanical design turnaround sheet, front, side, back and three-quarter views, orthographic, full body, neutral grey background, height scale bar with a human figure reaching only to the frame's ankle or lower shin. grounded real-robot mecha concept art, believable hardware, visible joints, hydraulic pistons and armour panel lines, stencilled markings without readable text, realistic weathering, detailed industrial design. Avoid: super robot proportions, glowing energy wings, glowing weapons, magic effects, chrome, organic or biomechanical forms, fantasy armour, cape, oversized head, chibi, cute, extra limbs, deformed hands, blurry, text, watermark, logo, copies of existing anime designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

---

## Ships

### 63 · Dreadnought · Transatlantic Union

**Atlas entry:** sfd0 · The war, c. 2187–2190. **File:** `key-63-summary--dreadnought-yernon`.

**What it must say:** A British dreadnought from the Union's Malapert docks arrives alone at the Battle of Yernon and breaks the Russian inner fleet. The Union, written off since the European Front, is a great power again.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. In high Earth orbit just after the Battle of Yernon, a single long British-built dreadnought, its hull a stepped wedge of heavy grey armour with a spinal gun along its keel and a cluster of radiator fins aft, holds station alone among the drifting broken hulls of a defeated Russian fleet. Small repair craft move along its scarred flank. Earth's curve fills the lower third of the frame, with the Moon small behind. The mood is stunned quiet rather than triumph. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, glowing exhaust, Star Wars or Star Trek ship designs, readable hull numbers, flags with text.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 64 · BZhD-9 Fortress Belt Railway · China

**Atlas entry:** yg20 · Gen 2 · 2171–2178. **File:** `key-64-summary--bzhd-9-fortress-belt-railway`.

**What it must say:** A railway behind the fortress belt carries Tieshans, Tiebis and ammunition to whichever sector is under attack, rerouted by Tianshu faster than any staff officer could.

**Reference:** 10-type-09-tieshan-scene.png and 12-type-15-tiebi-scene.png (design reference only).

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A long armoured train of twenty cars runs along a mountain valley behind a line of concrete fortress-belt bunkers in Central Asia. Its flatcars carry kneeling Type-09 Tieshan frames, boxy and heavily armoured with cockpits buried in the torso, and squat Type-15 Tiebi frames, lashed down under tarpaulin edges, between armoured ammunition wagons and a heavy diesel locomotive with an armoured cab. Railway workers wave signal flags at a junction; a switching tower stands beside the line. Dust and early morning light, snow on the peaks. Avoid: firing, beams, explosions, glowing weapons, Star Wars or Star Trek ship designs, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 65 · PKA-1 Tsitadel · Eurasian Ascendancy

**Atlas entry:** yh61 · The war, c. 2187–2190. **File:** `key-65-summary--pka-1-tsitadel`.

**What it must say:** Moscow's flying fortress: Kaspiy-Atom ground-effect lift under a Krepost's armour and Iskra turrets. It flies low and slow, is very hard to bring down, and carries a full breakthrough group of Mamonts.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A colossal 300 m armoured ground-effect fortress flies a few metres above a frozen steppe river, its broad flat hull riding a cushion of spray and snow thrown up by banks of lift fans along its sides, heavy slab armour like a land fortress, turret domes along its spine with their guns trained forward and not firing, and huge clamshell bow doors partly open to show heavy Mamont frames standing in a hangar. Tiny figures and trucks on the riverbank give scale. Grey winter light, a heavy, ominous mood. Avoid: firing, glowing weapons, aircraft wings, propellers, airship gasbags, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 66 · Providence-class Transport · United Nations of Earth and Luna

**Atlas entry:** sft13 · Gen 6 · late, c. 2260–2311. **File:** `key-66-summary--providence-class-transport`.

**What it must say:** UNEL's humanitarian flagship class: troops, refugees, medical cargo or reconstruction modules, the best environmental control in the system and almost no guns. Earth crews call Providences arks.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A large white-hulled transport with pale blue trim, built in modular blocks around a long spine with rows of cargo pods and a broad habitation ring of lit windows, docks at a lunar yard in orbit above the Moon. Reconstruction modules are being craned out of its hold by small tugs, and through a large pressurised observation window a line of families with bags waits to board, watched by UNEL crew in pale uniforms. Almost no visible weapons, just a few small point-defence blisters. Earth hangs in the background. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, glowing weapons, Star Wars or Star Trek ship designs, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 67 · Lifeline-class Transport · Colony One

**Atlas entry:** sft11 · Gen 6 · early, c. 2190–2260. **File:** `key-67-summary--lifeline-class-transport`.

**What it must say:** The mother ship of Colony One's fleet, with long-duration life support and sealed biosystems tuned to Martian physiology, for moving troops and habitats and evacuating the wounded. Crews paint settlement murals on its walls.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. Interior of a long pressurised cargo deck inside a Colony One transport in Mars orbit, curved metal walls covered in bright hand-painted murals of Martian settlements, domes, water channels and named family groups shown as figures without text. Crew in worn ochre coveralls secure stretchers and supply crates in racks while a mother and child sit on a bench under the mural. Through a small viewport the red curve of Mars. Warm work lights, a home-made, defiant pride. Avoid: firing, beams, explosions, glowing weapons, Star Wars or Star Trek ship designs, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 68 · Resolute-class Battleship · Constitutionalists

**Atlas entry:** sfb11 · Gen 9 · 2327. **File:** `key-68-summary--resolute-class-battleship`.

**What it must say:** The Constitutional capital ship: a modernised American-derived battleship, built for deterrence and for working alongside US forces.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A clean, modern battleship in off-white and deep blue with a thin gold trim line, an American-pattern hull with long armoured gun decks and a tall command tower, holds station in high Mars orbit beside a darker United States Navy cruiser, the two ships' shuttles crossing between them. Below, the dusty face of Mars with the lights of a settlement on the night side. Orderly, confident and civic rather than menacing. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, Star Wars or Star Trek ship designs, readable hull numbers, flags with text.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 69 · Axiom-class Battleship · Martian Research Directorate

**Atlas entry:** sfb17 · Gen 6 · late, c. 2260–2311. **File:** `key-69-summary--axiom-class-battleship`.

**What it must say:** The most accurate battleship in the system, built to set the geometry of a fight from stand-off range, with targeting that several Axioms share in real time. Its captains are austere and almost devout about optimal solutions.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. Three long, slender grey-and-teal battleships fly in a precise wide triangle above the small moon Deimos, each with a long spinal coil gun, a ring of sensor arrays at the bow and thin datalink masts, their positions so exact they look plotted, with a tiny survey cutter passing below for scale. Mars fills the background. Cool, austere, mathematical. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, glowing lines between ships, holograms, Star Wars or Star Trek ship designs.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 70 · Ledger-class Dreadnought · Celestial Prosperity Syndicate

**Atlas entry:** sfd13 · Gen 7 · 2312. **File:** `key-70-summary--ledger-class-dreadnought`.

**What it must say:** A trade-route anchor and neutral court for long, lonely voyages: a bank vault and a courtroom, with three bridges, one to fly the ship, one to count the money and one to negotiate marriages.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A massive black-and-gold dreadnought anchors a merchant caravan in the asteroid belt, its armoured hull shaped like a strongbox, with three distinct bridge towers along its back, each lit differently: one plain and functional, one with rows of lit counting-house windows, one with ornamented lanterns and a hall-like gallery. Smaller trading ships, ore haulers and shuttles cluster at its docking arms. Asteroids drift in the distance under hard sunlight. Prosperous, formal and slightly wry. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, glowing weapons, Star Wars or Star Trek ship designs, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 71 · Lifetide-class Dreadnought · Umoja

**Atlas entry:** sfd17 · Gen 9 · 2327. **File:** `key-71-summary--lifetide-class-dreadnought`.

**What it must say:** Umoja's largest living ship, dense with self-repair systems and sealed ecological architecture. Few powers want to find out what its hangars hold.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A vast dreadnought in orbit above Ganymede with banded Jupiter behind, its hull a layered shell of grown armour plates in deep green, russet and bone, like a seed pod crossed with a warship, engineered rather than monstrous, with sealed hangar mouths along its flanks, rows of greenhouse windows glowing softly along its spine and small repair craft tending patches of new growth on its hull. A Ganymede shuttle gives scale. Calm, alive and quietly formidable. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: tentacles, teeth, eyes, horror, slime, insect or monster shapes, firing, glowing weapons.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 72 · The Hakobune at Europa · Ashva Compact

**Atlas entry:** sfc13 · Gen 6 · late, c. 2260–2311. **File:** `key-72-summary--ar-1-hakobune-at-europa`.

**What it must say:** The Hakobune never flies in Earth's sky again after the Mandate, but it reaches Europa with the Nashik pilots and the Mitsurugi exiles. Its hangar is still the Compact's model for a carrier.

**Reference:** key-art-selected-10/26-carriers--ar-1-hakobune--first-flight-of-the-ark-v2.png (design reference for the Hakobune; copy the ship, not the setting).

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. The old AR-1 Hakobune, the Japanese fusion-lifted rescue carrier, now long settled on the ice of Europa, its hull weathered by radiation and patched with newer plates, its great hangar doors open. Inside the lit hangar paired Ashvin-E frames in faded saffron and red stand in their cradles while riders and engineers work around them. A small domed settlement has grown up around the ship's landing legs. Jupiter fills the sky. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, glowing weapons, Star Wars or Star Trek ship designs, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 73 · Habitat-ships · Communion

**Atlas entry:** sfc14 · Gen 6 · late, c. 2260–2311. **File:** `key-73-summary--communion-habitat-ships`.

**What it must say:** The ice communities' descendants leave in habitat-ships that carry everything they need, and go a long way from anyone else. Their first carriers are simply habitat-ships with hangars added.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. Three old habitat-ships travel together through the dark far beyond Saturn, each a long, patched cylinder of rings and tanks wrapped in insulation, with warm amber light in a few small windows, a hangar module bolted awkwardly onto the side of the largest one and an old insulated frame being walked into it on a gantry. The sun is only a bright star. Most of the image is darkness and faint starlight; the warmth is in the windows. Devotional, patient and lonely. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: firing, beams, explosions, glowing weapons, Star Wars or Star Trek ship designs, readable markings.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

---

## Key people

### 74 · Captain Priya Raman-Cole “Stopwatch” · United States of the Americas

**Atlas entry:** ac03 (ace card) · The Forty-Minute War, 2173. **File:** `key-74-summary--aces-priya-raman-cole-stopwatch`.

**What it must say:** The Kestrel's first ace. She flew drop-and-strike by the manual and never stayed past thirty-eight minutes on a battery, and when the defenders learned to wait out the clock she was the first to notice.

**Reference:** 01-hx-7-kestrel-scene.png (Kestrel design reference only).

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult South Asian American woman in her early thirties, a US Air Force frame pilot in a sealed flight suit with her helmet under her arm, stands on the sandy edge of a battery swap pit in the Jordanian desert, checking a large mechanical stopwatch on her wrist. Behind her an HX-7 Kestrel variable frame kneels in ground mode while ground crew wrestle a fresh battery spine into its back on a crane. Heat haze, low evening sun, other Kestrels landing in the distance. Focused, dry and competent, a pilot counting minutes. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 75 · Commandant Hélène Marchetti “Vermeil” · Transatlantic Union

**Atlas entry:** ac08 (ace card) · Svalbard, 2179. **File:** `key-75-summary--aces-helene-marchetti-vermeil`.

**What it must say:** The Union's first famous ace: at Svalbard her red Falco finished the Kestrels before they could get off the ice. Strasbourg made her the face of the Ace Showcase.

**Reference:** variants/09-ca-3-falco-no-1-scene.png (Falco no. 1 design reference only).

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult French woman in her early thirties, a Union lance commander with close-cropped dark hair, in a sealed cold-weather flight suit, stands on the snow at Svalbard after the battle, looking back at the wrecks of three American variable frames half buried in drifting snow. Behind her the CA-3 Falco no. 1, a lean red-and-gold Haubert-derived ace frame with a lance mount on its right arm, kneels with its cockpit open. Union ground crew in white snow gear approach across the ice. Grey Arctic light, a quiet, unboastful moment. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 76 · Chen Baoyu · China

**Atlas entry:** pc3 (Persons of Interest) · c. 2180s. **File:** `key-76-summary--persons-chen-baoyu`.

**What it must say:** One of the Tianlong engineers who taught Tianshu to schedule the frame trains, and later India's Tieshan spares. She wrote that a market is only a supply line nobody admits is one.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult Chinese woman in her forties, an engineer in a plain dark work jacket with rolled sleeves and reading glasses pushed up on her head, stands at a long desk in a railway dispatch hall beside a wall-sized board of illuminated route lines shown as coloured shapes without text. She marks a correction on a paper timetable while two younger engineers at terminals watch the board shift. Through tall windows, a rail yard with an armoured train loading kneeling frames. Evening light, orderly and precise. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 77 · Senior Lieutenant Kira Voronova · Eurasian Ascendancy

**Atlas entry:** ac19 (ace card) · Hari River, 2180s. **File:** `key-77-summary--aces-kira-voronova`.

**What it must say:** The wolf the observers saw at the Hari River: an augmented Department Zero pilot in a Volk, whose turns made Western analysts assume the frame was remote-controlled.

**Reference:** 15-ob-19-volk-scene-v2.png (Volk design reference only).

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult Russian woman in her late twenties, a Department Zero pilot with very short pale hair and a slim close-fitting pressure suit with ports at the neck and spine, sits on the lowered hand of an OB-19 Volk frame beside a shallow river crossing in western Afghanistan, unmoved, while a medic in a plain field uniform checks a monitor clipped to her wrist. The Volk, lean and wolf-like with a narrow head, crouches over her. Dust in the air, late afternoon light. Her augmentation is subtle and clinical, never monstrous; the mood is unsettling stillness. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 78 · Major Luíza Ferraz “Caipora” · United Nations of Earth and Luna

**Atlas entry:** ac36 (ace card) · Mong Hsat, 2185. **File:** `key-78-summary--aces-luiza-ferraz-caipora`.

**What it must say:** A Brazilian Army pilot seconded to the white squads, who led two of them up the valley at Mong Hsat and was the first UN officer to give the order to fire first.

**Reference:** 06-vk-3-enact-scene.png (Haubert design reference only).

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult Brazilian woman in her late thirties with dark curly hair tied back, in a UN pale-blue helmet and a worn field flight suit, talks on a handset with village elders around her in a misty jungle valley in the Shan Hills, just after a fight. Behind her a VK-3B Haubert frame painted UN white over jungle camouflage, the green showing through where the white has worn, stands with a breaching blade on its left arm; beyond it the smoking wreck of a heavy Type-09 Tieshan. A second white frame on the ridge. Humid, grey-green light, sober rather than triumphant. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 79 · Captain Sable Calder · Colony One

**Atlas entry:** ac70 (ace card) · The hidden docks, c. 2320. **File:** `key-79-summary--aces-sable-calder`.

**What it must say:** Torin Calder's daughter in her flying years: a Wayfarer pilot who trained in the remnant's hidden docks and flew operations nobody outside has ever confirmed.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult woman in her late twenties with a lean, weathered face and cropped dark hair, a Colony One remnant pilot in a patched ochre pressure suit, sits on a crate in a dim rock-cut hangar inside an asteroid, helmet in her lap, eating from a ration tin. Behind her a Wayfarer frame stands almost entirely in darkness under a tarpaulin, only its outline and a single work lamp catching one armoured foot, so its design stays unseen. Cold blue work lights, frost on the rock, a secret kept by everyone. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 80 · Ada McLarin Garza · Constitutionalists

**Atlas entry:** pu5 (Persons of Interest) · New Philadelphia, c. 2318. **File:** `key-80-summary--persons-ada-mclarin-garza`.

**What it must say:** Luz Garza's granddaughter, who presides over the charter's ratification at New Philadelphia and becomes the Constitutionalists' first Speaker. She is an altered American citizen, and the charter is the first law that has ever covered her.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult Latina woman in her late twenties, with a calm, steady face and slightly unusual pale-flecked eyes as the only sign of her alteration, stands at a plain wooden speaker's desk in a modest pressurised assembly hall on Mars, raising a gavel as delegates in practical clothes rise to their feet in the benches. A large window behind her shows Martian domes and water channels at dusk. A bound charter lies open on the desk without readable text. Earnest, hopeful and civic. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 81 · Dr Lene Halden · Martian Research Directorate

**Atlas entry:** pm4 (Persons of Interest) · Gen 6 · early, after 2190. **File:** `key-81-summary--persons-lene-halden`.

**What it must say:** Sabine Halden's daughter, who turns the ethics panel's conditions into the Directorate's founding charter: enhancement only by demonstrated necessity, and every programme before a panel.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult European woman in her forties with greying fair hair, in a plain research-station cardigan over a pressure undersuit, sits at the head of a long table in a bright pressurised conference room on Mars, reading aloud from a stack of annotated papers while six panel members of mixed ages and backgrounds listen and take notes. Through the window, the red plain and a cluster of research domes. Thoughtful, careful and quietly determined. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 82 · Han Zhuo · Celestial Prosperity Syndicate

**Atlas entry:** ac57 (ace card) · The Belt, c. 2300. **File:** `key-82-summary--aces-han-zhuo`.

**What it must say:** Before he commanded the Voidmarket Caravan, Han Zhuo was the Belt's most famous fighter: a Liang house pilot whose instinct beat predictive AI so often that pirates turned back when they heard his name.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult Chinese man in his thirties with a lean face and a confident half-smile, a Liang house pilot in a dark sealed flight suit with a gold-trimmed collar, leans against the foot of his frame in the hangar of a caravan carrier, drinking tea from a flask lid. Behind him a Tieshan-S, the Iron Mountain frame sealed for vacuum and stripped of a third of its armour, with a tether rig on its left arm, stands in a cradle while house engineers polish its plating. Through the open hangar doors, the lights of merchant ships in the Belt. Warm hangar light, relaxed and self-assured. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 83 · Keeper Baraka Osei · Umoja

**Atlas entry:** py2 (Persons of Interest) · Callisto, 2327. **File:** `key-83-summary--persons-baraka-osei`.

**What it must say:** Zawadi's son, bonded from childhood to a Kindred. By 2327 he leads the frames aboard a Mbegu seeding carrier, which lands on Callisto and grows a fortress where it stands. The Ashva watch every landing, and he waves at them.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult East African man in his early twenties, a keeper in a fitted green-and-russet pressure suit, stands on the dark cratered surface of Callisto beside his Kindred frame, a grown frame with pale printed bones and layered protective muscle under radiation-absorbing mats. Behind them a seeding carrier has landed and the first walls of a grown fortress are rising from its hull. Baraka raises one hand in a friendly wave towards two distant saffron-and-red paired frames watching from a ridge. Jupiter low on the horizon. Friendly, unhurried and confident. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers. horror, tentacles, teeth, slime, insect shapes, hostile gestures, firing.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 84 · Rider Darya Arsenyeva · Ashva Compact

**Atlas entry:** ph4 (Persons of Interest) · Europa and Io, c. 2240s. **File:** `key-84-summary--persons-darya-arsenyeva`.

**What it must say:** The rider who led her akhara into an Ascendancy settlement's cells on Europa to free three strays, and a year later rode out alone to bring one of them in after he killed a family on Io. The akharas still argue about it.

**Reference:** g3-11-nk-x-ashvin-scene-v2.png (Ashvin family design reference only).

**Approved correction, 14 November 2026:** Darya wears a fully sealed helmet with a transparent visor on Io's surface. Her hand is empty. This supersedes the helmet-in-hand wording in the original prompt below, retained as the first-pass generation record.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An adult Russian woman in her early thirties with a braided plait and a stern, tired face, a rider in a saffron-and-red sealed suit with oath marks shown as simple shapes on the chest, stands alone beside a single paired-frame Ashvin-E without its partner on the sulphur-yellow volcanic plain of Io, holding her helmet and looking towards a distant settlement. A long shadow, Jupiter enormous behind her, a plume rising on the horizon. Heroic but heavy with doubt. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```

### 85 · Mirrorwright Tomas Vey · Communion

**Atlas entry:** pw1 (Persons of Interest) · Uranus, 2320s. **File:** `key-85-summary--persons-tomas-vey`.

**What it must say:** Sister Aurore Vey's grandson, who flies a Mirrorwright at Uranus, turning the kilometre mirrors to catch a sun that is barely a bright star. He does not see the difference between keeping the mirrors and praying.

**Prompt**

```text
Use case: stylized-concept. Asset type: finished cinematic illustration for the No Haven on Earth atlas. One landscape 16:9 image, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8 m person is roughly one tenth of a normal frame, and ships are far larger again. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A young adult man of mixed Andean and European heritage in a hooded, heavily insulated pressure suit floats beside an enormous thin mirror more than a kilometre across, while his insulated Mirrorwright frame, hooded and long-armed, holds the mirror's edge with careful hands. The distant sun is only a bright star caught as a small reflected glint in the mirror; pale blue Uranus fills the far background. Through his visor his face is calm and absorbed, as if at prayer. Vast scale, deep darkness, devotional stillness. In vacuum there is no air haze, light is hard and single-sourced with deep black shadows, and pressurised interiors must read clearly as different from vacuum outside. Avoid: glamour posing, pin-up framing, heroic caricature, exaggerated anatomy, villainous expressions, generic cyberpunk city, ubiquitous holograms, readable text, logos, watermark, blurry faces, extra fingers.

Avoid: no red cross, red crescent or red crystal emblems, red plus signs or close lookalikes; medical markings are white-and-red stripes or a green cross only. No blue Star of Life. Check background medics, ambulances, crates, helmets, packs, cans and pods as well as the main subject.
```
