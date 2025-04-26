import Foundation

extension AsyncSequence where Element: Sendable {
    static func just(_ value: Element) -> AsyncStream<Element> {
        AsyncStream { continuation in
            continuation.yield(value)
        }
    }
}
