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

    class var handler: HandlerType {
        fatalError()
    }

    class var category: AppState.PlatformItem.Category {
        fatalError()
    }

    static var disposeBag = DisposeBag()
    var disposeBag = DisposeBag()

    override class func setUp() {
        super.setUp()

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

        Bus.shared.handlers = [handler]
    }

    override func tearDown() {
        super.tearDown()

        disposeBag = DisposeBag()
    }
}
