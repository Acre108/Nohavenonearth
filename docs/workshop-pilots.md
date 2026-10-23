# Workshop pilots

The workshop roster is in `data/catalogues/workshop_pilots.json`. It is separate from the
standalone skirmish catalogue. Anchor retains the existing Sol profile; the other two profiles
have the same five-point budget and use quarter-point stats. These are initial balance values.

| Pilot | Role | Gunnery | Melee | Precision | Reflex | Guard | Spirit |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Sol / ANCHOR | Brawler | 1 | 1 | 0 | 0 | 1 | 2 |
| Mara / KESTREL | Marksman | 1.5 | 0 | 1 | 0 | 0.5 | 2 |
| Vale / ROOK | Skirmisher | 0.5 | 0.5 | 0 | 1 | 1 | 2 |

All have Systems 0, Countermeasures 0 and the existing Push ability. Systems and Countermeasures
are displayed as reserved stats, matching the current rules. Each pilot's eight stats are shown
in the single right-hand table: Frame, Pilot, Total and Threshold. The Frame column includes
hardware bonuses and wear penalties. Total uses pilot + resolved hardware, rounded to quarter
points and clamped to Threshold, the effective maximum allowed by the frame and global caps.
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
