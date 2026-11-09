# Tabletop tools

Python (3.12 or later, standard library only) for the Discord tabletop game. The plan is in
[docs/discord-ttrpg-plan.md](../docs/discord-ttrpg-plan.md). Godot ignores this folder.

| File | Purpose |
| --- | --- |
| `sheet_export.py` | Checks the [Frames and Weapons sheet](https://docs.google.com/spreadsheets/d/1-5qpooUhSsjcMrzQWp6DiSxTNM7Y1OZav0AaZKeT00E/edit) strictly and writes `data/catalogue.json`, **the bot's data**. Lists the tags the bot understands. |
| `data/sheet_snapshot.json` | Cell text of the sheet's Frames, Weapons, On Foot and Protocols tabs at the last export, so the check runs offline. |
| `data/catalogue.json` | Typed frames, weapons, on-foot weapons and Protocols, keyed by ID. Built, never edited by hand. |
| `catalogue_check.py` | Strict check of the Godot prototype's `data/catalogues/*.json` (older numbers, not used by the bot): everything Godot's validator checks, plus unknown keys, types, workshop catalogues, workshop pilots and the points table. |
| `rules_ref.py` | Reference rules engine written from the Player's Guide: exact forecasts and scripted attack resolution. The bot and the sandbox are checked against it. |
| `build_vectors.py` | Builds the generated test vectors from the legacy cases, the catalogue and the engine. |
| `vectors/` | Test vectors the bot must reproduce; see [vectors/README.md](vectors/README.md). `vectors/legacy/` holds the old-scale Godot files. |
| `sandbox/combat-sandbox.html` | The [combat sandbox](https://claude.ai/artifact/JgqktsdJAv71A8j6XkpviL) page, published as an artifact. Its frame, weapon and Protocol numbers come from the embedded catalogue. |
| `sandbox/build.py` | Writes `data/catalogue.json` into the sandbox page between the `CATALOGUE:BEGIN` and `CATALOGUE:END` markers. |
| `sandbox/run_checks.js` | Runs the sandbox's built-in rules checks in node (`test_sandbox.py` runs it). |
| `sandbox/run_vectors.js` | Runs the test vectors in `vectors/` against the sandbox's own rules code in node and prints what was and wasn't compared per file (`test_sandbox.py` runs it). |
| `test_*.py` | Unit tests for the above. |

```powershell
py tabletop/catalogue_check.py
py -m unittest discover -s tabletop
```

`.\Test.ps1` runs both after the Godot suites.

## Exporting the sheet

Every frame, weapon and on-foot weapon row has a fixed `ID` (lower case, digits and `_`); never
change an ID once the bot uses it, even if the name changes. Frames also have `Protocol list`
(Protocol IDs separated by `;`, matching the Protocols count) and `Tags`. Tags are short
machine-readable forms of the Special text that change dice, targeting or resources, such as
`cm_field:2`, `stealth_range:6` or `on_hit:stagger`; specials without a tag are shown to the table as
text. The full tag list is at the top of `sheet_export.py`, and an unknown tag is an error.

After changing the sheet, read the four tabs with a Sheets API `spreadsheets.get` call with grid
data (the Google Sheets connector's `get_spreadsheet` with `includeGridData` saves exactly this), then:

```powershell
py tabletop/sheet_export.py path\to\grid.json   # refresh the snapshot and the catalogue
py tabletop/sheet_export.py                     # re-check the committed snapshot
```

Then run `py tabletop/build_vectors.py` so the catalogue test vectors follow the sheet.
The export refuses to write anything if there are errors. Budget and limit flags from the sheet's
own checks are printed as warnings; the GR-2 Guided Rifle's "Over limit" is intended.

## Building the combat sandbox

The sandbox takes its frames, weapons and Protocols from the catalogue, so a sheet change reaches it
without copying numbers by hand:

1. Change the sheet and export it with `sheet_export.py` (above).
2. Embed the new catalogue in the page and run the tests:

   ```powershell
   py tabletop/sandbox/build.py           # writes data/catalogue.json into the page
   py -m unittest discover -s tabletop    # includes the page's rules checks, run in node
   ```

   `test_sandbox.py` fails if the page's catalogue is older than `data/catalogue.json`, and skips the
   rules checks with a message if node is not installed. `node tabletop/sandbox/run_checks.js` runs
   them on their own.
3. Publish `tabletop/sandbox/combat-sandbox.html` to the same artifact URL.

Pilots, squads, presets, terrain, art, frame lore, manoeuvre lists and the Add unit tab's weapon sizes
are the page's own data and are edited in the page.

## Test vectors

After a sheet export or a rules change, rebuild the generated vectors and review the diff:

```powershell
py tabletop/build_vectors.py
```

The formats, the dice order the bot must follow and what each file covers are in
[vectors/README.md](vectors/README.md). Range, arc and line of sight are not in the vectors, because
the table measures them on hexes: each case gives cover directly and assumes the attack is in range.

The old-scale Godot vectors in `vectors/legacy/` come from the frozen prototype (tag
`prototype-final`) and are only regenerated if Godot's rules change:

```powershell
& 'C:\Program Files (x86)\Godot\Godot.exe' --headless --path . --script res://tests/export_vectors.gd
```
