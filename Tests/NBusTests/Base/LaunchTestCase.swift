//
//  LaunchTestCase.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

// MARK: - Launch - Program - UniversalLink

protocol LaunchProgramUniversalLinkTestCase: XCTestCase {

    /// Test launch universal link path
    func test_launch_ul(path: String)

    /// Test launch universal link queryItems
    func test_launch_ul(queryItems: inout [URLQueryItem], _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - UniversalLink

protocol _LaunchUniversalLinkTestCase:
    GeneralUniversalLinkTestCase,
    LaunchProgramUniversalLinkTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test launch universal link
    func _test_launch(url: URL, _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - Platform - Pasteboard

protocol LaunchProgramPasteboardTestCase: XCTestCase {

    /// Test launch pasteboard dictionary
    func test_launch_pb(dictionary: inout [String: Any], _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - Pasteboard

protocol _LaunchPasteboardTestCase:
    GeneralPasteboardTestCase,
    LaunchProgramPasteboardTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test launch pasteboard
    func _test_launch(items: [[String: Any]], _ platform: Platform, _ program: MiniProgramMessage)

    /// Test launch pasteboard dictionary
    func _test_launch_pb(dictionary: [String: Any], _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - Completion

protocol _LaunchCompletionTestCase: XCTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test launch completion
    func _test_launch(result: Result<Void, Bus.Error>, _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch

protocol LaunchTestCase: _LaunchUniversalLinkTestCase, _LaunchPasteboardTestCase, _LaunchCompletionTestCase {

    var disposeBag: DisposeBag { get }
}
