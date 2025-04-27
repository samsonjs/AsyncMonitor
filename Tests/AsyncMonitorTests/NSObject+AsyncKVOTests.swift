@testable import AsyncMonitor
import Foundation
import Testing

class AsyncKVOTests {
    var subject: Progress? = Progress(totalUnitCount: 42)
    var cancellable: (any AsyncCancellable)?

    @Test(.timeLimit(.minutes(1)))
    func monitorValuesYieldsChanges() async throws {
        let subject = try #require(subject)
        var values = [Double]()
        let total = 3
        cancellable = subject.values(for: \.fractionCompleted)
            .prefix(total)
            .monitor { progress in
                values.append(progress)
            }

        for n in 1...total {
            subject.completedUnitCount += 1
            while values.count < n {
                try await Task.sleep(for: .microseconds(2))
            }
        }

        #expect(values.count == total)
    }

    // It's important that the test or the progress-observing task are not on the same actor, so
    // we make the test @MainActor and observe progress values on another actor. Otherwise it's a
    // deadlock.
    @Test(.timeLimit(.minutes(1)))
    @MainActor func valuesYieldsChanges() async throws {
        let subject = try #require(subject)
        let total = 3
        let task = Task {
            var values = [Double]()
            for await progress in subject.values(for: \.fractionCompleted).prefix(total) {
                values.append(progress)
            }
            return values
        }
        await Task.yield()

        for _ in 1...total {
            subject.completedUnitCount += 1
        }
        let values = await task.value

        #expect(values.count == total)
    }
}
