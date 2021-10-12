// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "NBus",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "NBusHandlers",
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
            name: "NBusCore",
            path: "NBus/Classes/Core"
        ),
        .target(
            name: "NBusQQHandler",
            dependencies: ["NBusCore"],
            path: "NBus/Classes/Handler",
            sources: ["QQHandler.swift"]
        ),
        .target(
            name: "NBusWechatHandler",
            dependencies: ["NBusCore"],
            path: "NBus/Classes/Handler",
            sources: ["WechatHandler.swift"]
        ),
        .target(
            name: "NBusWeiboHandler",
            dependencies: ["NBusCore"],
            path: "NBus/Classes/Handler",
            sources: ["WeiboHandler.swift"]
        ),
        .target(
            name: "NBusSystemHandler",
            dependencies: ["NBusCore"],
            path: "NBus/Classes/Handler",
            sources: ["SystemHandler.swift"]
        ),
        .testTarget(
            name: "NBusTests",
            dependencies: ["NBusCore"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
