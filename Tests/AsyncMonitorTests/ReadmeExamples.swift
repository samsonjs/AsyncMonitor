import Foundation
@testable import AsyncMonitor

// MARK: Basics

class SimplestVersion {
    let cancellable = NotificationCenter.default
        .notifications(named: .NSCalendarDayChanged)
        .map(\.name)
        .monitor { _ in
            print("The date is now \(Date.now)")
        }
}

class WithContext {
    var cancellables = Set<AnyAsyncCancellable>()

    init() {
        NotificationCenter.default
            .notifications(named: .NSCalendarDayChanged)
            .map(\.name)
            .monitor(context: self) { _self, _ in
                _self.dayChanged()
            }.store(in: &cancellables)
    }

    func dayChanged() {
        print("The date is now \(Date.now)")
    }
}

// MARK: - Combine

import Combine

class CombineExample {
    var cancellables = Set<AnyAsyncCancellable>()

    init() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .values
            .monitor { date in
                print("Timer fired at \(date)")
            }
            .store(in: &cancellables)
    }
}

// MARK: - KVO

class KVOExample {
    var cancellables = Set<AnyAsyncCancellable>()

    init() {
        let progress = Progress(totalUnitCount: 42)
        progress.values(for: \.fractionCompleted) { fraction in
            print("Progress is \(fraction.formatted(.percent))%")
        }.store(in: &cancellables)
    }
}
