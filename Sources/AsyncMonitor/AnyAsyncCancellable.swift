public class AnyAsyncCancellable: AsyncCancellable {
    let canceller: () -> Void

    init<AC: AsyncCancellable>(cancellable: AC) {
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
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
