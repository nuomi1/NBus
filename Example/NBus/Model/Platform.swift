//
//  Platform.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import NBus

extension Platform {

    var key: String {
        switch self {
        case Platforms.wechat:
            return "Wechat"
        case Platforms.qq:
            return "QQ"
        case Platforms.weibo:
            return "Weibo"
        default:
            assertionFailure()
            return ""
        }
    }
}

extension Platform: CustomStringConvertible {

    public var description: String {
        switch self {
        case Platforms.wechat:
            return "微信"
        case Platforms.qq:
            return "QQ"
        case Platforms.weibo:
            return "微博"
        case Platforms.system:
            return "系统"
        default:
            assertionFailure()
            return "unknown"
        }
    }
}
