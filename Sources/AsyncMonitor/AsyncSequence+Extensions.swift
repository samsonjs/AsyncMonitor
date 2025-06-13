@available(iOS 18, macOS 15, *)
public extension AsyncSequence where Element: Sendable, Failure == Never {
    /// Observes the elements yielded by this sequence and executes the given closure with each element.
    ///
    /// This method creates an ``AsyncMonitor`` that observes the sequence and preserves the caller's
    /// actor isolation context by default. When called from a `@MainActor` context, the monitoring
    /// block will also run on the main actor.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`, 
    ///                preserving the caller's actor isolation.
    ///   - block: A closure that's executed with each yielded element. The closure runs with
    ///            the same actor isolation as the caller.
    ///
    /// - Returns: An ``AsyncMonitor`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @MainActor class ViewModel {
    ///     var cancellables: Set<AnyAsyncCancellable> = []
    ///     
    ///     func startMonitoring() {
    ///         // Monitor runs on MainActor since caller is @MainActor
    ///         NotificationCenter.default
    ///             .notifications(named: .NSCalendarDayChanged)
    ///             .map(\.name)
    ///             .monitor { _ in
    ///                 self.updateUI() // Safe to call @MainActor methods
    ///             }.store(in: &cancellables)
    ///     }
    /// }
    /// ```
    func monitor(
        isolation: isolated (any Actor)? = #isolation,
        _ block: @escaping (Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(isolation: isolation, sequence: self, performing: block)
    }

    /// Observes the elements yielded by this sequence and executes the given closure with each element and the weakly-captured context object.
    ///
    /// This method creates an ``AsyncMonitor`` that weakly captures the provided context object, preventing retain cycles.
    /// If the context object is deallocated, the monitoring block will not be executed for subsequent elements.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`, 
    ///                preserving the caller's actor isolation.
    ///   - context: The object to capture weakly for use within the closure. This prevents retain cycles
    ///              when the context holds a reference to the monitor.
    ///   - block: A closure that's executed with the weakly-captured context and each yielded element.
    ///            The closure runs with the same actor isolation as the caller.
    ///
    /// - Returns: An ``AsyncMonitor`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class DataManager {
    ///     var cancellables: Set<AnyAsyncCancellable> = []
    ///     
    ///     func startMonitoring() {
    ///         // Context is weakly captured, preventing retain cycle
    ///         dataStream
    ///             .monitor(context: self) { manager, data in
    ///                 manager.process(data) // manager won't be nil here
    ///             }.store(in: &cancellables)
    ///     }
    ///     
    ///     func process(_ data: Data) {
    ///         // Process the data
    ///     }
    /// }
    /// ```
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

@available(iOS 18, macOS 15, *)
public extension AsyncSequence where Element: Sendable {
    /// Observes the elements yielded by this sequence and executes the given closure with each element.
    ///
    /// This method creates an ``AsyncMonitor`` that observes the sequence and preserves the caller's
    /// actor isolation context by default. When called from a `@MainActor` context, the monitoring
    /// block will also run on the main actor.
    ///
    /// This version handles sequences that may throw errors. If an error is thrown, it will be logged
    /// and monitoring will stop.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`, 
    ///                preserving the caller's actor isolation.
    ///   - block: A closure that's executed with each yielded element. The closure runs with
    ///            the same actor isolation as the caller.
    ///
    /// - Returns: An ``AsyncMonitor`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NotificationCenter.default
    ///     .notifications(named: .NSCalendarDayChanged)
    ///     .map(\.name)
    ///     .monitor { _ in
    ///         print("Day changed!")
    ///     }.store(in: &cancellables)
    /// ```
    func monitor(
        isolation: isolated (any Actor)? = #isolation,
        _ block: @escaping (Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(isolation: isolation, sequence: self, performing: block)
    }

    /// Observes the elements yielded by this sequence and executes the given closure with each element and the weakly-captured context object.
    ///
    /// This method creates an ``AsyncMonitor`` that weakly captures the provided context object, preventing retain cycles.
    /// If the context object is deallocated, the monitoring block will not be executed for subsequent elements.
    ///
    /// This version handles sequences that may throw errors. If an error is thrown, it will be logged
    /// and monitoring will stop.
    ///
    /// - Parameters:
    ///   - isolation: An optional actor isolation context to inherit. Defaults to `#isolation`, 
    ///                preserving the caller's actor isolation.
    ///   - context: The object to capture weakly for use within the closure. This prevents retain cycles
    ///              when the context holds a reference to the monitor.
    ///   - block: A closure that's executed with the weakly-captured context and each yielded element.
    ///            The closure runs with the same actor isolation as the caller.
    ///
    /// - Returns: An ``AsyncMonitor`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class DataManager {
    ///     var cancellables: Set<AnyAsyncCancellable> = []
    ///     
    ///     func startMonitoring() {
    ///         notificationStream
    ///             .monitor(context: self) { manager, notification in
    ///                 manager.handleNotification(notification)
    ///             }.store(in: &cancellables)
    ///     }
    /// }
    /// ```
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
@available(macOS, introduced: 14, obsoleted: 15)
public extension AsyncSequence where Self: Sendable, Element: Sendable {
    /// Observes the elements yielded by this sequence and executes the given closure with each element (iOS 17 compatibility).
    ///
    /// This method provides backward compatibility for iOS 17. It requires both the sequence and its elements
    /// to be `Sendable`, and uses a `@Sendable` closure for thread safety.
    ///
    /// - Parameters:
    ///   - block: A `@Sendable` closure that's executed with each yielded element.
    ///
    /// - Returns: An ``AsyncMonitor`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let cancellable = sendableAsyncSequence.monitor { element in
    ///     print("Received: \(element)")
    /// }
    /// 
    /// // Store for automatic cleanup
    /// cancellable.store(in: &cancellables)
    /// ```
    ///
    /// - Note: This method is deprecated in iOS 18+ in favour of ``monitor(isolation:_:)``
    ///   which provides better actor isolation support.
    func monitor(
        _ block: @escaping @Sendable (Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(sequence: self, performing: block)
    }

    /// Observes the elements yielded by this sequence and executes the given closure with each element and the weakly-captured context object (iOS 17 compatibility).
    ///
    /// This method provides backward compatibility for iOS 17 with weak reference handling to prevent retain cycles.
    /// It requires the context to be both `AnyObject` and `Sendable` for thread safety.
    ///
    /// - Parameters:
    ///   - context: The object to capture weakly for use within the closure. Must be `Sendable` and will be
    ///              captured weakly to prevent retain cycles.
    ///   - block: A `@Sendable` closure that's executed with the weakly-captured context and each yielded element.
    ///
    /// - Returns: An ``AsyncMonitor`` that can be stored and cancelled as needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class SendableDataManager: Sendable {
    ///     var cancellables: Set<AnyAsyncCancellable> = []
    ///     
    ///     func startMonitoring() {
    ///         // Context is weakly captured, preventing retain cycle
    ///         sendableDataStream
    ///             .monitor(context: self) { manager, data in
    ///                 manager.process(data)
    ///             }.store(in: &cancellables)
    ///     }
    ///     
    ///     func process(_ data: Data) {
    ///         // Process the data
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This method is deprecated in iOS 18+ in favour of ``monitor(isolation:context:_:)``
    ///   which provides better actor isolation support.
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
