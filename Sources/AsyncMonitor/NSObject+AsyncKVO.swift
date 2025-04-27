public import Foundation

extension KeyPath: @unchecked @retroactive Sendable where Value: Sendable {}

public extension NSObjectProtocol where Self: NSObject {
    /// Observes changes to the specified key path on the object and asynchronously yields each value. Values must be `Sendable`.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to observe on this object. The value must be `Sendable`.
    ///   - options: KVO options to use for observation. Defaults to an empty set.
    ///   - changeHandler: A closure that's executed with each new value.
    func monitorValues<Value: Sendable>(
        for keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Value) -> Void
    ) -> any AsyncCancellable {
        values(for: keyPath, options: options)
            .monitor(changeHandler)
    }

    /// Returns an `AsyncSequence` of `Value`s for all changes to the given key path on this object.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to observe on this object. The value must be `Sendable`.
    ///   - options: KVO options to use for observation. Defaults to an empty set.
    func values<Value: Sendable>(
        for keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = []
    ) -> some AsyncSequence<Value, Never> {
        let (stream, continuation) = AsyncStream<Value>.makeStream()
        let token: NSKeyValueObservation? = self.observe(keyPath, options: options) { object, _ in
            continuation.yield(object[keyPath: keyPath])
        }
        // A nice side-effect of this is that the stream retains the token automatically.
        let locker = ValueLocker(value: token)
        continuation.onTermination = { _ in
            locker.modify { $0 = nil }
        }
        return stream
    }
}
