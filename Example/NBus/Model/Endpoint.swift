//
//  Endpoint.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import NBus

extension Endpoint: CustomStringConvertible {

    public var description: String {
        switch self {
        case Endpoints.Wechat.friend:
            return "好友"
        case Endpoints.Wechat.timeline:
            return "朋友圈"
        case Endpoints.Wechat.favorite:
            return "收藏"
        case Endpoints.QQ.friend:
            return "好友"
        case Endpoints.QQ.timeline:
            return "QQ空间"
        case Endpoints.Weibo.timeline:
            return "微博"
        case Endpoints.System.activity:
            return "分享"
        default:
            assertionFailure()
            return "unknown"
        }
    }
}
