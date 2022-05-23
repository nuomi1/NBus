// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "NBus",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "NBus",
            targets: [
                "NBusQQHandler",
                "NBusWechatHandler",
                "NBusWeiboHandler",
                "NBusSystemHandler",
            ]
        ),
    ],
    targets: [
        .target(
            name: "NBusCore"
        ),
        .target(
            name: "NBusQQHandler",
            dependencies: ["NBusCore"]
        ),
        .target(
            name: "NBusWechatHandler",
            dependencies: ["NBusCore"]
        ),
        .target(
            name: "NBusWeiboHandler",
            dependencies: ["NBusCore"]
        ),
        .target(
            name: "NBusSystemHandler",
            dependencies: ["NBusCore"]
        ),
        .testTarget(
            name: "NBusTests",
            dependencies: ["NBusCore"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
