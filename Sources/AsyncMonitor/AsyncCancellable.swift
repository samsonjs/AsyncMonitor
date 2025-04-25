public protocol AsyncCancellable: Hashable {
    func cancel()

    func store(in set: inout Set<AnyAsyncCancellable>)
}

public extension AsyncCancellable {
    func store(in set: inout Set<AnyAsyncCancellable>) {
        set.insert(AnyAsyncCancellable(cancellable: self))
    }
}
