// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-xxhash",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .visionOS(.v1),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "XXHash",
            targets: ["XXHash"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing", branch: "main")
    ],
    targets: [
        .target(
            name: "XXHash",
            dependencies: []
        ),
        .testTarget(
            name: "XXHashTests",
            dependencies: [
                "XXHash",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests"
        ),
    ]
)
