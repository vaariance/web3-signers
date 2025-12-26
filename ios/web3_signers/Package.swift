// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "web3_signers",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15"),
    ],
    products: [
        .library(name: "web3-signers", targets: ["web3_signers"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "web3_signers",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "web3_signersTests",
            dependencies: ["web3_signers"],
            path: "Tests"
        ),
    ]
)
