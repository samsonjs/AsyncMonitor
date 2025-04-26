public import Foundation

extension KeyPath: @unchecked @retroactive Sendable where Value: Sendable {}

public extension NSObjectProtocol where Self: NSObject {
    func values<Value: Sendable>(
        for keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Value) -> Void
    ) -> any AsyncCancellable {
        let (stream, continuation) = AsyncStream<Value>.makeStream()
        let token = self.observe(keyPath, options: options) { object, _ in
            continuation.yield(object[keyPath: keyPath])
        }
        return stream.monitor { value in
            _ = token // keep this alive
            changeHandler(value)
        }
    }
}
