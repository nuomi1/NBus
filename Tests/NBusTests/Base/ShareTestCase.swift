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

// MARK: - Share - Common - UniversalLink

protocol ShareCommonUniversalLinkTestCase: XCTestCase {

    /// Test share common universal link path
    func test_share_common_ul(path: String)

    /// Test share common universal link queryItems
    func test_share_common_ul(queryItems: inout [URLQueryItem])
}

// MARK: - Share - MediaMessage - UniversalLink

protocol ShareMediaMessageUniversalLinkTestCase: XCTestCase {

    /// Test share media message universal link queryItems
    func test_share_media_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - UniversalLink

protocol ShareMessageUniversalLinkTestCase: XCTestCase {

    /// Test share message universal link queryItems
    func test_share_message_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - UniversalLink

protocol _ShareUniversalLinkTestCase:
    GeneralUniversalLinkTestCase,
    ShareCommonUniversalLinkTestCase,
    ShareMediaMessageUniversalLinkTestCase,
    ShareMessageUniversalLinkTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test share universal link
    func _test_share(url: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Common - Pasteboard

protocol ShareCommonPasteboardTestCase: XCTestCase {

    /// Test share common pasteboard dictionary
    func test_share_common_pb(dictionary: inout [String: Any])
}

// MARK: - Share - MediaMessage - Pasteboard

protocol ShareMediaMessagePasteboardTestCase: XCTestCase {

    /// Test share media message pasteboard dictionary
    func test_share_media_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - Pasteboard

protocol ShareMessagePasteboardTestCase: XCTestCase {

    /// Test share message pasteboard dictionary
    func test_share_message_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Pasteboard

protocol _SharePasteboardTestCase:
    GeneralPasteboardTestCase,
    ShareCommonPasteboardTestCase,
    ShareMediaMessagePasteboardTestCase,
    ShareMessagePasteboardTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test share pasteboard
    func _test_share(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint)

    /// Test share pasteboard dictionary
    func _test_share_pb(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint)
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
}
