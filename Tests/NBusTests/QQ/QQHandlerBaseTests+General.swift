//
//  QQHandlerBaseTests+General.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import XCTest

// MARK: - General - UniversalLink

extension QQHandlerBaseTests: GeneralUniversalLinkTestCase {

    func test_general_ul(scheme: String) {
        XCTAssertEqual(scheme, "https")
    }

    func test_general_ul(host: String) {
        XCTAssertEqual(host, "qm.qq.com")
    }

    func test_general_ul(queryItems: inout [URLQueryItem]) {
        let appsign_txid = queryItems.removeFirst { $0.name == "appsign_txid" }!
        test_appsign_txid(appsign_txid)

        let bundleid = queryItems.removeFirst { $0.name == "bundleid" }!
        test_bundleid(bundleid)

        let sdkv = queryItems.removeFirst { $0.name == "sdkv" }!
        test_sdkv(sdkv)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_txid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, txID)
    }

    func test_bundleid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, bundleID.bus.base64EncodedString)
    }

    func test_sdkv(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, sdkShortVersion)
    }
}

// MARK: - General - Pasteboard

extension QQHandlerBaseTests: GeneralPasteboardTestCase {

    func test_extract_major_pb(items: inout [[String: Data]]) -> [String: Any] {
        test_extract_KeyedArchiver_pb(items: &items, key: "com.tencent.mqq.api.apiLargeData")
    }

    func test_general_pb(dictionary: inout [String: Any]) {
        XCTAssertTrue(true)
    }

    func test_extra_pb(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}
