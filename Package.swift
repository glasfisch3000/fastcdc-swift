// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fastcdc",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "fastcdc", targets: ["FastCDC"]),
    ],
    targets: [
        .target(
            name: "FastCDC",
            path: "./Sources/fastcdc"
        )
    ]
)
