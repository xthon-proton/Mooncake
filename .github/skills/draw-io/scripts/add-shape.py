#!/usr/bin/env python3
"""
add-shape.py — Add a new shape (mxCell vertex) to an existing draw.io file.

Usage:
    python add-shape.py <file.drawio> \\
        --label "My Shape" \\
        --type process|decision|start|end|swimlane \\
        --x 100 --y 200 \\
        [--width 160] [--height 60] \\
        [--page "Page Name or index (default: first page)"] \\
        [--color primary|success|warning|error|neutral|external]

Examples:
    python add-shape.py diagram.drawio --label "Load Data" --type process --x 200 --y 300
    python add-shape.py diagram.drawio --label "Error?" --type decision --x 400 --y 400 --color warning
    python add-shape.py diagram.drawio --label "Start" --type start --x 100 --y 100 --color success
"""

import sys
import argparse
import uuid
from xml.etree import ElementTree as ET

# --- Semantic color palette ---
COLOR_PALETTE = {
    "primary":  {"fillColor": "#dae8fc", "strokeColor": "#6c8ebf"},
    "success":  {"fillColor": "#d5e8d4", "strokeColor": "#82b366"},
    "warning":  {"fillColor": "#fff2cc", "strokeColor": "#d6b656"},
    "error":    {"fillColor": "#f8cecc", "strokeColor": "#b85450"},
    "neutral":  {"fillColor": "#f5f5f5", "strokeColor": "#666666"},
    "external": {"fillColor": "#e1d5e7", "strokeColor": "#9673a6"},
}

# Default colors per shape type
TYPE_DEFAULT_COLOR = {
    "process":  "primary",
    "decision": "warning",
    "start":    "success",
    "end":      "error",
    "swimlane": "neutral",
}

# Default geometry per shape type
TYPE_DEFAULT_GEOMETRY = {
    "process":  (160, 60),
    "decision": (160, 80),
    "start":    (60, 60),
    "end":      (60, 60),
    "swimlane": (320, 120),
}


def build_style(shape_type, color_name):
    """Return the mxGraph style string for the given type and color."""
    colors = COLOR_PALETTE[color_name]
    fill = colors["fillColor"]
    stroke = colors["strokeColor"]

    if shape_type == "process":
        return (
            f"rounded=1;whiteSpace=wrap;html=1;"
            f"fillColor={fill};strokeColor={stroke};"
        )
    elif shape_type == "decision":
        return (
            f"rhombus;whiteSpace=wrap;html=1;"
            f"fillColor={fill};strokeColor={stroke};"
        )
    elif shape_type == "start":
        return (
            f"ellipse;whiteSpace=wrap;html=1;aspect=fixed;"
            f"fillColor={fill};strokeColor={stroke};"
        )
    elif shape_type == "end":
        return (
            f"ellipse;whiteSpace=wrap;html=1;aspect=fixed;strokeWidth=3;"
            f"fillColor={fill};strokeColor={stroke};"
        )
    elif shape_type == "swimlane":
        return (
            f"swimlane;whiteSpace=wrap;html=1;fontStyle=1;startSize=30;"
            f"fillColor={fill};strokeColor={stroke};"
        )
    else:
        return (
            f"rounded=1;whiteSpace=wrap;html=1;"
            f"fillColor={fill};strokeColor={stroke};"
        )


def generate_id():
    """Generate a unique cell ID using UUID4."""
    return str(uuid.uuid4())


def get_root_element(model_el):
    """Return the <root> child of an <mxGraphModel> element."""
    root_el = model_el.find("root")
    if root_el is None:
        raise ValueError("<mxGraphModel> has no <root> child element")
    return root_el


def find_model(tree_root, page):
    """
    Find the <mxGraphModel> element for the requested page.
    page: None or int index → first page / index
          str → match by diagram name
    Returns (model_element, page_name)
    """
    if tree_root.tag == "mxGraphModel":
        # Single-page bare file
        return tree_root, "(single page)"

    if tree_root.tag == "mxfile":
        diagrams = tree_root.findall("diagram")
        if not diagrams:
            raise ValueError("No <diagram> elements found in <mxfile>")

        # Resolve page selector
        if page is None or page == "0" or page == 0:
            target_diagram = diagrams[0]
        else:
            # Try as integer index
            try:
                idx = int(page)
                target_diagram = diagrams[idx]
            except (ValueError, IndexError):
                # Try as name match
                matched = [d for d in diagrams if d.get("name") == page]
                if not matched:
                    names = [d.get("name", f"[{i}]") for i, d in enumerate(diagrams)]
                    raise ValueError(
                        f"Page '{page}' not found. Available pages: {names}"
                    )
                target_diagram = matched[0]

        page_name = target_diagram.get("name", "(unnamed)")
        model = target_diagram.find("mxGraphModel")
        if model is None:
            raise ValueError(
                f"Page '{page_name}' uses compressed XML (not editable by this script). "
                "Save the file as uncompressed XML in draw.io first."
            )
        return model, page_name

    raise ValueError(
        f"Unexpected root element <{tree_root.tag}>. Expected <mxGraphModel> or <mxfile>."
    )


def add_shape(filepath, label, shape_type, x, y, width, height, color, page):
    """Parse the file, add the shape, and write back."""

    try:
        tree = ET.parse(filepath)
    except ET.ParseError as exc:
        print(f"❌ Failed to parse XML: {exc}", file=sys.stderr)
        sys.exit(1)

    tree_root = tree.getroot()

    try:
        model, page_name = find_model(tree_root, page)
    except ValueError as exc:
        print(f"❌ {exc}", file=sys.stderr)
        sys.exit(1)

    root_el = get_root_element(model)

    # Resolve color
    resolved_color = color or TYPE_DEFAULT_COLOR.get(shape_type, "primary")
    if resolved_color not in COLOR_PALETTE:
        print(
            f"❌ Unknown color '{resolved_color}'. "
            f"Valid options: {', '.join(COLOR_PALETTE.keys())}",
            file=sys.stderr,
        )
        sys.exit(1)

    # Resolve geometry defaults
    default_w, default_h = TYPE_DEFAULT_GEOMETRY.get(shape_type, (160, 60))
    final_width = width if width is not None else default_w
    final_height = height if height is not None else default_h

    # Build style string
    style = build_style(shape_type, resolved_color)

    # Generate unique cell ID
    new_id = generate_id()

    # Create new <mxCell> element
    new_cell = ET.Element("mxCell")
    new_cell.set("id", new_id)
    new_cell.set("value", label)
    new_cell.set("style", style)
    new_cell.set("vertex", "1")
    new_cell.set("parent", "1")

    geo = ET.SubElement(new_cell, "mxGeometry")
    geo.set("x", str(x))
    geo.set("y", str(y))
    geo.set("width", str(final_width))
    geo.set("height", str(final_height))
    geo.set("as", "geometry")

    # Insert before </root>
    root_el.append(new_cell)

    # Serialize to a string in memory, then write atomically to avoid race conditions
    import io
    import re as _re

    buf = io.StringIO()
    tree.write(buf, encoding="unicode", xml_declaration=True)
    content = buf.getvalue()

    # Normalise XML declaration to UTF-8 (ET may emit 'us-ascii' or vary the quoting)
    content = _re.sub(
        r"<\?xml[^?]*\?>",
        '<?xml version="1.0" encoding="UTF-8"?>',
        content,
        count=1,
    )

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

    print(
        f'✅ Added shape "{label}" (type={shape_type}, color={resolved_color}, '
        f'id={new_id}) to "{filepath}" page "{page_name}"'
    )


def main():
    parser = argparse.ArgumentParser(
        description="Add a new shape to an existing draw.io file.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Shape types:
  process    Rounded rectangle (primary blue by default)
  decision   Diamond (warning yellow by default)
  start      Circle (success green by default)
  end        Double-stroke circle (error red by default)
  swimlane   Swimlane container (neutral grey by default)

Color options (semantic palette):
  primary    #dae8fc fill, #6c8ebf stroke
  success    #d5e8d4 fill, #82b366 stroke
  warning    #fff2cc fill, #d6b656 stroke
  error      #f8cecc fill, #b85450 stroke
  neutral    #f5f5f5 fill, #666666 stroke
  external   #e1d5e7 fill, #9673a6 stroke

Examples:
  python add-shape.py diagram.drawio --label "Load Data" --type process --x 200 --y 300
  python add-shape.py diagram.drawio --label "Error?" --type decision --x 400 --y 400 --color warning
  python add-shape.py diagram.drawio --label "Start" --type start --x 100 --y 100
  python add-shape.py diagram.drawio --label "Auth Service" --type process --x 300 --y 200 \\
      --page "Architecture" --color external
        """,
    )
    parser.add_argument("file", help="Path to the .drawio file to modify")
    parser.add_argument("--label", required=True, help="Label text for the new shape")
    parser.add_argument(
        "--type",
        dest="shape_type",
        required=True,
        choices=["process", "decision", "start", "end", "swimlane"],
        help="Shape type",
    )
    parser.add_argument("--x", type=float, required=True, help="X coordinate (pixels)")
    parser.add_argument("--y", type=float, required=True, help="Y coordinate (pixels)")
    parser.add_argument("--width", type=float, default=None, help="Width in pixels (default: per type)")
    parser.add_argument("--height", type=float, default=None, help="Height in pixels (default: per type)")
    parser.add_argument(
        "--page",
        default=None,
        help="Page name or 0-based index (default: first page)",
    )
    parser.add_argument(
        "--color",
        default=None,
        choices=list(COLOR_PALETTE.keys()),
        help="Semantic color role (default: per shape type)",
    )

    args = parser.parse_args()

    add_shape(
        filepath=args.file,
        label=args.label,
        shape_type=args.shape_type,
        x=args.x,
        y=args.y,
        width=args.width,
        height=args.height,
        color=args.color,
        page=args.page,
    )


if __name__ == "__main__":
    main()
