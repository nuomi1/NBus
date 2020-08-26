//
//  AppState.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import NBus
import UIKit

class AppState {

    static let shared = AppState()

    private init() {}
}

extension AppState {

    struct PlatformItem {
        let platform: Platform
        let handler: HandlerType
        let viewController: () -> UIViewController
    }
}
