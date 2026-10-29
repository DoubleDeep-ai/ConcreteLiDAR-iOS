# ConcreteLiDAR-iOS

**Synthetic 3D-printed concrete specimen preview and export — research prototype**

Early-stage iOS prototype assets for inspecting a synthetic layered concrete specimen, previewing a generated RGB texture, and exporting 3D geometry and dimensional data.

> **Research status:** These are synthetic demonstration outputs, **not** iPhone LiDAR captures or validated dimensional measurements. The Swift/Xcode source code is not yet included.

## Current specimen

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

**Pending upload:** The image, model and CSV assets are prepared separately; they have not yet been committed to this repository. The original Swift/Xcode source has also not been supplied.

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
| Synthetic model and texture export | Example outputs generated |
| Blender RGB texture rendering | Under verification |
| Swift / Xcode source available in repository | Not yet |
| Real LiDAR capture and accuracy validation | Not yet |

## Roadmap

1. Add the original Swift/Xcode application source and reproducible build steps.
2. Confirm consistent RGB texture rendering inside the app and in Blender.
3. Test optional synthetic roughness and sampling noise, clearly separated from sensor data.
4. Conduct physical specimen experiments and quantify errors against reference dimensions.

**Research direction:** smartphone RGB–LiDAR-based evaluation of layered geometry in 3D concrete printing (3DCP).
