"""Embed the catalogue in the combat sandbox page.

Writes tabletop/data/catalogue.json (built from the Frames and Weapons sheet by
tabletop/sheet_export.py) into tabletop/sandbox/combat-sandbox.html, between the marker
comments /* CATALOGUE:BEGIN */ and /* CATALOGUE:END */, as `const CATALOGUE = {...};`.
Whatever was between the markers is replaced, so running it twice changes nothing.

    py tabletop/sandbox/build.py           # update the page
    py tabletop/sandbox/build.py --check   # exit 1 if the page's catalogue is stale

Python 3.12 or later, standard library only.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
PAGE = HERE / "combat-sandbox.html"
CATALOGUE = HERE.parent / "data" / "catalogue.json"
BEGIN = "/* CATALOGUE:BEGIN */"
END = "/* CATALOGUE:END */"
PREFIX = "const CATALOGUE = "


def _dump(value) -> str:
    """Compact JSON that is also safe inside an inline <script>."""
    text = json.dumps(value, ensure_ascii=False, separators=(",", ":"))
    return text.replace("</", "<\\/").replace("\u2028", "\\u2028").replace("\u2029", "\\u2029")


def catalogue_js(catalogue: dict) -> str:
    """`const CATALOGUE = {...};` with one record per line, so a sheet change is a readable diff."""
    lines = [PREFIX + "{"]
    items = list(catalogue.items())
    for i, (key, value) in enumerate(items):
        comma = "," if i < len(items) - 1 else ""
        if isinstance(value, list):
            lines.append(f" {_dump(key)}: [")
            lines.extend(f"  {_dump(rec)}{',' if j < len(value) - 1 else ''}" for j, rec in enumerate(value))
            lines.append(f" ]{comma}")
        else:
            lines.append(f" {_dump(key)}: {_dump(value)}{comma}")
    lines.append("};")
    return "\n".join(lines)


def _span(page: str) -> tuple[int, int]:
    """Start and end of the text between the markers."""
    if page.count(BEGIN) != 1 or page.count(END) != 1:
        raise ValueError(f"the page must contain {BEGIN} and {END} exactly once each")
    start, end = page.index(BEGIN) + len(BEGIN), page.index(END)
    if end < start:
        raise ValueError(f"{END} comes before {BEGIN}")
    return start, end


def embed(page: str, catalogue: dict) -> str:
    """The page with the catalogue between the markers, in the page's own line endings."""
    start, end = _span(page)
    nl = "\r\n" if "\r\n" in page else "\n"
    return page[:start] + nl + catalogue_js(catalogue).replace("\n", nl) + nl + page[end:]


def extract(page: str) -> dict:
    """The catalogue embedded in the page."""
    start, end = _span(page)
    body = page[start:end].strip()
    if not body.startswith(PREFIX) or not body.endswith(";"):
        raise ValueError(f"expected `{PREFIX}{{...}};` between the markers")
    return json.loads(body[len(PREFIX):-1])


def main(argv: list[str]) -> int:
    check = "--check" in argv
    catalogue = json.loads(CATALOGUE.read_text(encoding="utf-8"))
    with PAGE.open(encoding="utf-8", newline="") as f:
        page = f.read()
    new = embed(page, catalogue)
    if new == page:
        print(f"{PAGE.name}: catalogue up to date ({len(catalogue['frames'])} frames, "
              f"{len(catalogue['weapons'])} weapons, {len(catalogue['protocols'])} Protocols)")
        return 0
    if check:
        print(f"{PAGE.name}: catalogue is stale; run py tabletop/sandbox/build.py")
        return 1
    with PAGE.open("w", encoding="utf-8", newline="") as f:
        f.write(new)
    print(f"{PAGE.name}: catalogue updated ({len(catalogue['frames'])} frames, "
          f"{len(catalogue['weapons'])} weapons, {len(catalogue['protocols'])} Protocols)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
