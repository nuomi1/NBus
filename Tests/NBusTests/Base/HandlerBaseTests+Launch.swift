//
//  HandlerBaseTests+Launch.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxCocoa
import RxSwift
import XCTest

// MARK: - Launch

extension LaunchTestCase {

    func test_launch(_ platform: Platform, _ program: MiniProgramMessage) {
        UIApplication.shared.rx
            .canOpenURL()
            .bind(onNext: { [unowned self] url in
                self._test_launch(scheme: url, platform, program)
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self._test_launch_request(url: url, platform, program)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .filter { !$0.allSatisfy { $0.isEmpty } }
            .bind(onNext: { [unowned self] items in
                self._test_launch_request(items: items, platform, program)
            })
            .disposed(by: disposeBag)

        Bus.shared.launch(
            program: program,
            with: platform,
            completionHandler: { [unowned self] result in
                self._test_launch(result: result, platform, program)
            }
        )
    }
}

// MARK: - Launch - Scheme

extension _LaunchSchemeTestCase {

    func _test_launch(scheme: URL, _ platform: Platform, _ program: MiniProgramMessage) {
        var schemeList: Set<String> = []
        schemeList.formUnion(report_general_scheme())
        schemeList.formUnion(report_launch_scheme(platform, program))

        XCTAssertTrue(schemeList.contains(try XCTUnwrap(scheme.scheme)))
    }
}

// MARK: - Launch - UniversalLink - Request

extension _LaunchUniversalLinkRequestTestCase {

    func _test_launch_request(url: URL, _ platform: Platform, _ program: MiniProgramMessage) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink - Request

        test_general_ul_request(scheme: try XCTUnwrap(urlComponents.scheme))
        test_general_ul_request(host: try XCTUnwrap(urlComponents.host))
        test_general_ul_request(queryItems: &queryItems)

        // Launch - Program - UniversalLink - Request

        test_launch_ul_request(path: urlComponents.path)
        test_launch_ul_request(queryItems: &queryItems, platform, program)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)

        ulExpectation.fulfill()
    }
}

// MARK: - Launch - Pasteboard - Request

extension _LaunchPasteboardRequestTestCase {

    func _test_launch_request(items: [[String: Any]], _ platform: Platform, _ program: MiniProgramMessage) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        _test_launch_pb_request(dictionary: extract_major_pb_request(items: &items), platform, program)

        test_extra_pb_request(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func _test_launch_pb_request(dictionary: [String: Any], _ platform: Platform, _ program: MiniProgramMessage) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard - Request

        test_general_pb_request(dictionary: &dictionary)

        // Launch - Program - Pasteboard - Request

        test_launch_pb_request(dictionary: &dictionary, platform, program)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

// MARK: - Launch - Completion

extension _LaunchCompletionTestCase {

    func _test_launch(result: Result<Void, Bus.Error>, _ platform: Platform, _ program: MiniProgramMessage) {
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTAssertTrue(false)
        }
    }
}
