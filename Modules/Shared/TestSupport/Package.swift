// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "TestSupport",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TestSupport", targets: ["TestSupport"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.2"),
        .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.6"),
    ],
    targets: [
        .target(
            name: "TestSupport",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "Clocks", package: "swift-clocks"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "TestSupportTests",
            dependencies: ["TestSupport"],
            swiftSettings: swift6),
    ]
)
