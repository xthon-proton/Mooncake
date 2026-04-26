# draw.io Style Reference

Complete reference for all style keys, shape names, and edge types used in mxGraph/draw.io.

---

## Style String Format

Styles are semicolon-separated `key=value` pairs in the `style` attribute of an `<mxCell>`:

```
style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;"
```

- Keys are case-sensitive
- Values may be strings, integers, floats, or hex colors
- Unknown keys are silently ignored by draw.io
- A trailing semicolon after the last key is allowed

---

## Color Style Keys

| Key | Type | Description | Example |
|---|---|---|---|
| `fillColor` | `#rrggbb` or `none` | Shape interior fill color | `fillColor=#dae8fc` |
| `strokeColor` | `#rrggbb` or `none` | Shape border/outline color | `strokeColor=#6c8ebf` |
| `fontColor` | `#rrggbb` | Label text color | `fontColor=#333333` |
| `gradientColor` | `#rrggbb` or `none` | Second color for gradient fill | `gradientColor=#ffffff` |
| `gradientDirection` | `north`, `south`, `east`, `west` | Direction of gradient | `gradientDirection=north` |
| `swimlaneLine` | `0` or `1` | Show/hide swimlane separator line | `swimlaneLine=1` |

**Semantic Color Palette:**

| Role | `fillColor` | `strokeColor` |
|---|---|---|
| primary | `#dae8fc` | `#6c8ebf` |
| success | `#d5e8d4` | `#82b366` |
| warning | `#fff2cc` | `#d6b656` |
| error | `#f8cecc` | `#b85450` |
| neutral | `#f5f5f5` | `#666666` |
| external | `#e1d5e7` | `#9673a6` |

---

## Font and Text Style Keys

| Key | Type | Description | Example |
|---|---|---|---|
| `fontSize` | integer | Font size in points | `fontSize=14` |
| `fontStyle` | bitmask integer | Font decorations: 1=bold, 2=italic, 4=underline, 8=strikethrough | `fontStyle=1` |
| `fontFamily` | string | Font family name | `fontFamily=Helvetica` |
| `align` | `left`, `center`, `right` | Horizontal text alignment | `align=center` |
| `verticalAlign` | `top`, `middle`, `bottom` | Vertical text alignment | `verticalAlign=middle` |
| `labelPosition` | `left`, `center`, `right` | Position of label relative to shape | `labelPosition=center` |
| `verticalLabelPosition` | `top`, `middle`, `bottom` | Vertical position of label | `verticalLabelPosition=bottom` |
| `labelBackgroundColor` | `#rrggbb` or `none` | Label background fill | `labelBackgroundColor=#ffffff` |
| `labelBorderColor` | `#rrggbb` or `none` | Label border color | `labelBorderColor=none` |
| `html` | `0` or `1` | Allow HTML tags in `value` attribute | `html=1` |
| `whiteSpace` | `wrap`, `nowrap` | Text wrapping behaviour | `whiteSpace=wrap` |
| `overflow` | `hidden`, `visible` | Clip text to shape bounds | `overflow=hidden` |
| `rotation` | float (-360 to 360) | Shape rotation angle in degrees | `rotation=45` |

---

## Shape Geometry Style Keys

| Key | Type | Description | Example |
|---|---|---|---|
| `rounded` | `0` or `1` | Rounded corners on rectangles | `rounded=1` |
| `arcSize` | integer (0–100) | Corner rounding percentage | `arcSize=50` |
| `aspect` | `fixed` | Lock width/height ratio | `aspect=fixed` |
| `perimeter` | perimeter function | Override connection perimeter | `perimeter=ellipsePerimeter` |
| `fixedSize` | `0` or `1` | Prevent auto-resize | `fixedSize=1` |
| `resizable` | `0` or `1` | Allow resize handles | `resizable=1` |
| `rotatable` | `0` or `1` | Allow rotation handle | `rotatable=0` |
| `movable` | `0` or `1` | Allow drag-move | `movable=0` |
| `deletable` | `0` or `1` | Allow delete | `deletable=0` |
| `editable` | `0` or `1` | Allow label edit | `editable=0` |
| `cloneable` | `0` or `1` | Allow clone/copy | `cloneable=0` |

---

## Border and Fill Style Keys

| Key | Type | Description | Example |
|---|---|---|---|
| `strokeWidth` | integer | Border line width in pixels | `strokeWidth=2` |
| `dashed` | `0` or `1` | Dashed border | `dashed=1` |
| `dashPattern` | string | Custom dash pattern (space-separated) | `dashPattern=8 4` |
| `opacity` | integer (0–100) | Shape opacity (100 = fully opaque) | `opacity=80` |
| `shadow` | `0` or `1` | Drop shadow | `shadow=1` |
| `glass` | `0` or `1` | Glass/gloss effect | `glass=1` |
| `sketch` | `0` or `1` | Hand-drawn sketch effect | `sketch=1` |

---

## Container / Swimlane Style Keys

| Key | Type | Description | Example |
|---|---|---|---|
| `swimlane` | (present) | Marks shape as a swimlane container | `swimlane;` |
| `container` | `0` or `1` | Whether shape acts as a container | `container=1` |
| `collapsible` | `0` or `1` | Whether container can collapse | `collapsible=1` |
| `startSize` | integer | Header height (swimlane) or width (vertical) | `startSize=30` |
| `horizontal` | `0` or `1` | Orientation of swimlane (1=horizontal lanes) | `horizontal=1` |
| `childLayout` | `stackLayout`, `tableLayout` | Auto-layout mode for children | `childLayout=stackLayout` |
| `fillColor2` | `#rrggbb` | Secondary fill for container body | `fillColor2=#f8f8f8` |

---

## Edge / Connector Style Keys

| Key | Type | Description | Example |
|---|---|---|---|
| `edgeStyle` | string | Routing algorithm (see below) | `edgeStyle=orthogonalEdgeStyle` |
| `endArrow` | arrow name | Arrow head at target end | `endArrow=block` |
| `startArrow` | arrow name | Arrow head at source end | `startArrow=none` |
| `endFill` | `0` or `1` | Fill the end arrow head | `endFill=1` |
| `startFill` | `0` or `1` | Fill the start arrow head | `startFill=0` |
| `exitX` | float (0.0–1.0) | Relative X of source exit point | `exitX=0.5` |
| `exitY` | float (0.0–1.0) | Relative Y of source exit point | `exitY=1` |
| `exitDx` | float | Absolute X offset of source exit point | `exitDx=0` |
| `exitDy` | float | Absolute Y offset of source exit point | `exitDy=0` |
| `entryX` | float (0.0–1.0) | Relative X of target entry point | `entryX=0.5` |
| `entryY` | float (0.0–1.0) | Relative Y of target entry point | `entryY=0` |
| `entryDx` | float | Absolute X offset of target entry point | `entryDx=0` |
| `entryDy` | float | Absolute Y offset of target entry point | `entryDy=0` |
| `curved` | `0` or `1` | Curved edge corners | `curved=1` |
| `rounded` | `0` or `1` | Rounded edge bends | `rounded=1` |
| `jettySize` | `auto` or integer | Connector jetty size | `jettySize=auto` |
| `orthogonalLoop` | `1` | Enable orthogonal loop routing | `orthogonalLoop=1` |

### Edge Style Values

| Value | Description |
|---|---|
| (empty) | Direct straight line |
| `orthogonalEdgeStyle` | Right-angle routing with automatic bend points |
| `elbowEdgeStyle` | Single elbow bend |
| `entityRelationEdgeStyle` | Entity-relation diagram style routing |
| `segmentEdgeStyle` | Manually adjustable segments |
| `isometricEdgeStyle` | Isometric grid routing |
| `curved=1` | Bezier curve |

### Arrow Head Values

| Value | Description |
|---|---|
| `none` | No arrow head |
| `classic` | Filled chevron (default) |
| `classicThin` | Thin filled chevron |
| `open` | Open (hollow) chevron |
| `openThin` | Thin open chevron |
| `block` | Filled triangle block |
| `blockThin` | Thin filled triangle |
| `oval` | Filled circle |
| `diamond` | Filled diamond |
| `diamondThin` | Thin filled diamond |
| `ERone` | ER notation: one (single vertical bar) |
| `ERmany` | ER notation: many (crow's foot) |
| `ERoneToOne` | ER notation: one-to-one |
| `ERmandOne` | ER notation: mandatory one |
| `ERzeroToOne` | ER notation: zero-or-one |
| `ERzeroToMany` | ER notation: zero-or-many |
| `ERmanyToOne` | ER notation: many-to-one |

---

## Built-in Shape Names

Use the `shape=` key to select from draw.io's built-in shape libraries.

### Basic Shapes (no prefix needed)

| Style Key | Shape |
|---|---|
| (default) | Rectangle |
| `ellipse` | Circle / oval |
| `rhombus` | Diamond |
| `hexagon` | Hexagon |
| `triangle` | Triangle |
| `cylinder` | Cylinder / database symbol |
| `actor` | Stick figure actor |
| `parallelogram` | Parallelogram |
| `trapezoid` | Trapezoid |
| `cloud` | Cloud shape |
| `document` | Document with wavy bottom |
| `callout` | Speech callout bubble |
| `image` | Image placeholder |
| `text` | Text-only (no border) |
| `swimlane` | Swimlane container |

### Flowchart Shapes (`shape=mxgraph.flowchart.*`)

| Shape Name | Description |
|---|---|
| `shape=mxgraph.flowchart.process` | Process rectangle |
| `shape=mxgraph.flowchart.decision` | Decision diamond |
| `shape=mxgraph.flowchart.terminator` | Oval start/end |
| `shape=mxgraph.flowchart.database` | Database cylinder |
| `shape=mxgraph.flowchart.document` | Document |
| `shape=mxgraph.flowchart.manual_input` | Manual input |
| `shape=mxgraph.flowchart.display` | Display output |
| `shape=mxgraph.flowchart.delay` | Delay (D-shape) |
| `shape=mxgraph.flowchart.or` | Logical OR |
| `shape=mxgraph.flowchart.summing_junction` | Summation junction |
| `shape=mxgraph.flowchart.internal_storage` | Internal storage |
| `shape=mxgraph.flowchart.stored_data` | Stored data |

### Network / Infrastructure Shapes (`shape=mxgraph.network.*`)

| Shape Name | Description |
|---|---|
| `shape=mxgraph.network.server` | Generic server |
| `shape=mxgraph.network.cloud` | Network cloud |
| `shape=mxgraph.network.firewall` | Firewall |
| `shape=mxgraph.network.router` | Router |
| `shape=mxgraph.network.switch` | Network switch |
| `shape=mxgraph.network.laptop` | Laptop |
| `shape=mxgraph.network.workstation` | Desktop workstation |
| `shape=mxgraph.network.printer` | Printer |

### AWS Shapes (`shape=mxgraph.aws4.*`)

| Shape Name | Description |
|---|---|
| `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.ec2` | EC2 instance |
| `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.s3` | S3 bucket |
| `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.rds` | RDS database |
| `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda` | Lambda function |
| `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.elb` | Load balancer |

### Azure Shapes (`shape=mxgraph.azure.*`)

| Shape Name | Description |
|---|---|
| `shape=mxgraph.azure.vm` | Virtual Machine |
| `shape=mxgraph.azure.database` | Azure Database |
| `shape=mxgraph.azure.storage` | Azure Storage |
| `shape=mxgraph.azure.app_service` | App Service |

### GCP Shapes (`shape=mxgraph.gcp2.*`)

| Shape Name | Description |
|---|---|
| `shape=mxgraph.gcp2.compute_engine` | Compute Engine |
| `shape=mxgraph.gcp2.cloud_storage` | Cloud Storage |
| `shape=mxgraph.gcp2.cloud_sql` | Cloud SQL |
| `shape=mxgraph.gcp2.kubernetes_engine` | Kubernetes Engine |

---

## Special Style Values

### Text / Label Shapes

```
style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;"
```

### Invisible Anchor / Spacer

```
style="point;x=0.5;y=0.5;perimeter=pointPerimeter;"
```

### Image Shape

```
style="shape=image;verticalLabelPosition=bottom;labelBackgroundColor=#ffffff;verticalAlign=top;align=center;strokeColor=none;fillColor=none;image;image=img/lib/clip_art/networking/cloud_service.svg;"
```
