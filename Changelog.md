# Changelog

## [Unreleased]

- Your change here.

[Unreleased]: https://github.com/samsonjs/AsyncMonitor/compare/0.3.1...HEAD

## [0.3.1] - 2025-05-25

### Changed
- Updated documentation in Readme.md

[0.3.1]: https://github.com/samsonjs/AsyncMonitor/compare/0.3...0.3.1

## [0.3] - 2025-05-25

### Added
- Support for iOS 17 and macOS 14 (expanded platform compatibility)
- Legacy initializers and monitor methods with Sendable requirements for iOS 17+ compatibility
- Backward compatibility layer for actor isolation features

### Changed
- Enhanced AsyncMonitor class with dual initializer pattern for different iOS versions
- Improved AsyncSequence extensions with version-specific monitor methods
- Updated NSObject+AsyncKVO implementation for broader platform support

[0.3]: https://github.com/samsonjs/AsyncMonitor/compare/0.2.1...0.3

## [0.2.1] - 2025-04-26

### Changed
- **Breaking**: Refactored KVO monitoring API
  - Split `values` method into separate `values(for:)` method that returns AsyncStream
  - Added `monitorValues(for:)` convenience method that combines values observation with monitoring
- Replaced `TokenLocker` with `ValueLocker` for improved value management

### Added
- Enhanced test coverage for NSObject+AsyncKVO functionality
- Additional test cases for async cancellable behavior

[0.2.1]: https://github.com/samsonjs/AsyncMonitor/compare/0.2...0.2.1

## [0.2] - 2025-04-26

### Changed
- Version bump to 0.2

[0.2]: https://github.com/samsonjs/AsyncMonitor/compare/0.1.1...0.2

## [0.1.1] - 2025-04-25

### Changed
- Updated minimum iOS platform requirement to 18.0
- Removed main actor restrictions from public API

### Added
- Comprehensive documentation comments on public API
- Enhanced README with detailed usage examples and patterns
- Expanded test suite coverage

[0.1.1]: https://github.com/samsonjs/AsyncMonitor/compare/0.1...0.1.1

## [0.1] - 2025-04-25

### Added
- Initial release of AsyncMonitor
- Core `AsyncMonitor` class for wrapping async sequence observation in manageable Tasks
- `AsyncCancellable` protocol and `AnyAsyncCancellable` type-eraser for uniform cancellation
- AsyncSequence extensions with `.monitor()` convenience methods
- KVO integration via `NSObject+AsyncKVO` extension
- Support for context-aware monitoring to prevent reference cycles
- Swift Testing framework integration
- Comprehensive test suite
- Documentation and usage examples

[0.1]: https://github.com/samsonjs/AsyncMonitor/releases/tag/0.1
