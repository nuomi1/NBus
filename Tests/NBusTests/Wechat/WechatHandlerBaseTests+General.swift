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

// MARK: - General - UniversalLink - Request

extension WechatHandlerBaseTests: GeneralUniversalLinkRequestTestCase {

    func test_general_ul_request(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), "https")
    }

    func test_general_ul_request(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), "help.wechat.com")
    }

    func test_general_ul_request(queryItems: inout [URLQueryItem]) {
        let wechat_app_bundleId = queryItems.removeFirst { $0.name == "wechat_app_bundleId" }!
        test_wechat_app_bundleId(wechat_app_bundleId)

        if context.shareState == .requestFirst {
            let wechat_auth_context_id = queryItems.removeFirst { $0.name == "wechat_auth_context_id" }!
            test_wechat_auth_context_id(wechat_auth_context_id)
        }
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

// MARK: - General - Pasteboard - Request

extension WechatHandlerBaseTests: GeneralPasteboardRequestTestCase {

    func extract_major_pb_request(items: inout [[String: Data]]) -> [String: Any] {
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

    func test_general_pb_request(dictionary: inout [String: Any]) {
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

    func test_extra_pb_request(items: inout [[String: Data]]) {
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
        switch context.shareState! {
        case .requestFirst,
             .responseUniversalLink:
            XCTAssertEqual(value, false)
        case .requestSecond:
            XCTAssertEqual(value, true)
        case .responseSignToken,
             .responseURLScheme,
             .requestThird,
             .success,
             .failure:
            fatalError()
        }
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

// MARK: - General - URLScheme - Response

extension WechatHandlerBaseTests: GeneralURLSchemeResponseTestCase {

    func test_general_us_response(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), appID)
    }

    func test_general_us_response(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), "resendContextReqByScheme")
    }

    func test_general_us_response(queryItems: inout [URLQueryItem]) {
        let wechat_auth_context_id = queryItems.removeFirst { $0.name == "wechat_auth_context_id" }!
        test_wechat_auth_context_id(wechat_auth_context_id)
    }
}

// MARK: - General - UniversalLink - Response

extension WechatHandlerBaseTests: GeneralUniversalLinkResponseTestCase {

    func test_general_ul_response(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), universalLink.scheme)
    }

    func test_general_ul_response(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), universalLink.host)
    }

    func test_general_ul_response(queryItems: inout [URLQueryItem]) {
        if context.shareState == .responseSignToken {
            let wechat_auth_context_id = queryItems.removeFirst { $0.name == "wechat_auth_context_id" }!
            test_wechat_auth_context_id(wechat_auth_context_id)
        }

        if context.shareState == .responseSignToken {
            let wechat_auth_token = queryItems.removeFirst { $0.name == "wechat_auth_token" }!
            test_wechat_auth_token(wechat_auth_token)
        }
    }
}

extension WechatHandlerBaseTests {

    func test_wechat_auth_token(_ queryItem: URLQueryItem) {
        let token = try! XCTUnwrap(queryItem.value).split(separator: "_")
        XCTAssertEqual(token.count, 2)
        XCTAssertEqual(try XCTUnwrap(token.first).count, 64)
    }
}

// MARK: - General - Pasteboard - Response

extension WechatHandlerBaseTests: GeneralPasteboardResponseTestCase {

    func extract_major_pb_response(items: inout [[String: Data]]) -> [String: Any] {
        extract_major_pb_request(items: &items)
    }

    func test_general_pb_response(dictionary: inout [String: Any]) {
        let country = dictionary.removeValue(forKey: "country") as! String
        test_country(country)

        let isAutoResend = dictionary.removeValue(forKey: "isAutoResend") as! Bool
        test_isAutoResend(isAutoResend)

        let language = dictionary.removeValue(forKey: "language") as! String
        test_language(language)

        let returnFromApp = dictionary.removeValue(forKey: "returnFromApp") as! String
        test_returnFromApp(returnFromApp)

        let wechatVersion = dictionary.removeValue(forKey: "wechatVersion") as! Int
        test_wechatVersion(wechatVersion)
    }

    func test_extra_pb_response(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}

extension WechatHandlerBaseTests {

    func test_country(_ value: String) {
        XCTAssertEqual(value, "")
    }

    func test_language(_ value: String) {
        XCTAssertEqual(value, "zh_CN")
    }

    func test_wechatVersion(_ value: Int) {
        XCTAssertEqual(value, remoteSDKShortVersion)
    }
}
