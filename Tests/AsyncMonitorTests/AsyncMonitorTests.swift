import Foundation
import Testing
@testable import AsyncMonitor

class AsyncMonitorTests {
    let center = NotificationCenter()
    let name = Notification.Name("a random notification")

    private var subject: AsyncMonitor?

    @Test func callsBlockWhenNotificationsArePosted() async throws {
        await withCheckedContinuation { [center, name] continuation in
            subject = center.notifications(named: name)
                .map(\.name)
                .monitor { receivedName in
                    #expect(name == receivedName)
                    continuation.resume()
                }
            Task {
                center.post(name: name, object: nil)
            }
        }
    }

    @Test func doesNotCallBlockWhenOtherNotificationsArePosted() async throws {
        subject = center.notifications(named: name)
            .map(\.name)
            .monitor { receivedName in
                Issue.record("Called for irrelevant notification \(receivedName)")
            }
        Task { [center] in
            center.post(name: Notification.Name("something else"), object: nil)
        }
        try await Task.sleep(for: .milliseconds(10))
    }

    @Test @MainActor func stopsCallingBlockWhenDeallocated() async throws {
        subject = center.notifications(named: name)
            .map(\.name)
            .monitor { _ in
                Issue.record("Called after deallocation")
            }

        Task { @MainActor in
            subject = nil
            center.post(name: name, object: nil)
        }

        try await Task.sleep(for: .milliseconds(10))
    }

    final class Owner: Sendable {
        let deinitHook: @Sendable () -> Void

        nonisolated(unsafe) private var cancellable: (any AsyncCancellable)?

        init(center: NotificationCenter, deinitHook: @escaping @Sendable () -> Void) {
            self.deinitHook = deinitHook
            let name = Notification.Name("irrelevant name")
            cancellable = center.notifications(named: name)
                .map(\.name)
                .monitor(context: self) { _, _ in }
        }

        deinit {
            deinitHook()
        }
    }

    private var owner: Owner?

    @Test(.timeLimit(.minutes(1))) func doesNotCreateReferenceCyclesWithContext() async throws {
        await withCheckedContinuation { continuation in
            self.owner = Owner(center: center) {
                continuation.resume()
            }
            self.owner = nil
        }
    }

    final class SendableObject: NSObject, Sendable {}

    @Test func stopsCallingBlockWhenContextIsDeallocated() async throws {
        var context: SendableObject? = SendableObject()
        subject = center.notifications(named: name)
            .map(\.name)
            .monitor(context: context!) { context, receivedName in
                Issue.record("Called after context was deallocated")
            }
        context = nil
        Task { [center, name] in
            center.post(name: name, object: nil)
        }
        try await Task.sleep(for: .milliseconds(10))
    }

    @Test func equatable() throws {
        let subject = AsyncMonitor(sequence: AsyncStream.just(42)) { _ in }
        #expect(subject == subject)
        #expect(subject != AsyncMonitor(sequence: AsyncStream.just(42)) { _ in })
    }

    @Test func hashable() throws {
        let subjects = (1...100).map { _ in
            AsyncMonitor(sequence: AsyncStream.just(42)) { _ in }
        }
        var hashValues: Set<Int> = []
        for subject in subjects {
            hashValues.insert(subject.hashValue)
        }
        #expect(hashValues.count == subjects.count)
    }
}
