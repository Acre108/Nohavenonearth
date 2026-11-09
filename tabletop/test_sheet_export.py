import copy
import json
import unittest

import sheet_export as se


def load_snapshot():
    return json.loads(se.SNAPSHOT.read_text(encoding="utf-8"))


def col(rows, name):
    return rows[0].index(name)


def find_row(rows, first_cell):
    for i, row in enumerate(rows):
        if row and row[0] == first_cell:
            return i
    raise KeyError(first_cell)


class CommittedSnapshot(unittest.TestCase):
    def test_snapshot_builds_without_errors(self):
        catalogue, p = se.build_catalogue(load_snapshot())
        self.assertEqual(p.errors, [])
        self.assertGreater(len(catalogue["frames"]), 0)

    def test_catalogue_matches_snapshot(self):
        catalogue, _ = se.build_catalogue(load_snapshot())
        committed = json.loads(se.CATALOGUE.read_text(encoding="utf-8"))
        self.assertEqual(committed, catalogue, "run py tabletop/sheet_export.py to rebuild the catalogue")

    def test_known_values(self):
        catalogue, _ = se.build_catalogue(load_snapshot())
        frames = {f["id"]: f for f in catalogue["frames"]}
        weapons = {w["id"]: w for w in catalogue["weapons"]}
        garrison = frames["m4_garrison"]
        self.assertEqual(garrison["limits"]["reflex"], 6)
        self.assertEqual(garrison["weapons"], ["m30_hand_cannon", "pb1_pile_bunker"])
        self.assertEqual(frames["hx7_kestrel"]["protocols"], ["sensor_link", "target_painter"])
        self.assertEqual(frames["ob12_medved"]["tags"], {"cm_field": 2})
        self.assertEqual(weapons["type09_long_cannon"]["tags"], {"on_hit": "stagger"})
        self.assertTrue(weapons["lr1_linear_rifle"]["heavy"])


class Checks(unittest.TestCase):
    def setUp(self):
        self.snap = copy.deepcopy(load_snapshot())
        self.frames = self.snap["tabs"]["Frames"]
        self.weapons = self.snap["tabs"]["Weapons"]
        self.protocols = self.snap["tabs"]["Protocols"]

    def errors(self):
        _, p = se.build_catalogue(self.snap)
        return "\n".join(p.errors)

    def set_cell(self, rows, first_cell, column, value):
        row = rows[find_row(rows, first_cell)]
        c = col(rows, column)
        while len(row) <= c:
            row.append("")
        row[c] = value

    def test_duplicate_id(self):
        self.set_cell(self.weapons, "LR-1 Linear Rifle", "ID", "m30_hand_cannon")
        self.assertIn("also used by", self.errors())

    def test_bad_id(self):
        self.set_cell(self.frames, "M4 Garrison", "ID", "M4 Garrison")
        self.assertIn("lower case", self.errors())

    def test_unknown_tag(self):
        self.set_cell(self.frames, "M4 Garrison", "Tags", "jump_jets")
        self.assertIn("unknown tag 'jump_jets'", self.errors())

    def test_tag_value(self):
        self.set_cell(self.frames, "M4 Garrison", "Tags", "cm_field:big")
        self.assertIn("needs a whole number", self.errors())
        self.set_cell(self.frames, "M4 Garrison", "Tags", "")
        self.set_cell(self.weapons, "M30 Hand Cannon", "Tags", "on_hit:melt")
        self.assertIn("is not one of", self.errors())

    def test_missing_weapon(self):
        self.set_cell(self.frames, "M4 Garrison", "Weapon 1", "M31 Hand Cannon")
        self.assertIn("not on the Weapons tab", self.errors())

    def test_protocol_count(self):
        self.set_cell(self.frames, "HX-7 Kestrel", "Protocol list", "sensor_link")
        self.assertIn("Protocols column says 2", self.errors())

    def test_unknown_protocol(self):
        self.set_cell(self.frames, "OB-12 Medved", "Protocol list", "purgatory")
        self.assertIn("not on the Protocols tab", self.errors())

    def test_gen1_protocols(self):
        self.set_cell(self.frames, "M4 Garrison", "Protocols", "1")
        self.set_cell(self.frames, "M4 Garrison", "Protocol list", "jam")
        self.assertIn("Gen 1 frames carry no Protocols", self.errors())

    def test_not_a_number(self):
        self.set_cell(self.weapons, "M30 Hand Cannon", "Damage", "7a")
        self.assertIn("not a whole number", self.errors())

    def test_enum(self):
        self.set_cell(self.weapons, "M30 Hand Cannon", "Arc", "Wide")
        self.assertIn("Arc 'Wide'", self.errors())

    def test_difficulty_modifier(self):
        self.set_cell(self.protocols, "jam", "Modifier", "2")
        self.assertIn("does not match Standard", self.errors())

    def test_missing_column(self):
        header = self.weapons[0]
        header[col(self.weapons, "ID")] = "Id"
        self.assertIn("missing column 'ID'", self.errors())


if __name__ == "__main__":
    unittest.main()
