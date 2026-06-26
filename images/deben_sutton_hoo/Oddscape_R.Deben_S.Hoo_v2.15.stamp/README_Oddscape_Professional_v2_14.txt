Studio Oddscape — Terrain Delivery Engine Professional v2.14
Professional Terrain Delivery Pipeline — Author Crop Control + Cleanup QA Foundation

Input file: S_Hoo_DTM_1m.tif
Scale mode: Tabletop model
Surface mode: Sculptural relief
Cleanup crop border: True
Cleanup fill voids: True
Coastal void compression: False
Coastal cells compressed: 0
Sea plane level: None
Sea plane mode: None
Smart framing enabled: False
Smart framing mode: None
Smart framing margin pixels: None
Smart framing removed cells: 0
Information-aware frame used: None
Information focus cells: 0
Smart frame window: rows None–None, columns None–None
Before nodata: 0.000%
After nodata: 0.000%
After delivery status: UNKNOWN
Downsample: 43
Vertices approx: 81,317
Faces approx: 161,472
Model width: 2.0 m
Object-view scale multiplier: 0.8
Vertical exaggeration: 3.0
Rotate degrees: 0.0
Emergency N/S raster flip: False
Legacy Flip Y / invert north-south: False
Flip normals: True
Matte underside / sealed base: False
Professional clean underside seal: False
Flat base offset below terrain: 0.08
Terrain table mesh mode: False
Terrain table depth: 0.08
Terrain table sides: False
Terrain table bottom plate: False
Top surface orientation lock: True
Top surface faces flipped upward: 0
Backface cull reverse terrain faces: True
Strict NoData cell rejection: True
NoData/void faces removed before OBJ: 0
Blender-style mesh cleanup: False
Tooth cleanup bottom-zone ratio: 0.015
Downward face threshold: 0.98
Tooth-triangle killer: False
Tooth long-edge factor: 7.0
Tooth vertical-drop factor: 5.0
Tooth bottom-zone search: 0.2
Mesh hygiene repair enabled: False
Mesh hygiene cells repaired: 0
Max defensible pit/crater depth: None
Water/base plate: False
Water/base style: Deep slate water

Professional v2.14 purpose:
- author-controlled crop rectangle for final composition
- reliable slider-driven gold crop overlay shown on the hillshade author preview before export
- Author_Crop_Overlay PNG included in the client package
- optional information-aware framing retained
- coastal void compression for sea/nodata gaps
- edge-connected nodata compressed to a flat sea plane
- coastal edge softening into a beach/ramp transition
- smart framing crops away excessive flat sea while retaining context
- crop empty border, fill small internal voids, re-run QA
- preview-locked Apple AR terrain-table export
- dark readable relief assigned to top surface
- lightweight Apple-safe USDZ
- client-ready export package with QA, hillshade author crop overlay, selected export preview, USDZ and OBJ
- colour REM retained for QA while hillshade drives author composition
- Professional v2.14 flat sealed underside reduces underside spike artefacts