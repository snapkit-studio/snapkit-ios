// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnapKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SnapKit",
            targets: ["SnapKit"]
        ),
    ],
    targets: [
        .target(
            name: "SnapKit",
            dependencies: []
        ),
        .testTarget(
            name: "SnapKitTests",
            dependencies: ["SnapKit"]
        ),
    ]
)
