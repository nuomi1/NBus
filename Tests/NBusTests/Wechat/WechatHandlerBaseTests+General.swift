//
//  WechatHandlerBaseTests+General.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import XCTest

// MARK: - General - Scheme

extension WechatHandlerBaseTests: GeneralSchemeTestCase {

    func report_general_scheme() -> Set<String> {
        [
            "weixin",
            "weixinULAPI",
        ]
    }
}

// MARK: - General - UniversalLink

extension WechatHandlerBaseTests: GeneralUniversalLinkTestCase {

    func test_general_ul(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), "https")
    }

    func test_general_ul(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), "help.wechat.com")
    }

    func test_general_ul(queryItems: inout [URLQueryItem]) {
        let wechat_app_bundleId = queryItems.removeFirst { $0.name == "wechat_app_bundleId" }!
        test_wechat_app_bundleId(wechat_app_bundleId)

        let wechat_auth_context_id = queryItems.removeFirst { $0.name == "wechat_auth_context_id" }!
        test_wechat_auth_context_id(wechat_auth_context_id)
    }
}

extension WechatHandlerBaseTests {

    func test_wechat_app_bundleId(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), bundleID)
    }

    func test_wechat_auth_context_id(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value).count, 64)
    }
}

// MARK: - General - Pasteboard

extension WechatHandlerBaseTests: GeneralPasteboardTestCase {

    func extract_major_pb(items: inout [[String: Data]]) -> [String: Any] {
        var plist = extract_PropertyList_pb(items: &items, key: "content")

        logger.debug("\(UIPasteboard.self), start, \(plist.keys.sorted())")

        let dictionary = plist.removeValue(forKey: appID) as! [String: Any]

        if context.setPasteboardString {
            let old_text = plist.removeValue(forKey: "old_text") as! String
            test_old_text(old_text)
        }

        logger.debug("\(UIPasteboard.self), end, \(plist.keys.sorted())")

        XCTAssertTrue(plist.isEmpty)

        return dictionary
    }

    func test_general_pb(dictionary: inout [String: Any]) {
        let isAutoResend = dictionary.removeValue(forKey: "isAutoResend") as! Bool
        test_isAutoResend(isAutoResend)

        let result = dictionary.removeValue(forKey: "result") as! String
        test_result(result)

        let returnFromApp = dictionary.removeValue(forKey: "returnFromApp") as! String
        test_returnFromApp(returnFromApp)

        let sdkver = dictionary.removeValue(forKey: "sdkver") as! String
        test_sdkver(sdkver)

        let universalLink = dictionary.removeValue(forKey: "universalLink") as! String
        test_universalLink(universalLink)
    }

    func test_extra_pb(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}

extension WechatHandlerBaseTests {

    func test_old_text(_ value: String) {
        XCTAssertEqual(value, AppState.defaultPasteboardString)
    }
}

extension WechatHandlerBaseTests {

    func test_isAutoResend(_ value: Bool) {
        XCTAssertEqual(value, false)
    }

    func test_result(_ value: String) {
        XCTAssertEqual(value, "1")
    }

    func test_returnFromApp(_ value: String) {
        XCTAssertEqual(value, "0")
    }

    func test_sdkver(_ value: String) {
        XCTAssertEqual(value, sdkVersion)
    }

    func test_universalLink(_ value: String) {
        XCTAssertEqual(value, universalLink.absoluteString)
    }
}
