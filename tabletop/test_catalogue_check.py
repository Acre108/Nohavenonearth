"""The strict catalogue check accepts the shipped data and rejects the mistakes Godot let through."""

import copy
import json
import unittest

import catalogue_check
from catalogue_check import CATALOGUE_DIR, check_all


def load(name: str) -> dict:
    return json.loads((CATALOGUE_DIR / name).read_text(encoding="utf-8"))


class CatalogueCheckTest(unittest.TestCase):
    def errors_with(self, name: str, change) -> list[str]:
        data = copy.deepcopy(load(name))
        change(data)
        return check_all(override={name: data})

    def assertRejected(self, name: str, change, fragment: str) -> None:
        errors = self.errors_with(name, change)
        self.assertTrue(any(fragment in message for message in errors), "%r not in %s" % (fragment, errors))

    def test_shipped_catalogues_pass(self):
        self.assertEqual(check_all(), [])

    def test_unknown_keys_are_errors(self):
        self.assertRejected("standard.json", lambda d: d["frames"][0].update(armor=3), "unknown key: armor")
        self.assertRejected("standard.json", lambda d: d.update(weapon=[]), "unknown section: weapon")
        self.assertRejected("teamster_workshop.json", lambda d: d["parts"][0]["bonuses"].update(armor=1), "unknown key: armor")
        self.assertRejected("costs.json", lambda d: d["frame"].update(armor_per_point=4), "unknown key: armor_per_point")
        self.assertRejected("workshop_pilots.json", lambda d: d["pilots"][0].update(callsing="X"), "unknown key: callsing")

    def test_types(self):
        self.assertRejected("standard.json", lambda d: d["weapons"][0].update(shots=2.5), "shots must be a whole number")
        self.assertRejected("standard.json", lambda d: d["weapons"][0].update(heavy=1), "heavy must be true or false")
        self.assertRejected("standard.json", lambda d: d["weapons"][0].update(damage_type="laser"), "damage_type must be one of")
        self.assertRejected("standard.json", lambda d: d["weapons"][0].pop("damage"), "missing damage")

    def test_godot_validator_rules(self):
        self.assertRejected("standard.json", lambda d: d["weapons"].append(copy.deepcopy(d["weapons"][0])), "Duplicate weapons id")
        self.assertRejected("standard.json", lambda d: d["frames"][0]["manoeuvres"].append("missing_move"), "references unknown id: missing_move")
        self.assertRejected("standard.json", lambda d: d["weapons"][0].update(aim_bonus=5), "multiple of 10")
        self.assertRejected("standard.json", lambda d: d["frames"][0]["stat_max"].pop("reflex"), "stat_max is missing reflex")
        self.assertRejected("standard.json", lambda d: d["frames"][0]["stat_bonuses"].update(spirit=1), "pilot-only stat")
        self.assertRejected("standard.json", lambda d: d["pilots"][0]["stats"].update(gunnery=5), "whole number up to 4")
        self.assertRejected("standard.json", lambda d: d["frames"][1].update(default_melee="lr3_rifle"), "must name a melee weapon")

    def test_workshop_references(self):
        self.assertRejected("teamster_workshop.json", lambda d: d["parts"][0].update(manufacturer="acme"), "unknown manufacturer: acme")
        self.assertRejected("teamster_workshop.json", lambda d: d["parts"][0].update(family="m9_wing"), "fits no slot: m9_wing")
        self.assertRejected("teamster_workshop.json", lambda d: d["regions"][0]["slots"][0].update(standard="missing"), "standard part must be")
        self.assertRejected("kestrel_workshop.json", lambda d: d.update(default_pilot="nobody"), "not a workshop pilot")
        self.assertRejected("kestrel_workshop.json", lambda d: d["stock_arm_weapons"].update({"right_arm.actuator": "railgun"}), "unknown slot or weapon")

    def test_every_ability_has_a_cost(self):
        self.assertRejected("costs.json", lambda d: d["pilot"]["ability"].pop("see_it"), "missing see_it")


if __name__ == "__main__":
    unittest.main()
