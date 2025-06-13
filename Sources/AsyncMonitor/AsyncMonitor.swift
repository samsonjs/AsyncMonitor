/// A monitor that observes an asynchronous sequence and invokes the given block for each received element.
///
/// `AsyncMonitor` wraps the observation of an async sequence in a `Task`, providing automatic cancellation
/// and memory management. Elements must be `Sendable`. For notifications, map to something sendable:
///
/// ```swift
/// NotificationCenter.default
///     .notifications(named: .NSCalendarDayChanged)
///     .map(\.name)
///     .monitor { _ in print("Day changed!") }
/// ```
///
/// On iOS 18+, preserves the caller's actor isolation context by default.
///
public final class AsyncMonitor: Hashable, AsyncCancellable {
    let task: Task<Void, Never>

    /// Creates an ``AsyncMonitor`` that observes the provided asynchronous sequence with actor isolation support (iOS 18+).
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`.
    ///   - sequence: The asynchronous sequence of elements to observe.
    ///   - block: A closure to execute for each element yielded by the sequence.
    @available(iOS 18, macOS 15, *)
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

    /// Creates an ``AsyncMonitor`` for sequences that may throw errors (iOS 18+).
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`.
    ///   - sequence: The asynchronous sequence of elements to observe. May throw errors.
    ///   - block: A closure to execute for each element yielded by the sequence.
    @available(iOS 18, macOS 15, *)
    public init<Element: Sendable, Sequence: AsyncSequence>(
        isolation: isolated (any Actor)? = #isolation,
        sequence: Sequence,
        performing block: @escaping (Element) async -> Void
    ) where Sequence.Element == Element {
        self.task = Task {
            _ = isolation // use capture trick to inherit isolation

            do {
                for try await element in sequence {
                    await block(element)
                }
            } catch {
                guard !Task.isCancelled else { return }
            }
        }
    }

    /// Creates an ``AsyncMonitor`` for iOS 17 compatibility.
    ///
    /// - Parameters:
    ///   - sequence: The asynchronous sequence of elements to observe. Must be `Sendable`.
    ///   - block: A `@Sendable` closure to execute for each element yielded by the sequence.
    @available(iOS, introduced: 17, obsoleted: 18)
    @available(macOS, introduced: 14, obsoleted: 15)
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

    /// Cancels the underlying task. Safe to call multiple times and automatically called when deallocated.
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
