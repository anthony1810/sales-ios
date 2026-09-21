// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "ProductList",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ProductListFeature", targets: ["ProductListFeature"]),
        .library(name: "ProductListTestSupport", targets: ["ProductListTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport")
    ],
    targets: [
        .target(
            name: "ProductListFeature",
            swiftSettings: swift6),
        .target(
            name: "ProductListTestSupport",
            dependencies: [
                "ProductListFeature",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductListFeatureTests",
            dependencies: [
                "ProductListFeature",
                "ProductListTestSupport",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
