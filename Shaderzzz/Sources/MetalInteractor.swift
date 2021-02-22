import Foundation
import Metal
import MetalKit

extension MetalInteractor {
    static let `default`: MetalInteractor = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("no metal device")
        }
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("no metal command queue")
        }
        guard let library = device.makeDefaultLibrary() else {
            fatalError("no metal library")
        }
        return .init(device: device, commandQueue: commandQueue, library: library)
    }()
}

struct ShaderNames {
    let vertex: String
    let fragment: String
}

final class MetalInteractor {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let library: MTLLibrary

    init(device: MTLDevice, commandQueue: MTLCommandQueue, library: MTLLibrary) {
        self.device = device
        self.commandQueue = commandQueue
        self.library = library
    }

    func makeRenderPipelineState(
        functionNames: ShaderNames,
        pixelFormat: MTLPixelFormat
    ) throws -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = self.library.makeFunction(name: functionNames.vertex)
        descriptor.fragmentFunction = self.library.makeFunction(name: functionNames.fragment)
        descriptor.colorAttachments[0].pixelFormat = pixelFormat
        return try self.device.makeRenderPipelineState(descriptor: descriptor)
    }

    func draw(in view: MTKView, action: (MTLRenderCommandEncoder) -> Void) {
        assert(view.device === self.device)

        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = self.commandQueue.makeCommandBuffer(),
              let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        do {
            action(renderCommandEncoder)
        }
        renderCommandEncoder.endEncoding()
        view.currentDrawable.flatMap(commandBuffer.present(_:))
        commandBuffer.commit()
    }
}
