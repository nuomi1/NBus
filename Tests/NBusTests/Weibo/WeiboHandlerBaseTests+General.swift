//
//  WeiboHandlerBaseTests+General.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import XCTest

// MARK: - General - UniversalLink

extension WeiboHandlerBaseTests: GeneralUniversalLinkTestCase {

    func test_general_ul(scheme: String) {
        XCTAssertEqual(scheme, "https")
    }

    func test_general_ul(host: String) {
        XCTAssertEqual(host, "open.weibo.com")
    }

    func test_general_ul(queryItems: inout [URLQueryItem]) {
        let lfid = queryItems.removeFirst { $0.name == "lfid" }!
        test_lfid(lfid)

        let luicode = queryItems.removeFirst { $0.name == "luicode" }!
        test_luicode(luicode)

        let newVersion = queryItems.removeFirst { $0.name == "newVersion" }!
        test_newVersion(newVersion)

        let objId = queryItems.removeFirst { $0.name == "objId" }!
        test_objId(objId)

        let sdkversion = queryItems.removeFirst { $0.name == "sdkversion" }!
        test_sdkversion(sdkversion)

        let urltype = queryItems.removeFirst { $0.name == "urltype" }!
        test_urltype(urltype)
    }
}

extension WeiboHandlerBaseTests {

    func test_lfid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, bundleID)
    }

    func test_luicode(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "10000360")
    }

    func test_newVersion(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, sdkShortVersion)
    }

    func test_objId(_ queryItem: URLQueryItem) {
        XCTAssertNotNil(UUID(uuidString: queryItem.value!))
    }

    func test_sdkversion(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, sdkVersion)
    }

    func test_urltype(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "link")
    }
}

// MARK: - General - Pasteboard

extension WeiboHandlerBaseTests: GeneralPasteboardTestCase {

    func test_extract_major_pb(items: inout [[String: Data]]) -> [String: Any] {
        test_extract_KeyedArchiver_pb(items: &items, key: "transferObject")
    }

    func test_general_pb(dictionary: inout [String: Any]) {
        let requestID = dictionary.removeValue(forKey: "requestID") as! String
        test_requestID(requestID)
    }

    func test_extra_pb(items: inout [[String: Data]]) {
        test_app(&items)

        test_sdkVersion(&items)

        test_userInfo(&items)
    }
}

extension WeiboHandlerBaseTests {

    func test_requestID(_ value: String) {
        XCTAssertNotNil(UUID(uuidString: value))
    }
}

extension WeiboHandlerBaseTests {

    func test_app(_ items: inout [[String: Data]]) {
        var dictionary = test_extract_KeyedArchiver_pb(items: &items, key: "app")

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let aid = dictionary.removeValue(forKey: "aid") as! String
        test_aid(aid)

        let appKey = dictionary.removeValue(forKey: "appKey") as! String
        test_appKey(appKey)

        let bundleID = dictionary.removeValue(forKey: "bundleID") as! String
        test_bundleID(bundleID)

        let universalLink = dictionary.removeValue(forKey: "universalLink") as! String
        test_universalLink(universalLink)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_aid(_ value: String) {
        XCTAssertEqual(value.count, 50)
    }

    func test_appKey(_ value: String) {
        XCTAssertEqual(value, appNumber)
    }

    func test_bundleID(_ value: String) {
        XCTAssertEqual(value, bundleID)
    }

    func test_universalLink(_ value: String) {
        XCTAssertEqual(value, universalLink.absoluteString)
    }
}

extension WeiboHandlerBaseTests {

    func test_sdkVersion(_ items: inout [[String: Data]]) {
        let data = items.removeFirst { $0.keys.contains("sdkVersion") }!["sdkVersion"]!

        XCTAssertEqual(data, Data(sdkVersion.utf8))
    }
}

extension WeiboHandlerBaseTests {

    func test_userInfo(_ items: inout [[String: Data]]) {
        var dictionary = test_extract_KeyedArchiver_pb(items: &items, key: "userInfo")

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let startTime = dictionary.removeValue(forKey: "startTime") as! String
        test_startTime(startTime)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_startTime(_ value: String) {
        XCTAssertNotNil(dateFormatter.date(from: value))
    }
}
