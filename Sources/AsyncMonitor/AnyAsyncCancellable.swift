/// Type-erasing wrapper for ``AsyncCancellable`` that ties its instance lifetime to cancellation. In other words, when you release
/// an instance of ``AnyAsyncCancellable`` and it's deallocated then it automatically cancels its given ``AsyncCancellable``.
public class AnyAsyncCancellable: AsyncCancellable {
    lazy var id = ObjectIdentifier(self)

    let canceller: () -> Void

    public init<AC: AsyncCancellable>(cancellable: AC) {
        canceller = { cancellable.cancel() }
    }

    deinit {
        cancel()
    }

    // MARK: AsyncCancellable conformance

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
