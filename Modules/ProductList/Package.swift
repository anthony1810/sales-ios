// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "ProductList",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ProductListFeature", targets: ["ProductListFeature"]),
        .library(name: "ProductListAPI", targets: ["ProductListAPI"]),
        .library(name: "ProductListPresentation", targets: ["ProductListPresentation"]),
        .library(name: "ProductListUI", targets: ["ProductListUI"]),
        .library(name: "ProductListTestSupport", targets: ["ProductListTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport"),
        .package(path: "../Shared/SharedPresentation"),
    ],
    targets: [
        .target(
            name: "ProductListFeature",
            swiftSettings: swift6),
        .target(
            name: "ProductListAPI",
            dependencies: ["ProductListFeature"],
            swiftSettings: swift6),
        .target(
            name: "ProductListPresentation",
            dependencies: [
                "ProductListFeature",
                .product(name: "SharedPresentation", package: "SharedPresentation"),
            ],
            resources: [.process("Resources")],
            swiftSettings: swift6),
        .target(
            name: "ProductListUI",
            dependencies: ["ProductListPresentation"],
            swiftSettings: swift6),
        .target(
            name: "ProductListTestSupport",
            dependencies: [
                "ProductListFeature",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductListAPITests",
            dependencies: [
                "ProductListAPI",
                "ProductListTestSupport",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            resources: [.copy("Fixtures")],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductListPresentationTests",
            dependencies: [
                "ProductListPresentation",
                "ProductListTestSupport",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "ProductListUITests",
            dependencies: [
                "ProductListUI",
                "ProductListTestSupport",
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
