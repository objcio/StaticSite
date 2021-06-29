// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Todo we could only use swift-crypto on linux with a conditional dependency

let package = Package(
    name: "StaticSite",
    platforms: [
          .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "StaticSite",
            targets: ["StaticSite"]),
    ],
    dependencies: [
        .package(name: "HTML", url: "https://github.com/robb/Swim.git", .branch("main")),
        .package(name: "CommonMark", url: "https://github.com/chriseidhof/commonmark-swift/", .branch("embed-c")),
        .package(name: "swift-crypto", url: "https://github.com/apple/swift-crypto.git", from: "1.1.6"),
    ],
    targets: [
       
        .target(
            name: "StaticSite",
            dependencies: [
                "CommonMark",
                .product(name: "Swim", package: "HTML"),
                .product(name: "HTML", package: "HTML"),
                .product(name: "Crypto", package: "swift-crypto"),

            ]),
        .testTarget(
            name: "StaticSiteTests",
            dependencies: ["StaticSite"]),
    ]
)
