//
//  QQHandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

class QQHandlerBaseTests: HandlerBaseTests {

    override var appID: String {
        switch handler {
        case let handler as QQSDKHandler:
            return handler.appID
        case let handler as QQHandler:
            return handler.appID
        default:
            fatalError()
        }
    }

    override var sdkShortVersion: String {
        "3.5.11"
    }

    override var sdkVersion: String {
        "3.5.11_lite"
    }

    var statusMachine: String {
        UIDevice.current.bus.machine
    }

    var statusOS: String {
        UIDevice.current.systemVersion
    }

    var statusVersion: String {
        "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)"
    }

    var txID: String {
        "QQ\(String(format: "%08llX", (appNumber as NSString).longLongValue))"
    }

    override var universalLink: URL {
        switch handler {
        case let handler as QQSDKHandler:
            return handler.universalLink
        case let handler as QQHandler:
            return handler.universalLink
        default:
            fatalError()
        }
    }
}
