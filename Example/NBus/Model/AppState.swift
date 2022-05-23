//
//  AppState.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
#if BusMockQQSDK || BusMockWechatSDK || BusMockWeiboSDK
import RxSwift
#endif

class AppState {

    #if BusMockQQSDK || BusMockWechatSDK || BusMockWeiboSDK
    let platformItems = BehaviorRelay<[PlatformItem]>(value: [])
    #endif

    static let shared = AppState()

    static let defaultPasteboardString = "NBus"

    private init() {}
}
