//
//  AppState+Setup.swift
//  NBus
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import NBus

extension AppState {

    func setup() {
        setupBusMock()
    }

    private func setupWechatItem() -> PlatformItem {
        let wechatSDKHandler = WechatSDKHandler(
            appID: AppState.getAppID(for: Platforms.wechat)!,
            universalLink: AppState.getUniversalLink(for: Platforms.wechat)!
        )

        let wechatHandler = WechatHandler(
            appID: AppState.getAppID(for: Platforms.wechat)!,
            universalLink: AppState.getUniversalLink(for: Platforms.wechat)!
        )

        let wechatItem = AppState.PlatformItem(
            platform: Platforms.wechat,
            category: .sdk,
            handlers: [
                .bus: wechatHandler,
                .sdk: wechatSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        return wechatItem
    }

    private func setupQQItem() -> PlatformItem {
        let qqSDKHandler = QQSDKHandler(
            appID: AppState.getAppID(for: Platforms.qq)!,
            universalLink: AppState.getUniversalLink(for: Platforms.qq)!
        )

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

        return qqItem
    }

    private func setupWeiboItem() -> PlatformItem {
        let weiboSDKHandler = WeiboSDKHandler(
            appID: AppState.getAppID(for: Platforms.weibo)!,
            universalLink: AppState.getUniversalLink(for: Platforms.weibo)!,
            redirectLink: AppState.getRedirectLink(for: Platforms.weibo)!
        )

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

        return weiboItem
    }

    private func setupSystemItem() -> PlatformItem {
        let systemHandler = SystemHandler()

        let systemItem = AppState.PlatformItem(
            platform: Platforms.system,
            category: .bus,
            handlers: [
                .bus: systemHandler,
            ],
            viewController: { PlatformViewController() }
        )

        return systemItem
    }

    private func setupBusMock() {

        let wechatItem = setupWechatItem()
        let qqItem = setupQQItem()
        let weiboItem = setupWeiboItem()
        let systemItem = setupSystemItem()

        platformItems.accept([
            wechatItem,
            qqItem,
            weiboItem,
            systemItem,
        ])
    }
}
