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

    override var handler: HandlerType { AppState.qqSDKHandler }

    override var category: AppState.PlatformItem.Category { .sdk }
}
