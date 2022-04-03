//
//  WechatSDKHandlerTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus

class WechatSDKHandlerTests: WechatHandlerBaseTests {

    override class var handler: HandlerType { AppState.wechatSDKHandler }

    override class var category: AppState.PlatformItem.Category { .sdk }
}
