//
//  QQHandlerBaseTests+Oauth.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import XCTest

// MARK: - Oauth

extension QQHandlerBaseTests: OauthTestCase {

    func test_oauth() {
        test_oauth(Platforms.qq)
    }
}

// MARK: - Oauth - Platform - Scheme

extension QQHandlerBaseTests: OauthPlatformSchemeTestCase {

    func report_oauth_scheme(_ platform: Platform) -> Set<String> {
        [
            "mqqopensdknopasteboard",
        ]
    }
}

// MARK: - Oauth - Platform - UniversalLink

extension QQHandlerBaseTests: OauthPlatformUniversalLinkTestCase {

    func test_oauth_ul(path: String) {
        XCTAssertEqual(path, "/opensdkul/mqqOpensdkSSoLogin/SSoLogin/\(appID)")
    }

    func test_oauth_ul(queryItems: inout [URLQueryItem], _ platform: Platform) {
        let objectlocation = queryItems.removeFirst { $0.name == "objectlocation" }!
        test_objectlocation(objectlocation)

        let pasteboard = queryItems.removeFirst { $0.name == "pasteboard" }!
        test_pasteboard(pasteboard)
    }
}

extension QQHandlerBaseTests {

    func test_objectlocation(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value, "url")
    }

    func test_pasteboard(_ queryItem: URLQueryItem) {
        let data = Data(base64Encoded: queryItem.value!)!
        var object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]

        let appsign_token = object.removeValue(forKey: "appsign_token") as! String
        XCTAssertEqual(appsign_token, "")

        let app_id = object.removeValue(forKey: "app_id") as! String
        XCTAssertEqual(app_id, appNumber)

        let app_name = object.removeValue(forKey: "app_name") as! String
        XCTAssertEqual(app_name, displayName)

        let bundleid = object.removeValue(forKey: "bundleid") as! String
        XCTAssertEqual(bundleid, bundleID)

        let client_id = object.removeValue(forKey: "client_id") as! String
        XCTAssertEqual(client_id, appNumber)

        let refUniversallink = object.removeValue(forKey: "refUniversallink") as! String
        XCTAssertEqual(refUniversallink, universalLink.absoluteString)

        let response_type = object.removeValue(forKey: "response_type") as! String
        XCTAssertEqual(response_type, "token")

        let scope = object.removeValue(forKey: "scope") as! String
        XCTAssertEqual(scope, "get_user_info")

        let sdkp = object.removeValue(forKey: "sdkp") as! String
        XCTAssertEqual(sdkp, "i")

        let sdkv = object.removeValue(forKey: "sdkv") as! String
        XCTAssertEqual(sdkv, sdkVersion)

        let status_machine = object.removeValue(forKey: "status_machine") as! String
        XCTAssertEqual(status_machine, statusMachine)

        let status_os = object.removeValue(forKey: "status_os") as! String
        XCTAssertEqual(status_os, statusOS)

        let status_version = object.removeValue(forKey: "status_version") as! String
        XCTAssertEqual(status_version, statusVersion)

        logger.debug("\(URLComponents.self), \(object.keys.sorted())")
        XCTAssertTrue(object.isEmpty)
    }
}

// MARK: - Oauth - Platform - Pasteboard

extension QQHandlerBaseTests: OauthPlatformPasteboardTestCase {

    func test_oauth_pb(dictionary: inout [String: Any], _ platform: Platform) {
        XCTAssertTrue(true)
    }
}
