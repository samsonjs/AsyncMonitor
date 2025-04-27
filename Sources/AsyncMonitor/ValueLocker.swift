import Foundation

final class ValueLocker<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var unsafeValue: Value

    init(value: Value) {
        unsafeValue = value
    }

    var value: Value {
        lock.withLock { unsafeValue }
    }

    func modify(_ f: (inout Value) -> Void) {
        lock.withLock {
            f(&unsafeValue)
        }
    }
}
