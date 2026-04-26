#!/usr/bin/env python3
"""
validate-drawio.py — XML structure validator for draw.io (.drawio) files.

Usage:
    python validate-drawio.py <file.drawio> [--strict]

Exit codes:
    0  All checks passed
    1  One or more errors found
"""

import sys
import argparse
import re
from xml.etree import ElementTree as ET

# Semantic color palette (fillColor values)
SEMANTIC_FILL_COLORS = {
    "#dae8fc",  # primary
    "#d5e8d4",  # success
    "#fff2cc",  # warning
    "#f8cecc",  # error
    "#f5f5f5",  # neutral
    "#e1d5e7",  # external
    "none",
    "#ffffff",
    "#000000",
}

ERRORS = []
WARNINGS = []


def error(msg):
    ERRORS.append(msg)
    print(f"  ❌ ERROR: {msg}")


def warn(msg):
    WARNINGS.append(msg)
    print(f"  ⚠️  WARN:  {msg}")


def ok(msg):
    print(f"  ✅ OK:    {msg}")


def parse_style(style_str):
    """Parse a draw.io style string into a dict."""
    result = {}
    if not style_str:
        return result
    for part in style_str.split(";"):
        part = part.strip()
        if not part:
            continue
        if "=" in part:
            key, _, val = part.partition("=")
            result[key.strip()] = val.strip()
        else:
            result[part] = True
    return result


def validate_drawio(filepath, strict=False):
    print(f"\n🔍 Validating: {filepath}")
    print("-" * 60)

    # --- 1. Parse XML ---
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()
        ok("XML parses without errors")
    except ET.ParseError as exc:
        error(f"XML parse failure: {exc}")
        return

    # Support both bare <mxGraphModel> and <mxfile><diagram><mxGraphModel>
    graphs = []
    if root.tag == "mxGraphModel":
        graphs.append(("(single page)", root))
    elif root.tag == "mxfile":
        for diagram in root.findall("diagram"):
            name = diagram.get("name", "(unnamed)")
            # Diagram content may be compressed (Base64+deflate) or plain XML
            model = diagram.find("mxGraphModel")
            if model is not None:
                graphs.append((name, model))
            else:
                # Content is compressed — skip deep validation, just note it
                warn(f"Page '{name}' uses compressed XML — skipping deep validation")
    else:
        error(f"Unexpected root element: <{root.tag}>. Expected <mxGraphModel> or <mxfile>.")
        return

    for page_name, model in graphs:
        print(f"\n  📄 Page: {page_name}")
        validate_graph_model(model, page_name, strict)


def validate_graph_model(model, page_name, strict):
    root_el = model.find("root")
    if root_el is None:
        error(f"[{page_name}] Missing <root> element inside <mxGraphModel>")
        return
    ok(f"[{page_name}] <root> element present")

    cells = root_el.findall("mxCell")
    if not cells:
        error(f"[{page_name}] No <mxCell> elements found inside <root>")
        return

    # --- 2. Check id=0 and id=1 ---
    if len(cells) < 2:
        error(f"[{page_name}] Need at least 2 cells (id=0 and id=1), found {len(cells)}")
        return

    cell0 = cells[0]
    cell1 = cells[1]

    if cell0.get("id") != "0":
        error(f"[{page_name}] First cell must have id=\"0\", got id=\"{cell0.get('id')}\"")
    else:
        ok(f"[{page_name}] First cell has id=\"0\"")

    if cell1.get("id") != "1":
        error(f"[{page_name}] Second cell must have id=\"1\", got id=\"{cell1.get('id')}\"")
    else:
        ok(f"[{page_name}] Second cell has id=\"1\"")

    if cell1.get("parent") != "0":
        error(f"[{page_name}] Cell id=\"1\" must have parent=\"0\", got parent=\"{cell1.get('parent')}\"")
    else:
        ok(f"[{page_name}] Cell id=\"1\" has parent=\"0\"")

    # --- 3. Collect all IDs ---
    all_ids = set()
    duplicate_ids = []

    for cell in cells:
        cid = cell.get("id")
        if cid is None:
            error(f"[{page_name}] Found a <mxCell> with no id attribute")
            continue
        if cid in all_ids:
            duplicate_ids.append(cid)
        all_ids.add(cid)

    if duplicate_ids:
        for dup in duplicate_ids:
            error(f"[{page_name}] Duplicate cell id: \"{dup}\"")
    else:
        ok(f"[{page_name}] All {len(cells)} cell IDs are unique")

    # --- 4. Validate vertices have mxGeometry ---
    missing_geometry = []
    for cell in cells:
        if cell.get("vertex") == "1":
            geo = cell.find("mxGeometry")
            if geo is None:
                missing_geometry.append(cell.get("id", "(no-id)"))

    if missing_geometry:
        for cid in missing_geometry:
            error(f"[{page_name}] Vertex cell id=\"{cid}\" is missing <mxGeometry>")
    else:
        ok(f"[{page_name}] All vertex cells have <mxGeometry>")

    # --- 5. Validate edges reference valid cell IDs ---
    invalid_refs = []
    for cell in cells:
        if cell.get("edge") == "1":
            src = cell.get("source")
            tgt = cell.get("target")
            cid = cell.get("id", "(no-id)")
            if src and src not in all_ids:
                invalid_refs.append(f"edge id=\"{cid}\" has source=\"{src}\" which does not exist")
            if tgt and tgt not in all_ids:
                invalid_refs.append(f"edge id=\"{cid}\" has target=\"{tgt}\" which does not exist")

    if invalid_refs:
        for ref in invalid_refs:
            error(f"[{page_name}] {ref}")
    else:
        ok(f"[{page_name}] All edge source/target references are valid")

    # --- 6. Validate parent references ---
    bad_parents = []
    for cell in cells:
        cid = cell.get("id")
        if cid in ("0", "1"):
            continue
        parent = cell.get("parent")
        if parent and parent not in all_ids:
            bad_parents.append(f"cell id=\"{cid}\" has parent=\"{parent}\" which does not exist")

    if bad_parents:
        for bp in bad_parents:
            error(f"[{page_name}] {bp}")
    else:
        ok(f"[{page_name}] All parent references are valid")

    # --- 7. Strict mode checks ---
    if strict:
        print(f"\n  🔬 Strict mode checks for page: {page_name}")
        _strict_checks(cells, all_ids, page_name)


def _strict_checks(cells, all_ids, page_name):
    """Additional strict checks: grid alignment and semantic color palette."""
    non_grid = []
    unknown_colors = []

    for cell in cells:
        cid = cell.get("id")
        if cid in ("0", "1"):
            continue

        # Grid alignment: x, y, width, height should be multiples of 10
        geo = cell.find("mxGeometry")
        if geo is not None:
            for attr in ("x", "y", "width", "height"):
                val = geo.get(attr)
                if val is not None:
                    try:
                        num = float(val)
                        remainder = num % 10
                        if remainder > 0.01 and remainder < 9.99:
                            non_grid.append(
                                f"cell id=\"{cid}\" geometry {attr}={val} is not a multiple of 10"
                            )
                    except ValueError:
                        pass

        # Semantic color palette
        style_str = cell.get("style", "")
        style = parse_style(style_str)
        fill = style.get("fillColor")
        if fill and fill.lower() not in SEMANTIC_FILL_COLORS:
            unknown_colors.append(
                f"cell id=\"{cid}\" uses non-semantic fillColor=\"{fill}\""
            )

    if non_grid:
        for msg in non_grid:
            warn(f"[{page_name}] [strict] {msg}")
    else:
        ok(f"[{page_name}] [strict] All geometry coordinates are multiples of 10")

    if unknown_colors:
        for msg in unknown_colors:
            warn(f"[{page_name}] [strict] {msg}")
    else:
        ok(f"[{page_name}] [strict] All fillColors are in the semantic palette")


def main():
    parser = argparse.ArgumentParser(
        description="Validate a draw.io (.drawio) XML file for structural correctness.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python validate-drawio.py diagram.drawio
  python validate-drawio.py diagram.drawio --strict
        """,
    )
    parser.add_argument("file", help="Path to the .drawio file to validate")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Also check grid alignment (multiples of 10) and semantic color palette",
    )
    args = parser.parse_args()

    validate_drawio(args.file, strict=args.strict)

    print("\n" + "=" * 60)
    if ERRORS:
        print(f"❌ Validation FAILED: {len(ERRORS)} error(s), {len(WARNINGS)} warning(s)")
        sys.exit(1)
    elif WARNINGS:
        print(f"⚠️  Validation passed with {len(WARNINGS)} warning(s)")
        sys.exit(0)
    else:
        print("✅ Validation PASSED — no errors or warnings")
        sys.exit(0)


if __name__ == "__main__":
    main()
