//
//  ShareTestCase.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

// MARK: - Share - Message - Scheme

protocol ShareMessageSchemeTestCase: XCTestCase {

    /// Report share scheme
    func report_share_scheme(_ message: MessageType, _ endpoint: Endpoint) -> Set<String>
}

// MARK: - Share - Scheme

protocol _ShareSchemeTestCase:
    GeneralSchemeTestCase,
    ShareMessageSchemeTestCase {

    /// Test share scheme
    func _test_share(scheme: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - UniversalLink - Request

protocol ShareMessageUniversalLinkRequestTestCase: XCTestCase {

    /// Test share universal link request path
    func test_share_ul_request(path: String)

    /// Test share universal link request queryItems
    func test_share_ul_request(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - UniversalLink - Request

protocol _ShareUniversalLinkRequestTestCase:
    GeneralUniversalLinkRequestTestCase,
    ShareMessageUniversalLinkRequestTestCase {

    /// Test share universal link request
    func _test_share_request(url: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - Pasteboard - Request

protocol ShareMessagePasteboardRequestTestCase: XCTestCase {

    /// Test share pasteboard request dictionary
    func test_share_pb_request(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Pasteboard - Request

protocol _SharePasteboardRequestTestCase:
    GeneralPasteboardRequestTestCase,
    ShareMessagePasteboardRequestTestCase {

    /// Test share pasteboard request
    func _test_share_request(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint)

    /// Test share pasteboard request dictionary
    func _test_share_pb_request(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - URLScheme - Response

protocol ShareMessageURLSchemeResponseTestCase: XCTestCase {

    /// Test share url scheme response path
    func test_share_us_response(path: String)

    /// Test share url scheme response queryItems
    func test_share_us_response(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - URLScheme - Response

protocol _ShareURLSchemeResponseTestCase:
    GeneralURLSchemeResponseTestCase,
    ShareMessageURLSchemeResponseTestCase {

    /// Test share url scheme response
    func _test_share_response(us: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - UniversalLink - Response

protocol ShareMessageUniversalLinkResponseTestCase: XCTestCase {

    /// Test share universal link response path
    func test_share_ul_response(path: String)

    /// Test share universal link response queryItems
    func test_share_ul_response(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - UniversalLink - Response

protocol _ShareUniversalLinkResponseTestCase:
    GeneralUniversalLinkResponseTestCase,
    ShareMessageUniversalLinkResponseTestCase {

    /// Test share universal link response
    func _test_share_response(url: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - Pasteboard - Response

protocol ShareMessagePasteboardResponseTestCase: XCTestCase {

    /// Test share pasteboard response dictionary
    func test_share_pb_response(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Pasteboard - Response

protocol _SharePasteboardResponseTestCase:
    GeneralPasteboardResponseTestCase,
    ShareMessagePasteboardResponseTestCase {

    /// Test share pasteboard response
    func _test_share_response(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint)

    /// Test share pasteboard response dictionary
    func _test_share_pb_response(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Completion

protocol _ShareCompletionTestCase: XCTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    var context: HandlerTestContext { get set }

    /// Test share completion
    func _test_share(result: Result<Void, Bus.Error>, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share

protocol ShareTestCase:
    _ShareSchemeTestCase,
    _ShareUniversalLinkRequestTestCase,
    _SharePasteboardRequestTestCase,
    _ShareURLSchemeResponseTestCase,
    _ShareUniversalLinkResponseTestCase,
    _SharePasteboardResponseTestCase,
    _ShareCompletionTestCase {

    var disposeBag: DisposeBag { get }

    var context: HandlerTestContext { get set }
}
