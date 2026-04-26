# draw.io Diagram Skill

Use this skill to generate, edit, and validate draw.io diagrams (`.drawio` files) using valid mxGraph XML. This skill covers all common diagram types used in software architecture and documentation.

---

## Agent Workflow

Follow these steps for every draw.io task:

1. **Identify** the diagram type:
   - Flowchart — process flows, algorithms, decision trees
   - Architecture — system components, services, infrastructure tiers
   - Sequence — time-ordered message passing between actors
   - ER Diagram — database entities and relationships
   - UML Class — object-oriented class hierarchies and associations
   - Network — physical/logical network topology
   - BPMN — business process notation

2. **Select** the matching template from `.github/skills/draw-io/templates/` or use the XML recipe below.

3. **Plan** the layout before writing XML:
   - List all nodes/entities
   - Define groups or swimlane tiers
   - Sketch connection topology

4. **Generate** the XML:
   - Always start with the minimal skeleton (id=0, id=1)
   - Use the semantic color palette
   - Align all coordinates to the 10px grid
   - Add a title cell at the top of the diagram

5. **Validate** the file:
   ```
   python .github/skills/draw-io/scripts/validate-drawio.py <file>
   python .github/skills/draw-io/scripts/validate-drawio.py <file> --strict
   ```

6. **Confirm** rendering in VS Code with the draw.io extension (`hediet.vscode-drawio`).

---

## Minimal XML Skeleton

Every `.drawio` file must start with this structure:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- diagram cells go here -->
  </root>
</mxGraphModel>
```

**Rules (non-negotiable):**
- `id="0"` and `id="1"` must always be the first two cells
- Every cell `id` must be unique within the diagram
- Every vertex must have a child `<mxGeometry ... as="geometry"/>` element
- All coordinates must be multiples of 10
- Top-level cells must have `parent="1"`

---

## Semantic Color Palette

| Role | Fill | Stroke | Usage |
|---|---|---|---|
| `primary` | `#dae8fc` | `#6c8ebf` | Main steps, primary actors |
| `success` | `#d5e8d4` | `#82b366` | Success states, positive outcomes |
| `warning` | `#fff2cc` | `#d6b656` | Decisions, warnings, branch points |
| `error` | `#f8cecc` | `#b85450` | Error states, failure paths |
| `neutral` | `#f5f5f5` | `#666666` | Notes, annotations, secondary elements |
| `external` | `#e1d5e7` | `#9673a6` | External systems, third-party services |

---

## XML Recipes

### Recipe 1: Flowchart

A complete, valid flowchart skeleton with start, two process steps, a decision, and end.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- Title -->
    <mxCell id="title" value="Flowchart Title" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=16;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="330" y="20" width="300" height="40" as="geometry"/>
    </mxCell>

    <!-- Start -->
    <mxCell id="start" value="Start" style="ellipse;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;aspect=fixed;" vertex="1" parent="1">
      <mxGeometry x="460" y="80" width="60" height="60" as="geometry"/>
    </mxCell>

    <!-- Step 1 -->
    <mxCell id="step1" value="Process Step 1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="400" y="190" width="180" height="60" as="geometry"/>
    </mxCell>

    <!-- Step 2 -->
    <mxCell id="step2" value="Process Step 2" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="400" y="310" width="180" height="60" as="geometry"/>
    </mxCell>

    <!-- Decision -->
    <mxCell id="decision1" value="Condition?" style="rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
      <mxGeometry x="390" y="430" width="200" height="80" as="geometry"/>
    </mxCell>

    <!-- End -->
    <mxCell id="end" value="End" style="ellipse;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;aspect=fixed;strokeWidth=3;" vertex="1" parent="1">
      <mxGeometry x="460" y="580" width="60" height="60" as="geometry"/>
    </mxCell>

    <!-- Edges -->
    <mxCell id="e1" edge="1" source="start" target="step1" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e2" edge="1" source="step1" target="step2" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e3" edge="1" source="step2" target="decision1" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e4" value="Yes" edge="1" source="decision1" target="end" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e5" value="No" edge="1" source="decision1" target="step1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <Array as="points">
          <mxPoint x="650" y="470"/>
          <mxPoint x="650" y="220"/>
        </Array>
      </mxGeometry>
    </mxCell>
  </root>
</mxGraphModel>
```

---

### Recipe 2: Architecture Diagram (Swimlane Tiers)

A three-tier architecture with client, application, and data layers using swimlanes.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- Title -->
    <mxCell id="title" value="System Architecture" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=16;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="300" y="20" width="400" height="40" as="geometry"/>
    </mxCell>

    <!-- Tier 1: Client Layer -->
    <mxCell id="tier-client" value="Client Layer" style="swimlane;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontStyle=1;startSize=30;" vertex="1" parent="1">
      <mxGeometry x="60" y="80" width="960" height="130" as="geometry"/>
    </mxCell>
    <mxCell id="web-client" value="Web Browser" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="tier-client">
      <mxGeometry x="60" y="50" width="160" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="mobile-client" value="Mobile App" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="tier-client">
      <mxGeometry x="280" y="50" width="160" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="external-api" value="External API" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" vertex="1" parent="tier-client">
      <mxGeometry x="500" y="50" width="160" height="60" as="geometry"/>
    </mxCell>

    <!-- Tier 2: Application Layer -->
    <mxCell id="tier-app" value="Application Layer" style="swimlane;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontStyle=1;startSize=30;" vertex="1" parent="1">
      <mxGeometry x="60" y="240" width="960" height="130" as="geometry"/>
    </mxCell>
    <mxCell id="api-gateway" value="API Gateway" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="tier-app">
      <mxGeometry x="60" y="50" width="160" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="service-a" value="Service A" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="tier-app">
      <mxGeometry x="280" y="50" width="160" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="service-b" value="Service B" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="tier-app">
      <mxGeometry x="500" y="50" width="160" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="cache" value="Cache" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="tier-app">
      <mxGeometry x="720" y="50" width="160" height="60" as="geometry"/>
    </mxCell>

    <!-- Tier 3: Data Layer -->
    <mxCell id="tier-data" value="Data Layer" style="swimlane;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontStyle=1;startSize=30;" vertex="1" parent="1">
      <mxGeometry x="60" y="400" width="960" height="130" as="geometry"/>
    </mxCell>
    <mxCell id="primary-db" value="Primary DB" style="shape=mxgraph.flowchart.database;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="tier-data">
      <mxGeometry x="60" y="40" width="160" height="70" as="geometry"/>
    </mxCell>
    <mxCell id="replica-db" value="Replica DB" style="shape=mxgraph.flowchart.database;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="tier-data">
      <mxGeometry x="280" y="40" width="160" height="70" as="geometry"/>
    </mxCell>
    <mxCell id="object-store" value="Object Store" style="shape=mxgraph.flowchart.database;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;" vertex="1" parent="tier-data">
      <mxGeometry x="500" y="40" width="160" height="70" as="geometry"/>
    </mxCell>

    <!-- Cross-tier edges -->
    <mxCell id="e-web-gw" edge="1" source="web-client" target="api-gateway" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e-mobile-gw" edge="1" source="mobile-client" target="api-gateway" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e-gw-svcA" edge="1" source="api-gateway" target="service-a" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e-gw-svcB" edge="1" source="api-gateway" target="service-b" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e-svcA-db" edge="1" source="service-a" target="primary-db" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e-svcB-db" edge="1" source="service-b" target="primary-db" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="e-primary-replica" style="dashed=1;" edge="1" source="primary-db" target="replica-db" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

---

### Recipe 3: Sequence Diagram

A sequence diagram with three actors and message flows.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- Title -->
    <mxCell id="title" value="Sequence Diagram" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=16;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="300" y="20" width="400" height="40" as="geometry"/>
    </mxCell>

    <!-- Actor boxes -->
    <mxCell id="actor-client" value="Client" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="100" y="80" width="120" height="50" as="geometry"/>
    </mxCell>
    <mxCell id="actor-server" value="Server" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="460" y="80" width="120" height="50" as="geometry"/>
    </mxCell>
    <mxCell id="actor-db" value="Database" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="820" y="80" width="120" height="50" as="geometry"/>
    </mxCell>

    <!-- Lifelines -->
    <mxCell id="ll-client" style="endArrow=none;dashed=1;strokeColor=#666666;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="160" y="130" as="sourcePoint"/>
        <mxPoint x="160" y="620" as="targetPoint"/>
      </mxGeometry>
    </mxCell>
    <mxCell id="ll-server" style="endArrow=none;dashed=1;strokeColor=#666666;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="520" y="130" as="sourcePoint"/>
        <mxPoint x="520" y="620" as="targetPoint"/>
      </mxGeometry>
    </mxCell>
    <mxCell id="ll-db" style="endArrow=none;dashed=1;strokeColor=#666666;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="880" y="130" as="sourcePoint"/>
        <mxPoint x="880" y="620" as="targetPoint"/>
      </mxGeometry>
    </mxCell>

    <!-- Activation boxes -->
    <mxCell id="act-client-1" value="" style="fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="150" y="200" width="20" height="200" as="geometry"/>
    </mxCell>
    <mxCell id="act-server-1" value="" style="fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="510" y="240" width="20" height="120" as="geometry"/>
    </mxCell>
    <mxCell id="act-db-1" value="" style="fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="870" y="280" width="20" height="60" as="geometry"/>
    </mxCell>

    <!-- Messages -->
    <mxCell id="msg1" value="1: request(data)" style="endArrow=block;endFill=1;strokeColor=#6c8ebf;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="170" y="220" as="sourcePoint"/>
        <mxPoint x="510" y="250" as="targetPoint"/>
      </mxGeometry>
    </mxCell>
    <mxCell id="msg2" value="2: query(sql)" style="endArrow=block;endFill=1;strokeColor=#6c8ebf;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="530" y="290" as="sourcePoint"/>
        <mxPoint x="870" y="290" as="targetPoint"/>
      </mxGeometry>
    </mxCell>
    <mxCell id="msg3" value="3: results" style="endArrow=block;endFill=1;dashed=1;strokeColor=#82b366;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="870" y="330" as="sourcePoint"/>
        <mxPoint x="530" y="330" as="targetPoint"/>
      </mxGeometry>
    </mxCell>
    <mxCell id="msg4" value="4: response(payload)" style="endArrow=block;endFill=1;dashed=1;strokeColor=#82b366;" edge="1" parent="1">
      <mxGeometry relative="1" as="geometry">
        <mxPoint x="510" y="360" as="sourcePoint"/>
        <mxPoint x="170" y="390" as="targetPoint"/>
      </mxGeometry>
    </mxCell>
  </root>
</mxGraphModel>
```

---

### Recipe 4: ER Diagram

Entity-Relationship diagram with three entities and their relationships.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- Title -->
    <mxCell id="title" value="Entity-Relationship Diagram" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=16;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="280" y="20" width="440" height="40" as="geometry"/>
    </mxCell>

    <!-- Entity: User -->
    <mxCell id="entity-user" value="User" style="shape=table;startSize=30;container=1;collapsible=1;childLayout=tableLayout;fixedRows=1;rowLines=0;fontStyle=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="80" y="120" width="220" height="180" as="geometry"/>
    </mxCell>
    <mxCell id="user-pk" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=1;" vertex="1" parent="entity-user">
      <mxGeometry y="30" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-pk-icon" value="PK" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;fontStyle=1;overflow=hidden;" vertex="1" parent="user-pk">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-pk-name" value="user_id (INT)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="user-pk">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-name-row" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=0;" vertex="1" parent="entity-user">
      <mxGeometry y="60" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-name-icon" value="" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="user-name-row">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-name-val" value="username (VARCHAR)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="user-name-row">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-email-row" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=0;" vertex="1" parent="entity-user">
      <mxGeometry y="90" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-email-icon" value="" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="user-email-row">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="user-email-val" value="email (VARCHAR)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="user-email-row">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>

    <!-- Entity: Order -->
    <mxCell id="entity-order" value="Order" style="shape=table;startSize=30;container=1;collapsible=1;childLayout=tableLayout;fixedRows=1;rowLines=0;fontStyle=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="460" y="120" width="220" height="180" as="geometry"/>
    </mxCell>
    <mxCell id="order-pk" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=1;" vertex="1" parent="entity-order">
      <mxGeometry y="30" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-pk-icon" value="PK" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;fontStyle=1;overflow=hidden;" vertex="1" parent="order-pk">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-pk-name" value="order_id (INT)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="order-pk">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-fk-row" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=0;" vertex="1" parent="entity-order">
      <mxGeometry y="60" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-fk-icon" value="FK" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;fontStyle=2;overflow=hidden;" vertex="1" parent="order-fk-row">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-fk-val" value="user_id (INT)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="order-fk-row">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-date-row" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=0;" vertex="1" parent="entity-order">
      <mxGeometry y="90" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-date-icon" value="" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="order-date-row">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="order-date-val" value="created_at (DATETIME)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="order-date-row">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>

    <!-- Entity: Product -->
    <mxCell id="entity-product" value="Product" style="shape=table;startSize=30;container=1;collapsible=1;childLayout=tableLayout;fixedRows=1;rowLines=0;fontStyle=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="460" y="370" width="220" height="180" as="geometry"/>
    </mxCell>
    <mxCell id="prod-pk" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=1;" vertex="1" parent="entity-product">
      <mxGeometry y="30" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="prod-pk-icon" value="PK" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;fontStyle=1;overflow=hidden;" vertex="1" parent="prod-pk">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="prod-pk-name" value="product_id (INT)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="prod-pk">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="prod-name-row" value="" style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=0;" vertex="1" parent="entity-product">
      <mxGeometry y="60" width="220" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="prod-name-icon" value="" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="prod-name-row">
      <mxGeometry width="40" height="30" as="geometry"/>
    </mxCell>
    <mxCell id="prod-name-val" value="name (VARCHAR)" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;" vertex="1" parent="prod-name-row">
      <mxGeometry x="40" width="180" height="30" as="geometry"/>
    </mxCell>

    <!-- Relationships -->
    <mxCell id="rel-user-order" value="1..N" style="endArrow=ERmanyToOne;startArrow=ERzeroToOne;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" source="entity-user" target="entity-order" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="rel-order-product" value="N..N" style="endArrow=ERmanyToOne;startArrow=ERmanyToOne;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;" edge="1" source="entity-order" target="entity-product" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

---

### Recipe 5: UML Class Diagram

UML class diagram with inheritance, composition, and association.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
              tooltips="1" connect="1" arrows="1" fold="1" page="1"
              pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- Title -->
    <mxCell id="title" value="UML Class Diagram" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=16;fontStyle=1;" vertex="1" parent="1">
      <mxGeometry x="300" y="20" width="400" height="40" as="geometry"/>
    </mxCell>

    <!-- Abstract Base Class -->
    <mxCell id="class-animal" value="&lt;i&gt;&lt;&lt;abstract&gt;&gt;&lt;/i&gt;&#xa;Animal" style="swimlane;fontStyle=1;align=center;startSize=40;fillColor=#f5f5f5;strokeColor=#666666;fontColor=#333333;" vertex="1" parent="1">
      <mxGeometry x="380" y="80" width="240" height="160" as="geometry"/>
    </mxCell>
    <mxCell id="animal-attrs" value="- name: String&#xa;- age: int" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-animal">
      <mxGeometry y="40" width="240" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="animal-methods" value="+ getName(): String&#xa;+ makeSound(): void" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-animal">
      <mxGeometry y="100" width="240" height="60" as="geometry"/>
    </mxCell>

    <!-- Concrete Subclass: Dog -->
    <mxCell id="class-dog" value="Dog" style="swimlane;fontStyle=1;align=center;startSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="140" y="320" width="220" height="150" as="geometry"/>
    </mxCell>
    <mxCell id="dog-attrs" value="- breed: String" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-dog">
      <mxGeometry y="30" width="220" height="40" as="geometry"/>
    </mxCell>
    <mxCell id="dog-methods" value="+ makeSound(): void&#xa;+ fetch(): void" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-dog">
      <mxGeometry y="70" width="220" height="60" as="geometry"/>
    </mxCell>

    <!-- Concrete Subclass: Cat -->
    <mxCell id="class-cat" value="Cat" style="swimlane;fontStyle=1;align=center;startSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="640" y="320" width="220" height="150" as="geometry"/>
    </mxCell>
    <mxCell id="cat-attrs" value="- indoor: boolean" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-cat">
      <mxGeometry y="30" width="220" height="40" as="geometry"/>
    </mxCell>
    <mxCell id="cat-methods" value="+ makeSound(): void&#xa;+ purr(): void" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-cat">
      <mxGeometry y="70" width="220" height="60" as="geometry"/>
    </mxCell>

    <!-- Owner class with composition -->
    <mxCell id="class-owner" value="Owner" style="swimlane;fontStyle=1;align=center;startSize=30;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="380" y="560" width="240" height="130" as="geometry"/>
    </mxCell>
    <mxCell id="owner-attrs" value="- name: String&#xa;- pets: List&lt;Animal&gt;" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-owner">
      <mxGeometry y="30" width="240" height="50" as="geometry"/>
    </mxCell>
    <mxCell id="owner-methods" value="+ addPet(a: Animal): void" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-owner">
      <mxGeometry y="80" width="240" height="40" as="geometry"/>
    </mxCell>

    <!-- Inheritance edges (hollow arrow = generalization) -->
    <mxCell id="inh-dog" style="endArrow=block;endFill=0;startArrow=none;exitX=0.5;exitY=0;exitDx=0;exitDy=0;entryX=0;entryY=1;entryDx=0;entryDy=0;" edge="1" source="class-dog" target="class-animal" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="inh-cat" style="endArrow=block;endFill=0;startArrow=none;exitX=0.5;exitY=0;exitDx=0;exitDy=0;entryX=1;entryY=1;entryDx=0;entryDy=0;" edge="1" source="class-cat" target="class-animal" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>

    <!-- Composition edge (filled diamond) -->
    <mxCell id="comp-owner-animal" value="owns" style="endArrow=open;startArrow=ERmandOne;exitX=0.5;exitY=0;exitDx=0;exitDy=0;entryX=0.5;entryY=1;entryDx=0;entryDy=0;" edge="1" source="class-owner" target="class-animal" parent="1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

---

## Troubleshooting

### Error: Diagram is blank or shows no shapes

**Cause**: Missing `id="0"` or `id="1"` cells, or cells referencing a non-existent parent.

**Fix**:
- Ensure the first two cells are exactly `<mxCell id="0"/>` and `<mxCell id="1" parent="0"/>`
- Check that all top-level cells have `parent="1"`
- Run `python .github/skills/draw-io/scripts/validate-drawio.py <file>` to find the issue

---

### Error: Shapes appear at wrong positions or overlapping

**Cause**: Coordinates not aligned to the 10px grid.

**Fix**:
- Ensure all `x`, `y`, `width`, `height` values in `<mxGeometry>` are multiples of 10
- Run with `--strict` flag: `python .github/skills/draw-io/scripts/validate-drawio.py <file> --strict`

---

### Error: Edges not connecting to shapes

**Cause**: `source` or `target` attributes in edge cells reference non-existent cell IDs.

**Fix**:
- Verify that every `source="X"` and `target="Y"` matches a real `id="X"` or `id="Y"` cell in the same diagram
- Check for typos in cell IDs

---

### Error: Duplicate cell IDs

**Cause**: Two or more cells share the same `id` attribute.

**Fix**:
- Make all IDs unique — use descriptive names or UUIDs
- The validator will list all duplicate IDs: `python .github/skills/draw-io/scripts/validate-drawio.py <file>`

---

### Error: XML parse failure

**Cause**: Malformed XML (unclosed tags, invalid characters, bad encoding).

**Fix**:
- Ensure the file starts with `<?xml version="1.0" encoding="UTF-8"?>`
- Check that all tags are properly closed
- Escape special characters: `<` → `&lt;`, `>` → `&gt;`, `&` → `&amp;`, `"` → `&quot;`
- HTML content in `value` attributes must use HTML entities or be wrapped in `<![CDATA[...]]>`

---

### Error: Swimlane children not rendering inside parent

**Cause**: Child cells have `parent="1"` instead of `parent="<swimlane-id>"`.

**Fix**:
- Set `parent` attribute of child cells to the ID of the swimlane container, not `"1"`
- Also set `vertex="1"` on child cells

---

## Style Keys Quick Reference

| Key | Values | Description |
|---|---|---|
| `rounded` | `0`, `1` | Rounded corners on rectangles |
| `whiteSpace` | `wrap`, `nowrap` | Text wrapping inside shape |
| `html` | `0`, `1` | Enable HTML in label |
| `fillColor` | `#rrggbb` or `none` | Shape fill color |
| `strokeColor` | `#rrggbb` or `none` | Shape border color |
| `fontColor` | `#rrggbb` | Label text color |
| `fontSize` | integer | Label font size in pt |
| `fontStyle` | `0`=normal, `1`=bold, `2`=italic, `4`=underline | Label font style (bitmask) |
| `align` | `left`, `center`, `right` | Horizontal text alignment |
| `verticalAlign` | `top`, `middle`, `bottom` | Vertical text alignment |
| `strokeWidth` | integer | Border width in px |
| `dashed` | `0`, `1` | Dashed border/edge |
| `opacity` | `0`–`100` | Shape opacity |
| `shadow` | `0`, `1` | Drop shadow |
| `aspect` | `fixed` | Lock aspect ratio |
| `startSize` | integer | Header height for swimlane |
| `container` | `0`, `1` | Whether shape is a container |
| `collapsible` | `0`, `1` | Whether container can collapse |
| `childLayout` | `stackLayout`, `tableLayout` | Child auto-layout mode |
| `endArrow` | `block`, `open`, `classic`, `ERone`, `ERmany`, etc. | Arrow head at target end |
| `startArrow` | same as endArrow | Arrow head at source end |
| `endFill` | `0`, `1` | Fill end arrow head |
| `startFill` | `0`, `1` | Fill start arrow head |
| `edgeStyle` | `orthogonalEdgeStyle`, `elbowEdgeStyle`, `entityRelationEdgeStyle` | Edge routing style |
| `exitX`, `exitY` | `0.0`–`1.0` | Source connection point (relative) |
| `entryX`, `entryY` | `0.0`–`1.0` | Target connection point (relative) |
| `shape` | shape name | Override default shape |
