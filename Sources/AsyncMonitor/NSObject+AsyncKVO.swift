public import Foundation

extension KeyPath: @unchecked @retroactive Sendable where Value: Sendable {}

public extension NSObjectProtocol where Self: NSObject {
    /// Returns an `AsyncSequence` of values for all changes to the given key path on this object.
    ///
    /// This method creates an `AsyncStream` that yields the current value of the specified key path
    /// whenever it changes via Key-Value Observing (KVO). The stream automatically manages the KVO
    /// observation lifecycle and cleans up when the stream is terminated.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to observe on this object. The value type must be `Sendable`
    ///              to ensure thread safety across async contexts.
    ///   - options: KVO options to use for observation. Defaults to an empty set.
    ///              See `NSKeyValueObservingOptions` for available options.
    ///
    /// - Returns: An `AsyncStream<Value>` that yields the current value of the key path
    ///            whenever it changes.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let progress = Progress(totalUnitCount: 100)
    /// 
    /// for await fraction in progress.values(for: \.fractionCompleted) {
    ///     print("Progress: \(fraction.formatted(.percent))")
    ///     if fraction >= 1.0 { break }
    /// }
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// The returned stream is thread-safe and can be consumed from any actor context.
    /// The KVO observation token is automatically retained by the stream and released
    /// when the stream terminates.
    ///
    /// - Important: The observed object must remain alive for the duration of the observation.
    ///   If the object is deallocated, the stream will terminate.
    func values<Value: Sendable>(
        for keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = []
    ) -> AsyncStream<Value> {
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

@available(iOS 18, macOS 15, *)
public extension NSObjectProtocol where Self: NSObject {
    /// Observes changes to the specified key path on the object and executes a handler for each change.
    ///
    /// This method combines KVO observation with ``AsyncMonitor`` to provide a convenient way to
    /// monitor object property changes. It creates an ``AsyncMonitor`` that observes the key path
    /// and preserves the caller's actor isolation context.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to observe on this object. The value type must be `Sendable`
    ///              to ensure thread safety across async contexts.
    ///   - options: KVO options to use for observation. Defaults to an empty set.
    ///              See `NSKeyValueObservingOptions` for available options.
    ///   - changeHandler: A closure that's executed with each new value. The closure runs with
    ///                    the same actor isolation as the caller.
    ///
    /// - Returns: An ``AsyncCancellable`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @MainActor class ProgressView: UIView {
    ///     var cancellables: Set<AnyAsyncCancellable> = []
    ///     
    ///     func observeProgress(_ progress: Progress) {
    ///         // Handler runs on MainActor since caller is @MainActor
    ///         progress.monitorValues(for: \.fractionCompleted) { [weak self] fraction in
    ///             self?.updateProgressBar(fraction)
    ///         }.store(in: &cancellables)
    ///     }
    ///     
    ///     func updateProgressBar(_ fraction: Double) {
    ///         // Update UI safely on MainActor
    ///     }
    /// }
    /// ```
    ///
    /// ## Usage with KVO Options
    ///
    /// ```swift
    /// object.monitorValues(for: \.property, options: [.initial, .new]) { newValue in
    ///     print("Property changed to: \(newValue)")
    /// }
    /// ```
    func monitorValues<Value: Sendable>(
        for keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Value) -> Void
    ) -> any AsyncCancellable {
        values(for: keyPath, options: options)
            .monitor(changeHandler)
    }
}

@available(iOS, introduced: 17, obsoleted: 18)
@available(macOS, introduced: 14, obsoleted: 15)
public extension NSObjectProtocol where Self: NSObject {
    /// Observes changes to the specified key path on the object and executes a handler for each change (iOS 17 compatibility).
    ///
    /// This method provides backward compatibility for iOS 17. It combines KVO observation with ``AsyncMonitor``
    /// and requires a `@Sendable` closure for thread safety.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to observe on this object. The value type must be `Sendable`
    ///              to ensure thread safety across async contexts.
    ///   - options: KVO options to use for observation. Defaults to an empty set.
    ///              See `NSKeyValueObservingOptions` for available options.
    ///   - changeHandler: A `@Sendable` closure that's executed with each new value.
    ///
    /// - Returns: An ``AsyncCancellable`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class ProgressObserver {
    ///     var cancellables: Set<AnyAsyncCancellable> = []
    ///     
    ///     func observeProgress(_ progress: Progress) {
    ///         progress.monitorValues(for: \.fractionCompleted) { fraction in
    ///             print("Progress: \(fraction.formatted(.percent))")
    ///         }.store(in: &cancellables)
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This method is deprecated in iOS 18+ in favour of the non-`@Sendable` version
    ///   which provides better actor isolation support.
    func monitorValues<Value: Sendable>(
        for keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping @Sendable (Value) -> Void
    ) -> any AsyncCancellable {
        values(for: keyPath, options: options)
            .monitor(changeHandler)
    }
}
