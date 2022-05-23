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
        let wechatItem = AppState.PlatformItem(
            platform: Platforms.wechat,
            category: .sdk,
            handlers: [
                .bus: Self.wechatHandler,
                .sdk: Self.wechatSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        return wechatItem
    }

    private func setupQQItem() -> PlatformItem {
        let qqItem = AppState.PlatformItem(
            platform: Platforms.qq,
            category: .sdk,
            handlers: [
                .bus: Self.qqHandler,
                .sdk: Self.qqSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        return qqItem
    }

    private func setupWeiboItem() -> PlatformItem {
        let weiboItem = AppState.PlatformItem(
            platform: Platforms.weibo,
            category: .sdk,
            handlers: [
                .bus: Self.weiboHandler,
                .sdk: Self.weiboSDKHandler,
            ],
            viewController: { PlatformViewController() }
        )

        return weiboItem
    }

    private func setupSystemItem() -> PlatformItem {
        let systemItem = AppState.PlatformItem(
            platform: Platforms.system,
            category: .bus,
            handlers: [
                .bus: Self.systemHandler,
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
