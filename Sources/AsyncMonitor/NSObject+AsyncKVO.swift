public import Foundation

extension KeyPath: @unchecked @retroactive Sendable where Value: Sendable {}

public extension NSObjectProtocol where Self: NSObject {
    /// Observes changes to the specified key path on the object and asynchronously yields each value. Values must be `Sendable`.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to observe on this object. The value must be `Sendable`.
    ///   - options: KVO options to use for observation. Defaults to an empty set.
    ///   - changeHandler: A closure that's executed with each new value.
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
