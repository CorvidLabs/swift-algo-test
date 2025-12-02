// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-algo-test",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AlgoTest",
            targets: ["AlgoTest"]
        )
    ],
    dependencies: [
        .package(path: "../swift-algorand"),
        .package(path: "../swift-algokit"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AlgoTest",
            dependencies: [
                .product(name: "Algorand", package: "swift-algorand"),
                .product(name: "AlgoKit", package: "swift-algokit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AlgoTestTests",
            dependencies: ["AlgoTest"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
