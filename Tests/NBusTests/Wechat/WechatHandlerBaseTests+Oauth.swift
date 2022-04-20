//
//  WechatHandlerBaseTests+Oauth.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import XCTest

// MARK: - Oauth

extension WechatHandlerBaseTests: OauthTestCase {

    func test_oauth() {
        test_oauth(Platforms.wechat)
    }
}

// MARK: - Oauth - Platform - Scheme

extension WechatHandlerBaseTests: OauthPlatformSchemeTestCase {

    func report_oauth_scheme(_ platform: Platform) -> Set<String> {
        []
    }
}

// MARK: - Oauth - Platform - UniversalLink - Request

extension WechatHandlerBaseTests: OauthPlatformUniversalRequestLinkTestCase {

    func test_oauth_ul_request(path: String) {
        XCTAssertEqual(path, "/app/\(appID)/auth/")
    }

    func test_oauth_ul_request(queryItems: inout [URLQueryItem], _ platform: Platform) {
        let scope = queryItems.removeFirst { $0.name == "scope" }!
        test_scope(scope)

        let state = queryItems.removeFirst { $0.name == "state" }!
        test_state(state)
    }
}

extension WechatHandlerBaseTests {

    func test_scope(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "snsapi_userinfo")
    }

    func test_state(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "")
    }
}

// MARK: - Oauth - Platform - Pasteboard - Request

extension WechatHandlerBaseTests: OauthPlatformPasteboardRequestTestCase {

    func test_oauth_pb_request(dictionary: inout [String: Any], _ platform: Platform) {
        let command = dictionary.removeValue(forKey: "command") as! String
        test_command_oauth(command)
    }
}

extension WechatHandlerBaseTests {

    func test_command_oauth(_ value: String) {
        XCTAssertEqual(value, "0")
    }
}
