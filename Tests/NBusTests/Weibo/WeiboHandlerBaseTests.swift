//
//  WeiboHandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/4.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import NBusWeiboSDK
import RxSwift
import XCTest

class WeiboHandlerBaseTests: HandlerBaseTests {

    override var appID: String {
        switch handler {
        case let handler as WeiboSDKHandler:
            return handler.appID
        case let handler as WeiboHandler:
            return handler.appID
        default:
            fatalError()
        }
    }

    var redirectLink: URL {
        switch handler {
        case let handler as WeiboSDKHandler:
            return handler.redirectLink
        case let handler as WeiboHandler:
            return handler.redirectLink
        default:
            fatalError()
        }
    }

    override var sdkShortVersion: String {
        "3.3"
    }

    override var sdkVersion: String {
        "003233000"
    }

    override var universalLink: URL {
        switch handler {
        case let handler as WeiboSDKHandler:
            return handler.universalLink
        case let handler as WeiboHandler:
            return handler.universalLink
        default:
            fatalError()
        }
    }

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return dateFormatter
    }()
}
