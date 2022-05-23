//
//  AppState+Handler.swift
//  NBus
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import NBus

extension AppState {

    static let wechatSDKHandler = WechatSDKHandler(
        appID: AppState.getAppID(for: Platforms.wechat)!,
        universalLink: AppState.getUniversalLink(for: Platforms.wechat)!
    )

    static let wechatHandler = WechatHandler(
        appID: AppState.getAppID(for: Platforms.wechat)!,
        universalLink: AppState.getUniversalLink(for: Platforms.wechat)!
    )
}

extension AppState {

    static let qqSDKHandler = QQSDKHandler(
        appID: AppState.getAppID(for: Platforms.qq)!,
        universalLink: AppState.getUniversalLink(for: Platforms.qq)!
    )

    static let qqHandler = QQHandler(
        appID: AppState.getAppID(for: Platforms.qq)!,
        universalLink: AppState.getUniversalLink(for: Platforms.qq)!
    )
}

extension AppState {

    static let weiboSDKHandler = WeiboSDKHandler(
        appID: AppState.getAppID(for: Platforms.weibo)!,
        universalLink: AppState.getUniversalLink(for: Platforms.weibo)!,
        redirectLink: AppState.getRedirectLink(for: Platforms.weibo)!
    )

    static let weiboHandler = WeiboHandler(
        appID: AppState.getAppID(for: Platforms.weibo)!,
        universalLink: AppState.getUniversalLink(for: Platforms.weibo)!,
        redirectLink: AppState.getRedirectLink(for: Platforms.weibo)!
    )
}

extension AppState {

    static let systemHandler = SystemHandler()
}
