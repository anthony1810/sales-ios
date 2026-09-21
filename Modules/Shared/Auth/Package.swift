// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "Auth",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "AuthLive", targets: ["AuthLive"]),
    ],
    dependencies: [
        .package(path: "../TestSupport"),
        .package(path: "../HTTPClient"),
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "HTTPClient", package: "HTTPClient")
            ],
            swiftSettings: swift6),
        .target(
            name: "AuthLive",
            dependencies: ["Auth"],
            swiftSettings: swift6),
        .testTarget(
            name: "AuthTests",
            dependencies: [
                "Auth",
                "AuthLive",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
