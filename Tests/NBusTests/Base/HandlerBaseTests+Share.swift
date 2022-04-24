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
                if url.scheme == "mqqopensdknopasteboard" {
                    self.context.skipPasteboard = true
                }

                self._test_share(scheme: url, message, endpoint)
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                if context.shareState == .signToken {
                    context.shareState = .requestSecond
                }

                self._test_share_request(url: url, message, endpoint)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .filter { [unowned self] items in
                if self.context.skipPasteboard {
                    return false
                }

                if self.context.setPasteboardString {
                    return items.pasteboardString() != AppState.defaultPasteboardString
                }

                return true
            }
            .filter { !$0.allSatisfy { $0.isEmpty } }
            .bind(onNext: { [unowned self] items in
                self._test_share_request(items: items, message, endpoint)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                precondition(self.context.shareState == .requestFirst)

                self.context.shareState = .responseURLScheme

                self._test_share_response(us: url, message, endpoint)

                HandlerBaseTests.openURL(url)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openUserActivity()
            .bind(onNext: { [unowned self] userActivity in
                self._test_share_response(url: userActivity.webpageURL!, message, endpoint)

                HandlerBaseTests.openUserActivity(userActivity)
            })
            .disposed(by: disposeBag)

        context.shareState = .requestFirst

        Bus.shared.share(
            message: message,
            to: endpoint,
            completionHandler: { [unowned self] result in
                if case .failure(.unsupportedMessage) = result {
                    self.context.skipCompletion = true
                }

                self._test_share(result: result, message, endpoint)
            }
        )

        wait(for: [ulExpectation, pbExpectation], timeout: 30)
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
}

// MARK: - Share - URLScheme - Response

extension _ShareURLSchemeResponseTestCase {

    func _test_share_response(us: URL, _ message: MessageType, _ endpoint: Endpoint) {
        let urlComponents = URLComponents(url: us, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - URLScheme - Response

        test_general_us_response(scheme: try XCTUnwrap(urlComponents.scheme))
        test_general_us_response(host: try XCTUnwrap(urlComponents.host))
        test_general_us_response(queryItems: &queryItems)

        // Share - Message - URLScheme - Response

        test_share_us_response(path: urlComponents.path)
        test_share_us_response(queryItems: &queryItems, message, endpoint)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)
    }
}

// MARK: - Share - UniversalLink - Response

extension _ShareUniversalLinkResponseTestCase {

    func _test_share_response(url: URL, _ message: MessageType, _ endpoint: Endpoint) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink - Response

        test_general_ul_response(scheme: try XCTUnwrap(urlComponents.scheme))
        test_general_ul_response(host: try XCTUnwrap(urlComponents.host))
        test_general_ul_response(queryItems: &queryItems)

        // Share - Message - UniversalLink - Response

        test_share_ul_response(path: urlComponents.path)
        test_share_ul_response(queryItems: &queryItems, message, endpoint)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)
    }
}

// MARK: - Share - Pasteboard - Response

extension _SharePasteboardResponseTestCase {

    func _test_share_response(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        _test_share_pb_response(dictionary: extract_major_pb_response(items: &items), message, endpoint)

        test_extra_pb_response(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)
    }

    func _test_share_pb_response(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard - Response

        test_general_pb_response(dictionary: &dictionary)

        // Share - Message - Pasteboard - Response

        test_share_pb_response(dictionary: &dictionary, message, endpoint)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

// MARK: - Share - Completion

extension _ShareCompletionTestCase {

    func _test_share(result: Result<Void, Bus.Error>, _ message: MessageType, _ endpoint: Endpoint) {
        switch result {
        case .success:
            if context.shareState == .success {
                XCTAssertTrue(true)
                break
            }

            XCTAssertTrue(false)
        case let .failure(error):
            logger.error("\(error)")

            if context.skipCompletion {
                XCTAssertTrue(true)
                break
            }

            if context.shareState == .failure {
                XCTAssertTrue(true)
                break
            }

            XCTAssertTrue(false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.ulExpectation.fulfill()
            self.pbExpectation.fulfill()
        }
    }
}
