import Foundation

final class TokenLocker: @unchecked Sendable {
    private let lock = NSLock()
    private var unsafeToken: NSKeyValueObservation?

    init(token: NSKeyValueObservation) {
        unsafeToken = token
    }

    func clear() {
        lock.withLock {
            unsafeToken = nil
        }
    }
}
