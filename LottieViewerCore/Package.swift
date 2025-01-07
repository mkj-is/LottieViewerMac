// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LottieViewerCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "LottieViewerCore",
            targets: ["LottieViewerCore"]),
    ],
    targets: [
        .target(
            name: "LottieViewerCore"),

    ]
)
