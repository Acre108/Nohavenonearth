"""The combat sandbox page: its built-in rules checks pass in node, and its catalogue is current."""

import importlib.util
import json
import shutil
import subprocess
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
SANDBOX = HERE / "sandbox"
PAGE = SANDBOX / "combat-sandbox.html"
CATALOGUE = HERE / "data" / "catalogue.json"


def load_build():
    spec = importlib.util.spec_from_file_location("sandbox_build", SANDBOX / "build.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


build = load_build()


def read_page():
    with PAGE.open(encoding="utf-8", newline="") as f:
        return f.read()


class RulesChecks(unittest.TestCase):
    def test_page_rules_checks_pass_in_node(self):
        node = shutil.which("node")
        if not node:
            self.skipTest("node is not installed: the sandbox's rules checks were not run")
        run = subprocess.run([node, str(SANDBOX / "run_checks.js"), str(PAGE)],
                             capture_output=True, text=True, encoding="utf-8", timeout=300)
        self.assertEqual(run.returncode, 0, f"sandbox rules checks failed:\n{run.stdout}\n{run.stderr}")
        self.assertIn("rules checks pass", run.stdout)


class EmbeddedCatalogue(unittest.TestCase):
    def test_page_catalogue_matches_catalogue_json(self):
        embedded = build.extract(read_page())
        current = json.loads(CATALOGUE.read_text(encoding="utf-8"))
        self.assertEqual(embedded, current, "the page's catalogue is stale: run py tabletop/sandbox/build.py")

    def test_build_is_idempotent(self):
        page = read_page()
        catalogue = json.loads(CATALOGUE.read_text(encoding="utf-8"))
        once = build.embed(page, catalogue)
        self.assertEqual(build.embed(once, catalogue), once)
        self.assertEqual(once, page, "the page differs from a fresh build: run py tabletop/sandbox/build.py")

    def test_embed_replaces_whatever_is_between_the_markers(self):
        page = f"a\n{build.BEGIN}\nconst CATALOGUE = {{}};\nold stuff\n{build.END}\nb"
        out = build.embed(page, {"frames": [{"id": "x", "name": "</script>"}]})
        self.assertNotIn("old stuff", out)
        self.assertNotIn("</script>", out)
        self.assertEqual(build.extract(out), {"frames": [{"id": "x", "name": "</script>"}]})
        self.assertTrue(out.startswith("a\n") and out.endswith("\nb"))

    def test_markers_must_appear_once(self):
        with self.assertRaises(ValueError):
            build.embed("no markers here", {})


if __name__ == "__main__":
    unittest.main()
