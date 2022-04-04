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

    override class var handler: HandlerType { AppState.weiboSDKHandler }

    override class var category: AppState.PlatformItem.Category { .sdk }
}
