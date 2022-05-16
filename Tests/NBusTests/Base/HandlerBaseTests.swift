//
//  HandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxCocoa
import RxRelay
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

    static let schemeRelay = PublishRelay<URL>()

    static let universalLinkRequestRelay = PublishRelay<URL>()

    static let pasteboardRequestRelay = PublishRelay<[[String: Any]]>()

    static let urlSchemeResponseRelay = PublishRelay<URL>()

    static let universalLinkResponseRelay = PublishRelay<URL>()

    static let pasteboardResponseRelay = PublishRelay<[[String: Any]]>()

    var context = HandlerTestContext()

    let ulExpectation = XCTestExpectation(description: "UniversalLink")
    let pbExpectation = XCTestExpectation(description: "Pasteboard")

    override class func setUp() {
        super.setUp()

        UIApplication.shared.rx
            .canOpenURL()
            .bind(onNext: { url in
                schemeRelay.accept(url)
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { url in
                universalLinkRequestRelay.accept(url)

                let items = UIPasteboard.general.items

                if filter(items) {
                    pasteboardRequestRelay.accept(items)
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openURL()
            .bind(onNext: { url, items in
                urlSchemeResponseRelay.accept(url)

                if filter(items) {
                    pasteboardResponseRelay.accept(items)
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openUserActivity()
            .bind(onNext: { userActivity, items in
                universalLinkResponseRelay.accept(userActivity.webpageURL!)

                if filter(items) {
                    pasteboardResponseRelay.accept(items)
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openURL()
            .bind(onNext: { url, items in
                logger.debug("\(url)")
                logger.debug("\(items.map { $0.keys.sorted() })")
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openUserActivity()
            .bind(onNext: { userActivity, items in
                logger.debug("\(userActivity.webpageURL!)")
                logger.debug("\(items.map { $0.keys.sorted() })")
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

        UIPasteboard.general.rx
            .items()
            .bind(onNext: { items in
                logger.debug("\(items.map { $0.keys.sorted() })")
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openURL()
            .bind(onNext: { url, _ in
                openURL(url)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .openUserActivity()
            .bind(onNext: { userActivity, _ in
                openUserActivity(userActivity)
            })
            .disposed(by: disposeBag)
    }

    static func openURL(_ url: URL) {
        let result = Bus.shared.openURL(url)

        NotificationCenter.default.post(
            name: AppState.OpenURL.responseName,
            object: nil,
            userInfo: [
                AppState.OpenURL.responseResultKey: result,
            ]
        )
    }

    static func openUserActivity(_ userActivity: NSUserActivity) {
        let result = Bus.shared.openUserActivity(userActivity)

        NotificationCenter.default.post(
            name: AppState.OpenUserActivity.responseName,
            object: nil,
            userInfo: [
                AppState.OpenUserActivity.responseResultKey: result,
            ]
        )
    }

    static func filter(_ items: [[String: Any]]) -> Bool {
        !items.allSatisfy { $0.isEmpty }
            && items.pasteboardString() != AppState.defaultPasteboardString
    }
}

extension HandlerBaseTests {

    override func setUp() {
        super.setUp()

        context.setPasteboardString = true

        AppState.shared.clearPasteboard(shouldSetString: context.setPasteboardString)
        AppState.shared.clearKeychains()
        AppState.shared.clearUserDefaults()

        Bus.shared.handlers = [handler]
    }

    override func tearDown() {
        super.tearDown()

        disposeBag = DisposeBag()
    }
}
