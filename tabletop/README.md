# Tabletop tools

Python (3.12 or later, standard library only) for the Discord tabletop game. The plan is in
[docs/discord-ttrpg-plan.md](../docs/discord-ttrpg-plan.md). Godot ignores this folder.

| File | Purpose |
| --- | --- |
| `catalogue_check.py` | Strict check of `data/catalogues/*.json`: everything Godot's validator checks, plus unknown keys, types, workshop catalogues, workshop pilots and the points table. |
| `vectors/attacks.json` | Attack test vectors: inputs and the exact forecast from `CombatRules.forecast`. The bot must reproduce every case. |
| `vectors/stats.json` | Stat resolution vectors from `UnitState.resolve` (whole points, fractions, thresholds). |
| `test_*.py` | Unit tests for the above. |

```powershell
py tabletop/catalogue_check.py
py -m unittest discover -s tabletop
```

`.\Test.ps1` runs both after the Godot suites.

## Regenerating the vectors

The vectors come from the frozen prototype (tag `prototype-final`). After any rule change that is
also made in Godot, regenerate them and review the diff. Each case is on its own line:

```powershell
& 'C:\Program Files (x86)\Godot\Godot.exe' --headless --path . --script res://tests/export_vectors.gd
```

Range, arc and line of sight are not in the vectors, because the tabletop measures them on hexes.
Each case gives cover directly and assumes the attack is legal. Protocols, the Target Lock roll,
ammunition and evade or brace are not in Godot, so their vectors will be written by hand from the
rulebook's worked examples.
