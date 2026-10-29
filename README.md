# ConcreteLiDAR-iOS

**Smartphone LiDAR research for 3D-printed concrete — Blender measurements and iOS prototype**

<img src="screenshots/ios-simulator-preview.png" alt="ConcreteLiDAR iOS simulator run showing specimen preview, dimension controls and export actions" width="311">

*Actual simulator-run screenshot of the prototype. The specimen and texture are synthetic.*

Early-stage iOS prototype assets for inspecting a synthetic layered concrete specimen, previewing a generated RGB texture, and exporting 3D geometry and dimensional data.

> **Research status:** Physical-specimen Blender measurement records are included separately from the synthetic iOS demonstration outputs. Reference dimensions are pending, so measurement accuracy has not yet been validated. The Swift/Xcode source code is not yet included.

## Research purpose

Explore smartphone RGB–LiDAR workflows for evaluating layer height, width, cross-sectional area and shape error in 3D-printed concrete. The current synthetic specimen provides known nominal geometry for inspecting file formats and planning later comparisons with physical specimens.

## Blender measurements of physical specimens

**Four physical specimens · 32 recorded dimensions · five Blender images**

The supplied workbook records Polycam GLTF captures dated **2026-09-14**, with dimensions measured on the reconstructed meshes in Blender. These measurements document the physical-specimen study; they are separate from the synthetic app example below.

<img src="research/blender-measurements/images/p03-img4-measurements.png" alt="P03 Blender reconstructed mesh with height, side-length and thickness measurements" width="800">

*P03 (IMG4): four corner heights, four side lengths and two wall thicknesses.*

[All measurements and five images](research/blender-measurements/) · [Original Excel workbook](research/blender-measurements/iphone-lidar-3dcp-measurements.xlsx)

| Specimen | Recorded dimensions | Height range (mm) | Side-length range (mm) |
| --- | ---: | ---: | ---: |
| P01 | 4 | 182.530–188.387 | 521.420–531.639 |
| P02 | 8 | 138.320–153.652 | 510.924–521.241 |
| P03 | 10 | 180.292–194.800 | 510.022–531.399 |
| P04 | 10 | 110.582–117.409 | 527.003–538.684 |

P03 also has two thickness records (37.154–46.772 mm); P04 has four (24.416–30.559 mm). Ranges describe different measurement locations, not accuracy or repeatability. Reference dimensions are not yet entered, so MAE, RMSE and relative error are unavailable. Photo-relative location labels and measurement alignment require verification.

## Current synthetic specimen

| Parameter | Nominal value |
| --- | ---: |
| Outer width / depth | 500 × 500 mm |
| Overall height | 150 mm |
| Layers | 6 |
| Layer height | 25 mm |
| Wall thickness | 40 mm |

The app screenshot shows an iPhone simulator with a ring-shaped concrete model, RGB texture toggle, dimension controls and export actions. Visual display in the simulator does not establish correct material rendering in Blender.

## Dataset and formats

The synthetic export comprises:
- `synthetic_specimen.obj`: mesh geometry and UV coordinates.
- `synthetic_material.mtl`: material mapping.
- `synthetic_texture.png`: 1024 × 1024 procedural RGB surface pattern.
- `synthetic_specimen.ply`: XYZ geometry samples without RGB or confidence.
- `synthetic_measurements.csv`: analytic dimensions, **not observations**.
- `DATA_NOTES.txt`: provenance and limitations.

The example assets are available in [examples/synthetic-specimen/](examples/synthetic-specimen/). Keep the OBJ, MTL and PNG filenames together so the material reference resolves.

### RGB texture preview

<img src="examples/synthetic-specimen/synthetic_texture.png" alt="Procedurally generated concrete-like RGB texture, not a camera image" width="480">

[OBJ mesh](examples/synthetic-specimen/synthetic_specimen.obj) · [PLY points](examples/synthetic-specimen/synthetic_specimen.ply) · [RGB texture PNG](examples/synthetic-specimen/synthetic_texture.png)

## Project structure

```text
ConcreteLiDAR-iOS/
├── README.md
├── .gitignore
├── research/
│   └── blender-measurements/
│       ├── README.md
│       ├── iphone-lidar-3dcp-measurements.xlsx
│       └── images/  (five original workbook images)
├── screenshots/
│   └── ios-simulator-preview.png
└── examples/
    └── synthetic-specimen/
        ├── synthetic_specimen.obj
        ├── synthetic_material.mtl
        ├── synthetic_texture.png
        ├── synthetic_specimen.ply
        ├── synthetic_measurements.csv
        └── DATA_NOTES.txt
```

## Prototype features and evidence

| Feature | Available evidence |
| --- | --- |
| 3D specimen preview | Visible in the simulator screenshot |
| Nominal dimension and layer controls | Controls shown for width, depth, height and layer count |
| RGB texture display | Toggle shown in the UI; procedural PNG supplied |
| Export controls | OBJ / MTL / PNG / PLY / CSV action and save-status text shown |
| Example export files | OBJ with UVs, MTL–PNG linkage, XYZ-only PLY and analytic CSV included |
| Reproducible app implementation | Swift source and Xcode project have not been supplied |

The screenshot documents an app run, but does not establish the underlying Swift implementation or end-to-end export correctness. App builds and interactive behavior cannot be reproduced from this repository yet.

## Synthetic data limits

- The model, texture and dimensions are generated examples, not LiDAR or camera measurements.
- The PNG repeats over mesh faces; its pattern scale is uncalibrated and adds no geometric roughness.
- The PLY contains 12,640 XYZ samples without color or confidence, including hidden idealized surfaces. It does not model sensor visibility or acquisition noise.
- CSV values are analytic dimensions. They do not demonstrate measurement accuracy.
- Real capture, RGB–depth alignment and dimensional error evaluation require device experiments and reference measurements.

See [DATA_NOTES.txt](examples/synthetic-specimen/DATA_NOTES.txt) for the original export assumptions.

## Blender inspection

1. Keep OBJ, MTL and PNG together with their original filenames.
2. Import the OBJ via **File → Import → Wavefront (.obj)**.
3. Switch to **Material Preview**.
4. If the surface remains gray, inspect the material Image Texture node and reconnect the PNG to **Principled BSDF → Base Color**.

Geometry coordinates are in **meters**, with X = width, Y = height, Z = depth, and origin at the base center. The RGB image modifies appearance, not geometric roughness. The PLY includes idealized model surfaces and is not a LiDAR sensor simulation.

## Development status

| Item | Status |
| --- | --- |
| Simulator visual preview | Demonstrated in screenshot |
| Synthetic model and texture export | Example outputs included; source implementation not supplied |
| Blender RGB texture rendering | Under verification |
| Swift / Xcode source available in repository | Not yet |
| Polycam / Blender physical-specimen records | Four specimens, 32 dimensions and five images included |
| Accuracy validation against reference dimensions | Pending reference measurements |
| Custom iOS app real LiDAR capture | Not demonstrated |

## Roadmap

1. Add the original Swift/Xcode application source and reproducible build steps.
2. Confirm consistent RGB texture rendering inside the app and in Blender.
3. Test optional synthetic roughness and sampling noise, clearly separated from sensor data.
4. Extend the physical-specimen study with matched reference dimensions and independent repeated scans, then quantify errors.

**Research direction:** smartphone RGB–LiDAR-based evaluation of layered geometry in 3D concrete printing (3DCP).


