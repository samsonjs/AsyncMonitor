/// Type-erasing wrapper for ``AsyncCancellable`` that automatically cancels when deallocated.
///
/// `AnyAsyncCancellable` provides automatic cancellation when deallocated, making it safe to store
/// cancellables without explicitly managing their lifecycle.
///
public class AnyAsyncCancellable: AsyncCancellable {
    lazy var id = ObjectIdentifier(self)

    let canceller: () -> Void

    /// Creates a type-erased wrapper around the provided cancellable.
    ///
    /// The wrapper will call the cancellable's `cancel()` method when either
    /// explicitly cancelled or deallocated.
    ///
    /// - Parameter cancellable: The ``AsyncCancellable`` to wrap.
    public init<AC: AsyncCancellable>(cancellable: AC) {
        canceller = { cancellable.cancel() }
    }

    deinit {
        cancel()
    }

    // MARK: AsyncCancellable conformance

    /// Cancels the wrapped cancellable. Safe to call multiple times and automatically called on deallocation.
    public func cancel() {
        canceller()
    }

    // MARK: Hashable conformance

    public static func == (lhs: AnyAsyncCancellable, rhs: AnyAsyncCancellable) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
