"""Build the generated test vector files in tabletop/vectors/.

    py tabletop/build_vectors.py

Writes:
  converted.json         the 505 legacy Godot cases on the 1-14 scale, self-contained, with the
                         prototype's own expected values (an independent check of rules_ref.py)
  catalogue_attacks.json attacks with the sheet's frames and weapons (tabletop/data/catalogue.json),
                         expected values from rules_ref.py
  protocols.json         lock, Protocol and Purge targets with the result of every roll 1-10
  stats.json             stat totals: pilot + whole bonuses + fractions, held to 1..limit

The hand-worked files, anchors.json and dice.json, are not generated. Standard library only.
"""

from __future__ import annotations

import json
from fractions import Fraction
from pathlib import Path

import rules_ref as rr

HERE = Path(__file__).resolve().parent
VECTORS = HERE / "vectors"
LEGACY = VECTORS / "legacy"
CATALOGUE = HERE / "data" / "catalogue.json"
STANDARD = HERE.parent / "data" / "catalogues" / "standard.json"

ABOUT = {
    "converted": "Legacy Godot attack cases (tabletop/vectors/legacy/attacks.json) moved to the 1-14 scale: every attacker and defender stat +5, weapon numbers from the prototype's standard.json written into each case. Expected values are the prototype's own, rounded to 2 decimals there, so damage figures are compared to within 0.006. Countermeasures and Systems were not part of these cases; 5 is filled in and the lock is given (locked or none).",
    "catalogue_attacks": "Attacks with the Frames and Weapons sheet's frames and weapons, from tabletop/data/catalogue.json. Attacker and defender stats are pilot + frame hardware held to the frame's limits. Expected values from tabletop/rules_ref.py. Rebuild after every sheet export.",
    "protocols": "Lock, Protocol and Purge targets, with the result of every d10 roll from 1 to 10. Expected values from tabletop/rules_ref.py.",
    "stats": "Stat totals: pilot + whole bonuses + fractions counted in whole points toward zero, held to 1..limit. Expected values from tabletop/rules_ref.py.",
}

# Pregenerated pilots (Player's Guide and GM's Guide): Gun, Mel, Pre, Ref, Sys, CM, Brace, Spirit.
PILOTS = {
    "anchor": (6, 6, 5, 6, 5, 7, 5, 7), "kestrel": (7, 5, 6, 5, 7, 5, 5, 7),
    "rook": (6, 5, 5, 7, 6, 6, 5, 7), "kite": (6, 5, 5, 6, 7, 5, 6, 7),
    "bulwark": (6, 5, 5, 6, 5, 6, 7, 7), "razor": (5, 5, 7, 6, 5, 6, 6, 7),
    "anvil": (6, 5, 5, 5, 5, 5, 5, 7), "wraith": (6, 6, 7, 6, 7, 6, 5, 8),
    "ace": (7, 6, 7, 7, 5, 5, 5, 9),
}
STAT_ORDER = ("gunnery", "melee", "precision", "reflex", "systems", "countermeasures", "brace", "spirit")
DEFENDER_FRAMES = ("m4_garrison", "hx7_kestrel", "ob12_medved", "f12_peregrine")


def num(x):
    if isinstance(x, Fraction):
        return round(float(x), 6)
    return x


def forecast_dict(attack: rr.Attack) -> dict:
    try:
        return {k: num(v) for k, v in attack.forecast().items()}
    except rr.IllegalAttack as err:
        return {"illegal": str(err).split(":")[0]}


def write(path: Path, about: str, sections: dict[str, list]) -> None:
    parts = [f'  "about": {json.dumps(about, ensure_ascii=False)}']
    for name, items in sections.items():
        lines = ",\n".join("    " + json.dumps(i, ensure_ascii=False, separators=(",", ":")) for i in items)
        parts.append(f'  "{name}": [\n{lines}\n  ]')
    path.write_text("{\n" + ",\n".join(parts) + "\n}\n", encoding="utf-8")


def case_inputs(attack: rr.Attack) -> dict:
    return {
        "attacker": {"attack": attack.attack, "precision": attack.precision, "systems": attack.systems},
        "weapon": {"shots": attack.shots, "damage": attack.damage, "ap": attack.ap, "aim": attack.aim,
                   "heavy": attack.heavy, "melee": attack.melee, "damage_type": attack.damage_type,
                   "on_hit": attack.on_hit, "ignore_cover": attack.ignore_cover, "kneel_only": attack.kneel_only},
        "defender": {"reflex": attack.reflex, "countermeasures": attack.countermeasures, "armour": attack.armour,
                     "armour_type": attack.armour_type, "size": attack.size, "brace": attack.brace,
                     "structure": attack.structure, "stance": attack.stance, "full_move": attack.full_move},
        "situation": {"cover": attack.cover, "lock": attack.lock, "push": attack.push, "see_it": attack.see_it,
                      "planted": attack.planted, "charged": attack.charged, "modifier": attack.modifier},
    }


# ---------------------------------------------------------------- converted legacy cases

LEGACY_SIZE = {"small": "Small", "medium": "Medium", "large": "Large", "super_heavy": "Super heavy"}


def converted_cases() -> list[dict]:
    weapons = {w["id"]: w for w in json.loads(STANDARD.read_text(encoding="utf-8"))["weapons"]}
    legacy = json.loads((LEGACY / "attacks.json").read_text(encoding="utf-8"))["cases"]
    out = []
    for c in legacy:
        w, a, d, s, e = weapons[c["weapon"]], c["attacker"], c["defender"], c["situation"], c["expected"]
        lock_rerolls = 1 if s["locked"] else 0
        attack = rr.Attack(
            attack=a["attack_rating"] + 5, precision=a["precision"] + 5, systems=5,
            shots=w["shots"], damage=w["damage"], ap=w.get("armour_piercing", 0), aim=w.get("aim_bonus", 0) // 10,
            heavy=w.get("heavy", False), melee=w.get("melee", w.get("range_max", 2) <= 1),
            damage_type=w.get("damage_type", "ballistic").title(),
            reflex=d["reflex"] + 5, countermeasures=5, armour=d["armour"], armour_type=d["armour_type"].title(),
            size=LEGACY_SIZE[d["size_class"]], structure=d["structure"],
            cover=s["cover"], lock="locked" if s["locked"] else "none", push=e["pushed"],
            see_it=e["rerolls"] - lock_rerolls > 0, charged=s["charged"],
        )
        case = {"id": c["id"], "legacy_weapon": c["weapon"], **case_inputs(attack)}
        case["expected"] = {
            "hit_target": e["hit_target"], "glance_to": e["glance_target"], "crit_target": e["crit_target"],
            "effective_armour": e["armour"], "hit_damage": e["hit_damage"], "crit_damage": e["crit_damage"],
            "glance_damage": e["glance_damage"], "expected_damage": e["expected_damage"],
            "p_damage": e["p_damage"], "p_destroy": e["p_destroy"],
        }
        out.append(case)
    return out


# ---------------------------------------------------------------- catalogue cases

def unit_stats(pilot: str, frame: dict) -> dict:
    stats = dict(zip(STAT_ORDER, PILOTS[pilot]))
    out = {}
    for s in STAT_ORDER:
        if s == "spirit":
            out[s] = rr.resolve_stat(stats[s], 0, 0, 14)
        else:
            out[s] = rr.resolve_stat(stats[s], frame["hardware"][s], 0, frame["limits"][s])
    return out


def catalogue_cases() -> list[dict]:
    cat = json.loads(CATALOGUE.read_text(encoding="utf-8"))
    frames = {f["id"]: f for f in cat["frames"]}
    carriers: dict[str, dict] = {}
    for f in cat["frames"]:
        for wid in f["weapons"]:
            carriers.setdefault(wid, f)
    situations = [
        ("base", {}),
        ("cover1-push", {"cover": 1, "push": True}),
        ("brace", {"stance": "brace"}),
        ("full-move", {"full_move": True}),
        ("planted-see-it", {"planted": True, "see_it": True}),
    ]
    out = []
    for wi, w in enumerate(cat["weapons"]):
        carrier = carriers.get(w["id"], frames["m4_garrison"])
        pilot = "anchor" if w["melee"] else "kestrel"
        a = unit_stats(pilot, carrier)
        for di, did in enumerate(DEFENDER_FRAMES):
            df = frames[did]
            d = unit_stats("bulwark", df)
            aircraft = df["movement"] == "Aircraft"
            # Every weapon meets every defender in the base case; the other situations rotate so each
            # weapon sees each of them against one defender or another.
            picks = [situations[0], situations[1 + (di + wi) % (len(situations) - 1)]]
            for name, sit in picks:
                stance = sit.get("stance", "evade")
                full_move = sit.get("full_move", False)
                label = name
                if aircraft:  # aircraft always evade and get the full-Move reroll (no High-G turn here)
                    stance, full_move = "evade", True
                    label = f"{name}-aircraft"
                planted = sit.get("planted", False) or w["tags"].get("kneel_only", False)
                attack = rr.Attack(
                    attack=a["melee"] if w["melee"] else a["gunnery"], precision=a["precision"],
                    systems=a["systems"],
                    shots=w["shots"], damage=w["damage"], ap=w["ap"], aim=w["aim"], heavy=w["heavy"],
                    melee=w["melee"], damage_type=w["damage_type"], on_hit=w["tags"].get("on_hit"),
                    ignore_cover=w["tags"].get("ignore_cover", 0), kneel_only=w["tags"].get("kneel_only", False),
                    reflex=d["reflex"], countermeasures=d["countermeasures"], armour=df["armour"],
                    armour_type=df["armour_type"], size=df["size"], brace=d["brace"],
                    structure=df["structure"], stance=stance, full_move=full_move,
                    cover=sit.get("cover", 0), lock="roll", push=sit.get("push", False),
                    see_it=sit.get("see_it", False), planted=planted,
                    charged=w["melee"] and name == "base",
                )
                case = {"id": f"{carrier['id']}>{did}/{w['id']}/{label}",
                        "weapon_id": w["id"], "attacker_frame": carrier["id"], "attacker_pilot": pilot,
                        "defender_frame": did, "defender_pilot": "bulwark", **case_inputs(attack)}
                case["expected"] = forecast_dict(attack)
                out.append(case)
    return out


# ---------------------------------------------------------------- protocols, locks, stats

def protocol_sections() -> dict[str, list]:
    cat = json.loads(CATALOGUE.read_text(encoding="utf-8"))
    locks = []
    for sys_ in range(3, 15):
        for cm in range(3, 15):
            t, countered = rr.lock_targets(sys_, cm)
            locks.append({"id": f"lock/{sys_}v{cm}", "systems": sys_, "countermeasures": cm,
                          "expected": {"lock_target": t, "lock_countered_to": countered,
                                       "results": [rr.lock_result(r, sys_, cm) for r in range(1, 11)]}})
    protocols = []
    for p in cat["protocols"]:
        if p["type"] == "Dispel":
            continue
        hostile = p["type"] in ("Debuff", "Damage")
        for sys_ in (5, 7, 9, 11):
            for cm in ((4, 6, 9) if hostile else (None,)):
                for push in (False, True):
                    success, countered = rr.protocol_targets(sys_, p["modifier"], hostile, cm, push)
                    protocols.append({
                        "id": f"{p['id']}/s{sys_}" + (f"vcm{cm}" if hostile else "") + ("/push" if push else ""),
                        "protocol": p["id"], "systems": sys_, "modifier": p["modifier"], "hostile": hostile,
                        "target_cm": cm, "push": push,
                        "expected": {"target": success, "countered_to": countered,
                                     "results": [rr.protocol_result(r, success, countered) for r in range(1, 11)]}})
    purges = []
    for cm in (4, 6, 8, 10):
        for strength in (5, 7, 9, 11):
            for push in (False, True):
                t = rr.purge_target(cm, strength, 0, push)
                purges.append({"id": f"purge/cm{cm}vs{strength}" + ("/push" if push else ""),
                               "countermeasures": cm, "strength": strength, "modifier": 0, "push": push,
                               "expected": {"target": t}})
    return {"locks": locks, "protocols": protocols, "purges": purges}


def stat_cases() -> list[dict]:
    out = []
    for limit in (6, 7, 9, 11, 14):
        for pilot in (1, 4, 5, 7, 10):
            for whole in (-1, 0, 1, 2, 4):
                for frac in ("-5/4", "-1/2", "-1/4", "0", "1/4", "3/4", "1", "5/4"):
                    out.append({"pilot": pilot, "whole": whole, "fractions": frac, "limit": limit,
                                "expected": rr.resolve_stat(pilot, whole, Fraction(frac), limit)})
    return out


def main() -> None:
    write(VECTORS / "converted.json", ABOUT["converted"], {"cases": converted_cases()})
    write(VECTORS / "catalogue_attacks.json", ABOUT["catalogue_attacks"], {"cases": catalogue_cases()})
    write(VECTORS / "protocols.json", ABOUT["protocols"], protocol_sections())
    write(VECTORS / "stats.json", ABOUT["stats"], {"cases": stat_cases()})
    for name in ("converted", "catalogue_attacks", "protocols", "stats"):
        data = json.loads((VECTORS / f"{name}.json").read_text(encoding="utf-8"))
        counts = ", ".join(f"{len(v)} {k}" for k, v in data.items() if isinstance(v, list))
        print(f"{name}.json: {counts}")


if __name__ == "__main__":
    main()
