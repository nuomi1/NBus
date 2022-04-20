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

// MARK: - General - UniversalLink - Request

protocol GeneralUniversalLinkRequestTestCase: XCTestCase {

    /// Test general universal link request scheme
    func test_general_ul_request(scheme: @autoclosure () throws -> String)

    /// Test general universal link request host
    func test_general_ul_request(host: @autoclosure () throws -> String)

    /// Test general universal link request queryItems
    func test_general_ul_request(queryItems: inout [URLQueryItem])
}

// MARK: - General - Pasteboard - Request

protocol GeneralPasteboardRequestTestCase: XCTestCase {

    /// Extract pasteboard request major data
    func extract_major_pb_request(items: inout [[String: Data]]) -> [String: Any]

    /// Test general pasteboard request dictionary
    func test_general_pb_request(dictionary: inout [String: Any])

    /// Test pasteboard request extra data
    func test_extra_pb_request(items: inout [[String: Data]])
}
