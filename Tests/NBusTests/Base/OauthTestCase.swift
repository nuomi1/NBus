//
//  OauthTestCase.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

// MARK: - Oauth - Platform - Scheme

protocol OauthPlatformSchemeTestCase: XCTestCase {

    /// Report oauth scheme
    func report_oauth_scheme(_ platform: Platform) -> Set<String>
}

// MARK: - Oauth - Scheme

protocol _OauthSchemeTestCase:
    GeneralSchemeTestCase,
    OauthPlatformSchemeTestCase {

    /// Test oauth scheme
    func _test_oauth(scheme: URL, _ platform: Platform)
}

// MARK: - Oauth - Platform - UniversalLink - Request

protocol OauthPlatformUniversalRequestLinkTestCase: XCTestCase {

    /// Test oauth universal link request path
    func test_oauth_ul_request(path: String)

    /// Test oauth universal link request queryItems
    func test_oauth_ul_request(queryItems: inout [URLQueryItem], _ platform: Platform)
}

// MARK: - Oauth - UniversalLink - Request

protocol _OauthUniversalLinkRequestTestCase:
    GeneralUniversalLinkRequestTestCase,
    OauthPlatformUniversalRequestLinkTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test oauth universal link request
    func _test_oauth_request(url: URL, _ platform: Platform)
}

// MARK: - Oauth - Platform - Pasteboard - Request

protocol OauthPlatformPasteboardRequestTestCase: XCTestCase {

    /// Test oauth pasteboard request dictionary
    func test_oauth_pb_request(dictionary: inout [String: Any], _ platform: Platform)
}

// MARK: - Oauth - Pasteboard - Request

protocol _OauthPasteboardRequestTestCase:
    GeneralPasteboardRequestTestCase,
    OauthPlatformPasteboardRequestTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test oauth pasteboard request
    func _test_oauth_request(items: [[String: Any]], _ platform: Platform)

    /// Test oauth pasteboard request dictionary
    func _test_oauth_pb_request(dictionary: [String: Any], _ platform: Platform)

    /// Avoid oauth pasteboard error
    func _avoid_oauth_pb_error(_ items: [[String: Any]], _ platform: Platform) -> Bool
}

// MARK: - Oauth - Completion

protocol _OauthCompletionTestCase: XCTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test oauth completion
    func _test_oauth(result: Result<[Bus.OauthInfoKey: String], Bus.Error>, _ platform: Platform)
}

// MARK: - Oauth

protocol OauthTestCase:
    _OauthSchemeTestCase,
    _OauthUniversalLinkRequestTestCase,
    _OauthPasteboardRequestTestCase,
    _OauthCompletionTestCase {

    var disposeBag: DisposeBag { get }

    var context: HandlerTestContext { get }
}
