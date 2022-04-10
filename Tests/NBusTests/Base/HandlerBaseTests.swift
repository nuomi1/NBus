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

// MARK: - Launch

extension LaunchTestCase {

    func test_launch(_ platform: Platform, _ program: MiniProgramMessage) {
        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self.test_launch(url: url, platform, program)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .filter { !$0.isEmpty }
            .bind(onNext: { [unowned self] items in
                self.test_launch(items: items, platform, program)
            })
            .disposed(by: disposeBag)

        Bus.shared.launch(
            program: program,
            with: platform,
            completionHandler: { [unowned self] result in
                self.test_launch(result: result, platform, program)
            }
        )
    }
}

// MARK: - Launch - URL

extension LaunchURLTestCase {

    func test_launch(url: URL, _ platform: Platform, _ program: MiniProgramMessage) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        logger.debug("\(URLComponents.self), start, \(queryItems.map(\.name).sorted())")

        // General - UniversalLink

        test_general_ul(scheme: urlComponents.scheme!)
        test_general_ul(host: urlComponents.host!)
        test_general_ul(queryItems: &queryItems)

        // Launch - UniversalLink

        test_launch_ul(path: urlComponents.path)
        test_launch_ul(queryItems: &queryItems, platform, program)

        logger.debug("\(URLComponents.self), end, \(queryItems.map(\.name).sorted())")

        XCTAssertTrue(queryItems.isEmpty)

        ulExpectation.fulfill()
    }
}

// MARK: - Launch - Pasteboard

extension LaunchPasteboardTestCase {

    func test_launch(items: [[String: Any]], _ platform: Platform, _ program: MiniProgramMessage) {
        var items = items as! [[String: Data]]

        logger.debug("\(UIPasteboard.self), start, \(items.map { $0.keys.sorted() })")

        test_launch_major_pb(dictionary: test_extract_major_pb(items: &items), platform, program)

        test_extra_pb(items: &items)

        logger.debug("\(UIPasteboard.self), end, \(items.map { $0.keys.sorted() })")

        XCTAssertTrue(items.isEmpty)

        pbExpectation.fulfill()
    }

    func test_launch_major_pb(dictionary: [String: Any], _ platform: Platform, _ program: MiniProgramMessage) {
        var dictionary = dictionary

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        // General - Pasteboard

        test_general_pb(dictionary: &dictionary)

        // Launch - Program - Pasteboard

        test_launch_pb(dictionary: &dictionary, platform, program)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

// MARK: - Launch - Completion

extension LaunchCompletionTestCase {

    func test_launch(result: Result<Void, Bus.Error>, _ platform: Platform, _ program: MiniProgramMessage) {
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTAssertTrue(false)
        }
    }
}
