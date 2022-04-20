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
            .canOpenURL()
            .bind(onNext: { [unowned self] url in
                self._test_share(scheme: url, message, endpoint)
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self._test_share_request(url: url, message, endpoint)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .skip(while: { [unowned self] items in
                if self._avoid_share_pb_error(items, message, endpoint) {
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
                self._test_share_request(items: items, message, endpoint)
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

// MARK: - Share - Scheme

extension _ShareSchemeTestCase {

    func _test_share(scheme: URL, _ message: MessageType, _ endpoint: Endpoint) {
        var schemeList: Set<String> = []
        schemeList.formUnion(report_general_scheme())
        schemeList.formUnion(report_share_scheme(message, endpoint))

        XCTAssertTrue(schemeList.contains(try XCTUnwrap(scheme.scheme)))
    }
}

// MARK: - Share - UniversalLink - Request

extension _ShareUniversalLinkRequestTestCase {

    func _test_share_request(url: URL, _ message: MessageType, _ endpoint: Endpoint) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink - Request

        test_general_ul_request(scheme: try XCTUnwrap(urlComponents.scheme))
        test_general_ul_request(host: try XCTUnwrap(urlComponents.host))
        test_general_ul_request(queryItems: &queryItems)

        // Share - Message - UniversalLink - Request

        test_share_ul_request(path: urlComponents.path)
        test_share_ul_request(queryItems: &queryItems, message, endpoint)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)

        ulExpectation.fulfill()
    }
}

// MARK: - Share - Pasteboard - Request

extension _SharePasteboardRequestTestCase {

    func _test_share_request(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        _test_share_pb_request(dictionary: extract_major_pb_request(items: &items), message, endpoint)

        test_extra_pb_request(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func _test_share_pb_request(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard - Request

        test_general_pb_request(dictionary: &dictionary)

        // Share - Message - Pasteboard - Request

        test_share_pb_request(dictionary: &dictionary, message, endpoint)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }

    func _avoid_share_pb_error(_ items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) -> Bool {
        (message.identifier == Messages.webPage && endpoint == Endpoints.QQ.friend)
            || (message.identifier == Messages.webPage && endpoint == Endpoints.QQ.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.QQ.friend)
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

            if _avoid_share_completion_error(error, message, endpoint) {
                XCTAssertTrue(true)

                ulExpectation.fulfill()
                pbExpectation.fulfill()
            } else {
                XCTAssertTrue(false)
            }
        }
    }

    func _avoid_share_completion_error(_ error: Bus.Error, _ message: MessageType, _ endpoint: Endpoint) -> Bool {
        (message.identifier == Messages.file && endpoint == Endpoints.QQ.timeline)
            || (message.identifier == Messages.file && endpoint == Endpoints.Wechat.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Wechat.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Wechat.favorite)
            || (message.identifier == Messages.file && endpoint == Endpoints.Weibo.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Weibo.timeline)
    }
}
