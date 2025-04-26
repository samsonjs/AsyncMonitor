import AsyncMonitor

class TestCancellable: AsyncCancellable {
    lazy var id = ObjectIdentifier(self)
    var isCancelled = false

    func cancel() {
        isCancelled = true
    }

    // MARK: Hashable conformance

    public static func == (lhs: TestCancellable, rhs: TestCancellable) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
