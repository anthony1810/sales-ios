// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "SharedPresentation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SharedPresentation", targets: ["SharedPresentation"])
    ],
    dependencies: [
        .package(path: "../TestSupport")
    ],
    targets: [
        .target(
            name: "SharedPresentation",
            swiftSettings: swift6),
        .testTarget(
            name: "SharedPresentationTests",
            dependencies: [
                "SharedPresentation",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
