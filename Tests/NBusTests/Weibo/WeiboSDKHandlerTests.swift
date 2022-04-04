//
//  WeiboSDKHandlerTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/4.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus

class WeiboSDKHandlerTests: WeiboHandlerBaseTests {

    override var handler: HandlerType { AppState.weiboSDKHandler }

    override var category: AppState.PlatformItem.Category { .sdk }
}
