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

// MARK: - Launch - Program - Scheme

protocol LaunchProgramSchemeTestCase: XCTestCase {

    /// Report launch scheme
    func report_launch_scheme(_ platform: Platform, _ program: MiniProgramMessage) -> Set<String>
}

// MARK: - Launch - Scheme

protocol _LaunchSchemeTestCase:
    GeneralSchemeTestCase,
    LaunchProgramSchemeTestCase {

    /// Test launch scheme
    func _test_launch(scheme: URL, _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - Program - UniversalLink - Request

protocol LaunchProgramUniversalLinkRequestTestCase: XCTestCase {

    /// Test launch universal link request path
    func test_launch_ul_request(path: String)

    /// Test launch universal link request queryItems
    func test_launch_ul_request(queryItems: inout [URLQueryItem], _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - UniversalLink - Request

protocol _LaunchUniversalLinkRequestTestCase:
    GeneralUniversalLinkRequestTestCase,
    LaunchProgramUniversalLinkRequestTestCase {

    /// Universal link expectation
    var ulExpectation: XCTestExpectation { get }

    /// Test launch universal link request
    func _test_launch_request(url: URL, _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - Platform - Pasteboard - Request

protocol LaunchProgramPasteboardRequestTestCase: XCTestCase {

    /// Test launch pasteboard request dictionary
    func test_launch_pb_request(dictionary: inout [String: Any], _ platform: Platform, _ program: MiniProgramMessage)
}

// MARK: - Launch - Pasteboard - Request

protocol _LaunchPasteboardRequestTestCase:
    GeneralPasteboardRequestTestCase,
    LaunchProgramPasteboardRequestTestCase {

    /// Pasteboard expectation
    var pbExpectation: XCTestExpectation { get }

    /// Test launch pasteboard request
    func _test_launch_request(items: [[String: Any]], _ platform: Platform, _ program: MiniProgramMessage)

    /// Test launch pasteboard request dictionary
    func _test_launch_pb_request(dictionary: [String: Any], _ platform: Platform, _ program: MiniProgramMessage)
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

protocol LaunchTestCase:
    _LaunchSchemeTestCase,
    _LaunchUniversalLinkRequestTestCase,
    _LaunchPasteboardRequestTestCase,
    _LaunchCompletionTestCase {

    var disposeBag: DisposeBag { get }

    var context: HandlerTestContext { get }
}
