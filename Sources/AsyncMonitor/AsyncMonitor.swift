public final class AsyncMonitor: Hashable, AsyncCancellable {
    let task: Task<Void, Never>

    public init<Element: Sendable>(
        isolation: isolated (any Actor)? = #isolation,
        sequence: any AsyncSequence<Element, Never>,
        performing block: @escaping (Element) async -> Void
    ) {
        self.task = Task {
            _ = isolation // use capture trick to inherit isolation

            for await element in sequence {
                await block(element)
            }
        }
    }

    deinit {
        cancel()
    }

    // MARK: AsyncCancellable conformance

    public func cancel() {
        task.cancel()
    }

    // MARK: Hashable conformance

    public static func == (lhs: AsyncMonitor, rhs: AsyncMonitor) -> Bool {
        lhs.task == rhs.task
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(task)
    }
}
