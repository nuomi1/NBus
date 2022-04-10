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

// MARK: - Launch

extension QQHandlerBaseTests: LaunchTestCase {

    func test_launch() {
        test_launch(Platforms.qq, MediaSource.qqMiniProgram as! MiniProgramMessage)
    }
}

// MARK: - Launch - URL

extension QQHandlerBaseTests: LaunchURLTestCase {

    func test_launch_ul(path: String) {
        XCTAssertEqual(path, "/opensdkul/mqqapi/profile/sdk_launch_mini_app")
    }

    func test_launch_ul(queryItems: inout [URLQueryItem], _ platform: Platform, _ program: MiniProgramMessage) {
        let appid = queryItems.removeFirst { $0.name == "appid" }!
        test_appid(appid)

        let callback_name = queryItems.removeFirst { $0.name == "callback_name" }!
        test_callback_name(callback_name)

        let callback_type = queryItems.removeFirst { $0.name == "callback_type" }!
        test_callback_type(callback_type)

        let src_type = queryItems.removeFirst { $0.name == "src_type" }!
        test_src_type(src_type)

        let thirdAppDisplayName = queryItems.removeFirst { $0.name == "thirdAppDisplayName" }!
        test_thirdAppDisplayName(thirdAppDisplayName)

        let version = queryItems.removeFirst { $0.name == "version" }!
        test_version(version)

        let mini_appid = queryItems.removeFirst { $0.name == "mini_appid" }!
        test_mini_appid(mini_appid, program)

        let mini_path = queryItems.removeFirst { $0.name == "mini_path" }!
        test_mini_path(mini_path, program)

        let mini_type = queryItems.removeFirst { $0.name == "mini_type" }!
        test_mini_type(mini_type, program)
    }
}

extension QQHandlerBaseTests {

    func test_appid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, appNumber)
    }
}

// MARK: - Launch - Pasteboard

extension QQHandlerBaseTests: LaunchPasteboardTestCase {

    func test_launch_pb(dictionary: inout [String: Any], _ platform: Platform, _ program: MiniProgramMessage) {
        XCTAssertTrue(true)
    }
}
