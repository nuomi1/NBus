//
//  WeiboHandlerBaseTests+General.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import XCTest

// MARK: - General - Scheme

extension WeiboHandlerBaseTests: GeneralSchemeTestCase {

    func report_general_scheme() -> Set<String> {
        [
            "sinaweibo",
            "weibosdk",
            "weibosdk3.3",
        ]
    }
}

// MARK: - General - UniversalLink - Request

extension WeiboHandlerBaseTests: GeneralUniversalLinkRequestTestCase {

    func test_general_ul_request(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), "https")
    }

    func test_general_ul_request(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), "open.weibo.com")
    }

    func test_general_ul_request(queryItems: inout [URLQueryItem]) {
        let newVersion = queryItems.removeFirst { $0.name == "newVersion" }!
        test_newVersion(newVersion)

        let objId = queryItems.removeFirst { $0.name == "objId" }!
        test_objId(objId)
    }
}

extension WeiboHandlerBaseTests {

    func test_newVersion(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), sdkShortVersion)
    }

    func test_objId(_ queryItem: URLQueryItem) {
        XCTAssertNotNil(try UUID(uuidString: XCTUnwrap(queryItem.value)))
    }
}

// MARK: - General - Pasteboard - Request

extension WeiboHandlerBaseTests: GeneralPasteboardRequestTestCase {

    func extract_major_pb_request(items: inout [[String: Data]]) -> [String: Any] {
        if context.shareState == .requestSecond {
            return extract_KeyedArchiver_pb(items: &items, key: "transferObject")
        }

        return [:]
    }

    func test_general_pb_request(dictionary: inout [String: Any]) {
        if context.shareState == .requestSecond {
            let requestID = dictionary.removeValue(forKey: "requestID") as! String
            test_requestID(requestID)
        }
    }

    func test_extra_pb_request(items: inout [[String: Data]]) {
        test_app(&items)

        test_sdkVersion(&items)

        if context.shareState == .requestSecond {
            test_userInfo_share(&items)
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_requestID(_ value: String) {
        XCTAssertNotNil(UUID(uuidString: value))
    }
}

extension WeiboHandlerBaseTests {

    func test_app(_ items: inout [[String: Data]]) {
        var dictionary = extract_KeyedArchiver_pb(items: &items, key: "app")

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let aid = dictionary.removeValue(forKey: "aid") as? String
        test_aid(aid)

        let appKey = dictionary.removeValue(forKey: "appKey") as! String
        test_appKey(appKey)

        let bundleID = dictionary.removeValue(forKey: "bundleID") as! String
        test_bundleID(bundleID)

        switch context.shareState! {
        case .requestFirst,
             .responseSignToken,
             .requestSecond:
            let universalLink = dictionary.removeValue(forKey: "universalLink") as! String
            test_universalLink(universalLink)
        case .success,
             .failure:
            XCTAssertTrue(true)
        case .responseURLScheme,
             .responseUniversalLink,
             .requestThird:
            fatalError()
        }

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_aid(_ value: String?) {
        let isNil = value == nil
        let isCountFifty = value?.count == 50
        XCTAssertTrue(isNil || isCountFifty)
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

        switch context.shareState! {
        case .requestFirst,
             .responseSignToken,
             .requestSecond:
            XCTAssertEqual(data, Data(sdkVersion.utf8))
        case .success,
             .failure:
            XCTAssertEqual(data, Data(remoteSDKShortVersion.utf8))
        case .responseURLScheme,
             .responseUniversalLink,
             .requestThird:
            fatalError()
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_userInfo_share(_ items: inout [[String: Data]]) {
        var dictionary = extract_KeyedArchiver_pb(items: &items, key: "userInfo")

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

// MARK: - General - URLScheme - Response

extension WeiboHandlerBaseTests: GeneralURLSchemeResponseTestCase {

    func test_general_us_response(scheme: @autoclosure () throws -> String) {
        fatalError()
    }

    func test_general_us_response(host: @autoclosure () throws -> String) {
        fatalError()
    }

    func test_general_us_response(queryItems: inout [URLQueryItem]) {
        fatalError()
    }
}

// MARK: - General - UniversalLink - Response

extension WeiboHandlerBaseTests: GeneralUniversalLinkResponseTestCase {

    func test_general_ul_response(scheme: @autoclosure () throws -> String) {
        XCTAssertEqual(try scheme(), universalLink.scheme)
    }

    func test_general_ul_response(host: @autoclosure () throws -> String) {
        XCTAssertEqual(try host(), universalLink.host)
    }

    func test_general_ul_response(queryItems: inout [URLQueryItem]) {
        let id = queryItems.removeFirst { $0.name == "id" }!
        test_id(id)
    }
}

extension WeiboHandlerBaseTests {

    func test_id(_ queryItem: URLQueryItem) {
        XCTAssertNotNil(try UUID(uuidString: XCTUnwrap(queryItem.value)))
    }
}

// MARK: - General - Pasteboard - Response

extension WeiboHandlerBaseTests: GeneralPasteboardResponseTestCase {

    func extract_major_pb_response(items: inout [[String: Data]]) -> [String: Any] {
        if context.shareState == .responseUniversalLink {
            return extract_KeyedArchiver_pb(items: &items, key: "transferObject")
        }

        return [:]
    }

    func test_general_pb_response(dictionary: inout [String: Any]) {
        test_general_pb_request(dictionary: &dictionary)
    }

    func test_extra_pb_response(items: inout [[String: Data]]) {
        test_app(&items)

        test_sdkVersion(&items)

        if context.shareState == .success {
            test_userInfo_share(&items)
        }
    }
}
