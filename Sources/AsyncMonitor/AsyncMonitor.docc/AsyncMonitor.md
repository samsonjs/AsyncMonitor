# ``AsyncMonitor``

Wraps async sequence observation in manageable tasks.

## Overview

AsyncMonitor wraps async sequence observation in a `Task` that can be cancelled and stored. It preserves actor isolation on iOS 18+ and includes KVO integration.

## Basic Usage

```swift
import AsyncMonitor

// Monitor notifications
NotificationCenter.default
    .notifications(named: .NSCalendarDayChanged)
    .map(\.name)
    .monitor { _ in print("Day changed!") }

// Store for longer lifetime
var cancellables: Set<AnyAsyncCancellable> = []

sequence.monitor { element in
    // Handle element
}.store(in: &cancellables)
```

## Context-Aware Monitoring

Prevent retain cycles with weak context:

```swift
class DataController {
    var cancellables: Set<AnyAsyncCancellable> = []
    
    func startMonitoring() {
        dataStream
            .monitor(context: self) { controller, data in
                controller.processData(data)
            }.store(in: &cancellables)
    }
}
```

## KVO Integration

```swift
let progress = Progress(totalUnitCount: 100)

progress.monitorValues(for: \.fractionCompleted, options: [.initial, .new]) { fraction in
    print("Progress: \(fraction.formatted(.percent))")
}.store(in: &cancellables)
```

## Error Handling

Both throwing and non-throwing sequences work. Errors are caught and logged automatically.

```swift
// Non-throwing
Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .values
    .monitor { date in print("Timer: \(date)") }

// Throwing (errors caught automatically)
networkDataStream()
    .monitor { data in processData(data) }
```

## Memory Management

Use weak captures or context to avoid retain cycles:

```swift
// Good
sequence.monitor(context: self) { controller, element in
    controller.handle(element)
}

// Good
sequence.monitor { [weak self] element in
    self?.handle(element)
}

// Bad - creates retain cycle
sequence.monitor { element in
    self.handle(element)
}
```

## Platform Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+

## Topics

### Core Types

- ``AsyncMonitor`` - Wraps async sequence observation in a managed Task
- ``AsyncCancellable`` - Protocol for async operations that can be cancelled
- ``AnyAsyncCancellable`` - Type-erasing wrapper that auto-cancels on deallocation

### Sequence Extensions

- ``Foundation/AsyncSequence/monitor(_:)``
- ``Foundation/AsyncSequence/monitor(context:_:)``

### KVO Integration

- ``Foundation/NSObjectProtocol/monitorValues(for:options:changeHandler:)``
