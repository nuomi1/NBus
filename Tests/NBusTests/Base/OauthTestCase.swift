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
