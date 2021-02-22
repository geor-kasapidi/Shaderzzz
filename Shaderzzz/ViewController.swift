import UIKit
import Metal

extension ShaderNames {
    static let craziness = ShaderNames(vertex: "craziness_vertex", fragment: "craziness_fragment")
    static let flame = ShaderNames(vertex: "flame_vertex", fragment: "flame_fragment")
}

class ViewController: UIViewController {
    override func loadView() {
        self.view = MetalView(interactor: .default, pixelFormat: .bgra8Unorm)
    }

    private lazy var metalView = self.view as! MetalView

    override func viewDidLoad() {
        super.viewDidLoad()

        self.metalView.transform = .init(scaleX: 1, y: -1) // tmp solution

        assert(self.setupDrawing(names: .craziness, dt: 0.01))
    }

    private func setupDrawing(names: ShaderNames, dt: Float) -> Bool {
        let simdRect: [SIMD2<Float>] = [
            .init(-1, -1),
            .init(-1, 1),
            .init(1, -1),
            .init(1, 1),
        ]

        var time: Float = 0

        guard let renderPipelineState = try? MetalInteractor.default.makeRenderPipelineState(
            functionNames: names,
            pixelFormat: self.metalView.colorPixelFormat
        ) else {
            return false
        }

        self.metalView.drawAction = { encoder in
            time += dt

            let drawableSize = self.metalView.drawableSize

            let simdSize = SIMD2<Float>(Float(drawableSize.width), Float(drawableSize.height))

            encoder.setRenderPipelineState(renderPipelineState)

            encoder.setVertexValues(simdRect, index: 0)
            encoder.setVertexValue(time, index: 1)
            encoder.setVertexValue(simdSize, index: 2)

            encoder.drawPrimitives(
                type: .triangleStrip,
                vertexStart: 0,
                vertexCount: simdRect.count
            )
        }

        return true
    }
}
