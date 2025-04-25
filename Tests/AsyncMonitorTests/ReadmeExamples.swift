import Foundation
@testable import AsyncMonitor

@MainActor class SimplestVersion {
    let cancellable = NotificationCenter.default
        .notifications(named: .NSCalendarDayChanged).map(\.name)
        .monitor { _ in
            print("The date is now \(Date.now)")
        }
}

@MainActor class WithContext {
    var cancellables = Set<AnyAsyncCancellable>()

    init() {
        NotificationCenter.default
            .notifications(named: .NSCalendarDayChanged).map(\.name)
            .monitor(context: self) { _self, _ in
                _self.dayChanged()
            }.store(in: &cancellables)
    }

    func dayChanged() {
        print("The date is now \(Date.now)")
    }
}
