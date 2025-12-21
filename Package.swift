// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-algotest",
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
        .package(url: "https://github.com/CorvidLabs/swift-algorand.git", from: "0.3.1"),
        .package(url: "https://github.com/CorvidLabs/swift-algokit.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AlgoTest",
            dependencies: [
                .product(name: "Algorand", package: "swift-algorand"),
                .product(name: "AlgoKit", package: "swift-algokit")
            ]
        ),
        .testTarget(
            name: "AlgoTestTests",
            dependencies: ["AlgoTest"]
        )
    ]
)
