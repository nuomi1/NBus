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
            .openURL()
            .bind(onNext: { [unowned self] url in
                self.test_oauth(url: url, platform)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .do(onNext: { [unowned self] items in
                if platform == Platforms.qq {
                    precondition(items.isEmpty)

                    self.pbExpectation.fulfill()
                }
            })
            .filter { !$0.isEmpty }
            .bind(onNext: { [unowned self] items in
                self.test_oauth(items: items, platform)
            })
            .disposed(by: disposeBag)

        Bus.shared.oauth(
            with: platform,
            completionHandler: { [unowned self] result in
                self.test_oauth(result: result, platform)
            }
        )

        wait(for: [ulExpectation, pbExpectation], timeout: 5)
    }
}

// MARK: - Oauth - URL

extension OauthURLTestCase {

    func test_oauth(url: URL, _ platform: Platform) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink

        test_general_ul(scheme: urlComponents.scheme!)
        test_general_ul(host: urlComponents.host!)
        test_general_ul(queryItems: &queryItems)

        // Oauth - UniversalLink

        test_oauth_ul(path: urlComponents.path)
        test_oauth_ul(queryItems: &queryItems, platform)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)

        ulExpectation.fulfill()
    }
}

// MARK: - Oauth - Pasteboard

extension OauthPasteboardTestCase {

    func test_oauth(items: [[String: Any]], _ platform: Platform) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        test_oauth_major_pb(dictionary: test_extract_major_pb(items: &items), platform)

        test_extra_pb(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func test_oauth_major_pb(dictionary: [String: Any], _ platform: Platform) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard

        test_general_pb(dictionary: &dictionary)

        // Oauth - Platform - Pasteboard

        test_oauth_pb(dictionary: &dictionary, platform)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

// MARK: - Oauth - Completion

extension OauthCompletionTestCase {

    func test_oauth(result: Result<[Bus.OauthInfoKey: String], Bus.Error>, _ platform: Platform) {
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTAssertTrue(false)
        }
    }
}
