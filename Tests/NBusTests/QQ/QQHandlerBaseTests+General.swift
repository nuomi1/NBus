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

// MARK: - General - UniversalLink - Request

extension QQHandlerBaseTests: GeneralUniversalLinkRequestTestCase {

    func test_general_ul_request(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), "https")
    }

    func test_general_ul_request(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), "qm.qq.com")
    }

    func test_general_ul_request(queryItems: inout [URLQueryItem]) {
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
        XCTAssertEqual(try XCTUnwrap(queryItem.value), txID)
    }

    func test_bundleid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), bundleID.bus.base64EncodedString)
    }

    func test_sdkv(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), sdkShortVersion)
    }
}

// MARK: - General - Pasteboard - Request

extension QQHandlerBaseTests: GeneralPasteboardRequestTestCase {

    func extract_major_pb_request(items: inout [[String: Data]]) -> [String: Any] {
        extract_KeyedArchiver_pb(items: &items, key: "com.tencent.mqq.api.apiLargeData")
    }

    func test_general_pb_request(dictionary: inout [String: Any]) {
        if context.setPasteboardString {
            let pasted_string = dictionary.removeValue(forKey: "pasted_string") as! String
            test_pasted_string(pasted_string)
        }
    }

    func test_extra_pb_request(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}

extension QQHandlerBaseTests {

    func test_pasted_string(_ value: String) {
        XCTAssertEqual(value, AppState.defaultPasteboardString)
    }
}

// MARK: - General - URLScheme - Response

extension QQHandlerBaseTests: GeneralURLSchemeResponseTestCase {

    func test_general_us_response(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), appID)
    }

    func test_general_us_response(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), "response_from_qq")
    }

    func test_general_us_response(queryItems: inout [URLQueryItem]) {
        let appsign_bundlenull = queryItems.removeFirst { $0.name == "appsign_bundlenull" }!
        test_appsign_bundlenull_us(appsign_bundlenull)

        let source = queryItems.removeFirst { $0.name == "source" }!
        test_source(source)

        let source_scheme = queryItems.removeFirst { $0.name == "source_scheme" }!
        test_source_scheme(source_scheme)

        let version = queryItems.removeFirst { $0.name == "version" }!
        test_version(version)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_bundlenull_us(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "2")
    }

    func test_source(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "qq")
    }

    func test_source_scheme(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "mqqapi")
    }
}

// MARK: - General - UniversalLink - Response

extension QQHandlerBaseTests: GeneralUniversalLinkResponseTestCase {

    func test_general_ul_response(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), universalLink.scheme)
    }

    func test_general_ul_response(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), universalLink.host)
    }

    func test_general_ul_response(queryItems: inout [URLQueryItem]) {
        XCTAssertTrue(true)
    }
}

// MARK: - General - Pasteboard - Response

extension QQHandlerBaseTests: GeneralPasteboardResponseTestCase {

    func extract_major_pb_response(items: inout [[String: Data]]) -> [String: Any] {
        extract_KeyedArchiver_pb(items: &items, key: "com.tencent.\(appID)")
    }

    func test_general_pb_response(dictionary: inout [String: Any]) {
        let appsign_bundlenull = dictionary.removeValue(forKey: "appsign_bundlenull") as! String
        test_appsign_bundlenull_pb(appsign_bundlenull)

        let appsign_redirect = dictionary.removeValue(forKey: "appsign_redirect") as! String
        test_appsign_redirect(appsign_redirect)

        let appsign_redirect_pasteboard = dictionary.removeValue(forKey: "appsign_redirect_pasteboard") as! [String: String]
        test_appsign_redirect_pasteboard(appsign_redirect_pasteboard)

        let appsign_retcode = dictionary.removeValue(forKey: "appsign_retcode") as! String
        test_appsign_retcode(appsign_retcode)

        let appsign_token = dictionary.removeValue(forKey: "appsign_token") as! String
        test_appsign_token(appsign_token)
    }

    func test_extra_pb_response(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_bundlenull_pb(_ value: String) {
        XCTAssertEqual(value, "2")
    }

    func test_appsign_redirect(_ value: String) {
        XCTAssertNotNil(URL(string: value))
    }

    func test_appsign_redirect_pasteboard(_ value: [String: String]) {
        XCTAssertEqual(value, ["pasted_string": AppState.defaultPasteboardString])
    }

    func test_appsign_retcode(_ value: String) {
        XCTAssertEqual(value, "25105")
    }

    func test_appsign_token(_ value: String) {
        XCTAssertEqual(value.count, 32)
    }
}
