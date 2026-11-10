# Atlas frame art QA — 30 October 2026

**Local correction update:** [Action record](atlas-qa-actions-2026-10-30.md). The five emblem findings, Earthrise Defender ambiguity, Blitz marks and three crop findings now have corrected local sources/exports. They were published in atlas version 90 and checked against the live atlas on 9 November. Marlinspike's scale graphic was closed unresolved at user request on 9 November 2026 after the final image-service rejection; the original sheet is retained. Original findings below record the reviewed published version.

Scope: every scene and technical image live in the atlas (version 89), as published. This covers 80 `ART` pairs (62 frames and 18 supers) and 32 `VART` variant pairs, 224 images in all. Each pair was viewed side by side, with zoomed crops wherever a detail was in doubt. Because the new [protected-emblem rule](art-direction.md#protected-emblems--no-red-crosses-30-october-2026) covers key art too, the key art and bonus plates with medical subjects were also checked: key-06, 13, 22, 25, 35, 36 and 41, and bonus-05.

This pass checked what the atlas actually shows: emblems, cropping and obvious defects. It doesn't repeat the per-frame design QA. Design findings still open from earlier reviews are in [Gen 2 QA](gen2-frame-art-qa-2026-10-27.md), [Gen 3 QA](gen3-frame-art-qa-2026-10-25.md) and the later action logs.

## 1. Red cross emblems — must fix

New rule from 30 October: no red cross, red crescent or red crystal anywhere. See [art direction](art-direction.md#protected-emblems--no-red-crosses-30-october-2026).

| Image (atlas file) | Where the emblem is | Fix |
|---|---|---|
| QF-6 Harmattan scene · `art/qf-6-harmattan-scene.jpg`, `thumb/…` | Ground medic's armband and backpack; one jerrycan | Targeted edit: white-and-red stripe armband, green cross on the pack, plain jerrycan |
| QT-1 Elissa front scene · `art/qt-1-elissa-scene.jpg`, `thumb/…` | Two background medics' tabards (lower left) | Targeted edit: stripe or green cross tabards |
| VAR OB-16 Rys scene · `art/var-17-ob-16-rys-scene.jpg`, `thumb/…` | Ambulance truck by the checkpoint (right background) | Targeted edit: remove the cross, or paint a green cross |
| Key art 22 "Room for a Medic" · `art/key-22-…room-for-a-medic.jpg` | Both ambulances (left foreground, centre background) | Targeted edit: stripes only |
| Key art 35 "People Before Territory" · `art/key-35-…people-before-territory.jpg` | Ground medic's armband and backpack | Targeted edit, as for the Harmattan scene |

Checked and clean:

- **Kizuna scene:** the ambulance carries red stripes only.
- **Polaris scene:** orange stretchers, no emblem.
- **Albedo:** red-and-white hazard chevrons, not a cross.
- **Hospital Safina key art (25):** no visible emblem.
- **Herat, White Convoys, Umoja and Safina key art (06, 36, 41, 13):** clean.

Unresolved at atlas resolution: the ambulance in the **Earthrise Defender** scene (`var-31`) is too small to read. Check it against the full-size source before closing this item.

All five failures come from 30 October or from variants made with "medic"/"ambulance" prompts that had no emblem exclusion. The generator adds the emblem by default, which is why the Avoid-list line in the art direction is now mandatory.

## 2. Sensitive insignia — your decision

**VK-1B Écuyer Blitz** (`var-32`, scene and technical sheet): the "Funke" callsign is painted as **two white lightning bolts side by side beside a German flag**. Whatever the intent, a pair of bolts on German military kit reads as the SS runes, which are banned in Germany (StGB §86a). The [Blitz QA](blitz-art-qa-2026-10-26.md) records the marks as intended. They are **not** a technical defect, but I recommend changing them. Options:

- a single bolt;
- a spark or star (it would match the Funkenwerk zigzag spark);
- the bolts separated and angled differently;
- the word FUNKE stencilled instead.

## 3. Technical sheets cropped instead of letterboxed

The standing rule (v87) is that sheets that aren't 16:9 are letterboxed with their edge colour. These three 3:2 sources (1536×1024) were centre-cropped instead, so views are clipped at the top or bottom:

| Frame | Source | What is lost |
|---|---|---|
| fb4 M15 Pathfinder | `gen3/qa-fixes-2026-10-26/02-m15-vanguard-technical.png` | Bottom detail row cut in half |
| fo4 OB-21 Tsar | `gen3/qa-fixes-2026-10-26/04-ob-21-tsar-technical.png` | Bottom silhouette/scale row cut |
| fa4 AWX-1 Marlinspike | `gen3/07-awx-1-marlinspike-technical.png` | Tops of the main views cut; its scale correction is also still pending |

Fix: reconvert with letterboxing and republish under the same stems. No image generation is needed.

## 4. Everything else

No other emblem, crop or obvious rendering defects were found in the remaining pairs, across the supers, frames, Lunar/UN set, Funkenwerk/Khiimori, Monsoon and the 32 variants. National flags (Japan, France, Germany, Canada, Portugal/Brazil, Netherlands, Poland), Pact red stars, Pamir's radiation trefoils and Albedo's hazard chevrons are all appropriate.

Notes, not defects:

- Saetta's scene shows a glowing beam weapon. That fits a Gen 4 prototype, but beams should stay rare.
- Raijin and Takemikazuchi carry red glowing radiator stacks by design.
- The Unacknowledged frames (Rakshasa, Hafun) follow the bad-evidence-photo rule.

## Suggested order

1. The five red-cross edits (section 1), then republish those files under the same stems.
2. Letterbox the three cropped sheets (section 3). This is mechanical and can go in the same publish.
3. Your call on the Blitz bolts (section 2).
