import Foundation
import Metal
import MetalKit

final class MetalView: MTKView, MTKViewDelegate {
    private let interactor: MetalInteractor

    init(interactor: MetalInteractor, pixelFormat: MTLPixelFormat) {
        self.interactor = interactor

        super.init(frame: .zero, device: interactor.device)

        self.clearColor = MTLClearColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1
        )
        self.colorPixelFormat = pixelFormat

        self.delegate = self
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    var drawableSizeWillChange: (CGSize) -> Void = { _ in }
    var drawAction: (MTLRenderCommandEncoder) -> Void = { _ in }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.drawableSizeWillChange(size)
    }

    func draw(in view: MTKView) {
        self.interactor.draw(in: view, action: self.drawAction)
    }
}
