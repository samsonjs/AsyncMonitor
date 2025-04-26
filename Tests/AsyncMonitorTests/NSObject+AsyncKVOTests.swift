@testable import AsyncMonitor
import Foundation
import Testing

class AsyncKVOTests {
    var subject: Progress? = Progress(totalUnitCount: 42)
    var cancellable: (any AsyncCancellable)?

    @Test func yieldsChanges() async throws {
        let subject = try #require(subject)
        var values = [Double]()
        cancellable = subject.values(for: \.fractionCompleted) { progress in
            values.append(progress)
        }
        for _ in 1...3 {
            subject.completedUnitCount += 1
            await Task.yield()
        }
        #expect(values.count == 3)
    }
}
