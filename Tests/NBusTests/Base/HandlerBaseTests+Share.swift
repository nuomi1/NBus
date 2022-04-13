//
//  HandlerBaseTests+Share.swift
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

// MARK: - Share

extension ShareTestCase {

    func test_share(_ message: MessageType, _ endpoint: Endpoint) {
        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self._test_share(url: url, message, endpoint)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .do(onNext: { [unowned self] items in
                if
                    (message.identifier == Messages.webPage && endpoint == Endpoints.QQ.friend)
                    || (message.identifier == Messages.webPage && endpoint == Endpoints.QQ.timeline)
                    || (message.identifier == Messages.miniProgram && endpoint == Endpoints.QQ.friend) {
                    precondition(items.isEmpty)

                    self.pbExpectation.fulfill()
                }
            })
            .filter { !$0.isEmpty }
            .bind(onNext: { [unowned self] items in
                self._test_share(items: items, message, endpoint)
            })
            .disposed(by: disposeBag)

        Bus.shared.share(
            message: message,
            to: endpoint,
            completionHandler: { [unowned self] result in
                self._test_share(result: result, message, endpoint)
            }
        )

        wait(for: [ulExpectation, pbExpectation], timeout: 5)
    }
}

// MARK: - Share - UniversalLink

extension _ShareUniversalLinkTestCase {

    func _test_share(url: URL, _ message: MessageType, _ endpoint: Endpoint) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink

        test_general_ul(scheme: urlComponents.scheme!)
        test_general_ul(host: urlComponents.host!)
        test_general_ul(queryItems: &queryItems)

        // Share - Common - UniversalLink

        test_share_common_ul(path: urlComponents.path)
        test_share_common_ul(queryItems: &queryItems)

        // Share - MediaMessage - UniversalLink

        test_share_media_ul(queryItems: &queryItems, message, endpoint)

        // Share - Message - UniversalLink

        test_share_message_ul(queryItems: &queryItems, message, endpoint)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)

        ulExpectation.fulfill()
    }
}

// MARK: - Share - Pasteboard

extension _SharePasteboardTestCase {

    func _test_share(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        _test_share_pb(dictionary: test_extract_major_pb(items: &items), message, endpoint)

        test_extra_pb(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func _test_share_pb(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard

        test_general_pb(dictionary: &dictionary)

        // Share - Common - Pasteboard

        test_share_common_pb(dictionary: &dictionary)

        // Share - MediaMessage - Pasteboard

        test_share_media_pb(dictionary: &dictionary, message, endpoint)

        // Share - Message - Pasteboard

        test_share_message_pb(dictionary: &dictionary, message, endpoint)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

// MARK: - Share - Completion

extension _ShareCompletionTestCase {

    func _test_share(result: Result<Void, Bus.Error>, _ message: MessageType, _ endpoint: Endpoint) {
        switch result {
        case .success:
            XCTAssertTrue(true)
        case let .failure(error):
            logger.error("\(error)")

            if _test_share_avoid_error(error, message, endpoint) {
                XCTAssertTrue(true)

                ulExpectation.fulfill()
                pbExpectation.fulfill()
            } else {
                XCTAssertTrue(false)
            }
        }
    }

    func _test_share_avoid_error(_ error: Bus.Error, _ message: MessageType, _ endpoint: Endpoint) -> Bool {
        (message.identifier == Messages.file && endpoint == Endpoints.QQ.timeline)
            || (message.identifier == Messages.file && endpoint == Endpoints.Wechat.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Wechat.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Wechat.favorite)
            || (message.identifier == Messages.file && endpoint == Endpoints.Weibo.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Weibo.timeline)
    }
}
