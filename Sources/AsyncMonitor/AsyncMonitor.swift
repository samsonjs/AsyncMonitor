/// A monitor that observes an asynchronous sequence and invokes the given block for each received element.
///
/// The element must be `Sendable` so to use it to monitor notifications from `NotificationCenter` you'll need to map them to
/// something sendable before calling `monitor` on the sequence. e.g.
///
/// ```
/// NotificationCenter.default
///     .notifications(named: .NSCalendarDayChanged)
///     .map(\.name)
///     .monitor { _ in whatever() }
///     .store(in: &cancellables)
/// ```
public final class AsyncMonitor: Hashable, AsyncCancellable {
    let task: Task<Void, Never>

    /// Creates an ``AsyncMonitor`` that observes the provided asynchronous sequence.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit.
    ///                Defaults to `#isolation`, preserving the caller's actor isolation.
    ///   - sequence: The asynchronous sequence of elements to observe.
    ///   - block: A closure to execute for each element yielded by the sequence.
    @available(iOS 18, *)
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

    /// Creates an ``AsyncMonitor`` that observes the provided asynchronous sequence.
    ///
    /// - Parameters:
    ///   - sequence: The asynchronous sequence of elements to observe.
    ///   - block: A closure to execute for each element yielded by the sequence.
    @available(iOS, introduced: 17, obsoleted: 18)
    public init<Element: Sendable, Sequence>(
        sequence: sending Sequence,
        @_inheritActorContext performing block: @escaping @Sendable (Element) async -> Void
    ) where Sequence: AsyncSequence, Element == Sequence.Element {
        self.task = Task {
            do {
                for try await element in sequence {
                    await block(element)
                }
            } catch {
                guard !Task.isCancelled else { return }

                print("Error iterating over sequence: \(error)")
            }
        }
    }

    deinit {
        cancel()
    }

    // MARK: AsyncCancellable conformance

    /// Cancels the underlying task monitoring the asynchronous sequence.
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
