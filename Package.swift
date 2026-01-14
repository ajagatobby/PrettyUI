// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrettyUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "PrettyUI",
            targets: ["PrettyUI"]
        ),
    ],
    targets: [
        .target(
            name: "PrettyUI",
            path: "Sources/PrettyUI"
        ),
        .testTarget(
            name: "PrettyUITests",
            dependencies: ["PrettyUI"]
        ),
    ]
)
