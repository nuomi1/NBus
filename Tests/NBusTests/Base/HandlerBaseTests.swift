//
//  HandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

class HandlerBaseTests: XCTestCase {

    var appID: String {
        fatalError()
    }

    final var appNumber: String {
        appID.trimmingCharacters(in: .letters)
    }

    final var bundleID: String {
        Bundle.main.bus.identifier!
    }

    var category: AppState.PlatformItem.Category {
        fatalError()
    }

    final var displayName: String {
        Bundle.main.bus.displayName!
    }

    var handler: HandlerType {
        fatalError()
    }

    var sdkShortVersion: String {
        fatalError()
    }

    var sdkVersion: String {
        fatalError()
    }

    var universalLink: URL {
        fatalError()
    }

    static var disposeBag = DisposeBag()
    var disposeBag = DisposeBag()

    let ulExpectation = XCTestExpectation(description: "UniversalLink")
    let pbExpectation = XCTestExpectation(description: "Pasteboard")

    override class func setUp() {
        super.setUp()

        NotificationCenter.default.rx
            .notification(AppState.OpenURL.requestName)
            .bind(onNext: { notification in
                let url = notification.userInfo?[AppState.OpenURL.requestKey] as! URL
                let result = Bus.shared.openURL(url)

                NotificationCenter.default.post(
                    name: AppState.OpenURL.responseName,
                    object: nil,
                    userInfo: [
                        AppState.OpenURL.responseKey: result,
                    ]
                )
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(AppState.OpenUserActivity.requestName)
            .bind(onNext: { notification in
                let userActivity = notification.userInfo?[AppState.OpenUserActivity.requestKey] as! NSUserActivity
                let result = Bus.shared.openUserActivity(userActivity)

                NotificationCenter.default.post(
                    name: AppState.OpenUserActivity.responseName,
                    object: nil,
                    userInfo: [
                        AppState.OpenUserActivity.responseKey: result,
                    ]
                )
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .canOpenURL()
            .bind(onNext: { url in
                logger.debug("\(url)")
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { url in
                logger.debug("\(url)")
            })
            .disposed(by: disposeBag)
    }
}

extension HandlerBaseTests {

    override func setUp() {
        super.setUp()

        Bus.shared.handlers = [handler]

        AppState.shared.clearPasteboard()
    }

    override func tearDown() {
        super.tearDown()

        disposeBag = DisposeBag()
    }
}

// MARK: - General - Pasteboard

extension GeneralPasteboardTestCase {

    func test_extract_KeyedArchiver_pb(items: inout [[String: Data]], key: String) -> [String: Any] {
        let item = items.removeFirst { $0.keys.contains(key) }!

        precondition(item.count == 1)

        let data = item[key]!
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]

        return dictionary
    }

    func test_extract_PropertyList_pb(items: inout [[String: Data]], key: String) -> [String: Any] {
        let item = items.removeFirst { $0.keys.contains(key) }!

        precondition(item.count == 1)

        let data = item[key]!
        let dictionary = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]

        return dictionary
    }
}

// MARK: - Share

extension ShareTestCase {

    func test_share(_ message: MessageType, _ endpoint: Endpoint) {
        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self.test_share(url: url, message, endpoint)
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
                self.test_share(items: items, message, endpoint)
            })
            .disposed(by: disposeBag)

        Bus.shared.share(
            message: message,
            to: endpoint,
            completionHandler: { [unowned self] result in
                self.test_share(result: result, message, endpoint)
            }
        )

        wait(for: [ulExpectation, pbExpectation], timeout: 5)
    }
}

// MARK: - Share - URL

extension ShareURLTestCase {

    func test_share(url: URL, _ message: MessageType, _ endpoint: Endpoint) {
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

extension SharePasteboardTestCase {

    func test_share(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        test_share_major_pb(dictionary: test_extract_major_pb(items: &items), message, endpoint)

        test_extra_pb(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func test_share_major_pb(dictionary: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard

        test_general_pb(dictionary: &dictionary)

        // Share - Comon - Pasteboard

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

extension ShareCompletionTestCase {

    func test_share(result: Result<Void, Bus.Error>, _ message: MessageType, _ endpoint: Endpoint) {
        switch result {
        case .success:
            XCTAssertTrue(true)
        case let .failure(error):
            logger.error("\(error)")

            if test_share_avoid_error(error, message, endpoint) {
                XCTAssertTrue(true)

                ulExpectation.fulfill()
                pbExpectation.fulfill()
            } else {
                XCTAssertTrue(false)
            }
        }
    }
}

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
