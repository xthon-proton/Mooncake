# draw.io Shape Libraries Reference

Catalog of shape libraries available in draw.io, with style strings for common shapes in each library.

---

## Using Shape Libraries

To use a shape from a library, set the `shape=` key in the cell's `style` attribute:

```xml
<mxCell id="my-shape" value="EC2" 
  style="shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.ec2;labelBackgroundColor=none;sketch=0;fontStyle=1;fontSize=11;"
  vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="60" height="60" as="geometry"/>
</mxCell>
```

---

## General / Basic Shapes

No prefix required — use the shape name directly as the style value.

| Shape | Style String |
|---|---|
| Rectangle (default) | `rounded=0;whiteSpace=wrap;html=1;` |
| Rounded Rectangle | `rounded=1;whiteSpace=wrap;html=1;arcSize=20;` |
| Circle / Ellipse | `ellipse;whiteSpace=wrap;html=1;` |
| Diamond (Decision) | `rhombus;whiteSpace=wrap;html=1;` |
| Cylinder (Database) | `shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;` |
| Triangle | `triangle;whiteSpace=wrap;html=1;` |
| Parallelogram | `shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;` |
| Hexagon | `shape=hexagon;perimeter=hexagonPerimeter2;whiteSpace=wrap;html=1;` |
| Cloud | `shape=cloud;whiteSpace=wrap;html=1;` |
| Actor (UML) | `shape=mxgraph.flowchart.actor;whiteSpace=wrap;html=1;` |
| Note (annotation) | `shape=note;whiteSpace=wrap;html=1;backgroundOutline=1;size=15;` |
| Callout | `shape=callout;whiteSpace=wrap;html=1;perimeter=calloutPerimeter;` |
| Document | `shape=mxgraph.flowchart.document;whiteSpace=wrap;html=1;` |

---

## Flowchart Library (`mxgraph.flowchart`)

| Shape | Style String |
|---|---|
| Process | `shape=mxgraph.flowchart.process;whiteSpace=wrap;html=1;` |
| Decision | `shape=mxgraph.flowchart.decision;whiteSpace=wrap;html=1;` |
| Start / Terminator | `shape=mxgraph.flowchart.start_2;fillColor=#00FF00;fontSize=12;fontStyle=1;` |
| End / Terminator | `shape=mxgraph.flowchart.start_2;fillColor=#FF0000;fontSize=12;fontStyle=1;` |
| Database | `shape=mxgraph.flowchart.database;whiteSpace=wrap;html=1;` |
| Document | `shape=mxgraph.flowchart.document;whiteSpace=wrap;html=1;` |
| Manual Operation | `shape=mxgraph.flowchart.manual;whiteSpace=wrap;html=1;` |
| Preparation | `shape=mxgraph.flowchart.preparation;whiteSpace=wrap;html=1;` |
| Delay | `shape=mxgraph.flowchart.delay;whiteSpace=wrap;html=1;` |
| Display | `shape=mxgraph.flowchart.display;whiteSpace=wrap;html=1;` |
| Stored Data | `shape=mxgraph.flowchart.stored_data;whiteSpace=wrap;html=1;` |
| Subroutine | `shape=mxgraph.flowchart.subroutine;whiteSpace=wrap;html=1;` |
| On-page Connector | `shape=mxgraph.flowchart.connector;whiteSpace=wrap;html=1;` |
| Off-page Connector | `shape=mxgraph.flowchart.off_page_reference;whiteSpace=wrap;html=1;` |

---

## Network Library (`mxgraph.network`)

| Shape | Style String |
|---|---|
| Generic Server | `shape=mxgraph.network.server;html=1;pointerEvents=1;dashed=0;fillColor=#dae8fc;strokeColor=#6c8ebf;` |
| Cloud | `shape=mxgraph.network.cloud;html=1;whiteSpace=wrap;` |
| Firewall | `shape=mxgraph.network.firewall;html=1;whiteSpace=wrap;` |
| Router | `shape=mxgraph.network.router;html=1;whiteSpace=wrap;` |
| Switch | `shape=mxgraph.network.switch;html=1;whiteSpace=wrap;` |
| Laptop | `shape=mxgraph.network.laptop;html=1;whiteSpace=wrap;` |
| Desktop / Workstation | `shape=mxgraph.network.workstation;html=1;whiteSpace=wrap;` |
| Printer | `shape=mxgraph.network.printer;html=1;whiteSpace=wrap;` |
| Mobile Phone | `shape=mxgraph.network.mobile;html=1;whiteSpace=wrap;` |
| Tablet | `shape=mxgraph.network.tablet;html=1;whiteSpace=wrap;` |
| Load Balancer | `shape=mxgraph.network.load_balancer;html=1;whiteSpace=wrap;` |
| Database Server | `shape=mxgraph.network.database;html=1;whiteSpace=wrap;` |

---

## AWS Architecture 4 Library (`mxgraph.aws4`)

General resource icon style:
```
shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.<SERVICE>;labelBackgroundColor=none;sketch=0;
```

| Service | `resIcon` value |
|---|---|
| EC2 | `mxgraph.aws4.ec2` |
| S3 | `mxgraph.aws4.s3` |
| RDS | `mxgraph.aws4.rds` |
| Lambda | `mxgraph.aws4.lambda` |
| ELB (Load Balancer) | `mxgraph.aws4.elb` |
| CloudFront | `mxgraph.aws4.cloudfront` |
| API Gateway | `mxgraph.aws4.api_gateway` |
| DynamoDB | `mxgraph.aws4.dynamodb` |
| SQS | `mxgraph.aws4.sqs` |
| SNS | `mxgraph.aws4.sns` |
| ECS | `mxgraph.aws4.ecs` |
| EKS | `mxgraph.aws4.eks` |
| VPC | `mxgraph.aws4.traditional_server` |
| Route 53 | `mxgraph.aws4.route_53` |
| IAM | `mxgraph.aws4.role` |
| CloudWatch | `mxgraph.aws4.cloudwatch` |
| Kinesis | `mxgraph.aws4.kinesis` |
| Glue | `mxgraph.aws4.glue` |

AWS group/container style:
```
points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;fillColor=#e6f3ff;strokeColor=#80c0ff;
```

---

## Azure Library (`mxgraph.azure`)

| Service | Style String |
|---|---|
| Virtual Machine | `shape=mxgraph.azure.vm;pointerEvents=1;html=1;` |
| Azure Database | `shape=mxgraph.azure.database;pointerEvents=1;html=1;` |
| Storage | `shape=mxgraph.azure.storage;pointerEvents=1;html=1;` |
| App Service | `shape=mxgraph.azure.app_service;pointerEvents=1;html=1;` |
| API Gateway | `shape=mxgraph.azure.api_management;pointerEvents=1;html=1;` |
| Function | `shape=mxgraph.azure.function_apps;pointerEvents=1;html=1;` |
| Container | `shape=mxgraph.azure.container_instances;pointerEvents=1;html=1;` |
| Kubernetes | `shape=mxgraph.azure.aks;pointerEvents=1;html=1;` |
| Load Balancer | `shape=mxgraph.azure.load_balancer;pointerEvents=1;html=1;` |
| CDN | `shape=mxgraph.azure.cdn;pointerEvents=1;html=1;` |
| Key Vault | `shape=mxgraph.azure.key_vault;pointerEvents=1;html=1;` |
| Monitor | `shape=mxgraph.azure.monitor;pointerEvents=1;html=1;` |

---

## GCP Library (`mxgraph.gcp2`)

| Service | Style String |
|---|---|
| Compute Engine | `shape=mxgraph.gcp2.compute_engine;pointerEvents=1;html=1;` |
| App Engine | `shape=mxgraph.gcp2.app_engine;pointerEvents=1;html=1;` |
| Cloud Functions | `shape=mxgraph.gcp2.cloud_functions;pointerEvents=1;html=1;` |
| Cloud Run | `shape=mxgraph.gcp2.cloud_run;pointerEvents=1;html=1;` |
| Kubernetes Engine | `shape=mxgraph.gcp2.kubernetes_engine;pointerEvents=1;html=1;` |
| Cloud Storage | `shape=mxgraph.gcp2.cloud_storage;pointerEvents=1;html=1;` |
| Cloud SQL | `shape=mxgraph.gcp2.cloud_sql;pointerEvents=1;html=1;` |
| BigQuery | `shape=mxgraph.gcp2.bigquery;pointerEvents=1;html=1;` |
| Pub/Sub | `shape=mxgraph.gcp2.cloud_pubsub;pointerEvents=1;html=1;` |
| Load Balancing | `shape=mxgraph.gcp2.load_balancing;pointerEvents=1;html=1;` |
| Cloud Endpoints | `shape=mxgraph.gcp2.cloud_endpoints;pointerEvents=1;html=1;` |
| Stackdriver | `shape=mxgraph.gcp2.stackdriver;pointerEvents=1;html=1;` |

---

## Kubernetes Library (`mxgraph.kubernetes`)

| Resource | Style String |
|---|---|
| Pod | `shape=mxgraph.kubernetes.pod;whiteSpace=wrap;html=1;` |
| Deployment | `shape=mxgraph.kubernetes.deploy;whiteSpace=wrap;html=1;` |
| Service | `shape=mxgraph.kubernetes.svc;whiteSpace=wrap;html=1;` |
| Ingress | `shape=mxgraph.kubernetes.ing;whiteSpace=wrap;html=1;` |
| ConfigMap | `shape=mxgraph.kubernetes.cm;whiteSpace=wrap;html=1;` |
| Secret | `shape=mxgraph.kubernetes.secret;whiteSpace=wrap;html=1;` |
| Node | `shape=mxgraph.kubernetes.node;whiteSpace=wrap;html=1;` |
| Namespace | `shape=mxgraph.kubernetes.ns;whiteSpace=wrap;html=1;` |
| StatefulSet | `shape=mxgraph.kubernetes.sts;whiteSpace=wrap;html=1;` |
| DaemonSet | `shape=mxgraph.kubernetes.ds;whiteSpace=wrap;html=1;` |
| Job | `shape=mxgraph.kubernetes.job;whiteSpace=wrap;html=1;` |
| PersistentVolume | `shape=mxgraph.kubernetes.pv;whiteSpace=wrap;html=1;` |

---

## UML Library (`mxgraph.uml`)

| Element | Style String |
|---|---|
| Class (swimlane) | `swimlane;fontStyle=1;align=center;startSize=30;` |
| Interface | `swimlane;fontStyle=3;align=center;startSize=30;` |
| Abstract Class | `swimlane;fontStyle=1;align=center;startSize=30;italic=1;` |
| Enumeration | `swimlane;fontStyle=1;align=center;startSize=30;` |
| Package | `shape=mxgraph.uml.package;whiteSpace=wrap;html=1;` |
| Component | `shape=mxgraph.uml.component;whiteSpace=wrap;html=1;` |
| Note | `shape=note;whiteSpace=wrap;html=1;backgroundOutline=1;size=15;` |
| Actor (Use Case) | `shape=mxgraph.uml.actor;whiteSpace=wrap;html=1;` |
| Use Case (oval) | `ellipse;whiteSpace=wrap;html=1;` |
| State | `rounded=1;whiteSpace=wrap;html=1;arcSize=50;` |
| Fork/Join (bar) | `shape=mxgraph.uml.fork;whiteSpace=wrap;html=1;` |
| Boundary | `shape=mxgraph.uml.boundary;whiteSpace=wrap;html=1;` |
| Entity | `shape=mxgraph.uml.entity;whiteSpace=wrap;html=1;` |
| Control | `shape=mxgraph.uml.control;whiteSpace=wrap;html=1;` |

### UML Edge Styles

| Relationship | Style String |
|---|---|
| Association | `endArrow=open;html=1;` |
| Directed Association | `endArrow=open;html=1;endFill=0;` |
| Generalization (inheritance) | `endArrow=block;endFill=0;html=1;` |
| Realization (implements) | `endArrow=block;endFill=0;dashed=1;html=1;` |
| Dependency | `endArrow=open;dashed=1;html=1;` |
| Composition | `endArrow=block;startArrow=diamondThin;startFill=1;endFill=1;html=1;` |
| Aggregation | `endArrow=block;startArrow=diamondThin;startFill=0;endFill=0;html=1;` |

---

## ER Diagram Library (Entity-Relation)

### Table Shape (recommended approach)

```xml
<mxCell id="tbl" value="TableName" 
  style="shape=table;startSize=30;container=1;collapsible=1;childLayout=tableLayout;fixedRows=1;rowLines=0;fontStyle=1;" 
  vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="200" height="120" as="geometry"/>
</mxCell>
```

### Table Row

```xml
<mxCell id="row1" value="" 
  style="shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;top=0;left=0;right=0;bottom=1;" 
  vertex="1" parent="tbl">
  <mxGeometry y="30" width="200" height="30" as="geometry"/>
</mxCell>
```

### Column Icon (PK / FK)

```xml
<mxCell id="pk-icon" value="PK" 
  style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;fontStyle=1;overflow=hidden;" 
  vertex="1" parent="row1">
  <mxGeometry width="40" height="30" as="geometry"/>
</mxCell>
```

### ER Relationship Edge Styles

| Cardinality | Style String |
|---|---|
| One-to-One | `endArrow=ERone;startArrow=ERone;html=1;` |
| One-to-Many | `endArrow=ERmany;startArrow=ERone;html=1;` |
| Many-to-Many | `endArrow=ERmany;startArrow=ERmany;html=1;` |
| Zero-or-One | `endArrow=ERzeroToOne;startArrow=ERone;html=1;` |
| One-or-Many | `endArrow=ERmanyToOne;startArrow=ERone;html=1;` |
| Zero-or-Many | `endArrow=ERzeroToMany;startArrow=ERone;html=1;` |

---

## BPMN Library (`mxgraph.bpmn`)

| Element | Style String |
|---|---|
| Start Event | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.ellipsePerimeter;symbol=general;verticalLabelPosition=bottom;` |
| End Event | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.ellipsePerimeter;symbol=terminate;verticalLabelPosition=bottom;strokeWidth=3;` |
| Task | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rectanglePerimeter;symbol=task;whiteSpace=wrap;` |
| Gateway (XOR) | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rhombusPerimeter;symbol=exclusiveGw;` |
| Gateway (AND) | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rhombusPerimeter;symbol=parallelGw;` |
| Pool | `shape=pool;startSize=30;horizontal=1;childLayout=stackLayout;horizontalStack=0;` |
| Lane | `swimlane;startSize=30;swimlaneHead=0;fillColor=none;` |
| Sequence Flow | `endArrow=block;endFill=1;html=1;` |
| Message Flow | `endArrow=block;endFill=0;dashed=1;html=1;` |

---

## Archimate 3 Library (`mxgraph.archimate3`)

| Element | Style String |
|---|---|
| Application Component | `shape=mxgraph.archimate3.application;whiteSpace=wrap;html=1;` |
| Business Actor | `shape=mxgraph.archimate3.actor;whiteSpace=wrap;html=1;` |
| Business Role | `shape=mxgraph.archimate3.role;whiteSpace=wrap;html=1;` |
| Business Process | `shape=mxgraph.archimate3.process;whiteSpace=wrap;html=1;` |
| Technology Node | `shape=mxgraph.archimate3.tech;whiteSpace=wrap;html=1;` |
| Data Object | `shape=mxgraph.archimate3.artifact;whiteSpace=wrap;html=1;` |
