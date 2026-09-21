// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "Login",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LoginFeature", targets: ["LoginFeature"]),
        .library(name: "LoginAPI", targets: ["LoginAPI"]),
        .library(name: "LoginPresentation", targets: ["LoginPresentation"]),
        .library(name: "LoginUI", targets: ["LoginUI"]),
    ],
    dependencies: [
        .package(path: "../Shared/Auth"),
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(
            name: "LoginFeature",
            dependencies: [
                .product(name: "Auth", package: "Auth")
            ],
            swiftSettings: swift6),
        .target(
            name: "LoginAPI",
            dependencies: [
                "LoginFeature",
                .product(name: "Auth", package: "Auth"),
            ],
            swiftSettings: swift6),
        .target(
            name: "LoginPresentation",
            dependencies: ["LoginFeature"],
            resources: [.process("Resources")],
            swiftSettings: swift6),
        .target(
            name: "LoginUI",
            dependencies: ["LoginPresentation"],
            swiftSettings: swift6),
        .testTarget(
            name: "LoginFeatureTests",
            dependencies: [
                "LoginFeature",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "LoginAPITests",
            dependencies: [
                "LoginAPI",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            resources: [.copy("Fixtures")],
            swiftSettings: swift6),
        .testTarget(
            name: "LoginPresentationTests",
            dependencies: [
                "LoginPresentation",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "LoginUITests",
            dependencies: [
                "LoginUI",
                "LoginFeature",
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
