"""Strict validation of the game catalogues before the tabletop bot loads them.

Repeats every rule in data/catalogue_validator.gd and adds what Godot never checked: unknown keys
(a typo such as "armor" is an error, not silently ignored), field types, the workshop catalogues,
the workshop pilots and the points table. Standard library only.

    py tabletop/catalogue_check.py            # check data/catalogues, exit 1 on any error
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

CATALOGUE_DIR = Path(__file__).resolve().parent.parent / "data" / "catalogues"

STAT_NAMES = ["gunnery", "melee", "precision", "reflex", "systems", "countermeasures", "spirit"]
PILOT_CAPS = {"gunnery": 4, "melee": 4, "precision": 5, "reflex": 4, "systems": 4, "countermeasures": 4, "spirit": 6}
PILOT_ONLY = ["spirit"]
HARDWARE_STATS = [stat for stat in STAT_NAMES if stat not in PILOT_ONLY]
DAMAGE_TYPES = ["ballistic", "energy", "explosive"]
SIZES = ["small", "medium", "large", "super_heavy"]
MOVEMENT_TYPES = ["ground", "flying", "aircraft"]
TIERS = ["vehicle", "mass", "line", "elite"]
MANOEUVRE_KINDS = ["ground", "vector", "lateral", "reverse", "charge", "aircraft"]
ABILITY_EVENTS = ["before_attack", "after_attack_roll", "after_movement"]
ABILITY_EFFECTS = ["accuracy", "reroll", "rotate"]
RARITIES = ["standard", "uncommon", "rare"]
# Frame fields a workshop part may raise or lower besides the hardware stats.
PART_FRAME_FIELDS = ["structure", "armour", "base_move", "energy_capacity", "energy_recharge"]
HIT_STEP = 10

# Field kinds: "str", "int" (whole number), "num", "bool", "stats", "str_list", "int_list", or a list
# of allowed strings. Required fields are listed separately.
FIELDS = {
    "weapons": {
        "id": "str", "display_name": "str", "shots": "int", "damage": "int", "armour_piercing": "int",
        "aim_bonus": "num", "damage_type": DAMAGE_TYPES, "size": SIZES, "heavy": "bool", "melee": "bool",
        "range_min": "num", "range_max": "num", "arc": "num", "energy_cost": "int",
    },
    "manoeuvres": {
        "id": "str", "display_name": "str", "kind": MANOEUVRE_KINDS, "minimum_move": "num", "distance": "num",
        "move_modifier": "num", "turn_degrees": "num", "energy_cost": "int",
    },
    "abilities": {
        "id": "str", "display_name": "str", "event": ABILITY_EVENTS, "effect": ABILITY_EFFECTS, "amount": "num",
        "will_cost": "int", "description": "str",
    },
    "pilots": {
        "id": "str", "display_name": "str", "stats": "stats", "abilities": "str_list",
        # Workshop pilot sheets only.
        "callsign": "str", "role": "str", "portrait": "str",
    },
    "frames": {
        "id": "str", "display_name": "str", "movement_type": MOVEMENT_TYPES, "generation": "int", "tier": TIERS,
        "tonnage": "num", "stat_bonuses": "stats", "stat_fractions": "stats", "stat_max": "stats",
        "size_class": SIZES, "manufacturer": "str", "compatible_manufacturers": "str_list", "structure": "int",
        "armour": "int", "armour_type": ["none"] + DAMAGE_TYPES, "base_move": "num", "energy_capacity": "int",
        "energy_reserved": "num", "energy_recharge": "int", "altitude_access": "int_list",
        "manoeuvres": "str_list", "default_melee": "str",
    },
}
REQUIRED = {
    "weapons": ["id", "display_name", "shots", "damage", "range_max"],
    "manoeuvres": ["id", "display_name", "kind"],
    "abilities": ["id", "display_name", "event", "effect", "amount", "will_cost"],
    "pilots": ["id", "display_name", "stats"],
    "frames": ["id", "display_name", "size_class", "structure", "stat_max", "altitude_access", "manoeuvres"],
}
PART_FIELDS = {
    "id": "str", "name": "str", "family": "str", "description": "str", "bonuses": "part_bonuses",
    "wear": "part_bonuses", "repair_rate": "int", "manufacturer": "str", "size_class": SIZES,
    "energy_reservation": "num", "rarity": RARITIES, "weapon": "str", "allowed_slots": "str_list",
    "requires": "str_map",
}
PART_REQUIRED = ["id", "name", "family", "bonuses", "wear", "repair_rate", "manufacturer", "size_class",
                 "energy_reservation", "rarity"]
WORKSHOP_KEYS = {"frame_id", "default_pilot", "default_finish", "starting_spares", "stock_arm_weapons",
                 "weapon_slots", "regions", "parts", "manufacturers", "finishes"}


def is_number(value) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def is_whole(value) -> bool:
    return is_number(value) and float(value).is_integer()


def kind_error(value, kind) -> str:
    """Why value does not fit kind, or an empty string."""
    if isinstance(kind, list):
        return "" if value in kind else "must be one of %s" % ", ".join(kind)
    checks = {
        "str": (lambda v: isinstance(v, str), "must be a string"),
        "int": (is_whole, "must be a whole number"),
        "num": (is_number, "must be a number"),
        "bool": (lambda v: isinstance(v, bool), "must be true or false"),
        "str_list": (lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v), "must be a list of strings"),
        "int_list": (lambda v: isinstance(v, list) and all(is_whole(x) for x in v), "must be a list of whole numbers"),
        "stats": (lambda v: isinstance(v, dict), "must be an object"),
        "part_bonuses": (lambda v: isinstance(v, dict) and all(is_number(x) for x in v.values()), "must be an object of numbers"),
        "str_map": (lambda v: isinstance(v, dict) and all(isinstance(x, str) for x in v.values()), "must be an object of strings"),
        # Region slots are checked one by one in check_workshop.
        "slots": (lambda v: isinstance(v, list), "must be a list"),
    }
    test, message = checks[kind]
    return "" if test(value) else message


def check_record(entry, fields: dict, required: list, context: str, errors: list) -> bool:
    """Keys and types of one record. False if it is not an object with a usable id."""
    if not isinstance(entry, dict) or not isinstance(entry.get("id"), str) or not entry["id"]:
        errors.append("Every %s entry needs a nonempty string id." % context)
        return False
    for key in entry:
        if key not in fields:
            errors.append("%s %s has unknown key: %s." % (context, entry["id"], key))
        else:
            problem = kind_error(entry[key], fields[key])
            if problem:
                errors.append("%s %s.%s %s." % (context, entry["id"], key, problem))
    for key in required:
        if key not in entry:
            errors.append("%s %s is missing %s." % (context, entry["id"], key))
    return True


def check_stats(values, context: str, errors: list) -> None:
    if not isinstance(values, dict):
        return
    for key, value in values.items():
        if key not in STAT_NAMES:
            errors.append("%s has unknown stat: %s." % (context, key))
        elif not is_number(value) or value < 0:
            errors.append("%s.%s must be a non-negative number." % (context, key))


def check_references(values, known, context: str, errors: list) -> None:
    for value in values if isinstance(values, list) else []:
        if value not in known:
            errors.append("%s references unknown id: %s." % (context, value))


def index(records: list) -> dict:
    return {entry["id"]: entry for entry in records if isinstance(entry, dict) and isinstance(entry.get("id"), str)}


def check_pilots(pilots, abilities: dict, context: str, errors: list) -> None:
    for pilot in pilots:
        if not check_record(pilot, FIELDS["pilots"], REQUIRED["pilots"], context, errors):
            continue
        check_references(pilot.get("abilities", []), abilities, "%s %s abilities" % (context, pilot["id"]), errors)
        stats = pilot.get("stats", {})
        check_stats(stats, "%s %s stats" % (context, pilot["id"]), errors)
        for key, value in stats.items() if isinstance(stats, dict) else []:
            if key in PILOT_CAPS and is_number(value) and (not is_whole(value) or value > PILOT_CAPS[key]):
                errors.append("%s %s.%s must be a whole number up to %d." % (context, pilot["id"], key, PILOT_CAPS[key]))


def check_standard(data: dict, errors: list) -> None:
    """standard.json: the same rules as CatalogueValidator, plus strict keys and types."""
    groups = list(FIELDS)
    for key in data:
        if key not in groups and not key.startswith("_"):
            errors.append("standard.json has unknown section: %s." % key)
    seen = {}
    for group in groups:
        seen[group] = set()
        if not isinstance(data.get(group), list):
            errors.append("Catalogue requires an array: %s." % group)
            data[group] = []
        for entry in data[group]:
            if isinstance(entry, dict) and entry.get("id") in seen[group]:
                errors.append("Duplicate %s id: %s." % (group, entry["id"]))
            if isinstance(entry, dict) and isinstance(entry.get("id"), str):
                seen[group].add(entry["id"])
    weapons, manoeuvres, abilities = index(data["weapons"]), index(data["manoeuvres"]), index(data["abilities"])
    for group in ["weapons", "manoeuvres", "abilities"]:
        for entry in data[group]:
            check_record(entry, FIELDS[group], REQUIRED[group], group[:-1].capitalize(), errors)
    check_pilots(data["pilots"], abilities, "Pilot", errors)
    for weapon in weapons.values():
        if is_number(weapon.get("shots")) and weapon["shots"] < 1:
            errors.append("Weapon %s requires at least one shot." % weapon["id"])
        if is_number(weapon.get("damage")) and weapon["damage"] < 0:
            errors.append("Weapon %s requires non-negative damage." % weapon["id"])
        # Hit chances move in d10 steps.
        if is_number(weapon.get("aim_bonus", 0)) and weapon.get("aim_bonus", 0) % HIT_STEP:
            errors.append("Weapon %s aim_bonus must be a multiple of 10." % weapon["id"])
        low, high = weapon.get("range_min", 0), weapon.get("range_max", 0)
        if is_number(low) and is_number(high) and low > high:
            errors.append("Weapon %s range_min is above range_max." % weapon["id"])
    for frame in data["frames"]:
        if not check_record(frame, FIELDS["frames"], REQUIRED["frames"], "Frame", errors):
            continue
        check_references(frame.get("manoeuvres", []), manoeuvres, "Frame %s manoeuvres" % frame["id"], errors)
        for field in ["stat_bonuses", "stat_fractions", "stat_max"]:
            check_stats(frame.get(field, {}), "Frame %s %s" % (frame["id"], field), errors)
        # Thresholds are the only ceiling on a mech's totals, so none may be left out; pilot-only stats
        # such as Spirit are the pilot's own, so frames may neither raise nor limit them.
        for key in STAT_NAMES:
            for field in ["stat_max", "stat_bonuses", "stat_fractions"]:
                values = frame.get(field, {})
                if not isinstance(values, dict):
                    continue
                if key in PILOT_ONLY and key in values:
                    errors.append("Frame %s %s cannot include %s, a pilot-only stat." % (frame["id"], field, key))
                elif field == "stat_max" and key not in PILOT_ONLY and key not in values:
                    errors.append("Frame %s stat_max is missing %s." % (frame["id"], key))
        hands = frame.get("default_melee", "")
        if hands and not weapons.get(hands, {}).get("melee", False):
            errors.append("Frame %s default_melee must name a melee weapon: %s." % (frame["id"], hands))


def check_workshop(name: str, data: dict, standard: dict, pilot_ids: set, errors: list) -> None:
    """A workshop catalogue: regions of slots, the parts that fit them, finishes and manufacturers."""
    for key in data:
        if key not in WORKSHOP_KEYS and not key.startswith("_"):
            errors.append("%s has unknown key: %s." % (name, key))
    frames, weapons = index(standard.get("frames", [])), index(standard.get("weapons", []))
    if data.get("frame_id") not in frames:
        errors.append("%s frame_id is not a standard.json frame: %s." % (name, data.get("frame_id")))
    manufacturers = data.get("manufacturers", {})
    if not isinstance(manufacturers, dict) or not all(isinstance(v, str) for v in manufacturers.values()):
        errors.append("%s manufacturers must map ids to names." % name)
        manufacturers = {}
    finishes = {}
    for finish in data.get("finishes", []):
        if check_record(finish, {"id": "str", "name": "str", "primary": "str", "secondary": "str", "marking": "str"},
                        ["id", "name", "primary", "secondary", "marking"], "%s finish" % name, errors):
            finishes[finish["id"]] = finish
    slots = {}
    for region in data.get("regions", []):
        if not check_record(region, {"id": "str", "name": "str", "slots": "slots"}, ["id", "name", "slots"],
                            "%s region" % name, errors):
            continue
        for slot in region.get("slots", []) if isinstance(region.get("slots"), list) else []:
            if check_record(slot, {"id": "str", "name": "str", "family": "str", "standard": "str"},
                            ["id", "name", "family", "standard"], "%s slot" % name, errors):
                if slot["id"] in slots:
                    errors.append("%s has duplicate slot id: %s." % (name, slot["id"]))
                slots[slot["id"]] = slot
    parts = {}
    for part in data.get("parts", []):
        if not check_record(part, PART_FIELDS, PART_REQUIRED, "%s part" % name, errors):
            continue
        if part["id"] in parts:
            errors.append("%s has duplicate part id: %s." % (name, part["id"]))
        parts[part["id"]] = part
    families = {slot["family"] for slot in slots.values()}
    for part in parts.values():
        context = "%s part %s" % (name, part["id"])
        for field in ["bonuses", "wear"]:
            for key in part.get(field, {}) if isinstance(part.get(field), dict) else []:
                if key not in HARDWARE_STATS + PART_FRAME_FIELDS:
                    errors.append("%s %s has unknown key: %s." % (context, field, key))
        if part.get("family") not in families:
            errors.append("%s family fits no slot: %s." % (context, part.get("family")))
        if part.get("manufacturer") not in manufacturers:
            errors.append("%s has unknown manufacturer: %s." % (context, part.get("manufacturer")))
        if part.get("weapon") and part["weapon"] not in weapons:
            errors.append("%s weapon is not a standard.json weapon: %s." % (context, part["weapon"]))
        for slot_id in part.get("allowed_slots", []) if isinstance(part.get("allowed_slots"), list) else []:
            if slot_id not in slots:
                errors.append("%s allowed_slots references unknown slot: %s." % (context, slot_id))
            elif slots[slot_id]["family"] != part.get("family"):
                errors.append("%s allowed_slots names a %s slot: %s." % (context, slots[slot_id]["family"], slot_id))
        for slot_id, part_id in (part.get("requires") or {}).items() if isinstance(part.get("requires"), dict) else []:
            if slot_id not in slots or part_id not in parts:
                errors.append("%s requires unknown slot or part: %s = %s." % (context, slot_id, part_id))
    for slot in slots.values():
        standard_part = parts.get(slot["standard"])
        if standard_part is None or standard_part.get("family") != slot["family"]:
            errors.append("%s slot %s standard part must be a %s part: %s." % (name, slot["id"], slot["family"], slot["standard"]))
    check_references(data.get("starting_spares", []), parts, "%s starting_spares" % name, errors)
    check_references(data.get("weapon_slots", []), slots, "%s weapon_slots" % name, errors)
    for slot_id, weapon_id in data.get("stock_arm_weapons", {}).items():
        if slot_id not in slots or weapon_id not in weapons:
            errors.append("%s stock_arm_weapons has unknown slot or weapon: %s = %s." % (name, slot_id, weapon_id))
    if "default_pilot" in data and data["default_pilot"] not in pilot_ids:
        errors.append("%s default_pilot is not a workshop pilot: %s." % (name, data["default_pilot"]))
    if "default_finish" in data and data["default_finish"] not in finishes:
        errors.append("%s default_finish is not one of its finishes: %s." % (name, data["default_finish"]))


def check_shape(value, template, context: str, errors: list) -> None:
    """costs.json against a template: exact key sets, with "num" leaves and enum strings."""
    if isinstance(template, dict):
        if not isinstance(value, dict):
            errors.append("%s must be an object." % context)
            return
        for key in value:
            if key not in template and not key.startswith("_"):
                errors.append("%s has unknown key: %s." % (context, key))
        for key, child in template.items():
            if key not in value:
                errors.append("%s is missing %s." % (context, key))
            else:
                check_shape(value[key], child, "%s.%s" % (context, key), errors)
        return
    problem = kind_error(value, template)
    if problem:
        errors.append("%s %s." % (context, problem))


def costs_template(standard: dict) -> dict:
    numbers = lambda keys: {key: "num" for key in keys}
    abilities = [entry["id"] for entry in standard.get("abilities", []) if isinstance(entry, dict) and "id" in entry]
    return {
        "generation_budget": numbers(["1", "2", "3"]),
        "tier_multiplier": numbers(TIERS),
        "frame": {**numbers(["structure_per_point", "armour_per_point", "armour_type", "move_per_unit",
                             "energy_capacity_per_point", "energy_recharge_per_point", "flight", "aircraft", "manoeuvre"]),
                  "size": numbers(SIZES), "stat_bonus_per_point": numbers(HARDWARE_STATS)},
        "weapon": {**numbers(["points_per_damage", "range_base", "range_per_unit", "minimum_range_per_unit",
                              "melee_range_factor", "energy_per_point"]),
                   "reference_target": {"reflex": "num", "armour": "num", "size": SIZES},
                   "reference_attacker": numbers(["attack", "precision"]),
                   "arc_factor": numbers(["90", "120", "180", "360"])},
        "pilot": {"stat_per_point": numbers(STAT_NAMES), "ability": numbers(abilities)},
    }


def check_all(folder: Path = CATALOGUE_DIR, override: dict | None = None) -> list[str]:
    """Every catalogue in folder. override replaces a file's parsed contents (for tests)."""
    files = {}
    errors: list[str] = []
    for path in sorted(folder.glob("*.json")):
        if override and path.name in override:
            files[path.name] = override[path.name]
            continue
        try:
            files[path.name] = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as problem:
            errors.append("Cannot read %s: %s" % (path.name, problem))
    standard = files.get("standard.json", {})
    check_standard(standard, errors)
    pilots = files.get("workshop_pilots.json", {})
    for key in pilots:
        if key != "pilots" and not key.startswith("_"):
            errors.append("workshop_pilots.json has unknown key: %s." % key)
    check_pilots(pilots.get("pilots", []), index(standard.get("abilities", [])), "Workshop pilot", errors)
    pilot_ids = set(index(pilots.get("pilots", [])))
    if "costs.json" in files:
        check_shape(files["costs.json"], costs_template(standard), "costs.json", errors)
    for name, data in files.items():
        if name.endswith("_workshop.json"):
            check_workshop(name, data, standard, pilot_ids, errors)
    known = {"standard.json", "costs.json", "workshop_pilots.json"}
    for name in files:
        if name not in known and not name.endswith("_workshop.json"):
            errors.append("Unrecognised catalogue file: %s." % name)
    return errors


def main() -> int:
    errors = check_all()
    for message in errors:
        print(message)
    print("%d catalogue errors." % len(errors) if errors else "Catalogues OK.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
