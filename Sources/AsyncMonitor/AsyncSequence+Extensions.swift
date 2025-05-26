@available(iOS 18, *)
public extension AsyncSequence where Element: Sendable, Failure == Never {
    /// Observes the elements yielded by this sequence and executes the given closure with each element.
    ///
    /// This method preserves the actor isolation of the caller by default when `isolation` is not specified.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`, preserving the caller's actor isolation.
    ///   - block: A closure that's executed with each yielded element.
    func monitor(
        isolation: isolated (any Actor)? = #isolation,
        _ block: @escaping (Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(isolation: isolation, sequence: self, performing: block)
    }

    /// Observes the elements yielded by this sequence and executes the given closure with each element the weakly-captured
    /// context object.
    ///
    /// This method preserves the actor isolation of the caller by default when `isolation` is not specified.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`, preserving the caller's actor isolation.
    ///   - context: The object to capture weakly for use within the closure.
    ///   - block: A closure that's executed with each yielded element, and the `context`.
    func monitor<Context: AnyObject>(
        isolation: isolated (any Actor)? = #isolation,
        context: Context,
        _ block: @escaping (Context, Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(isolation: isolation, sequence: self) { [weak context] element in
            guard let context else { return }
            await block(context, element)
        }
    }
}

@available(iOS, introduced: 17, obsoleted: 18)
public extension AsyncSequence where Self: Sendable, Element: Sendable {
    /// Observes the elements yielded by this sequence and executes the given closure with each element.
    ///
    /// - Parameters:
    ///   - block: A closure that's executed with each yielded element.
    func monitor(
        _ block: @escaping @Sendable (Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(sequence: self, performing: block)
    }

    /// Observes the elements yielded by this sequence and executes the given closure with each element the weakly-captured
    /// context object.
    ///
    /// - Parameters:
    ///   - context: The object to capture weakly for use within the closure.
    ///   - block: A closure that's executed with each yielded element, and the `context`.
    func monitor<Context: AnyObject & Sendable>(
        context: Context,
        _ block: @escaping @Sendable (Context, Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(sequence: self) { [weak context] element in
            guard let context else { return }
            await block(context, element)
        }
    }
}
