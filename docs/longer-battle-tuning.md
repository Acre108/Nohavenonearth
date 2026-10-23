# Longer-battle tuning — 17 October 2026

## Implemented changes

All four mech frame definitions now have exactly three times their previous maximum Structure. The shared fighter frame retains its original five Structure.

| Frame | Before | Current |
| --- | ---: | ---: |
| RX-style Gundam | 7 | 21 |
| Medium ground mech | 8 | 24 |
| Heavy ground mech | 10 | 30 |
| VX flying mech | 7 | 21 |
| Fighter | 5 | 5 |

The table expanded from **22×16 to 36×26**, increasing area from 352 to 936 square units (2.66×). Opposing mech columns now deploy at x=−11 and x=+11, compared with −5 and +5. Fighters deploy at x=±12, z=6.

Four low blocking ruins extend the terrain into the approach lanes. Ground units must go around these obstacles, while Low and High flight can cross directly. The original tall buildings and central cover remain. Flight therefore has useful route access on the larger battlefield without adding new frame stats.

Battlefield bounds now come from `data/scenarios/skirmish.json`. Table geometry, boundary markings, floor collision/picking, rule bounds, and camera overview/pan/zoom derive from those dimensions. Unit captions compensate for zooming out so the larger overview remains readable.

## Seeded battle results

The same eight seeds used by the rules suite reached victory:

| Seed | Previous rounds | Current rounds | Current winner |
| --- | ---: | ---: | --- |
| 1 | 7 | 11 | Blue |
| 2 | 5 | 17 | Blue |
| 3 | 7 | 13 | Blue |
| 4 | 6 | 12 | Red |
| 5 | 5 | 9 | Blue |
| 6 | 5 | 13 | Blue |
| 7 | 2 | 16 | Red |
| 8 | 7 | 11 | Blue |
| **Average** | **5.5** | **12.75** | |

The detailed seed-20261017 baseline replay grew from **5 to 13 rounds**, with **37 attacks**. First fire occurred in round 2 and the first mech destruction in round 9. Blue won. There were four Energy-costing movement orders and five flying-mech movement resolutions ending at Low altitude.

The Newtype-aware replay grew from **8 to 15 rounds**, with **34 attacks**. First fire occurred in round 2 and the first mech destruction in round 8. Blue won. There were five Energy-costing movement orders and six flying-mech movement resolutions ending at Low altitude.

These small samples establish a longer pace, not faction balance. Different positions and additional attacks also change the sequence of later random rolls.

## Remaining tuning question

Neither detailed replay encountered an attack option blocked by insufficient Energy. Basic shooting remains sustainable: a railgun shot costs 2 and its frame recharges 2, while a Beam Rifle costs 1 and its frame recharges 2. Longer battles do not change that arithmetic. The next resource experiment should examine combined movement/weapon expenditure or recharge rates, rather than assume extra health alone creates scarcity.

Flying mechs still often choose Ground in the current AI. The new ruins provide a demonstrable shortcut for flight, but further AI or movement tuning may be useful if the desired feel is sustained aerial manoeuvring rather than occasional terrain crossing.

## Validation and reproduction

- Expanded bounds, deployment clearance, exact mech/fighter health, opening engagement distance, and ground-blocked/air-clear routes are covered by the rules suite.
- Full-battle tests retain Energy and no-overlap invariants and complete for all eight seeds.
- Native UI checks cover the expanded overview, picking in the new outer area, all phases, victory, and restart.
- Replays use `tests/mock_battle.gd` and its optional `-- --newtype` policy, as in the historical report. JSON output includes scenario bounds, starting Structure, movement choices, attack legality, and results.

Run `powershell -ExecutionPolicy Bypass -File .\Test.ps1 -WithUI` for the verification suite. The original replay JSONs were preserved as `artifacts/mock-battle-before-longer.json` and `artifacts/mock-battle-newtype-before-longer.json`.
