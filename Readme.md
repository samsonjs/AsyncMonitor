# AsyncMonitor

[![0 dependencies!](https://0dependencies.dev/0dependencies.svg)](https://0dependencies.dev)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsamsonjs%2FAsyncMonitor%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/samsonjs/AsyncMonitor)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsamsonjs%2FAsyncMonitor%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/samsonjs/AsyncMonitor)

## Overview

AsyncMonitor is a Swift library that provides a simple and easy-to-use way to manage Swift concurrency `Task`s that observe async sequences. The `AsyncMonitor` class allows you to create tasks that observe streams and call the given closure with each new value, and optionally also with a context parameter so you don't have to manage its lifetime.

It uses a Swift `Task` to ensure that all resources are properly cleaned up when the `AsyncMonitor` is cancelled or deallocated.

That's it. It's pretty trivial. I just got tired of writing it over and over, mainly for notifications. You still have to map your `Notification`s to something sendable, which brings me to another point. This package pairs nicely with [NotificationSmuggler](https://github.com/samsonjs/NotificationSmuggler) for a complete notification handling system in the Swift 6 concurrency world.

## Usage

The simplest example uses a closure that receives the notification. The closure is async so you can await in there if you need to.

```swift
import AsyncMonitor

class SimplestVersion {
    let cancellable = NotificationCenter.default
        .notifications(named: .NSCalendarDayChanged)
        .map(\.name)
        .monitor { _ in
            print("The date is now \(Date.now)")
        }
}
```

This example uses the context parameter to avoid reference cycles with `self`.

```swift
final class WithContext: Sendable {
    nonisolated(unsafe) var cancellables = Set<AnyAsyncCancellable>()

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
```

### Combine

Working with Combine publishers is trivial thanks to [`AnyPublisher.values`][values].

```swift
@preconcurrency import Combine

class CombineExample {
    var cancellables: Set<AnyAsyncCancellable> = []

    init() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .values
            .monitor { date in
                print("Timer fired at \(date)")
            }.store(in: &cancellables)
    }
}
```

[values]: https://developer.apple.com/documentation/combine/anypublisher/values-3s2uy

### Key-Value Observing (KVO) extension

When you need to observe an object that uses [KVO][] there's an extension method you can use to monitor it:

```swift
class KVOExample {
    var cancellables: Set<AnyAsyncCancellable> = []

    init() {
        let progress = Progress(totalUnitCount: 42)
        progress.monitorValues(for: \.fractionCompleted, options: [.initial, .new]) { fraction in
            print("Progress is \(fraction.formatted(.percent))%")
        }.store(in: &cancellables)
    }
}
```

[KVO]: https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/KVO.html

## Installation

The only way to install this package is with Swift Package Manager (SPM). Please [file a new issue][] or submit a pull-request if you want to use something else.

[file a new issue]: https://github.com/samsonjs/AsyncMonitor/issues/new

### Supported Platforms

This package is supported on iOS 17.0+ and macOS 14.0+.

### Xcode

When you're integrating this into an app with Xcode then go to your project's Package Dependencies and enter the URL `https://github.com/samsonjs/AsyncMonitor` and then go through the usual flow for adding packages.

### Swift Package Manager (SPM)

When you're integrating this using SPM on its own then add this to the list of dependencies your Package.swift file:

```swift
.package(url: "https://github.com/samsonjs/AsyncMonitor.git", .upToNextMajor(from: "0.3.1"))
```

and then add `"AsyncMonitor"` to the list of dependencies in your target as well.

## License

Copyright © 2025 [Sami Samhuri](https://samhuri.net) <sami@samhuri.net>. Released under the terms of the [MIT License][MIT].

[MIT]: https://sjs.mit-license.org
