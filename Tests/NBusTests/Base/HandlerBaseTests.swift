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

    var context = HandlerTestContext()

    let ulExpectation = XCTestExpectation(description: "UniversalLink")
    let pbExpectation = XCTestExpectation(description: "Pasteboard")

    override class func setUp() {
        super.setUp()

        NotificationCenter.default.rx
            .notification(AppState.OpenURL.requestName)
            .bind(onNext: { notification in
                let url = notification.userInfo?[AppState.OpenURL.requestKey] as! URL
                let result = Bus.shared.openURL(url)

                logger.debug("\(url)")

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

                logger.debug("\(String(describing: userActivity.webpageURL))")

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

        context.setPasteboardString = true

        AppState.shared.clearPasteboard(shouldSetString: context.setPasteboardString)

        Bus.shared.handlers = [handler]
    }

    override func tearDown() {
        super.tearDown()

        disposeBag = DisposeBag()
    }
}
