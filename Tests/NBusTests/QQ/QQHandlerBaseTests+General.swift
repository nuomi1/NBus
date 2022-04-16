//
//  QQHandlerBaseTests+General.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import XCTest

// MARK: - General - Scheme

extension QQHandlerBaseTests: GeneralSchemeTestCase {

    func report_general_scheme() -> Set<String> {
        [
            "mqq",
            "mqqopensdkapiV2",
        ]
    }
}

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

    func extract_major_pb(items: inout [[String: Data]]) -> [String: Any] {
        extract_KeyedArchiver_pb(items: &items, key: "com.tencent.mqq.api.apiLargeData")
    }

    func test_general_pb(dictionary: inout [String: Any]) {
        if context.setPasteboardString {
            let pasted_string = dictionary.removeValue(forKey: "pasted_string") as! String
            test_pasted_string(pasted_string)
        }
    }

    func test_extra_pb(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}

extension QQHandlerBaseTests {

    func test_pasted_string(_ value: String) {
        XCTAssertEqual(value, AppState.defaultPasteboardString)
    }
}