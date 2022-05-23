//
//  GeneralTestCase.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import RxRelay
import XCTest

// MARK: - General - Scheme

protocol GeneralSchemeTestCase: XCTestCase {

    /// Report general scheme
    func report_general_scheme() -> Set<String>
}

// MARK: - General - UniversalLink - Request

protocol GeneralUniversalLinkRequestTestCase: XCTestCase {

    /// Test general universal link request scheme
    func test_general_ul_request(scheme: @autoclosure () throws -> String)

    /// Test general universal link request host
    func test_general_ul_request(host: @autoclosure () throws -> String)

    /// Test general universal link request queryItems
    func test_general_ul_request(queryItems: inout [URLQueryItem])
}

// MARK: - General - Pasteboard - Request

protocol GeneralPasteboardRequestTestCase: XCTestCase {

    /// Extract pasteboard request major data
    func extract_major_pb_request(items: inout [[String: Data]]) -> [String: Any]

    /// Test general pasteboard request dictionary
    func test_general_pb_request(dictionary: inout [String: Any])

    /// Test pasteboard request extra data
    func test_extra_pb_request(items: inout [[String: Data]])
}

// MARK: - General - URLScheme - Response

protocol GeneralURLSchemeResponseTestCase: XCTestCase {

    /// Test general url scheme response scheme
    func test_general_us_response(scheme: @autoclosure () throws -> String)

    /// Test general url scheme response host
    func test_general_us_response(host: @autoclosure () throws -> String)

    /// Test general url scheme response queryItems
    func test_general_us_response(queryItems: inout [URLQueryItem])
}

// MARK: - General - UniversalLink - Response

protocol GeneralUniversalLinkResponseTestCase: XCTestCase {

    /// Test general universal link response scheme
    func test_general_ul_response(scheme: @autoclosure () throws -> String)

    /// Test general universal link response host
    func test_general_ul_response(host: @autoclosure () throws -> String)

    /// Test general universal link response queryItems
    func test_general_ul_response(queryItems: inout [URLQueryItem])
}

// MARK: - General - Pasteboard - Response

protocol GeneralPasteboardResponseTestCase: XCTestCase {

    /// Extract pasteboard response major data
    func extract_major_pb_response(items: inout [[String: Data]]) -> [String: Any]

    /// Test general pasteboard response dictionary
    func test_general_pb_response(dictionary: inout [String: Any])

    /// Test pasteboard response extra data
    func test_extra_pb_response(items: inout [[String: Data]])
}

// MARK: - General - Completion

protocol GeneralCompletionTestCase: XCTestCase {

    /// scheme relay
    static var schemeRelay: PublishRelay<URL> { get }

    /// universal link request relay
    static var universalLinkRequestRelay: PublishRelay<URL> { get }

    /// pasteboard request relay
    static var pasteboardRequestRelay: PublishRelay<[[String: Any]]> { get }

    /// url scheme response relay
    static var urlSchemeResponseRelay: PublishRelay<URL> { get }

    /// universal link response relay
    static var universalLinkResponseRelay: PublishRelay<URL> { get }

    /// pasteboard response relay
    static var pasteboardResponseRelay: PublishRelay<[[String: Any]]> { get }
}
