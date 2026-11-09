"""Export and check the "Frames and Weapons" Google Sheet for the Discord bot.

The sheet is the source of every tabletop frame, weapon and Protocol number. This tool turns a
read of it into `tabletop/data/catalogue.json`, the file the bot loads, and refuses to write it if
anything is wrong: a missing or repeated id, a number that is not a number, a weapon or Protocol a
frame names that does not exist, or a tag the bot does not know.

Input is the JSON of a Sheets API `spreadsheets.get` call with grid data for the Frames, Weapons,
On Foot and Protocols tabs (the same shape the Google Sheets connector saves). The compact
snapshot of the cell text is kept in `tabletop/data/sheet_snapshot.json` so the check runs offline.

    py tabletop/sheet_export.py GRID.json     # snapshot the read, check it, write the catalogue
    py tabletop/sheet_export.py               # check the committed snapshot, rewrite the catalogue

Standard library only.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

SPREADSHEET_ID = "1-5qpooUhSsjcMrzQWp6DiSxTNM7Y1OZav0AaZKeT00E"
TABS = ("Frames", "Weapons", "On Foot", "Protocols")
DATA_DIR = Path(__file__).resolve().parent / "data"
SNAPSHOT = DATA_DIR / "sheet_snapshot.json"
CATALOGUE = DATA_DIR / "catalogue.json"

ID_RE = re.compile(r"^[a-z0-9][a-z0-9_]*$")
INT_RE = re.compile(r"^[+-]?\d+$")

SIZES = {"Small", "Medium", "Large", "Super heavy"}
MOVEMENT = {"Ground", "Variable", "Aircraft", "Zero-g"}
DAMAGE_TYPES = {"Ballistic", "Energy", "Explosive"}
ARMOUR_TYPES = DAMAGE_TYPES | {"None"}
ARCS = {"Narrow", "Front", "Half", "All"}
FOOT_RANGES = ["Reach", "Close", "Near", "Far"]
DIFFICULTY = {"Easy": 2, "Standard": 0, "Hard": -2, "Very hard": -4}
STATS = ("Gunnery", "Melee", "Precision", "Reflex", "Systems", "Countermeasures")

# Tags the bot understands. A value of int means the tag takes a whole number ("cm_field:2"),
# a set lists the allowed words, None means the tag stands alone. Specials without a tag are
# shown to the table as text and left to the GM.
FRAME_TAGS: dict[str, object] = {
    "aircraft": None,              # flies aircraft paths at LOW and HIGH
    "anchor": None,                # must spend its move anchoring before firing
    "augmented_only": None,        # unaugmented pilot's Reflex counts as 5
    "battery_crane": None,         # once per round an ally within 1 regains 2 Energy
    "charge_reach": int,           # Charge reaches Move + N
    "cm_field": int,               # countermeasure field radius
    "damage_floor": int,           # hits of N damage or less deal none
    "drone_command": None,         # commands uncrewed frames
    "dug_in_cover": int,           # +N cover if it did not move this round
    "extra_spare": int,            # extra spare magazines each mission
    "flies_high": None,            # a variable frame that can reach HIGH
    "front_cover": int,            # +N cover against attacks from its front arc
    "ground_move_only": None,
    "jury_rigged": None,           # d10 at mission start, on a 1 a weapon is jammed
    "limits_off": None,            # 1 Will for +1 Reflex this round
    "linked_fire": None,           # may fire two identical weapons as one attack
    "no_hands": None,              # no parting strike, no Hands attack
    "no_spares": None,
    "point_defence": int,          # explosive ranged attacks on it or allies within N are -2
    "rattletrap": None,            # d10 at mission start, on a 1 it has -1 Move
    "shared_lock": None,           # shares Target Lock results with a partner or link
    "shelter_cover": int,          # +N cover to allies within 1 behind it
    "shoot_and_scoot": int,        # after its attack it may move N hexes, unless it charged
    "space_only": None,
    "stealth_range": int,          # cannot be targeted beyond N hexes until it attacks
    "still_stealth_range": int,    # while it has not moved, cannot be targeted beyond N
    "swap_pit": None,              # needs a swap pit between missions
    "tank": None,
    "transform_no_attack": None,   # cannot attack in a round it changes band
    "unarmed": None,
}
WEAPON_TAGS: dict[str, object] = {
    "anchor": None,                # fires only after anchoring (no move that round)
    "cooldown": int,               # after two attacks it cools down for N rounds
    "gm_issue": None,              # issued only when the GM allows
    "hands_by_size": None,         # Large 2 x 5, Medium 2 x 4, Small 2 x 3
    "ignore_cover": int,
    "indirect": None,              # indirect fire with a spotter
    "kneel_only": None,            # fires only if braced and did not move
    "needs_generator": None,
    "on_hit": {"shred", "stagger", "tether", "dazzle"},
    "reach": int,                  # melee reach in hexes
    "vs_protocol_user": int,       # +N to hit a unit that used a Protocol this round
}
FOOT_TAGS: dict[str, object] = {"steady": None, "stun": None}
PROTOCOL_TAGS: dict[str, object] = {
    "damage": int,
    "dispel": None,
    "energy": int,
    "no_advanced": None,
    "no_lock": None,
    "no_reload": None,
    "reload": None,
    "self_energy": int,
    "stat": str,                   # e.g. "gunnery+1", "reflex-1", "move-1"
    "target": {"ally", "self", "enemy", "enemies_in_radius", "any"},
}
STAT_EFFECT_RE = re.compile(r"^(gunnery|melee|precision|reflex|systems|countermeasures|brace|move)[+-]\d+$")


class Problems:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, where: str, message: str) -> None:
        self.errors.append(f"{where}: {message}")

    def warn(self, where: str, message: str) -> None:
        self.warnings.append(f"{where}: {message}")


# ---------------------------------------------------------------- reading the sheet

def snapshot_from_grid(grid: dict) -> dict:
    """Reduce a spreadsheets.get grid read to {"revision", "tabs": {title: [[cell text]]}}."""
    tabs: dict[str, list[list[str]]] = {}
    for sheet in grid.get("sheets", []):
        title = sheet["properties"]["title"]
        rows: list[list[str]] = []
        for block in sheet.get("data", []):
            for row in block.get("rowData", []):
                rows.append([str(cell.get("formattedValue", "")) for cell in row.get("values", [])])
        while rows and not any(c.strip() for c in rows[-1]):
            rows.pop()
        tabs[title] = rows
    missing = [t for t in TABS if t not in tabs]
    if missing:
        raise ValueError(f"grid read is missing tabs: {', '.join(missing)}")
    return {"spreadsheet": SPREADSHEET_ID, "revision": grid.get("revisionId", ""), "tabs": {t: tabs[t] for t in TABS}}


def records(rows: list[list[str]]) -> list[tuple[int, dict[str, str]]]:
    """Rows as (sheet row number, {header: text}); rows with an empty first cell are skipped."""
    if not rows:
        return []
    header = [h.strip() for h in rows[0]]
    out = []
    for n, row in enumerate(rows[1:], start=2):
        if not row or not row[0].strip():
            continue
        out.append((n, {h: (row[i].strip() if i < len(row) else "") for i, h in enumerate(header) if h}))
    return out


# ---------------------------------------------------------------- field parsers

def need_columns(tab: str, rows: list[list[str]], columns: list[str], p: Problems) -> bool:
    header = {h.strip() for h in rows[0]} if rows else set()
    missing = [c for c in columns if c not in header]
    for c in missing:
        p.error(tab, f"missing column {c!r}")
    return not missing


def as_int(value: str, where: str, field: str, p: Problems, lo: int | None = None, hi: int | None = None) -> int:
    text = value.replace(",", "")
    if not INT_RE.match(text):
        p.error(where, f"{field} {value!r} is not a whole number")
        return 0
    n = int(text)
    if (lo is not None and n < lo) or (hi is not None and n > hi):
        p.error(where, f"{field} {n} is outside {lo}..{hi}")
    return n


def as_bool(value: str, where: str, field: str, p: Problems) -> bool:
    if value in ("Yes", "TRUE"):
        return True
    if value in ("No", "FALSE", ""):
        return False
    p.error(where, f"{field} {value!r} is not Yes or No")
    return False


def as_enum(value: str, allowed, where: str, field: str, p: Problems) -> str:
    if value not in allowed:
        p.error(where, f"{field} {value!r} is not one of {sorted(allowed)}")
    return value


def parse_tags(text: str, vocabulary: dict[str, object], where: str, p: Problems) -> dict[str, object]:
    tags: dict[str, object] = {}
    for part in (t.strip() for t in text.split(";")):
        if not part:
            continue
        name, _, raw = part.partition(":")
        name, raw = name.strip(), raw.strip()
        if name not in vocabulary:
            p.error(where, f"unknown tag {name!r}")
            continue
        if name in tags:
            p.error(where, f"tag {name!r} given twice")
        kind = vocabulary[name]
        if kind is None:
            if raw:
                p.error(where, f"tag {name!r} takes no value")
            tags[name] = True
        elif kind is int:
            if not INT_RE.match(raw):
                p.error(where, f"tag {name!r} needs a whole number, got {raw!r}")
                continue
            tags[name] = int(raw)
        elif kind is str:
            if not raw:
                p.error(where, f"tag {name!r} needs a value")
            tags[name] = raw
        else:
            if raw not in kind:
                p.error(where, f"tag {name!r} value {raw!r} is not one of {sorted(kind)}")
            tags[name] = raw
    return tags


def check_id(value: str, where: str, seen: dict[str, str], p: Problems) -> str:
    if not value:
        p.error(where, "has no ID")
    elif not ID_RE.match(value):
        p.error(where, f"ID {value!r} must be lower case letters, digits and _")
    elif value in seen:
        p.error(where, f"ID {value!r} is also used by {seen[value]}")
    else:
        seen[value] = where
    return value


# ---------------------------------------------------------------- tabs

def build_protocols(rows, p: Problems) -> list[dict]:
    cols = ["ID", "Protocol", "Type", "Difficulty", "Modifier", "Energy", "Range", "Radius",
            "Duration", "Channelled", "Effect", "Tags"]
    if not need_columns("Protocols", rows, cols, p):
        return []
    seen: dict[str, str] = {}
    out = []
    for n, r in records(rows):
        where = f"Protocols row {n} ({r['Protocol'] or r['ID']})"
        difficulty = as_enum(r["Difficulty"], DIFFICULTY, where, "Difficulty", p)
        modifier = as_int(r["Modifier"], where, "Modifier", p)
        if difficulty in DIFFICULTY and modifier != DIFFICULTY[difficulty]:
            p.error(where, f"Modifier {modifier} does not match {difficulty} ({DIFFICULTY[difficulty]:+d})")
        tags = parse_tags(r["Tags"], PROTOCOL_TAGS, where, p)
        if "stat" in tags and not STAT_EFFECT_RE.match(str(tags["stat"])):
            p.error(where, f"stat tag {tags['stat']!r} should look like reflex-1")
        out.append({
            "id": check_id(r["ID"], where, seen, p),
            "name": r["Protocol"],
            "type": as_enum(r["Type"], {"Buff", "Debuff", "Damage", "Dispel"}, where, "Type", p),
            "difficulty": difficulty,
            "modifier": modifier,
            "energy": as_int(r["Energy"], where, "Energy", p, 0, 9),
            "range": as_int(r["Range"], where, "Range", p, 0, 24),
            "radius": as_int(r["Radius"], where, "Radius", p, 0, 9),
            "duration": as_int(r["Duration"], where, "Duration", p, 0, 9),
            "channelled": as_bool(r["Channelled"], where, "Channelled", p),
            "effect": r["Effect"],
            "tags": tags,
        })
    return out


def build_weapons(rows, p: Problems) -> list[dict]:
    cols = ["Weapon", "Gen", "Role", "Damage type", "Shots", "Damage", "Armour piercing", "Aim",
            "Heavy", "Melee", "Min range", "Max range", "Arc", "Magazine", "Spares", "Energy",
            "Special", "Class", "Band check", "Generation limits", "Price ($10,000s)", "ID", "Tags"]
    if not need_columns("Weapons", rows, cols, p):
        return []
    seen: dict[str, str] = {}
    out = []
    for n, r in records(rows):
        where = f"Weapons row {n} ({r['Weapon']})"
        w = {
            "id": check_id(r["ID"], where, seen, p),
            "name": r["Weapon"],
            "gen": as_int(r["Gen"], where, "Gen", p, 1, 4),
            "role": r["Role"],
            "class": as_enum(r["Class"], {"Primary", "Secondary", "Fixed"}, where, "Class", p),
            "damage_type": as_enum(r["Damage type"], DAMAGE_TYPES, where, "Damage type", p),
            "shots": as_int(r["Shots"], where, "Shots", p, 1, 12),
            "damage": as_int(r["Damage"], where, "Damage", p, 0, 40),
            "ap": as_int(r["Armour piercing"], where, "Armour piercing", p, 0, 9),
            "aim": as_int(r["Aim"], where, "Aim", p, -3, 3),
            "heavy": as_bool(r["Heavy"], where, "Heavy", p),
            "melee": as_bool(r["Melee"], where, "Melee", p),
            "min_range": as_int(r["Min range"], where, "Min range", p, 1, 24),
            "max_range": as_int(r["Max range"], where, "Max range", p, 1, 24),
            "arc": as_enum(r["Arc"], ARCS, where, "Arc", p),
            "magazine": as_int(r["Magazine"], where, "Magazine", p, 0, 20),
            "spares": as_int(r["Spares"], where, "Spares", p, 0, 9),
            "energy": as_int(r["Energy"], where, "Energy", p, 0, 9),
            "special": r["Special"],
            "tags": parse_tags(r["Tags"], WEAPON_TAGS, where, p),
            "price": as_int(r["Price ($10,000s)"], where, "Price", p, 0),
        }
        if w["min_range"] > w["max_range"]:
            p.error(where, "Min range is above Max range")
        if w["melee"] and w["max_range"] != 1 and "reach" not in w["tags"]:
            p.error(where, "melee weapon reaching past 1 hex needs a reach tag")
        if w["magazine"] == 0 and w["energy"] == 0 and not w["melee"]:
            p.error(where, "ranged weapon with no magazine and no Energy cost")
        for check in ("Band check", "Generation limits"):
            if r[check] not in ("OK", "Fixed"):
                p.warn(where, f"{check} says {r[check]!r}")
        out.append(w)
    return out


def build_foot_weapons(rows, p: Problems) -> list[dict]:
    cols = ["Weapon", "Shots", "Damage", "Armour piercing", "Aim", "Heavy", "Melee", "Min range",
            "Max range", "Magazine", "Spares", "Special", "ID", "Tags"]
    if not need_columns("On Foot", rows, cols, p):
        return []
    seen: dict[str, str] = {}
    out = []
    for n, r in records(rows):
        where = f"On Foot row {n} ({r['Weapon']})"
        w = {
            "id": check_id(r["ID"], where, seen, p),
            "name": r["Weapon"],
            "shots": as_int(r["Shots"], where, "Shots", p, 1, 12),
            "damage": as_int(r["Damage"], where, "Damage", p, 0, 20),
            "ap": as_int(r["Armour piercing"], where, "Armour piercing", p, 0, 9),
            "aim": as_int(r["Aim"], where, "Aim", p, -3, 3),
            "heavy": as_bool(r["Heavy"], where, "Heavy", p),
            "melee": as_bool(r["Melee"], where, "Melee", p),
            "min_range": as_enum(r["Min range"], FOOT_RANGES, where, "Min range", p),
            "max_range": as_enum(r["Max range"], FOOT_RANGES, where, "Max range", p),
            "magazine": as_int(r["Magazine"], where, "Magazine", p, 0, 30),
            "spares": as_int(r["Spares"], where, "Spares", p, 0, 9),
            "special": r["Special"],
            "tags": parse_tags(r["Tags"], FOOT_TAGS, where, p),
        }
        if (w["min_range"] in FOOT_RANGES and w["max_range"] in FOOT_RANGES
                and FOOT_RANGES.index(w["min_range"]) > FOOT_RANGES.index(w["max_range"])):
            p.error(where, "Min range is beyond Max range")
        out.append(w)
    return out


def build_frames(rows, weapons: list[dict], protocols: list[dict], p: Problems) -> list[dict]:
    cols = (["Frame", "Class", "Gen", "Role", "Bloc", "Size", "Movement", "Structure", "Armour",
             "Armour type", "Move", "Energy", "Recharge", "Brace hardware", "Brace threshold",
             "Protocols", "Special", "Weapon 1", "Weapon 2", "Weapon 3", "Production",
             "Budget check", "Role check", "Hardware check", "Brace check", "Loadout check",
             "Price ($10,000s)", "ID", "Protocol list", "Tags"]
            + [f"{s} hardware" for s in STATS] + [f"{s} threshold" for s in STATS])
    if not need_columns("Frames", rows, cols, p):
        return []
    weapon_ids = {w["name"]: w["id"] for w in weapons}
    protocol_ids = {pr["id"] for pr in protocols}
    seen: dict[str, str] = {}
    out = []
    for n, r in records(rows):
        where = f"Frames row {n} ({r['Frame']})"
        gen = as_int(r["Gen"], where, "Gen", p, 1, 4)
        hardware = {s.lower(): as_int(r[f"{s} hardware"], where, f"{s} hardware", p, -3, 5) for s in STATS}
        limits = {s.lower(): as_int(r[f"{s} threshold"], where, f"{s} threshold", p, 1, 14) for s in STATS}
        hardware["brace"] = as_int(r["Brace hardware"], where, "Brace hardware", p, 0, 5)
        limits["brace"] = as_int(r["Brace threshold"], where, "Brace threshold", p, 1, 14)
        loadout = []
        for slot in ("Weapon 1", "Weapon 2", "Weapon 3"):
            name = r[slot]
            if not name:
                continue
            if name not in weapon_ids:
                p.error(where, f"{slot} {name!r} is not on the Weapons tab")
            else:
                loadout.append(weapon_ids[name])
        plist = [x for x in r["Protocol list"].split(";") if x]
        for pid in plist:
            if pid not in protocol_ids:
                p.error(where, f"Protocol {pid!r} is not on the Protocols tab")
        count = as_int(r["Protocols"], where, "Protocols", p, 0, 6)
        if count != len(plist):
            p.error(where, f"Protocols column says {count} but the list names {len(plist)}")
        if gen == 1 and (plist or hardware["systems"] or hardware["countermeasures"]):
            p.error(where, "Gen 1 frames carry no Protocols and no Systems or Countermeasures hardware")
        for s, total in hardware.items():
            if total < 0:
                p.warn(where, f"negative {s} hardware")
        f = {
            "id": check_id(r["ID"], where, seen, p),
            "name": r["Frame"],
            "class": as_enum(r["Class"], {"Mech", "Vehicle"}, where, "Class", p),
            "gen": gen,
            "role": r["Role"],
            "bloc": r["Bloc"],
            "size": as_enum(r["Size"], SIZES, where, "Size", p),
            "movement": as_enum(r["Movement"], MOVEMENT, where, "Movement", p),
            "structure": as_int(r["Structure"], where, "Structure", p, 1, 300),
            "armour": as_int(r["Armour"], where, "Armour", p, 0, 9),
            "armour_type": as_enum(r["Armour type"], ARMOUR_TYPES, where, "Armour type", p),
            "move": as_int(r["Move"], where, "Move", p, 0, 9),
            "energy": as_int(r["Energy"], where, "Energy", p, 0, 20),
            "recharge": as_int(r["Recharge"], where, "Recharge", p, 0, 9),
            "hardware": hardware,
            "limits": limits,
            "protocols": plist,
            "special": r["Special"],
            "tags": parse_tags(r["Tags"], FRAME_TAGS, where, p),
            "weapons": loadout,
            "production": r["Production"],
            "price": as_int(r["Price ($10,000s)"], where, "Price", p, 0),
        }
        for check in ("Budget check", "Role check", "Hardware check", "Brace check", "Loadout check"):
            if r[check] not in ("OK", "n/a"):
                p.warn(where, f"{check} says {r[check]!r}")
        out.append(f)
    return out


def build_catalogue(snapshot: dict) -> tuple[dict, Problems]:
    p = Problems()
    tabs = snapshot["tabs"]
    protocols = build_protocols(tabs["Protocols"], p)
    weapons = build_weapons(tabs["Weapons"], p)
    foot = build_foot_weapons(tabs["On Foot"], p)
    frames = build_frames(tabs["Frames"], weapons, protocols, p)
    catalogue = {
        "about": "Built by tabletop/sheet_export.py from the Frames and Weapons sheet. Do not edit by hand.",
        "spreadsheet": snapshot.get("spreadsheet", SPREADSHEET_ID),
        "revision": snapshot.get("revision", ""),
        "frames": frames,
        "weapons": weapons,
        "foot_weapons": foot,
        "protocols": protocols,
    }
    return catalogue, p


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def main(argv: list[str]) -> int:
    if len(argv) > 1:
        grid = json.loads(Path(argv[1]).read_text(encoding="utf-8"))
        snapshot = snapshot_from_grid(grid)
    else:
        snapshot = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
    catalogue, p = build_catalogue(snapshot)
    for w in p.warnings:
        print(f"warning: {w}")
    for e in p.errors:
        print(f"error: {e}")
    if p.errors:
        print(f"{len(p.errors)} errors; catalogue not written")
        return 1
    if len(argv) > 1:
        write_json(SNAPSHOT, snapshot)
    write_json(CATALOGUE, catalogue)
    print(f"OK: {len(catalogue['frames'])} frames, {len(catalogue['weapons'])} weapons, "
          f"{len(catalogue['foot_weapons'])} on-foot weapons, {len(catalogue['protocols'])} Protocols "
          f"({len(p.warnings)} warnings)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
