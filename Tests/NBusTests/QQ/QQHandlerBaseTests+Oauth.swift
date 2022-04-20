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
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "url")
    }

    func test_pasteboard(_ queryItem: URLQueryItem) {
        let data = try! XCTUnwrap(Data(base64Encoded: XCTUnwrap(queryItem.value)))
        var object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]

        logger.debug("\(URLComponents.self), start, \(object.keys.sorted())")

        let appsign_token = object.removeValue(forKey: "appsign_token") as! String
        test_appsign_token(appsign_token)

        let app_id = object.removeValue(forKey: "app_id") as! String
        test_app_id(app_id)

        let app_name = object.removeValue(forKey: "app_name") as! String
        test_app_name(app_name)

        let bundleid = object.removeValue(forKey: "bundleid") as! String
        test_bundleid_oauth(bundleid)

        let client_id = object.removeValue(forKey: "client_id") as! String
        test_client_id(client_id)

        let refUniversallink = object.removeValue(forKey: "refUniversallink") as! String
        test_refUniversallink(refUniversallink)

        let response_type = object.removeValue(forKey: "response_type") as! String
        test_response_type(response_type)

        let scope = object.removeValue(forKey: "scope") as! String
        test_scope(scope)

        let sdkp = object.removeValue(forKey: "sdkp") as! String
        test_sdkp(sdkp)

        let sdkv = object.removeValue(forKey: "sdkv") as! String
        test_sdkv_oauth(sdkv)

        let status_machine = object.removeValue(forKey: "status_machine") as! String
        test_status_machine(status_machine)

        let status_os = object.removeValue(forKey: "status_os") as! String
        test_status_os(status_os)

        let status_version = object.removeValue(forKey: "status_version") as! String
        test_status_version(status_version)

        logger.debug("\(URLComponents.self), end, \(object.keys.sorted())")

        XCTAssertTrue(object.isEmpty)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_token(_ value: String) {
        XCTAssertEqual(value, "")
    }

    func test_app_id(_ value: String) {
        XCTAssertEqual(value, appNumber)
    }

    func test_app_name(_ value: String) {
        XCTAssertEqual(value, displayName)
    }

    func test_bundleid_oauth(_ value: String) {
        XCTAssertEqual(value, bundleID)
    }

    func test_client_id(_ value: String) {
        test_app_id(value)
    }

    func test_refUniversallink(_ value: String) {
        XCTAssertEqual(value, universalLink.absoluteString)
    }

    func test_response_type(_ value: String) {
        XCTAssertEqual(value, "token")
    }

    func test_scope(_ value: String) {
        XCTAssertEqual(value, "get_user_info")
    }

    func test_sdkp(_ value: String) {
        XCTAssertEqual(value, "i")
    }

    func test_sdkv_oauth(_ value: String) {
        XCTAssertEqual(value, sdkVersion)
    }

    func test_status_machine(_ value: String) {
        XCTAssertEqual(value, statusMachine)
    }

    func test_status_os(_ value: String) {
        XCTAssertEqual(value, statusOS)
    }

    func test_status_version(_ value: String) {
        XCTAssertEqual(value, statusVersion)
    }
}

// MARK: - Oauth - Platform - Pasteboard

extension QQHandlerBaseTests: OauthPlatformPasteboardTestCase {

    func test_oauth_pb(dictionary: inout [String: Any], _ platform: Platform) {
        XCTAssertTrue(true)
    }
}
