//
//  HandlerBaseTests+Oauth.swift
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

// MARK: - Oauth

extension OauthTestCase {

    func test_oauth(_ platform: Platform) {
        UIApplication.shared.rx
            .canOpenURL()
            .bind(onNext: { [unowned self] url in
                self._test_oauth(scheme: url, platform)
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self._test_oauth_request(url: url, platform)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .skip(while: { [unowned self] items in
                if self._avoid_oauth_pb_error(items, platform) {
                    precondition(items.pasteboardString() == AppState.defaultPasteboardString)

                    self.pbExpectation.fulfill()

                    return true
                }

                if self.context.setPasteboardString {
                    return items.pasteboardString() == AppState.defaultPasteboardString
                }

                return false
            })
            .filter { !$0.allSatisfy { $0.isEmpty } }
            .bind(onNext: { [unowned self] items in
                self._test_oauth_request(items: items, platform)
            })
            .disposed(by: disposeBag)

        Bus.shared.oauth(
            with: platform,
            completionHandler: { [unowned self] result in
                self._test_oauth(result: result, platform)
            }
        )

        wait(for: [ulExpectation, pbExpectation], timeout: 5)
    }
}

// MARK: - Oauth - Scheme

extension _OauthSchemeTestCase {

    func _test_oauth(scheme: URL, _ platform: Platform) {
        var schemeList: Set<String> = []
        schemeList.formUnion(report_general_scheme())
        schemeList.formUnion(report_oauth_scheme(platform))

        XCTAssertTrue(schemeList.contains(try XCTUnwrap(scheme.scheme)))
    }
}

// MARK: - Oauth - UniversalLink - Request

extension _OauthUniversalLinkRequestTestCase {

    func _test_oauth_request(url: URL, _ platform: Platform) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink - Request

        test_general_ul_request(scheme: try XCTUnwrap(urlComponents.scheme))
        test_general_ul_request(host: try XCTUnwrap(urlComponents.host))
        test_general_ul_request(queryItems: &queryItems)

        // Oauth - Platform - UniversalLink - Request

        test_oauth_ul_request(path: urlComponents.path)
        test_oauth_ul_request(queryItems: &queryItems, platform)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)

        ulExpectation.fulfill()
    }
}

// MARK: - Oauth - Pasteboard - Request

extension _OauthPasteboardRequestTestCase {

    func _test_oauth_request(items: [[String: Any]], _ platform: Platform) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        _test_oauth_pb_request(dictionary: extract_major_pb_request(items: &items), platform)

        test_extra_pb_request(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func _test_oauth_pb_request(dictionary: [String: Any], _ platform: Platform) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard - Request

        test_general_pb_request(dictionary: &dictionary)

        // Oauth - Platform - Pasteboard - Request

        test_oauth_pb_request(dictionary: &dictionary, platform)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }

    func _avoid_oauth_pb_error(_ items: [[String: Any]], _ platform: Platform) -> Bool {
        platform == Platforms.qq
    }
}

// MARK: - Oauth - Completion

extension _OauthCompletionTestCase {

    func _test_oauth(result: Result<[Bus.OauthInfoKey: String], Bus.Error>, _ platform: Platform) {
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTAssertTrue(false)
        }
    }
}
