# draw.io XML Schema Reference

Complete attribute reference for `<mxGraphModel>`, `<root>`, `<mxCell>`, and `<mxGeometry>` elements.

---

## `<mxGraphModel>` Attributes

The root XML element that wraps the entire diagram.

| Attribute | Type | Default | Description |
|---|---|---|---|
| `dx` | integer | `1422` | Horizontal translation of the diagram viewport |
| `dy` | integer | `762` | Vertical translation of the diagram viewport |
| `grid` | `0` or `1` | `1` | Enable/disable the background grid |
| `gridSize` | integer | `10` | Grid cell size in pixels |
| `guides` | `0` or `1` | `1` | Enable/disable alignment guides |
| `tooltips` | `0` or `1` | `1` | Enable/disable cell tooltips on hover |
| `connect` | `0` or `1` | `1` | Enable/disable connection points on hover |
| `arrows` | `0` or `1` | `1` | Enable/disable arrow rendering on edges |
| `fold` | `0` or `1` | `1` | Enable/disable container collapse/expand |
| `page` | `0` or `1` | `1` | Enable/disable the page border |
| `pageScale` | float | `1` | Scale factor for the page |
| `pageWidth` | integer | `1169` | Page width in pixels (A4 landscape = 1169) |
| `pageHeight` | integer | `827` | Page height in pixels (A4 landscape = 827) |
| `math` | `0` or `1` | `0` | Enable LaTeX/MathJax rendering in labels |
| `shadow` | `0` or `1` | `0` | Enable global drop shadows |
| `background` | `#rrggbb` | (none) | Page background color |

**Minimal valid example:**
```xml
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
```

---

## `<root>` Element

Direct child of `<mxGraphModel>`. Contains all `<mxCell>` elements. No attributes.

**Rules:**
- Must contain exactly one `<mxCell id="0"/>` as the first child
- Must contain exactly one `<mxCell id="1" parent="0"/>` as the second child
- All other cells follow after these two

---

## `<mxCell>` Attributes

Each shape, edge, label, or container is an `<mxCell>` element.

| Attribute | Type | Required | Description |
|---|---|---|---|
| `id` | string | **Yes** | Unique identifier within the diagram. Must be unique. Reserved: `"0"`, `"1"`. |
| `parent` | string | **Yes** | ID of the parent cell. Top-level cells use `parent="1"`. Children of a container use the container's `id`. |
| `value` | string | No | Label text displayed inside the shape. Supports HTML when `html=1` in style. Use `&lt;`, `&gt;`, `&amp;` for XML special chars. |
| `style` | string | No | Semicolon-separated key=value style string. See style reference. |
| `vertex` | `"1"` | Conditional | Must be `"1"` for shapes (nodes). Cannot be used with `edge`. |
| `edge` | `"1"` | Conditional | Must be `"1"` for connectors. Cannot be used with `vertex`. |
| `source` | string | For edges | ID of the source vertex cell. |
| `target` | string | For edges | ID of the target vertex cell. |
| `connectable` | `"0"` | No | When `"0"`, the cell cannot be the endpoint of a connection. |
| `tooltip` | string | No | Tooltip text shown on hover (requires `tooltips="1"` on model). |

**Vertex cell example:**
```xml
<mxCell id="my-node" value="My Label" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="160" height="60" as="geometry"/>
</mxCell>
```

**Edge cell example:**
```xml
<mxCell id="my-edge" value="label" style="endArrow=block;endFill=1;" edge="1" source="node-a" target="node-b" parent="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

---

## `<mxGeometry>` Attributes

Child element of `<mxCell>`. Defines position, size, and path for vertices and edges.

| Attribute | Type | Required | Description |
|---|---|---|---|
| `x` | float | For vertices | X coordinate of the top-left corner (pixels from origin) |
| `y` | float | For vertices | Y coordinate of the top-left corner (pixels from origin) |
| `width` | float | For vertices | Width of the shape in pixels |
| `height` | float | For vertices | Height of the shape in pixels |
| `relative` | `"1"` | For edges | Must be `"1"` for edge geometry. Positions are relative to the edge. |
| `as` | `"geometry"` | **Yes** | Must always be `"geometry"` — this is the attribute name in the parent cell |

**Vertex geometry example:**
```xml
<mxGeometry x="80" y="120" width="160" height="60" as="geometry"/>
```

**Edge geometry example (no waypoints):**
```xml
<mxGeometry relative="1" as="geometry"/>
```

**Edge geometry with waypoints:**
```xml
<mxGeometry relative="1" as="geometry">
  <Array as="points">
    <mxPoint x="300" y="200"/>
    <mxPoint x="300" y="400"/>
  </Array>
</mxGeometry>
```

**Edge geometry with label position:**
```xml
<mxGeometry x="-0.1" y="10" relative="1" as="geometry">
  <mxPoint as="offset"/>
</mxGeometry>
```

---

## `<mxPoint>` Attributes

Used inside `<mxGeometry>` for fixed source/target points or waypoints.

| Attribute | Type | Description |
|---|---|---|
| `x` | float | X coordinate in pixels |
| `y` | float | Y coordinate in pixels |
| `as` | `"sourcePoint"`, `"targetPoint"`, `"offset"` | Role of this point |

**Fixed endpoint example (for edges without source/target cells):**
```xml
<mxGeometry relative="1" as="geometry">
  <mxPoint x="100" y="200" as="sourcePoint"/>
  <mxPoint x="400" y="200" as="targetPoint"/>
</mxGeometry>
```

---

## `<Array>` Element

Used inside `<mxGeometry>` to specify edge waypoints.

| Attribute | Value | Description |
|---|---|---|
| `as` | `"points"` | Identifies this array as the waypoints list |

Contains one or more `<mxPoint>` children.

---

## Multi-Page Diagrams

To create a multi-page `.drawio` file, wrap multiple `<mxGraphModel>` elements in a `<mxfile>` root element:

```xml
<mxfile host="app.diagrams.net">
  <diagram name="Page 1" id="page-1-id">
    <mxGraphModel ...>
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- page 1 cells -->
      </root>
    </mxGraphModel>
  </diagram>
  <diagram name="Page 2" id="page-2-id">
    <mxGraphModel ...>
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- page 2 cells -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

**Notes on multi-page files:**
- Each `<diagram>` element must have a unique `id` and a human-readable `name`
- Cell IDs only need to be unique within the same `<diagram>` (page), not across pages
- The `<mxfile>` root element may include `host`, `modified`, `agent`, `version`, and `type` attributes — these are metadata only

---

## Cell ID Conventions

| Convention | Example | When to Use |
|---|---|---|
| Semantic names | `start`, `db-primary`, `tier-client` | Small diagrams, easy to read |
| UUID v4 | `a3f2c1d0-...` | Large diagrams, generated by tools |
| Incremental integers | `2`, `3`, `4` | Auto-generated, avoid manually |

**Reserved IDs** (never use for your own cells):
- `"0"` — the root cell (no parent, no style)
- `"1"` — the default layer (parent=0)
