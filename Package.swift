// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AsyncMonitor",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AsyncMonitor",
            targets: ["AsyncMonitor"]),
    ],
    targets: [
        .target(
            name: "AsyncMonitor"
        ),
        .testTarget(
            name: "AsyncMonitorTests",
            dependencies: ["AsyncMonitor"]
        ),
    ]
)
