# Workshop pilots

The workshop roster is in `data/catalogues/workshop_pilots.json`. It is separate from the
standalone skirmish catalogue. All three profiles have the same seven-point budget. Pilot ratings
are whole numbers. These are initial balance values.

| Pilot | Role | Gunnery | Melee | Precision | Reflex | Systems | Countermeasures | Spirit |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sol / ANCHOR | Brawler | 1 | 1 | 0 | 1 | 0 | 2 | 2 |
| Mara / KESTREL | Marksman | 2 | 0 | 1 | 0 | 2 | 0 | 2 |
| Vale / ROOK | Skirmisher | 1 | 0 | 0 | 2 | 1 | 1 | 2 |

Changes on 26 October 2026:
- The budget went from five points to seven, to give every pilot Systems and Countermeasures for
  Target Lock and Protocols.
- ANCHOR took Countermeasures 2, KESTREL Systems 2, and ROOK one of each.

Changes on 23 October 2026:
- The move to a d10 made pilot ratings whole. KESTREL went from Gunnery 1.5 and Guard 0.5 to
  Gunnery 2, and ROOK from Gunnery 0.5 and Melee 0.5 to Gunnery 1.
- Guard was removed the same day, and each pilot's Guard moved into Reflex: ANCHOR 0 → 1, ROOK 1 → 2.

All have the existing Push ability. The game still displays Systems and Countermeasures as
reserved stats, because Target Lock and Protocols are not built yet. Their rules are in the
[tabletop rules](tabletop-d10-system.md). Spirit is pilot-only, so its Frame
column is always empty and its Threshold is the pilot limit of 6. Each pilot's seven stats are shown
in the single right-hand table: Frame, Pilot, Total and Threshold. The Frame column includes
hardware bonuses and wear penalties, fractions included. Total is the pilot rating plus the whole
points of hardware, held at or below Threshold. The fractions on parts are summed and count only in
whole points, rounded toward zero, so a matched set of ¼ parts adds a point. Threshold is the
frame's own maximum; pilots have separate limits on their own ratings.
Movement follows the current frame-only rules; Will is whole Spirit.
Weapon profiles include mounted weapons and the frame's standard melee attack.

Pilot assignment is a free pending refit change. Apply saves `pilot` alongside parts and paint;
Discard restores the last assignment. Saves lacking `pilot` migrate to Anchor. Unknown IDs are
rejected before saving. Deployment creates a detached PilotData resource and assigns its callsign,
so workshop selections cannot alter the standalone scenario or roster definitions.

## Portrait assets

These original anime portraits were generated using the built-in `image_gen.imagegen` tool.
The final prompts are preserved in [generation-prompts.json](../art/portraits/generation-prompts.json).

- [Anchor](../art/portraits/anchor.png): dark-haired, steady veteran in an olive flight suit.
- [Kestrel](../art/portraits/kestrel.png): copper-haired precision specialist with a communications earpiece.
- [Rook](../art/portraits/rook.png): silver-haired defensive specialist with a subtle eyebrow scar.

The portraits share a muted flight-suit palette, dark hangar setting, cel shading and warm rim
light. They are loaded into the bottom portrait buttons; full-resolution sources remain in the
project rather than depending on the generator's output directory.
