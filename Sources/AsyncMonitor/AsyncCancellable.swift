/// Represents an async operation that can be cancelled.
///
/// `AsyncCancellable` provides a common interface for cancelling async operations, similar to
/// Combine's `AnyCancellable` but designed for Swift concurrency patterns.
///
public protocol AsyncCancellable: AnyObject, Hashable {
    /// Cancels the operation. Safe to call multiple times.
    func cancel()

    /// Stores this cancellable in the given set using ``AnyAsyncCancellable``.
    ///
    /// - Parameter set: The set to store the wrapped cancellable in.
    func store(in set: inout Set<AnyAsyncCancellable>)
}

// MARK: Default implementations

public extension AsyncCancellable {
    func store(in set: inout Set<AnyAsyncCancellable>) {
        set.insert(AnyAsyncCancellable(cancellable: self))
    }
}
