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

// MARK: - Share - Message - UniversalLink

protocol ShareMessageUniversalLinkTestCase: XCTestCase {

    /// Test share universal link path
    func test_share_ul(path: String)

    /// Test share universal link queryItems
    func test_share_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - UniversalLink

protocol _ShareUniversalLinkTestCase:
    GeneralUniversalLinkTestCase,
    ShareMessageUniversalLinkTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test share universal link
    func _test_share(url: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - Pasteboard

protocol ShareMessagePasteboardTestCase: XCTestCase {

    /// Test share pasteboard dictionary
    func test_share_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Pasteboard

protocol _SharePasteboardTestCase:
    GeneralPasteboardTestCase,
    ShareMessagePasteboardTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test share pasteboard
    func _test_share(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint)

    /// Test share pasteboard dictionary
    func _test_share_pb(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint)

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
    _ShareUniversalLinkTestCase,
    _SharePasteboardTestCase,
    _ShareCompletionTestCase {

    var disposeBag: DisposeBag { get }

    var context: HandlerTestContext { get }
}