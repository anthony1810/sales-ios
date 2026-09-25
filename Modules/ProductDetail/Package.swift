// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "ProductDetail",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ProductDetailFeature", targets: ["ProductDetailFeature"]),
        .library(name: "ProductDetailAPI", targets: ["ProductDetailAPI"]),
        .library(name: "ProductDetailPresentation", targets: ["ProductDetailPresentation"]),
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
            name: "ProductDetailAPI",
            dependencies: ["ProductDetailFeature"],
            swiftSettings: swift6),
        .target(
            name: "ProductDetailPresentation",
            dependencies: ["ProductDetailFeature"],
            resources: [.process("Resources")],
            swiftSettings: swift6),
        .target(
            name: "ProductDetailTestSupport",
            dependencies: [
                "ProductDetailFeature",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductDetailAPITests",
            dependencies: [
                "ProductDetailAPI",
                "ProductDetailTestSupport",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            resources: [.copy("Fixtures")],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductDetailPresentationTests",
            dependencies: [
                "ProductDetailPresentation",
                "ProductDetailTestSupport",
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
