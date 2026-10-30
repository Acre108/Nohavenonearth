# Faction Origin Key Art Briefs

Key art briefs for the thirteen No Peace Past Luna factions on the atlas's Successors tab: the five Earth powers, UNEL and the seven space factions. Each piece shows where that faction **begins in the No Haven era** (before 2186, in 2186 or in the projected war), not what it looks like in 2327. Every faction will have fans, so each scene gives its people dignity and shows what they get right as well as what it costs.

The pieces continue the key-art numbering after 30. Output goes to `output/imagegen/key-art-factions/`, with filenames `<nn>-successors--<faction-slug>--<title-slug>.png` and a `manifest.json` in the same shape as `key-art-selected-10/manifest.json`.

| No. | Faction | Title | Year | Origin entry (attach to) | Main reference |
|---|---|---|---|---|---|
| 31 | United States of the Americas | Built for Ordinary People | 2186 | o9 Unaltered Crews | sr-08-concord-scene.png |
| 32 | Transatlantic Union | Nine Days | 2186 | wW14 The Berth Refusal | none (environment) |
| 33 | China | On Schedule | 2186 | o39 Steppe Outriders | 10-type-09-tieshan-scene.png |
| 34 | Eurasian Ascendancy | The Oath | 2180s | xk3 The Nashik Oath | 25-nk-12-medved-n-scene-v2.png |
| 35 | African Commonwealth | People Before Territory | 2186 | o46 Protect First | gen3/qa-fixes-2026-10-26/09-qf-6-harmattan-technical-no-bay.png |
| 36 | United Nations of Earth and Luna | The White Convoys | 2177 | wS14 The White Convoys | white-squads/var-27 and var-26 scenes |
| 37 | Colony One | Can You Go Without | 2182 | wO18 The Red Roster | none (environment) |
| 38 | Constitutionalists | The River Judges | 2186 | wO22 The River Judges | 04-m9-teamster-scene.png |
| 39 | MRD | The Panel Looks Up | War | wO20 The Panel Looks Up | none (interior) |
| 40 | CPS | The House Ledger | 2186 | wO6 The Belt Ledgers | none (interior) |
| 41 | Umoja | Care, Not Command | 2186 | xm9 The Keepers | sr-05-jinn-scene.png |
| 42 | Ashva Compact | Now Leave | War | wE15 The Vladivostok Blessing | g3-11-nk-x-ashvin-scene-v2.png, key-art 26 Hakobune v2 |
| 43 | Communion | The Northern Lift | War | wW17 The Northern Lift | g3-10-bd-x-polaris-scene-v2.png |

Reference paths are relative to `output/imagegen/`.

## How to use this file (instructions for ChatGPT)

- Generate one image per request, using the piece's **Prompt** as written. Each prompt already includes the series style and its own "Avoid" list.
- Attach the named reference image when there is one. References are **design reference only**: copy the machine's design, not the reference's weather, lighting or setting.
- The briefs are the source of truth. If a prompt and a brief disagree, follow the brief.
- **Scale:** a person is about 1.8 m, roughly one tenth of a normal frame and one twenty-fifth of a 40 m super. Ships and carriers are far larger again.
- No readable text anywhere: flags, ledgers, boards and screens show shapes and colours only.
- War-era pieces (39, 42, 43) are projected events. Draw them as plainly as the rest; the atlas marks them as projected.

## Atlas placement

Each piece goes in `SCENES` under its origin entry id, so it appears on that entry's detail sheet and map sheet (stored as `art/key-<nn>-<slug>.jpg`, 1600×900). The Successors cards themselves only show key art for UNEL today. Showing a piece on every faction card needs a small change to the page's `pcard` calls.

---

## 31 · United States of the Americas · Built for Ordinary People

**Year:** 2186. **Origin:** o9 Unaltered Crews, with wW0 The Partnership Act behind it.

**What it must say:** a confident, capable country where the companies are the army and biological purity is starting to sound like patriotism. The pride is real; so is the person quietly turned away.

**Composition:** a company depot open day. A CX-1 Concord towers under service gantries with both chest hatches open, its Army and Air Force pilots climbing the ladders side by side. In the foreground a queue of young recruits passes an implant-screening arch staffed by company technicians in coveralls and Army medics. Families watch behind a rope. At the edge of the frame, one recruit with a small surgical scar behind the ear is being walked aside, politely, by a medic.

**Must show:** the Concord's warship-like silhouette (massive layered shoulder mantlets, narrow waist, small head sunk under a heavy brow, prow-like chest with two side-by-side hatches, dark navy upper body and dark olive lower body); M9 Teamsters parked in a row; plain US flags without text; bright hangar lights and a clear sky outside.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. An American defence-company depot during a public open day in 2186. Inside a vast open hangar a 40m CX-1 Concord super-heavy stands under steel service gantries: towering top-heavy warship-like silhouette, massive layered armour mantlets on the shoulders, narrower armoured waist, long arms hanging to the knees, a small head sunk low under a heavy armoured brow with a slit visor, a prow-like sloped chest with TWO cockpit hatches side by side, both open, dark navy upper body and dark olive lower body, giant cannon on the right forearm and a stake driver on the left, both lowered. Two pilots, one in an Army flight suit and one in an Air Force flight suit, climb parallel ladders to the two hatches. In the foreground a long queue of young recruits in civilian clothes passes one by one through a white medical screening arch staffed by company technicians in coveralls and Army medics with tablets. Families and children watch from behind a rope line; plain American flags without text hang from the gantry. At the far right edge, one young recruit with a small surgical scar behind the ear is being quietly led aside by a medic, not roughly, while the queue moves on without noticing. A row of 17.6m M9 Teamster frames stands along the back wall. Warm bright hangar light, clear blue sky beyond the doors, a proud public mood with one quiet note of exclusion. Concord design reference: sr-08-concord-scene.png (design only). Avoid: combat, firing, glowing eyes, readable signs, corporate logos, crowds cheering with raised fists, villainous expressions, sci-fi holograms.

---

## 32 · Transatlantic Union · Nine Days

**Year:** 2186. **Origin:** wW14 The Berth Refusal, with wW9 The Long Session as its shadow.

**What it must say:** a council that could never agree in time agrees in nine days, and Europe and Britain build something together. The refounded Union starts here: institutions that can act.

**Composition:** the Malapert docks near the lunar south pole. In a pressurised slipway hall with one wall open to the airless dock, the first keel section of Britain's first orbital hull is being lowered into place: enormous dreadnought keel ribs, just a skeleton. Union yard crews in pale suits with teal shoulder stripes and Royal Navy crews in dark blue suits stand on the keel together; two of them clasp gloved hands. Worker frames hold the section on cables.

**Must show:** the scale of a dreadnought keel against tiny figures; long low sunlight raking across crater rims outside; Earth small and low on the horizon; two crew colours mixed together, not separated into camps.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. The Malapert orbital docks near the lunar south pole in 2186. A huge industrial slipway cut into grey lunar rock, its far side open to the airless dock and a black sky. The first keel section of a future space dreadnought is being lowered into the slipway: only a skeleton of massive curved steel keel ribs and a spine girder, hundreds of metres long, held on taut cables by four-armed station worker frames with thruster packs and anchoring legs. Tiny suited crews walk the keel: European Union yard workers in pale grey suits with teal shoulder stripes and British naval crews in dark navy suits with white trim, mixed together on the same girder. In the centre, one teal-striped worker and one navy-suited officer clasp gloved hands over the first weld seam, small within the vast structure. Outside the open dock wall, long low sunlight rakes across crater rims, casting kilometre-long shadows, and a small blue Earth sits low on the horizon. Cold white work lights, sparks from welding only, a quiet mood of purpose. Avoid: flags with text, readable markings, finished warship, combat, glowing engines, air or atmosphere effects outside, sci-fi holograms, heroic posing.

---

## 33 · China · On Schedule

**Year:** 2186. **Origin:** o39 Steppe Outriders, with Tianshu (ft3, wE10) behind it.

**What it must say:** a state that works: thousands of frames moved exactly on time by a network that plans everything, and depot crews who are fed, warm and proud of it. Its edge is the steppe crews the network relies on but can't see.

**Composition:** night on the Mongolian steppe. A long rail line runs from a brightly lit Fortress Belt depot into the distance. Tieshan frames kneel on flatcars under tarpaulins. The depot's floodlights, signal lamps and cranes switch on in one precise wave down the line, showing the network's timing. Dispatch workers in padded jackets move in calm order. In the foreground, on a dark ridge, a stripped-down Type-01M Steppe Tieniu outrider and two Mongolian crew by a small fire, blue khadag scarves tied to the frame's antenna, look down at the line; one points a hand lamp at a washed-out crossing ahead that the depot lights don't reach.

**Must show:** the Tieshan's egg-shaped torso and small three-lens dome head; the outrider frame lived-in (bedrolls, water drums, spare wheels); a sense of vast order and of human eyes beyond it.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A clear cold night on the Mongolian steppe in 2186. In the middle distance a large Chinese military rail depot glows under floodlights, and a long frame train stretches from it across the plain: dozens of 16.8m Type-09 Tieshan frames kneeling on flatcars under olive tarpaulins, each with an egg-shaped armoured torso, short thick limbs and a small dome head with three sensor lenses. The depot's floodlights, rail signal lamps and gantry crane lights switch on in one precise travelling wave down the line, every lamp in exact sequence, showing a planning network's timing. Dispatch workers in padded olive jackets move in calm order between heated barracks with steam rising, carrying flasks of tea. In the foreground, on a dark grassy ridge, a stripped-down Mongolian Steppe Tieniu scout frame rests on one knee: egg-shaped torso, lighter armour removed, bedrolls, water drums and spare tyres lashed to it, blue silk khadag scarves tied to its whip antenna. Two Mongolian crew sit by a small dung fire beside it in deel coats; one stands and points a hand lamp along the line toward a washed-out river crossing far ahead, dark and outside the depot's light. Starry sky, frost on the grass, an orderly, impressive and slightly uneasy mood. Tieshan design reference: 10-type-09-tieshan-scene.png; outrider design reference: variants/13-type-01m-steppe-tieniu-scene.png (design only). Avoid: readable signs, red propaganda banners with text, glowing network effects, holograms, combat, firing, snow storm.

---

## 34 · Eurasian Ascendancy · The Oath

**Year:** the 2180s. **Origin:** xk3 The Nashik Oath, written against og_dz Department Zero.

**What it must say:** people first. Augmented pilots refuse to be consumed, and say the strong defend those who can't be changed. Russians and Indians stand together in it; the enemy is a department, not a nation.

**Composition:** a frame bay at Nashik Works at monsoon dusk, rain hammering the open doors. A company of Indian and Russian breakthrough-group pilots stands in front of their Medved-N frames. Each lays their removable augmentation harness on a shared unit equipment rack, owed back to the unit. Facing them, a staff officer holds sealed transfer orders; behind him, on a flatbed, a crated pilot capsule sits unopened, and stays that way. Unaugmented ground crew stand among the pilots, the pilots slightly in front of them. An older OKB-7 engineer in a Russian work jacket stands on the pilots' side.

**Must show:** the Medved-N's bear-like bulk, sealed rubber joint boots and big radiator grilles in khaki and dark green with saffron chevrons; the harnesses as equipment (padded collar and spine unit, no body cables); dignity, not defiance theatre.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A frame maintenance bay at an Indian heavy-mech factory at dusk in the monsoon, heavy warm rain pouring past the huge open doors. Three 19.4m NK-12 Medved-N frames stand in the bay: hunched bear-like bulk, large louvred radiator grilles on the shoulders and back, sealed black rubber boots on elbows and knees, wide mud-stained feet, sand-khaki and dark green paint with deep saffron chevrons, weapons lowered. In front of them a company of about twelve pilots in plain flight suits, Indian and Russian men and women mixed together, stands in an even line. One by one they lay their removable augmentation harnesses, each a padded collar with a slim back-spine unit, on a long shared steel equipment rack, as equipment returned to the unit store. Unaugmented ground crew in oil-stained coveralls stand among them, the pilots one step in front. Facing the line, a staff officer in a grey greatcoat holds a sealed courier case of transfer orders; behind him on a flatbed truck a crated, sealed pilot capsule sits unopened under a tarp. An older Russian factory engineer in a worn work jacket stands with the pilots, arms folded. Amber work lamps, wet concrete reflections, a still, serious mood. Medved-N design reference: 25-nk-12-medved-n-scene-v2.png (design only, not weather). Avoid: glowing implants, cables into bodies, gore, readable insignia, weapons pointed at people, shouting, snow, frost.

---

## 35 · African Commonwealth · People Before Territory

**Year:** 2186. **Origin:** o46 Protect First and fq5 Harmattan (the League lane already has the Khartoum Charter as key-18).

**What it must say:** the first frame designed in Africa, built to shelter people rather than hold ground. Its doctrine is that a battalion's first duty is evacuation.

**Composition:** a haboob sweeps over a Sahel water point. A QF-6 Harmattan kneels with its broad curved dozer-blade shield planted in the sand like a wall; behind it, villagers, a family and their goats shelter in its lee. Its torso is compact and completely closed, with no side bay or platform. A medic treats a child at ground level behind the shield using portable first-aid supplies. Blue hoses from its hip water tanks fill jerrycans. A Kafila carrier looms in the dust beyond, and a Tunis Works engineer and a Sudanese pilot talk in the cab doorway.

**Must show:** the Harmattan's shield (about one and a half times its shoulder width, ladder rungs on the back), mono-eye head under a fabric sun shroud, sand and white paint with ochre panels, the plain white and red medical stripe; the wall of dust stopped by the shield.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A Sahel village water point in 2186 as a towering brown haboob dust storm rolls in from the left. A 17.6m QF-6 Harmattan rescue frame kneels side-on to the storm with ONE rigid curved dozer-blade shield on its left arm, about one and a half times its shoulder width, planted in the sand on two fold-down struts like a wall, with ladder rungs and handholds on its back. Dust streams around the shield edges while the sheltered side stays calm and clear. In its lee, villagers crouch with their goats and bundles: a grandmother, a mother with children, a herder. The frame has compact continuous sealed torso armour, with no medical bay, side hatch, balcony or fold-down platform. A medic treats a child at ground level in the shield's lee with portable first-aid supplies. Blue hoses run from water-tank panniers on its hips into a row of yellow jerrycans. Mono-eye head behind a fabric sun shroud with a floodlight bar, sand and white paint with ochre panels, a single short tank-gun barrel on the right shoulder pointing up and away, a composite rifle stowed. In the dust behind, the silhouette of a huge six-wheeled Kafila desert carrier with its ramp down. In the cab doorway a European engineer in a faded work shirt and a Sudanese pilot in a sealed suit talk over a paper map. Warm ochre light, a protective, humane mood. Harmattan design reference: gen3/qa-fixes-2026-10-26/09-qf-6-harmattan-technical-no-bay.png (design only). Avoid: combat, firing, people in distress close-up, readable markings, flags with text, second shield, extra arms, glowing effects.

---

## 36 · United Nations of Earth and Luna · The White Convoys

**Year:** 2177. **Origin:** wS14 The White Convoys (UNEL's Earth half). Key-19 already shows UNEL after the war; this piece is where its frames begin.

**What it must say:** an institution every bloc vetoed, buying its own second-hand frames, painting them white and walking food through a raid zone with one rule: never fire except to protect a convoy.

**Composition:** a dusty Copperbelt road in late afternoon. A column of battered food lorries escorted by white-painted Copperbelt mining walkers and UN-1 Convoy Refits with blue heads, weapons pointed down. Volunteer crews in mixed civilian clothes and blue helmets walk beside them. At a roadside checkpoint in a village, League Technical Refits watch and let them pass; a League fighter lifts the barrier. Children run alongside.

**Must show:** white paint over old mining yellow and old Garrison olive showing through at the scuffs; blue-painted heads; the mismatch of donated frames; trust given cautiously by the League side.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A red-dust road through the Zambian Copperbelt in 2177, late afternoon. A long column of battered white food lorries with tarpaulined loads moves along the road, escorted by mismatched donated frames painted white with bright blue heads: broad 14m Copperbelt mining walkers with wide enclosed cabs and old yellow paint showing through scuffs, and 17.2m refitted Garrison-type convoy frames with old olive paint showing at the edges. Every weapon is pointed at the ground. Volunteer crews in mixed civilian clothes, sun hats and light blue helmets walk beside the lorries with water bottles. Ahead, at a village checkpoint of oil drums and a pole barrier, two League technical-refit frames with sand filters, mismatched panels and sand and ochre paint stand watching, weapons lowered; a League fighter in a headwrap lifts the barrier pole to let the convoy through. Village children run alongside the column, and a woman watches from a doorway. Low golden light through dust, long shadows, a mood of cautious trust. Design references: white-squads/var-27-copperbelt-escort-walker-un-scene-v2.png and white-squads/var-26-un-1-convoy-refit-scene.png (design only). Avoid: combat, firing, readable UN lettering, flags with text, glowing effects, heroic poses, bodies.

---

## 37 · Colony One · Can You Go Without

**Year:** 2182. **Origin:** wO18 The Red Roster.

**What it must say:** the people Washington had already stopped helping are the ones who can live on Mars. Pride, grit and self-reliance, recruited from the places America left behind.

**Composition:** a stilt town on the drowned Gulf coast at low tide in the evening. On a walkway, an Ascension recruiter's folding table under a patched tarp. The queue: a stilt-town fisher who rebuilt her own pumps, an Alaskan homesteader in patched furs, a desert water-commune man carrying a hand-built solar still, an ice-road driver. A hand-painted board shows three questions as shapes only. On a battered tablet, a photograph of red Martian ground. In the background, a federal relief station on stilts, rusted shut.

**Must show:** water and drowned rooftops, hand-made repairs everywhere, competence in every face; no pity.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A stilt town on the drowned American Gulf coast at evening low tide in 2182. Weathered houses stand on tall piles over shallow brown water; old drowned rooftops and a half-sunk highway sign post show in the shallows, with no readable text. Along a plank walkway, an orbital-company recruiter in a pale grey jacket sits at a folding table under a patched blue tarp with a battered tablet showing a photograph of red Martian ground. A queue of applicants waits on the walkway: a sunburnt woman in waders carrying a hand-rebuilt water pump, an Alaskan homesteader in patched furs, a lean man from a desert water commune holding a hand-built solar still, an older ice-road truck driver with a toolbag. Beside the table, a hand-painted board shows three short lines of brush strokes, not readable. In the background a federal relief station on stilts stands rusted, boarded and shut. Hand-made repairs, solar panels and rainwater barrels on every roof, gulls, a warm orange sky over the water. Every face is calm, capable and proud. Avoid: readable text or signs, mechs, spacecraft, misery or pleading, glowing screens, holograms, flags with text.

---

## 38 · Constitutionalists · The River Judges

**Year:** 2186. **Origin:** wO22 The River Judges (with wW18 The Loyal Minority and m24 The Rio Bravo Compact behind it).

**What it must say:** law that both banks accept. Mexican water judges and American river officers sharing a shrinking river fairly, a joint patrol that keeps the peace instead of making war, and the Ascension recruiter who realises this is what Mars is missing. Water kept by law, not rationing.

**Composition:** the dry bed of the Rio Bravo in a drought. Under a canvas shade canopy on the cracked riverbed, a binational water hearing at a long folding table: Mexican water judges (one elderly judge in a guayabera, a younger woman engineer with survey rolls) and US river commission officers in shirtsleeves. A cloth-bound ledger lies open, the Virgin of Guadalupe painted on its cover. Farmers from both banks wait in the shade, hats in hand. In the thin remaining channel stands an M9 Teamster of the joint border patrol, weapons slung, shading the canopy. To one side, an Ascension recruiter in a pale coat watches with a folder under her arm.

**Must show:** both banks visible (one with a Mexican town and church tower, one with a US pump station); the Teamster's patrol stripes in two colour schemes without text; the painted Guadalupe ledger as a clear focal point; fairness: neither side above the other at the table.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. The drought-shrunken bed of the Rio Bravo on the Mexico–US border in 2186, midday. Cracked pale mud stretches between two banks: on the left a small Mexican town with a whitewashed church tower and green irrigated plots, on the right an American pump station and orchards. Under a large canvas shade canopy on the dry riverbed, a water hearing is held at one long folding table, both sides seated level with each other: Mexican water judges, an elderly man in a white guayabera and a young woman engineer with rolled survey maps, beside American river commission officers in shirtsleeves. At the centre of the table lies an open cloth-bound ledger whose cover shows a painted image of the Virgin of Guadalupe. Farmers from both banks wait on benches in the shade with hats in hand. In the thin remaining river channel behind the canopy stands a 17.6m M9 Teamster frame of a joint border patrol, ankle-deep in water, utility stake driver on its left arm, rifle slung and pointed down, its olive armour carrying two different patrol stripe colours with no text, its shadow falling across the canopy. To the right, a woman in a pale orbital-company coat stands slightly apart with a folder under her arm, watching the judges closely. Hard white sun, heat haze, warm earth colours, a calm, fair and hopeful mood. Teamster design reference: 04-m9-teamster-scene.png (design only). Avoid: readable text, flags with text, combat, firing, border walls, police raids, sombreros or cartoon stereotypes, glowing effects.

---

## 39 · MRD · The Panel Looks Up

**Year:** the war (projected). **Origin:** wO20 The Panel Looks Up, built on o17 Ethics Review and xm8 The Mars Proposal.

**What it must say:** reason that keeps working while the city above it burns. The Directorate's charter is written by people who decided someone must answer for what is done beyond the Moon, and that it had better be people who have read the conditions.

**Composition:** a concrete hearing room in a bunker under Strasbourg. A plain table under caged work lights, the ethics panel seated with stacks of the four-hundred-page conditions. Dust sifts from the ceiling with each distant impact. On the evidence table, a sealed opaque specimen case. Pinned to the wall, a large paper map of Mars with Valles Marineris crossed by a pencil line. One panel member has turned in her chair to look up at the map.

**Must show:** order and paperwork under strain; the map as the focal point; no screens doing the work for them.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. A wartime concrete bunker deep under a European city. A long plain hearing room lit by caged yellow work lamps; fine dust sifts down from the ceiling from a distant impact, catching the light. Seven members of an ethics panel, men and women of different ages in plain civilian clothes and cardigans, sit at a long wooden table covered in tall stacks of bound documents, each stack hundreds of pages thick, with pencils, reading glasses and tin mugs. A witness chair stands empty facing them. On a separate evidence table sits a sealed, opaque grey specimen case with clamps and an accession tag with no readable text. Pinned to the back wall is a huge paper map of Mars, hand-annotated, the great canyon of Valles Marineris crossed by a single long pencil line. One older woman on the panel has turned in her chair and looks up at the map, while the others keep reading. Muted greys and ochres, deep shadow, a quiet, determined, slightly haunted mood. Avoid: holograms, glowing screens, readable text, flags, soldiers, gore, visible specimen contents, sci-fi lab.

---

## 40 · CPS · The House Ledger

**Year:** 2186. **Origin:** wO6 The Belt Ledgers and xv3 Continuity Contracts.

**What it must say:** families out where the plan arrives late, who keep their own books, trade by reputation and treat their elders' knowledge as the house's capital. Warm, commercial, close-knit and independent.

**Composition:** inside the cramped cabin of a family-crewed prospecting tender docked to a small asteroid. Three generations: a grandmother wears a light recording headset for a continuity contract while her grandchildren watch; her son keeps the ledger by hand next to an abacus and a tablet. Tea in bulbs, dried fruit strung on a line, bunk curtains. Through the viewport, a prospecting drill rig on the asteroid, a second family tender and a very small Earth. On a terminal, a delayed instruction packet waits, ignored.

**Must show:** handwritten ledgers and a family seal stamp (shape only); the recording as a family ritual, not a horror; free-floating small objects held by elastic cords.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. The cramped, warm interior cabin of a small Chinese family-crewed asteroid prospecting tender in 2186, in microgravity. Padded walls, bunk curtains, strung dried fruit, tea in squeeze bulbs, cables and small tools held by elastic cords. Three generations float together: an elderly grandmother wearing a slim fabric recording headset with a few small sensor pads, eyes closed, telling a story, while two grandchildren hold her hands and listen; her middle-aged son writes by hand in a thick cloth ledger next to a wooden abacus and a tablet, a red family seal stamp beside it. A wall terminal blinks with an incoming instruction packet that nobody is looking at. Through a large round viewport: a small grey rubble asteroid with a skeletal prospecting drill rig and work lights, a second family tender docked nearby, black space, and a very small distant Earth. Warm amber cabin light against cold starlight, an intimate, proud, family mood. Avoid: readable text, glowing brains, wires into skulls, horror, holograms, weapons, mechs, gravity-bound posture, open helmets in vacuum.

---

## 41 · Umoja · Care, Not Command

**Year:** 2186. **Origin:** xm9 The Keepers and wS11 The Kafila Ambush (the tragedy that follows: wS12, wS18).

**What it must say:** it begins as medicine. The keepers heal the Jinn and burn victims with tissue that adapts to any body, under the rule that care is never a command. The people who will steal it are already watching.

**Composition:** night at an oasis camp in the Great Sand Sea. The Jinn kneels by the water while keepers in headscarves and scrubs fit a cultured tissue patch over a wound on its forearm from an insulated culture vat on a Kafila carrier's ramp. In a lit field tent nearby, burn patients receive trial grafts. Far off, on a dune crest barely lit by the camp, two raid-cadre fighters beside a rebuilt Garrison watch the vats through binoculars.

**Must show:** the Jinn's design (repaired restraint-frame truss and League armour panels, grey-black mineralised tissue only in the gaps, scavenged mono-eye sensor head on a cage bracket, chest cockpit hatch with ladder); tenderness; the watchers small and easy to miss.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. Night at a small oasis camp in a vast desert dune sea in 2186. The Jinn, a 40m giant, kneels beside the water: repaired white steel truss sections and sand and ochre desert mech armour panels bolted over its arms and legs, yellow mining-rig hydraulics, weathered grey-black mineralised tissue visible only in the gaps, a faceless head enclosed by a scavenged grey-blue mono-eye sensor head on a welded cage bracket, an armoured cockpit module in the chest with a ladder and a closed hatch. Its left forearm rests on the sand; on a scaffold beside it, keepers in headscarves and pale scrubs gently fit a pale cultured tissue patch over a wound in the forearm, passing it from an insulated culture vat on the lowered ramp of a huge six-wheeled desert carrier. Nearby, a lit field-hospital tent with its side rolled up shows burn patients on cots receiving small graft dressings from a doctor. Lanterns, cooking fires, palm trees and still water reflecting the camp. Far in the background, on a dune crest at the edge of the light, two small figures in mismatched gear stand beside a rebuilt 17m Garrison-type frame, one raising binoculars toward the vats; they are tiny and easy to miss. Deep blue night, warm lantern light, a tender mood with a cold edge. Jinn design reference: sr-05-jinn-scene.png (design only). Avoid: gore, open wounds in close-up, glowing tissue, slime, tentacles, monster face, glowing eyes, combat, firing, readable text.

---

## 42 · Ashva Compact · Now Leave

**Year:** the war (projected). **Origin:** wE15 The Vladivostok Blessing, with xk3 The Nashik Oath, fn2 Ashvin and yh64 Hakobune.

**What it must say:** an honourable exile. Moscow and Delhi, who agree on little, send away the pilots who won't be commanded by anyone who ran Department Zero, with the Hakobune, the Ashvin drawings and the Mitsurugi engineers who asked to go. "You won't let us control you; you have our blessing; now leave, before we change our minds."

**Composition:** the Vladivostok quay at a winter dawn. The Hakobune ark rests grounded beside the harbour, steam rising from its lift ducts. A pair of NK-X Ashvins kneel side by side, one with a white stripe and one with a black stripe. Between them and the ship, Nashik pilots and Mitsurugi exile engineers carrying archive crates face two envoys: a Russian in a greatcoat and an Indian officer in a shawl. The Russian envoy raises one hand, palm out, in blessing; the Indian envoy holds out a rolled drawing set.

**Must show:** the Ashvin pair's lean angular slab armour, khaki and dark green with saffron trim, white horse shoulder insignia, link pods facing each other; the Hakobune's hospital-ship hull and horizontal lift ducts; respect on both sides, and sadness.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. The harbour quay at Vladivostok at a pale winter dawn, light snow on the concrete, grey sea and cranes behind. A 220m Japanese-built rescue ark rests grounded beside the quay: a long hospital-ship hull with rows of ward windows, a wide hangar door open, and large horizontal lift-fan ducts along its side, gently steaming in the cold. In front of it a pair of 18.6m NK-X Ashvin frames kneel side by side, mirror images: lean angular slab armour, long sealed-joint legs, khaki and dark green paint with saffron trim and a white horse insignia on each shoulder, one with a white stripe and one with a black stripe, each with one boxy link pod on its inner shoulder turned toward its partner, rail rifles grounded and rotary cannons lowered. On the quay between the frames and the ship, a group of Indian and Russian pilots in flight suits and Japanese engineers in company work jackets carrying archive crates stand facing two envoys: a grey-haired Russian in a long greatcoat raising one hand palm outward in a blessing, and an Indian officer in a wool shawl over his uniform holding out a rolled set of engineering drawings. Breath fogging in the cold, warm light from the ark's open hangar, a dignified, bittersweet farewell. Ashvin design reference: g3-11-nk-x-ashvin-scene-v2.png; ark reference: key-art-selected-10/26-carriers--ar-1-hakobune--first-flight-of-the-ark-v2.png (design only). Avoid: weapons raised, combat, readable text, flags with text, glowing effects, sideways fan rotors, extra arms.

---

## 43 · Communion · The Northern Lift

**Year:** the war (projected). **Origin:** wW17 The Northern Lift, wW8 The Polar Exodus and ys53 The Hearth.

**What it must say:** a million people carried onto the ice to wait out a war where nobody fights, learning to live on almost no heat. Their faith of the distant sun is not born yet, but its seed is here: the only warmth is what they carry, and the sun is a thin line on the horizon.

**Composition:** Arctic polar twilight at midday, the sun a thin pale band of light on the southern horizon. A long column of ice-road haulers and BD-X Polaris frames leads refugees on foot and on sledges across sea ice toward an Ellesmere fjord. There, the Hearth, a Polar Carrier frozen into the ice, glows warm through its open hangar doors: the only warm light in the picture. A child at the front of the column has turned to look back at the sun. Very faint, at the far edge of the ice, a tall silhouette walks with the column and might be a giant.

**Must show:** the Polaris (sealed long-endurance cab, compact heat-recovery equipment); the scale of the column; cold blue against the carrier's amber; the giant ambiguous enough to be a rumour.

**Prompt:**

> Use case: stylized-concept. Asset type: finished cinematic key art for the No Haven on Earth atlas. One landscape 16:9 environmental illustration, no collage or inset panels. Grounded real-robot industrial concept art matching the established series: crisp believable machinery, richly painted environments, worn materials, sombre cinematic lighting, restrained late-1990s OVA atmosphere. Human and vehicle scale must be convincing; a 1.8m person is roughly one tenth of a normal frame and one twenty-fifth of a super. No title, captions, readable lettering, watermark, logo, HUD, fantasy effects, energy wings or toy finish. No firing or glowing energy unless explicitly requested. Preserve exactly the described limb counts. High Arctic sea ice in deep polar twilight at midday: the sun stays below the horizon and shows only as a thin pale gold band of light along the far southern edge of the sky. A long column of refugees crosses the ice from the left foreground into the distance: families on foot and on sledges, bundled in mismatched parkas, led and flanked by tracked ice-road haulers with yellow lamps and several 16.4m BD-X Polaris frames, compact sealed long-endurance search-and-rescue mechs with insulated cabs, heat-recovery radiators and snowshoe feet, walking slowly beside the people. At the head of the column, at the mouth of a steep fjord, a 170m military polar carrier sits frozen into the ice, its tall hangar doors open and glowing warm amber from within, the only warm light in the whole scene, with people already gathered inside. In the foreground, a small child in a too-big parka has turned around to look back at the thin band of sunlight. Very faint and far away at the right edge of the ice, half-hidden in blowing snow, a single very tall humanoid silhouette walks parallel to the column, ambiguous enough to be a trick of the light. Cold blues and violets, warm amber, a quiet, enduring, hopeful mood. Polaris design reference: g3-10-bd-x-polaris-scene-v2.png (design only). Avoid: daylight sun disc, aurora fireworks, combat, readable text, flags, glowing giant, clear giant details, religious symbols.
