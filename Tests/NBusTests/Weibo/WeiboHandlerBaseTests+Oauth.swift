//
//  WeiboHandlerBaseTests+Oauth.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import XCTest

// MARK: - Oauth

extension WeiboHandlerBaseTests: OauthTestCase {

    func test_oauth() {
        test_oauth(Platforms.weibo)
    }
}

// MARK: - Oauth - Platform - Scheme

extension WeiboHandlerBaseTests: OauthPlatformSchemeTestCase {

    func report_oauth_scheme(_ platform: Platform) -> Set<String> {
        []
    }
}

// MARK: - Oauth - Platform - UniversalLink - Request

extension WeiboHandlerBaseTests: OauthPlatformUniversalRequestLinkTestCase {

    func test_oauth_ul_request(path: String) {
        test_share_ul_request(path: path)
    }

    func test_oauth_ul_request(queryItems: inout [URLQueryItem], _ platform: Platform) {
        XCTAssertTrue(true)
    }
}

// MARK: - Oauth - Platform - Pasteboard - Request

extension WeiboHandlerBaseTests: OauthPlatformPasteboardRequestTestCase {

    func test_oauth_pb_request(dictionary: inout [String: Any], _ platform: Platform) {
        let `class` = dictionary.removeValue(forKey: "__class") as! String
        test_class_oauth(`class`)

        let redirectURI = dictionary.removeValue(forKey: "redirectURI") as! String
        test_redirectURI(redirectURI)
    }
}

extension WeiboHandlerBaseTests {

    func test_class_oauth(_ value: String) {
        XCTAssertEqual(value, "WBAuthorizeRequest")
    }

    func test_redirectURI(_ value: String) {
        XCTAssertEqual(value, redirectLink.absoluteString)
    }
}
