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

// MARK: - Oauth

extension WeiboHandlerBaseTests: OauthTestCase {

    func test_oauth() {
        test_oauth(Platforms.weibo)
    }
}

// MARK: - Oauth - Platform -UniversalLink

extension WeiboHandlerBaseTests: OauthPlatformUniversalLinkTestCase {

    func test_oauth_ul(path: String) {
        test_share_common_ul(path: path)
    }

    func test_oauth_ul(queryItems: inout [URLQueryItem], _ platform: Platform) {
        XCTAssertTrue(true)
    }
}

// MARK: - Oauth - Platform - Pasteboard

extension WeiboHandlerBaseTests: OauthPlatformPasteboardTestCase {

    func test_oauth_pb(dictionary: inout [String: Any], _ platform: Platform) {
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
