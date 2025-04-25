import Foundation
import Testing
@testable import AsyncMonitor

@MainActor class AsyncMonitorTests {
    let center = NotificationCenter()
    let name = Notification.Name("a random notification")

    private var subject: AsyncMonitor?

    @Test func callsBlockWhenNotificationsArePosted() async throws {
        await withCheckedContinuation { [center, name] continuation in
            subject = center.notifications(named: name).map(\.name).monitor { receivedName in
                #expect(name == receivedName)
                continuation.resume()
            }
            Task {
                center.post(name: name, object: nil)
            }
        }
    }

    @Test func doesNotCallBlockWhenOtherNotificationsArePosted() async throws {
        subject = center.notifications(named: name).map(\.name).monitor { receivedName in
            Issue.record("Called for irrelevant notification \(receivedName)")
        }
        Task {
            center.post(name: Notification.Name("something else"), object: nil)
        }
        try await Task.sleep(for: .milliseconds(10))
    }

    @Test func stopsCallingBlockWhenDeallocated() async throws {
        subject = center.notifications(named: name).map(\.name).monitor { _ in
            Issue.record("Called after deallocation")
        }

        Task {
            subject = nil
            center.post(name: name, object: nil)
        }

        try await Task.sleep(for: .milliseconds(10))
    }

    class Owner {
        let deinitHook: () -> Void

        private var cancellable: (any AsyncCancellable)?

        @MainActor init(center: NotificationCenter, deinitHook: @escaping () -> Void) {
            self.deinitHook = deinitHook
            let name = Notification.Name("irrelevant name")
            cancellable = center.notifications(named: name).map(\.name)
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

    @Test func stopsCallingBlockWhenContextIsDeallocated() async throws {
        var context: NSObject? = NSObject()
        subject = center.notifications(named: name).map(\.name)
            .monitor(context: context!) { context, receivedName in
                Issue.record("Called after context was deallocated")
            }
        context = nil
        Task {
            center.post(name: name, object: nil)
        }
        try await Task.sleep(for: .milliseconds(10))
    }
}
