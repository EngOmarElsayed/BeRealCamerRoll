// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MultiCam",
    platforms: [
      .iOS(.v16)
    ],
    products: [
        .library(
            name: "MultiCam",
            targets: ["MultiCam"]),
    ],
    targets: [
        .target(
            name: "MultiCam"),
        .testTarget(
            name: "MultiCamTests",
            dependencies: ["MultiCam"]),
    ]
)
