@testable import AsyncMonitor
import Testing

@MainActor class AnyAsyncCancellableTests {
    var subject: AnyAsyncCancellable!

    @Test func cancelsWhenReleased() {
        let cancellable = TestCancellable()
        subject = AnyAsyncCancellable(cancellable: cancellable)
        #expect(!cancellable.isCancelled)

        subject = nil

        #expect(cancellable.isCancelled)
    }

    @Test func cancelsWhenCancelled() {
        let cancellable = TestCancellable()
        subject = AnyAsyncCancellable(cancellable: cancellable)
        #expect(!cancellable.isCancelled)

        subject.cancel()

        #expect(cancellable.isCancelled)
    }
}
