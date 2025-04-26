@testable import AsyncMonitor
import Testing

@MainActor class AsyncCancellableTests {
    var cancellables = Set<AnyAsyncCancellable>()

    @Test func storeInsertsIntoSetAndKeepsSubjectAlive() throws {
        var subject: TestCancellable? = TestCancellable()
        weak var weakSubject: TestCancellable? = subject
        try #require(subject).store(in: &cancellables)
        #expect(cancellables.count == 1)
        subject = nil
        #expect(weakSubject != nil)
        cancellables.removeAll()
        #expect(weakSubject == nil)
    }
}
