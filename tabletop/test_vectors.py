"""Test vectors against the reference rules engine (tabletop/rules_ref.py).

- anchors.json and dice.json are worked by hand from the Player's Guide: they check the engine.
- converted.json holds the Godot prototype's own results: an independent check of the engine.
- catalogue_attacks.json, protocols.json and stats.json are built by build_vectors.py: they must
  match a fresh build, so a rules or sheet change shows up as a reviewable diff.
"""

import json
import unittest
from fractions import Fraction
from pathlib import Path

import build_vectors
import rules_ref as rr

VECTORS = Path(__file__).resolve().parent / "vectors"

DEFAULTS = {
    "weapon": {"ap": 0, "aim": 0, "heavy": False, "melee": False, "damage_type": "Ballistic", "on_hit": None,
               "ignore_cover": 0, "kneel_only": False},
    "defender": {"armour_type": "None", "size": "Medium", "brace": 5, "stance": "evade", "full_move": False},
    "situation": {"cover": 0, "lock": "roll", "push": False, "see_it": False, "planted": False, "charged": False,
                  "modifier": 0},
}


def load(name):
    return json.loads((VECTORS / name).read_text(encoding="utf-8"))


def with_defaults(case):
    out = dict(case)
    for part, defaults in DEFAULTS.items():
        out[part] = {**defaults, **case.get(part, {})}
    return out


def forecast(case):
    attack = rr.Attack.from_case(with_defaults(case))
    try:
        return {k: (float(v) if isinstance(v, Fraction) else v) for k, v in attack.forecast().items()}
    except rr.IllegalAttack as err:
        return {"illegal": str(err).split(":")[0]}


class Anchors(unittest.TestCase):
    data = load("anchors.json")

    def check_fields(self, got, expected, cid, tol=1e-9):
        for key, want in expected.items():
            self.assertIn(key, got, f"{cid}: no {key}")
            if isinstance(want, float) and got[key] is not None:
                self.assertAlmostEqual(got[key], want, delta=tol, msg=f"{cid}: {key}")
            else:
                self.assertEqual(got[key], want, f"{cid}: {key}")

    def test_attacks(self):
        for case in self.data["attacks"]:
            with self.subTest(case["id"]):
                self.check_fields(forecast(case), case["expected"], case["id"])

    def test_locks(self):
        for case in self.data["locks"]:
            t, countered = rr.lock_targets(case["systems"], case["countermeasures"])
            got = {"lock_target": t, "lock_countered_to": countered,
                   "results": [rr.lock_result(r, case["systems"], case["countermeasures"]) for r in range(1, 11)]}
            self.check_fields(got, case["expected"], case["id"])

    def test_protocols(self):
        for case in self.data["protocols"]:
            success, countered = rr.protocol_targets(case["systems"], case["modifier"], case["hostile"],
                                                     case.get("target_cm"), case["push"])
            got = {"target": success, "countered_to": countered}
            got.update({f"roll_{r}": rr.protocol_result(r, success, countered) for r in range(1, 11)})
            self.check_fields(got, case["expected"], case["id"])

    def test_purges(self):
        for case in self.data["purges"]:
            t = rr.purge_target(case["countermeasures"], case["strength"], case["modifier"], case["push"])
            self.assertEqual(t, case["expected"]["target"], case["id"])

    def test_stats(self):
        for case in self.data["stats"]:
            got = rr.resolve_stat(case["pilot"], case["whole"], Fraction(case["fractions"]), case["limit"])
            self.assertEqual(got, case["expected"], case["id"])

    def test_tasks(self):
        for case in self.data["tasks"]:
            got = rr.task_target(case["stat"], case["modifier"], case["push"], case["help"])
            self.assertEqual(got, case["expected"], case["id"])


class Dice(unittest.TestCase):
    def test_scripted_attacks(self):
        for case in load("dice.json")["cases"]:
            with self.subTest(case["id"]):
                attack = rr.Attack.from_case(with_defaults(case))
                res = attack.resolve(case["dice"])
                got = {"lock": res["lock"], "results": [s["result"] for s in res["shots"]],
                       "damage": [s["damage"] for s in res["shots"]], "total": res["total"],
                       "will_see_it": res["will_see_it"], "on_hit": res["on_hit"], "destroyed": res["destroyed"]}
                for key, want in case["expected"].items():
                    self.assertEqual(got[key], want, f"{case['id']}: {key}")

    def test_dice_must_all_be_used(self):
        case = with_defaults(load("dice.json")["cases"][0])
        attack = rr.Attack.from_case(case)
        with self.assertRaises(ValueError):
            attack.resolve(case["dice"] + [5])
        with self.assertRaises(ValueError):
            attack.resolve(case["dice"][:-1])


class Converted(unittest.TestCase):
    def test_engine_matches_prototype(self):
        cases = load("converted.json")["cases"]
        self.assertEqual(len(cases), 505)
        exact = ("hit_target", "glance_to", "crit_target", "effective_armour", "hit_damage", "crit_damage",
                 "glance_damage")
        for case in cases:
            got = forecast(case)
            for key in exact:
                self.assertEqual(got[key], case["expected"][key], f"{case['id']}: {key}")
            for key in ("expected_damage", "p_damage", "p_destroy"):
                self.assertAlmostEqual(got[key], case["expected"][key], delta=0.006, msg=f"{case['id']}: {key}")


class Built(unittest.TestCase):
    def test_converted_is_current(self):
        self.assertEqual(load("converted.json")["cases"],
                         json.loads(json.dumps(build_vectors.converted_cases())))

    def test_catalogue_is_current(self):
        fresh = json.loads(json.dumps(build_vectors.catalogue_cases()))
        self.assertEqual(load("catalogue_attacks.json")["cases"], fresh,
                         "run py tabletop/build_vectors.py after a sheet export or rules change")

    def test_protocols_are_current(self):
        data = load("protocols.json")
        fresh = json.loads(json.dumps(build_vectors.protocol_sections()))
        for key in ("locks", "protocols", "purges"):
            self.assertEqual(data[key], fresh[key], key)

    def test_stats_are_current(self):
        self.assertEqual(load("stats.json")["cases"], json.loads(json.dumps(build_vectors.stat_cases())))

    def test_catalogue_coverage(self):
        cases = load("catalogue_attacks.json")["cases"]
        catalogue = json.loads(build_vectors.CATALOGUE.read_text(encoding="utf-8"))
        self.assertEqual({c["weapon_id"] for c in cases}, {w["id"] for w in catalogue["weapons"]})
        self.assertTrue(any(c["defender"]["stance"] == "brace" for c in cases))
        self.assertTrue(any(c["defender"]["full_move"] for c in cases))
        self.assertTrue(any(c["situation"]["see_it"] for c in cases))
        self.assertTrue(any(c["situation"]["planted"] for c in cases))
        self.assertTrue(any(c["situation"]["push"] for c in cases))
        self.assertTrue(any(c["situation"]["charged"] for c in cases))
        self.assertTrue(any(c["expected"].get("p_on_hit") is not None for c in cases))
        self.assertTrue(any(0 < c["expected"].get("p_destroy", 0) < 1 for c in cases))
        self.assertFalse(any("illegal" in c["expected"] for c in cases))


if __name__ == "__main__":
    unittest.main()
