// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "HTTPClient",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]),
    ],
    targets: [
        .target(
            name: "HTTPClient",
            swiftSettings: swift6),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient"],
            swiftSettings: swift6),
    ]
)
