//
//  QQSDKHandlerTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus

class QQSDKHandlerTests: QQHandlerBaseTests {

    static let qqSDKHandler = QQSDKHandler(
        appID: AppState.getAppID(for: Platforms.qq)!,
        universalLink: AppState.getUniversalLink(for: Platforms.qq)!
    )

    override class var handler: HandlerType { qqSDKHandler }

    override class var category: AppState.PlatformItem.Category { .sdk }
}
