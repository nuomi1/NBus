//
//  HandlerBaseTestCase.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/5.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

// MARK: - General - UniversalLink

protocol GeneralUniversalLinkTestCase: XCTestCase {

    /// Test general universal link scheme
    func test_general_ul(scheme: String)

    /// Test general universal link host
    func test_general_ul(host: String)

    /// Test general universal link queryItems
    func test_general_ul(queryItems: inout [URLQueryItem])
}

// MARK: - General - Pasteboard

protocol GeneralPasteboardTestCase: XCTestCase {

    /// Test pasteboard extract major data
    func test_extract_major_pb(items: inout [[String: Data]]) -> [String: Any]

    /// Test general pasteboard dictionary
    func test_general_pb(dictionary: inout [String: Any])

    /// Test pasteboard extra data
    func test_extra_pb(items: inout [[String: Data]])
}

// MARK: - Share - Common - UniversalLink

protocol ShareCommonUniversalLinkTestCase: XCTestCase {

    /// Test share common universal link path
    func test_share_common_ul(path: String)

    /// Test share common universal link queryItems
    func test_share_common_ul(queryItems: inout [URLQueryItem])
}

// MARK: - Share - Common - Pasteboard

protocol ShareCommonPasteboardTestCase: XCTestCase {

    /// Test share common pasteboard dictionary
    func test_share_common_pb(dictionary: inout [String: Any])
}

// MARK: - Share - MediaMessage - UniversalLink

protocol ShareMediaMessageUniversalLinkTestCase: XCTestCase {

    /// Test share media message universal link queryItems
    func test_share_media_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - MediaMessage - Pasteboard

protocol ShareMediaMessagePasteboardTestCase: XCTestCase {

    /// Test share media message pasteboard dictionary
    func test_share_media_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - UniversalLink

protocol ShareMessageUniversalLinkTestCase: XCTestCase {

    /// Test share message universal link queryItems
    func test_share_message_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Message - Pasteboard

protocol ShareMessagePasteboardTestCase: XCTestCase {

    /// Test share message pasteboard dictionary
    func test_share_message_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - URL

protocol ShareURLTestCase:
    GeneralUniversalLinkTestCase,
    ShareCommonUniversalLinkTestCase,
    ShareMediaMessageUniversalLinkTestCase,
    ShareMessageUniversalLinkTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test share universal link
    func test_share(url: URL, _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Pasteboard

protocol SharePasteboardTestCase:
    GeneralPasteboardTestCase,
    ShareCommonPasteboardTestCase,
    ShareMediaMessagePasteboardTestCase,
    ShareMessagePasteboardTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test share pasteboard
    func test_share(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint)

    /// Test share pasteboard major data
    func test_share_major_pb(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint)
}

// MARK: - Share - Completion

protocol ShareCompletionTestCase: XCTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test share completion
    func test_share(result: Result<Void, Bus.Error>, _ message: MessageType, _ endpoint: Endpoint)

    /// Test share avoid error
    func test_share_avoid_error(_ error: Bus.Error, _ message: MessageType, _ endpoint: Endpoint) -> Bool
}

// MARK: - Share

protocol ShareTestCase: ShareURLTestCase, SharePasteboardTestCase, ShareCompletionTestCase {

    var disposeBag: DisposeBag { get }
}

// MARK: - Oauth - Platform - UniversalLink

protocol OauthPlatformUniversalLinkTestCase: XCTestCase {

    /// Test oauth universal link path
    func test_oauth_ul(path: String)

    /// Test oauth universal link queryItems
    func test_oauth_ul(queryItems: inout [URLQueryItem], _ platform: Platform)
}

// MARK: - Oauth - URL

protocol OauthURLTestCase:
    GeneralUniversalLinkTestCase,
    OauthPlatformUniversalLinkTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test oauth universal link
    func test_oauth(url: URL, _ platform: Platform)
}

// MARK: - Oauth - Platform - Pasteboard

protocol OauthPlatformPasteboardTestCase: XCTestCase {

    /// Test oauth pasteboard dictionary
    func test_oauth_pb(dictionary: inout [String: Any], _ platform: Platform)
}

// MARK: - Oauth - Pasteboard

protocol OauthPasteboardTestCase:
    GeneralPasteboardTestCase,
    OauthPlatformPasteboardTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test oauth pasteboard
    func test_oauth(items: [[String: Any]], _ platform: Platform)

    /// Test oauth pasteboard major data
    func test_oauth_major_pb(dictionary: [String: Any], _ platform: Platform)
}

// MARK: - Oauth - Completion

protocol OauthCompletionTestCase: XCTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test oauth completion
    func test_oauth(result: Result<[Bus.OauthInfoKey: String], Bus.Error>, _ platform: Platform)
}

// MARK: - Oauth

protocol OauthTestCase: OauthURLTestCase, OauthPasteboardTestCase, OauthCompletionTestCase {

    var disposeBag: DisposeBag { get }
}
