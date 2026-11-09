// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PinVaultCore",
    platforms: [
        // Placeholder pending OPEN-007 (iOS minimum version).
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "PinVaultCore", targets: ["PinVaultCore"]),
    ],
    targets: [
        .target(name: "PinVaultCore"),
        .testTarget(name: "PinVaultCoreTests", dependencies: ["PinVaultCore"]),
    ]
)
