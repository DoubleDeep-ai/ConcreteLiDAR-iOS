import SwiftUI
import SceneKit
import UIKit
import simd

// Synthetic geometry only. No ARKit, camera, or measured LiDAR data.
struct ContentView: View {
    @State private var useTexture = true
    @State private var texture = SyntheticTexture.make()
    @State private var width = 500
    @State private var depth = 500
    @State private var height = 150
    @State private var layers = 5
    @State private var scene = SCNScene()
    @State private var status = "가상 데이터 · 실제 LiDAR 측정 아님"
    @State private var exportPath = ""
    @State private var share: ExportShare?
    @State private var current = SyntheticSpecimen()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Group {
                    Text("SYNTHETIC · 가상 시편").font(.headline).foregroundColor(.orange)
                    SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                        .frame(height: 250).background(Color.black)
                    Text("드래그: 회전 / 두 손가락: 확대·축소").font(.caption)
                    }
                    Group {
                    Toggle("RGB 텍스처 표시", isOn: $useTexture)
                        .onChange(of: useTexture) { _ in refreshMaterial() }
                    Text("텍스처 1024 × 1024 px · 합성 색상 무늬, 실제 요철 아님").font(.caption)
                    Stepper("가로: \(width) mm", value: $width, in: 200...1000, step: 50)
                    Stepper("세로: \(depth) mm", value: $depth, in: 200...1000, step: 50)
                    Stepper("전체 높이: \(height) mm", value: $height, in: 50...300, step: 10)
                    Stepper("층 수: \(layers)", value: $layers, in: 1...10)
                    Text("벽 두께 40 mm 고정 · 밑판 없는 사각 링").font(.caption)
                    }
                    Group {
                    Button("1. 설정한 치수로 시편 생성") { rebuild() }
                        .buttonStyle(.borderedProminent)
                    Text("현재 생성 모델: \(Int(current.w * 1000)) × \(Int(current.d * 1000)) × \(Int(current.h * 1000)) mm / \(current.count)층")
                        .font(.caption)
                    Text(String(format: "층 높이 %.2f mm · 벽 단면적 %.2f mm²", current.h * 1000 / Double(current.count), current.t * current.h * 1_000_000 / Double(current.count)))
                        .font(.caption)
                    Button("2. OBJ + MTL + PNG + PLY + CSV 저장") { export() }
                        .buttonStyle(.borderedProminent)
                    Text(status).font(.caption)
                    }
                    Group {
                    if !exportPath.isEmpty {
                        Text("시뮬레이터 저장 폴더:").font(.caption.bold())
                        Text(exportPath).font(.caption2).textSelection(.enabled)
                        Button("저장 경로 복사") { UIPasteboard.general.string = exportPath }
                    }
                    Text("단면적은 가정한 직사각형 벽 단면(두께 × 층 높이)의 계산값입니다. 센서 정확도나 실제 적층 단면적을 검증한 결과가 아닙니다.")
                        .font(.caption).foregroundColor(.secondary)
                    }
                }.padding()
            }
            .navigationTitle("ConcreteLiDAR 연습")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear { rebuild() }
        .sheet(item: $share) { ShareFiles(urls: $0.urls) }
    }

    private func rebuild() {
        current = SyntheticSpecimen(w: Double(width)/1000, d: Double(depth)/1000,
                                    h: Double(height)/1000, t: 0.04, count: layers)
        scene = current.makeScene(texture: useTexture ? texture : nil)
        status = "생성 완료 · 치수 변경 후 생성 버튼을 다시 눌러주세요."
    }

    private func refreshMaterial() {
        scene.rootNode.enumerateChildNodes { node, _ in
            guard let material = node.geometry?.firstMaterial else { return }
            if useTexture {
                material.diffuse.contents = texture
            } else {
                material.diffuse.contents = UIColor.lightGray
            }
        }
    }

    private func export() {
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folder = docs.appendingPathComponent("synthetic_" + UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            let outputs = [("synthetic_specimen.ply", current.ply()),
                           ("synthetic_specimen.obj", current.obj()),
                           ("synthetic_material.mtl", "newmtl synthetic_concrete\nKa 0.2 0.2 0.2\nKd 1.0 1.0 1.0\nKs 0.0 0.0 0.0\nd 1.0\nillum 1\nmap_Kd synthetic_texture.png\n"),
                           ("synthetic_measurements.csv", current.csv()),
                           ("README.txt", "SYNTHETIC DATA ONLY. Not measured LiDAR.\nCoordinates: meters; X width, Y height, Z depth. Origin: base center.\nOBJ/PLY: explicit units in comments; import scale = 1.\nPLY: sampled model surfaces (10 mm maximum quad grid step), no RGB/confidence.\nIncludes hidden interfaces between idealized layers and wall blocks. Not a scan simulation.\nCSV: analytic dimensions, not measurements. Cross-section = wall thickness * layer height, excluding corners.\nTexture: synthetic_texture.png, 1024x1024 pixels, generated RGB colors; not a camera capture. Each quad maps the same image over UV 0..1. Pattern scale is not calibrated and repeats. No geometric roughness or accuracy claim. OBJ always exports the texture even when preview toggle is OFF. Keep OBJ, MTL and PNG in the same folder. PLY remains XYZ only.\n")]
            var urls: [URL] = []
            for (name, text) in outputs {
                let url = folder.appendingPathComponent(name)
                try text.write(to: url, atomically: true, encoding: .utf8)
                urls.append(url)
            }
            guard let png = texture.pngData() else {
                throw NSError(domain: "SyntheticTexture", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "PNG 인코딩 실패"])
            }
            let pngURL = folder.appendingPathComponent("synthetic_texture.png")
            try png.write(to: pngURL, options: .atomic)
            urls.append(pngURL)
            exportPath = folder.path
            print("SYNTHETIC_EXPORT_FOLDER: \(folder.path)")
            status = "6개 파일 저장 완료 · 공유창을 닫아도 파일은 유지됩니다."
            share = ExportShare(urls: urls)
        } catch {
            status = "저장 실패: \(error.localizedDescription)"
        }
    }
}

struct ExportShare: Identifiable {
    let id = UUID()
    let urls: [URL]
}
struct ShareFiles: UIViewControllerRepresentable {
    let urls: [URL]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: urls, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

struct SyntheticSpecimen {
    var w: Double = 0.5
    var d: Double = 0.5
    var h: Double = 0.15
    var t: Double = 0.04
    var count: Int = 5
    struct Box {
        let x0, x1, y0, y1, z0, z1: Double
        var vertices: [SIMD3<Double>] {
            [SIMD3(x0,y0,z0), SIMD3(x1,y0,z0), SIMD3(x1,y1,z0), SIMD3(x0,y1,z0),
             SIMD3(x0,y0,z1), SIMD3(x1,y0,z1), SIMD3(x1,y1,z1), SIMD3(x0,y1,z1)]
        }
    }
    // Outward-oriented quads. Blocks meet without volumetric overlap.
    let faces = [[0,3,2,1], [4,5,6,7], [0,4,7,3], [1,2,6,5], [0,1,5,4], [3,7,6,2]]
    var boxes: [Box] {
        var result: [Box] = []
        for layer in 0..<count {
            let a = Double(layer) * h / Double(count)
            let b = Double(layer+1) * h / Double(count)
            result.append(Box(x0: -w/2, x1: w/2, y0: a, y1: b, z0: -d/2, z1: -d/2+t))
            result.append(Box(x0: -w/2, x1: w/2, y0: a, y1: b, z0: d/2-t, z1: d/2))
            result.append(Box(x0: -w/2, x1: -w/2+t, y0: a, y1: b, z0: -d/2+t, z1: d/2-t))
            result.append(Box(x0: w/2-t, x1: w/2, y0: a, y1: b, z0: -d/2+t, z1: d/2-t))
        }
        return result
    }
    func makeScene(texture: UIImage?) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(white: 0.12, alpha: 1)
        let uv = [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
                  CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1)]
        for box in boxes {
            var vertices: [SCNVector3] = []
            var normals: [SCNVector3] = []
            var coordinates: [CGPoint] = []
            var indices: [Int32] = []
            let points = box.vertices
            for face in faces {
                let base = Int32(vertices.count)
                let normal = simd_normalize(simd_cross(
                    points[face[1]] - points[face[0]],
                    points[face[2]] - points[face[0]]))
                for (j, index) in face.enumerated() {
                    let p = points[index]
                    vertices.append(SCNVector3(Float(p.x), Float(p.y), Float(p.z)))
                    normals.append(SCNVector3(Float(normal.x), Float(normal.y), Float(normal.z)))
                    coordinates.append(uv[j])
                }
                indices += [base, base+1, base+2, base, base+2, base+3]
            }
            let sources = [SCNGeometrySource(vertices: vertices),
                           SCNGeometrySource(normals: normals),
                           SCNGeometrySource(textureCoordinates: coordinates)]
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let geometry = SCNGeometry(sources: sources, elements: [element])
            let material = SCNMaterial()
            material.lightingModel = .lambert
            if let image = texture {
                material.diffuse.contents = image
            } else {
                material.diffuse.contents = UIColor.lightGray
            }
            geometry.materials = [material]
            scene.rootNode.addChildNode(SCNNode(geometry: geometry))
        }
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.zNear = 0.001
        let span = Float(max(w, max(d, h)))
        camera.position = SCNVector3(span*1.3, span*1.2, span*1.5)
        camera.look(at: SCNVector3(0, Float(h/2), 0))
        scene.rootNode.addChildNode(camera)
        return scene
    }
    private func number(_ value: Double) -> String {
        String(format: "%.9f", locale: Locale(identifier: "en_US_POSIX"), value)
    }
    private func row(_ p: SIMD3<Double>) -> String {
        "\(number(p.x)) \(number(p.y)) \(number(p.z))"
    }
    func obj() -> String {
        var lines = ["# SYNTHETIC, not LiDAR", "# units meters; X width Y up Z depth", "mtllib synthetic_material.mtl", "o synthetic_specimen", "vt 0 0", "vt 1 0", "vt 1 1", "vt 0 1", "usemtl synthetic_concrete"]
        for b in boxes { for p in b.vertices { lines.append("v " + row(p)) } }
        for (i,_) in boxes.enumerated() {
            lines.append("g layer_\(i/4+1)_wall_\(i%4+1)")
            for f in faces {
                let v = f.map { $0 + i*8 + 1 }
                lines.append("f \(v[0])/1 \(v[1])/2 \(v[2])/3")
                lines.append("f \(v[0])/1 \(v[2])/3 \(v[3])/4")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }
    func ply() -> String {
        var points: [String] = []
        var seen = Set<String>()
        for b in boxes {
            let v = b.vertices
            for f in faces {
                let start = v[f[0]], u = v[f[1]]-start, z = v[f[3]]-start
                let nu = max(1, Int(ceil(simd_length(u)/0.01)))
                let nv = max(1, Int(ceil(simd_length(z)/0.01)))
                for i in 0...nu { for j in 0...nv {
                    let p = start + u * (Double(i)/Double(nu)) + z * (Double(j)/Double(nv))
                    let key = "\(Int64((p.x*1e9).rounded())),\(Int64((p.y*1e9).rounded())),\(Int64((p.z*1e9).rounded()))"
                    if seen.insert(key).inserted { points.append(row(p)) }
                } }
            }
        }
        let header = ["ply", "format ascii 1.0", "comment SYNTHETIC not measured LiDAR", "comment units meters X width Y up Z depth", "element vertex \(points.count)", "property double x", "property double y", "property double z", "end_header"]
        return (header + points).joined(separator: "\n") + "\n"
    }
    func csv() -> String {
        var lines = ["data_type,layer_id,outer_width_mm,outer_depth_mm,total_height_mm,wall_thickness_mm,layer_height_mm,wall_cross_section_mm2,ring_horizontal_area_mm2"]
        for i in 1...count {
            let values = [w*1000, d*1000, h*1000, t*1000, h*1000/Double(count), t*h*1e6/Double(count), (w*d-(w-2*t)*(d-2*t))*1e6]
            lines.append("synthetic,L\(String(format: "%02d", i))," + values.map { number($0) }.joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }
}

// 동일한 색상 무늬를 재현하기 위한 고정 시드 난수입니다.
struct TextureRandom {
    private var state: UInt64 = 20261019
    mutating func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(Double(state >> 11) / 9007199254740992.0)
    }
}

enum SyntheticTexture {
    static func make() -> UIImage {
        let size = CGSize(width: 1024, height: 1024)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1  // 1024 points = exactly 1024 pixels, not Retina-scaled
        format.opaque = true
        format.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let cg = context.cgContext
            cg.setFillColor(UIColor(red: 0.60, green: 0.59, blue: 0.56, alpha: 1).cgColor)
            cg.fill(CGRect(origin: .zero, size: size))
            var random = TextureRandom()
            // 입자 모양의 색상 패턴이며 표면 꼭짓점은 변경하지 않습니다.
            for _ in 0..<24000 {
                let x = random.next() * 1024
                let y = random.next() * 1024
                let radius = 0.5 + random.next() * 3
                let gray = 0.35 + random.next() * 0.45
                let color = UIColor(red: gray, green: gray * 0.98,
                                    blue: gray * 0.94, alpha: 0.45)
                cg.setFillColor(color.cgColor)
                cg.fillEllipse(in: CGRect(x: x, y: y, width: radius*2, height: radius*2))
            }
            // 어두운 반점도 색상일 뿐 실제 구멍이나 깊이가 아닙니다.
            for _ in 0..<160 {
                let x = random.next() * 1024
                let y = random.next() * 1024
                let radius = 2 + random.next() * 6
                cg.setFillColor(UIColor(white: 0.24, alpha: 0.28).cgColor)
                cg.fillEllipse(in: CGRect(x: x, y: y, width: radius*2, height: radius))
            }
        }
    }
}
