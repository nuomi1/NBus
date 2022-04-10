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

// MARK: - Launch

extension WechatHandlerBaseTests: LaunchTestCase {

    func test_launch() {
        test_launch(Platforms.wechat, MediaSource.wechatMiniProgram as! MiniProgramMessage)
    }
}

// MARK: - Launch - URL

extension WechatHandlerBaseTests: LaunchURLTestCase {

    func test_launch_ul(path: String) {
        XCTAssertEqual(path, "/app/\(appID)/jumpWxa/")
    }

    func test_launch_ul(queryItems: inout [URLQueryItem], _ platform: Platform, _ program: MiniProgramMessage) {
        let extMsg = queryItems.removeFirst { $0.name == "extMsg" }!
        test_extMsg(extMsg)

        let miniProgramType = queryItems.removeFirst { $0.name == "miniProgramType" }!
        test_miniProgramType(miniProgramType, program)

        let path = queryItems.removeFirst { $0.name == "path" }!
        test_path(path, program)

        let userName = queryItems.removeFirst { $0.name == "userName" }!
        test_userName(userName, program)
    }
}

extension WechatHandlerBaseTests {

    func test_extMsg(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "")
    }

    func test_miniProgramType(_ queryItem: URLQueryItem, _ message: MessageType) {
        let miniProgramType: (MiniProgramMessage.MiniProgramType) -> String = { miniProgramType in
            switch miniProgramType {
            case .release:
                return "0"
            case .test:
                return "1"
            case .preview:
                return "2"
            }
        }

        switch message {
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem.value!, miniProgramType(message.miniProgramType))
        default:
            XCTAssertTrue(false, "\(String(describing: queryItem.value))")
        }
    }

    func test_path(_ queryItem: URLQueryItem, _ message: MessageType) {
        switch message {
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem.value!, message.path)
        default:
            XCTAssertTrue(false, "\(String(describing: queryItem.value))")
        }
    }

    func test_userName(_ queryItem: URLQueryItem, _ message: MessageType) {
        switch message {
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem.value!, message.miniProgramID)
        default:
            XCTAssertTrue(false, "\(String(describing: queryItem.value))")
        }
    }
}

// MARK: - Launch - Pasteboard

extension WechatHandlerBaseTests: LaunchPasteboardTestCase {

    func test_launch_pb(dictionary: inout [String: Any], _ platform: Platform, _ program: MiniProgramMessage) {
        let command = dictionary.removeValue(forKey: "command") as! String
        test_command_launch(command)
    }
}

extension WechatHandlerBaseTests {

    func test_command_launch(_ value: String) {
        XCTAssertEqual(value, "1080")
    }
}
