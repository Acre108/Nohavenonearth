"""The exported test vectors are complete: every closed-form target in them follows from the case's own
inputs and the catalogue, using the tabletop formulas in docs/tabletop-d10-system.md §7.

Regenerate the vectors with: Godot --headless --path . --script res://tests/export_vectors.gd
"""

import json
import math
import unittest
from pathlib import Path

from catalogue_check import CATALOGUE_DIR

VECTORS = Path(__file__).resolve().parent / "vectors"
SIZE_ADJUSTMENT = {"small": -1, "medium": 0, "large": 1, "super_heavy": 2}
CHARGE_BONUS = 2
LOCK_REROLLS = 1
GLANCE_WINDOW = 2


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def quarter(value: float) -> float:
    # Half away from zero, as Godot's roundf; Python's round() would round half to even.
    return math.copysign(math.floor(abs(value) * 4 + 0.5), value) / 4


def toward_zero(value: float) -> float:
    stepped = quarter(value)
    return math.copysign(math.floor(abs(stepped)), stepped)


def resolve_stat(pilot: float, bonus: float, fractions: float, cap: float) -> int:
    whole = toward_zero(bonus)
    spare = quarter(bonus) - whole + quarter(fractions)
    return int(min(max(math.floor(quarter(pilot)) + whole + toward_zero(spare), 0), cap))


class VectorTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        standard = load(CATALOGUE_DIR / "standard.json")
        cls.weapons = {weapon["id"]: weapon for weapon in standard["weapons"]}
        cls.abilities = {ability["id"]: ability for ability in standard["abilities"]}
        cls.attacks = load(VECTORS / "attacks.json")["cases"]
        cls.stats = load(VECTORS / "stats.json")["cases"]

    def test_cases_are_unique_and_known(self):
        ids = [case["id"] for case in self.attacks]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertGreater(len(ids), 400)
        for case in self.attacks:
            self.assertIn(case["weapon"], self.weapons, case["id"])

    def test_situations_are_covered(self):
        cases = self.attacks
        self.assertTrue(any(c["situation"]["cover"] for c in cases))
        self.assertTrue(any(c["situation"]["charged"] for c in cases))
        self.assertTrue(any(c["situation"]["locked"] and c["situation"]["use_will"] for c in cases))
        self.assertTrue(any(c["expected"]["hit_target"] == 9 for c in cases), "upper limit")
        self.assertTrue(any(c["expected"]["hit_target"] == 1 for c in cases), "lower limit")
        self.assertTrue(any(0 < c["expected"]["p_destroy"] < 1 for c in cases))

    def test_targets_follow_from_inputs(self):
        for case in self.attacks:
            weapon = self.weapons[case["weapon"]]
            attacker, defender, situation, expected = case["attacker"], case["defender"], case["situation"], case["expected"]
            will = attacker["will"]
            push = 0
            if situation["push"] and "push" in attacker["abilities"] and will >= self.abilities["push"]["will_cost"]:
                push = self.abilities["push"]["amount"] // 10
                will -= self.abilities["push"]["will_cost"]
            raw = (5 + attacker["attack_rating"] - defender["reflex"] - situation["cover"] + weapon.get("aim_bonus", 0) // 10
                   + SIZE_ADJUSTMENT[defender["size_class"]] + (CHARGE_BONUS if situation["charged"] else 0) + push)
            hit = min(max(raw, 1), 9)
            self.assertEqual(expected["hit_target"], hit, case["id"])
            self.assertEqual(expected["pushed"], push > 0, case["id"])
            self.assertEqual(expected["crit_target"], attacker["precision"], case["id"])
            glance = hit + min(GLANCE_WINDOW, 10 - hit) if weapon.get("heavy") else None
            self.assertEqual(expected["glance_target"], glance, case["id"])
            matched = 2 if defender["armour_type"] == weapon.get("damage_type", "ballistic") else 0
            armour = max(0, defender["armour"] + matched - weapon.get("armour_piercing", 0))
            self.assertEqual(expected["armour"], armour, case["id"])
            self.assertEqual(expected["hit_damage"], max(0, weapon["damage"] - armour), case["id"])
            self.assertEqual(expected["crit_damage"], weapon["damage"], case["id"])
            self.assertEqual(expected["glance_damage"], max(0, weapon["damage"] // 2 - armour), case["id"])
            rerolls = LOCK_REROLLS if situation["locked"] else 0
            see_it = self.abilities["see_it"]
            if situation["use_will"] and "see_it" in attacker["abilities"] and will >= see_it["will_cost"]:
                rerolls += see_it["amount"]
            self.assertEqual(expected["rerolls"], rerolls, case["id"])
            for key in ["p_damage", "p_destroy"]:
                self.assertTrue(0 <= expected[key] <= 1, case["id"])
            self.assertLessEqual(expected["expected_damage"], weapon["shots"] * weapon["damage"] + 1e-6, case["id"])

    def test_stat_resolution(self):
        for case in self.stats:
            total = resolve_stat(case["pilot"], case["bonus"], case["fractions"], case["cap"])
            self.assertEqual(case["total"], total, case)


if __name__ == "__main__":
    unittest.main()
