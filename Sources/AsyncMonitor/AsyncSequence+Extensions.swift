public extension AsyncSequence where Element: Sendable, Failure == Never {
    func monitor(
        isolation: isolated (any Actor)? = #isolation,
        _ block: @escaping (Element) async -> Void
    ) -> AsyncMonitor {
        AsyncMonitor(isolation: isolation, sequence: self, performing: block)
    }

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
