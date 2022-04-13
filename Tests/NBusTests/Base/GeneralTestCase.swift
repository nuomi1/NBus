//
//  GeneralTestCase.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import XCTest

// MARK: - General - Scheme

protocol GeneralSchemeTestCase: XCTestCase {

    /// Report general scheme
    func report_general_scheme() -> Set<String>
}

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
