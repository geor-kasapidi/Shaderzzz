import Foundation
import Metal

extension MTLRenderCommandEncoder {
    func setVertexValue<T>(_ value: T, index: Int) {
        var value = value
        self.setVertexBytes(&value, length: MemoryLayout<T>.stride, index: index)
    }

    func setVertexValues<T>(_ values: [T], index: Int) {
        var values = values
        self.setVertexBytes(&values, length: MemoryLayout<T>.stride * values.count, index: index)
    }
}
