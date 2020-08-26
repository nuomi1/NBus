//
//  AppState.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import NBus
import RxCocoa
import UIKit

class AppState {

    let platformItems = BehaviorRelay<[PlatformItem]>(value: [])

    static let shared = AppState()

    private init() {}
}

extension AppState {

    struct PlatformItem {
        let platform: Platform
        let handler: HandlerType
        let viewController: () -> UIViewController
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
            handler: wechatSDKHandler,
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

        let qqItem = AppState.PlatformItem(
            platform: Platforms.qq,
            handler: qqSDKHandler,
            viewController: { PlatformViewController() }
        )

        // MARK: Weibo

        let weiboSDKHandler = WeiboSDKHandler(
            appID: AppState.getAppID(for: Platforms.weibo)!,
            redirectLink: AppState.getRedirectLink(for: Platforms.weibo)!
        )

        weiboSDKHandler.logHandler = { message, file, function, line in
            logger.debug("\(message)", file: file, function: function, line: line)
        }

        let weiboItem = AppState.PlatformItem(
            platform: Platforms.weibo,
            handler: weiboSDKHandler,
            viewController: { PlatformViewController() }
        )

        // MARK: System

        let systemHandler = SystemHandler()

        systemHandler.logHandler = { message, file, function, line in
            logger.debug("\(message)", file: file, function: function, line: line)
        }

        let systemItem = AppState.PlatformItem(
            platform: Platforms.system,
            handler: systemHandler,
            viewController: { PlatformViewController() }
        )

        platformItems.accept([
            wechatItem,
            qqItem,
            weiboItem,
            systemItem,
        ])

        Bus.shared.handlers = [
            wechatSDKHandler,
            qqSDKHandler,
            weiboSDKHandler,
            systemHandler,
        ]
    }

    // swiftlint:enable function_body_length
}
