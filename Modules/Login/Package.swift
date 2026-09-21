// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "Login",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LoginPresentation", targets: ["LoginPresentation"])
    ],
    targets: [
        .target(
            name: "LoginPresentation",
            swiftSettings: swift6),
        .testTarget(
            name: "LoginPresentationTests",
            dependencies: ["LoginPresentation"],
            swiftSettings: swift6),
    ]
)
