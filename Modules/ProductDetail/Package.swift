// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "ProductDetail",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ProductDetailFeature", targets: ["ProductDetailFeature"]),
        .library(name: "ProductDetailTestSupport", targets: ["ProductDetailTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport")
    ],
    targets: [
        .target(
            name: "ProductDetailFeature",
            swiftSettings: swift6),
        .target(
            name: "ProductDetailTestSupport",
            dependencies: [
                "ProductDetailFeature",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductDetailFeatureTests",
            dependencies: [
                "ProductDetailFeature",
                "ProductDetailTestSupport",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
