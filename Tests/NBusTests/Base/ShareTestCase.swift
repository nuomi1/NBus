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

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

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

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test share pasteboard request
    func _test_share_request(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint)

    /// Test share pasteboard request dictionary
    func _test_share_pb_request(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint)

    /// Avoid share pasteboard error
    func _avoid_share_pb_error(_ items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) -> Bool
}

// MARK: - Share - Completion

protocol _ShareCompletionTestCase: XCTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test share completion
    func _test_share(result: Result<Void, Bus.Error>, _ message: MessageType, _ endpoint: Endpoint)

    /// Avoid share completion error
    func _avoid_share_completion_error(_ error: Bus.Error, _ message: MessageType, _ endpoint: Endpoint) -> Bool
}

// MARK: - Share

protocol ShareTestCase:
    _ShareSchemeTestCase,
    _ShareUniversalLinkRequestTestCase,
    _SharePasteboardRequestTestCase,
    _ShareCompletionTestCase {

    var disposeBag: DisposeBag { get }

    var context: HandlerTestContext { get }
}
