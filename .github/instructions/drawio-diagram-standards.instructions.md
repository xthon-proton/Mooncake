---
description: "Use when creating, editing, or reviewing draw.io diagrams and mxGraph XML in .drawio, .drawio.svg, or .drawio.png files."
applyTo: "**/*.drawio,**/*.drawio.svg,**/*.drawio.png"
---

# draw.io Diagram Standards

> **Skill**: Load `.github/skills/draw-io/SKILL.md` for full workflow, XML recipes, and troubleshooting before generating or editing any `.drawio` file.

---

## Required Workflow

Follow these steps for every draw.io task:

1. **Identify** the diagram type (flowchart / architecture / sequence / ER / UML / network / BPMN)
2. **Select** the matching template from `.github/skills/draw-io/templates/` and adapt it, or start from the minimal skeleton
3. **Plan** the layout on paper before writing XML — define tiers, actors, or entities first
4. **Generate** valid mxGraph XML following the rules below
5. **Validate** using `python .github/skills/draw-io/scripts/validate-drawio.py <file>`
6. **Confirm** the file renders by opening it in VS Code with the draw.io extension (`hediet.vscode-drawio`)

---

## XML Structure Rules (Non-Negotiable)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- your cells here, all with parent="1" unless nested -->
  </root>
</mxGraphModel>
```

- `id="0"` and `id="1"` **must** be present and must be the first two cells — no exceptions
- Every cell `id` must be **unique** within the diagram
- Every vertex (`vertex="1"`) must have a child `<mxGeometry ... as="geometry"/>` element
- Every edge (`edge="1"`) must have `source` and `target` attributes referencing valid cell ids
- All coordinates must be multiples of 10 (grid-aligned)
- The `parent` attribute of top-level cells must be `"1"`

---

## Semantic Color Palette

| Role | Fill Color | Stroke Color | Usage |
|---|---|---|---|
| `primary` | `#dae8fc` | `#6c8ebf` | Main process steps, primary actors |
| `success` | `#d5e8d4` | `#82b366` | Success states, positive outcomes |
| `warning` | `#fff2cc` | `#d6b656` | Warnings, decisions, branch points |
| `error` | `#f8cecc` | `#b85450` | Error states, failures |
| `neutral` | `#f5f5f5` | `#666666` | Notes, annotations, secondary elements |
| `external` | `#e1d5e7` | `#9673a6` | External systems, third-party services |

---

## Shape Style Quick Reference

| Shape Type | Style String |
|---|---|
| Process (rectangle) | `rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;` |
| Decision (diamond) | `rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;` |
| Start (circle) | `ellipse;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;aspect=fixed;` |
| End (double circle) | `ellipse;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;aspect=fixed;strokeWidth=3;` |
| Swimlane | `swimlane;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontStyle=1;` |
| Database | `shape=mxgraph.flowchart.database;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;` |
| Actor | `shape=mxgraph.archimate3.actor;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;` |

---

## Reference Files

| File | Use For |
|---|---|
| `.github/skills/draw-io/SKILL.md` | Full agent workflow, recipes, troubleshooting |
| `.github/skills/draw-io/references/drawio-xml-schema.md` | Complete mxCell attribute reference |
| `.github/skills/draw-io/references/style-reference.md` | All style keys, shape names, edge types |
| `.github/skills/draw-io/references/shape-libraries.md` | Shape library catalog with style strings |
| `.github/skills/draw-io/templates/` | Ready-to-use `.drawio` templates per diagram type |
| `.github/skills/draw-io/scripts/validate-drawio.py` | XML structure validator |
| `.github/skills/draw-io/scripts/add-shape.py` | CLI: add a shape to an existing diagram |
