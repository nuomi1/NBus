//
//  WechatHandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

class WechatHandlerBaseTests: HandlerBaseTests {

    override var appID: String {
        switch handler {
        case let handler as WechatSDKHandler:
            return handler.appID
        case let handler as WechatHandler:
            return handler.appID
        default:
            fatalError()
        }
    }

    override var sdkVersion: String {
        "1.9.2"
    }

    override var universalLink: URL {
        switch handler {
        case let handler as WechatSDKHandler:
            return handler.universalLink
        case let handler as WechatHandler:
            return handler.universalLink
        default:
            fatalError()
        }
    }
}
