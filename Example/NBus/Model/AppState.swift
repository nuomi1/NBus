//
//  AppState.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import NBus
import RxRelay
import UIKit

class AppState {

    let platformItems = BehaviorRelay<[PlatformItem]>(value: [])

    static let shared = AppState()

    private init() {}
}

extension AppState {

    struct PlatformItem {
        let platform: Platform
        let category: Category
        let handlers: [Category: HandlerType]
        let viewController: () -> UIViewController
    }
}

extension AppState.PlatformItem {

    enum Category: Hashable {
        case bus
        case sdk
    }
}

extension AppState.PlatformItem.Category: CustomStringConvertible {

    var description: String {
        switch self {
        case .bus:
            return "开源"
        case .sdk:
            return "官方"
        }
    }
}

extension AppState.PlatformItem.Category {

    mutating func toggle() {
        switch self {
        case .bus:
            self = .sdk
        case .sdk:
            self = .bus
        }
    }

    func toggled() -> Self {
        var copy = self
        copy.toggle()
        return copy
    }
}

extension AppState {

    func setup() {
        setupBusMock()
    }

    // swiftlint:disable function_body_length

    private func setupBusMock() {

        // MARK: Wechat

        let wechatSDKHandler = WechatSDKHandler(
            appID: AppState.getAppID(for: Platforms.wechat)!,
            universalLink: AppState.getUniversalLink(for: Platforms.wechat)!
        )

        wechatSDKHandler.logHandler = { message, file, function, line in
            logger.debug("\(message)", file: file, function: function, line: line)
        }

        let wechatItem = AppState.PlatformItem(
            platform: Platforms.wechat,
            category: .sdk,
            handlers: [
                .sdk: wechatSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        // MARK: QQ

        let qqSDKHandler = QQSDKHandler(
            appID: AppState.getAppID(for: Platforms.qq)!,
            universalLink: AppState.getUniversalLink(for: Platforms.qq)!
        )

        qqSDKHandler.logHandler = { message, file, function, line in
            logger.debug("\(message)", file: file, function: function, line: line)
        }

        let qqHandler = QQHandler(
            appID: AppState.getAppID(for: Platforms.qq)!,
            universalLink: AppState.getUniversalLink(for: Platforms.qq)!
        )

        let qqItem = AppState.PlatformItem(
            platform: Platforms.qq,
            category: .sdk,
            handlers: [
                .bus: qqHandler,
                .sdk: qqSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        // MARK: Weibo

        let weiboSDKHandler = WeiboSDKHandler(
            appID: AppState.getAppID(for: Platforms.weibo)!,
            universalLink: AppState.getUniversalLink(for: Platforms.weibo)!,
            redirectLink: AppState.getRedirectLink(for: Platforms.weibo)!
        )

        weiboSDKHandler.logHandler = { message, file, function, line in
            logger.debug("\(message)", file: file, function: function, line: line)
        }

        let weiboHandler = WeiboHandler(
            appID: AppState.getAppID(for: Platforms.weibo)!,
            universalLink: AppState.getUniversalLink(for: Platforms.weibo)!,
            redirectLink: AppState.getRedirectLink(for: Platforms.weibo)!
        )

        let weiboItem = AppState.PlatformItem(
            platform: Platforms.weibo,
            category: .sdk,
            handlers: [
                .bus: weiboHandler,
                .sdk: weiboSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        // MARK: System

        let systemHandler = SystemHandler()

        systemHandler.logHandler = { message, file, function, line in
            logger.debug("\(message)", file: file, function: function, line: line)
        }

        let systemItem = AppState.PlatformItem(
            platform: Platforms.system,
            category: .bus,
            handlers: [
                .bus: systemHandler,
            ],
            viewController: { PlatformViewController() }
        )

        platformItems.accept([
            wechatItem,
            qqItem,
            weiboItem,
            systemItem,
        ])
    }

    // swiftlint:enable function_body_length
}
