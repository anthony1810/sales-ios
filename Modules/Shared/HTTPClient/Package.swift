// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "HTTPClient",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPClientLive", targets: ["HTTPClientLive"]),
    ],
    dependencies: [
        .package(path: "../TestSupport")
    ],
    targets: [
        .target(
            name: "HTTPClient",
            swiftSettings: swift6),
        .target(
            name: "HTTPClientLive",
            dependencies: ["HTTPClient"],
            swiftSettings: swift6),
        .testTarget(
            name: "HTTPClientLiveTests",
            dependencies: [
                "HTTPClientLive",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
