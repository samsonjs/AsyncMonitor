/// Represents an async operation that can be cancelled.
public protocol AsyncCancellable: AnyObject, Hashable {
    /// Cancels the operation.
    func cancel()

    /// Stores this cancellable in the given set, using the type-erasing wrapper ``AnyAsyncCancellable``. This method has a
    /// default implementation and you typically shouldn't need to override it.
    func store(in set: inout Set<AnyAsyncCancellable>)
}

// MARK: Default implementations

public extension AsyncCancellable {
    func store(in set: inout Set<AnyAsyncCancellable>) {
        set.insert(AnyAsyncCancellable(cancellable: self))
    }
}

// MARK: Hashable conformance

public extension AsyncCancellable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
