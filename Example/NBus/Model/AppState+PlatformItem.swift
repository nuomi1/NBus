//
//  AppState+PlatformItem.swift
//  NBus
//
//  Created by nuomi1 on 2022/4/20.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import NBus
import UIKit

extension AppState {

    struct PlatformItem {
        let platform: Platform
        let category: Category
        let handlers: [Category: HandlerType]
        let viewController: () -> UIViewController
    }
}

extension AppState.PlatformItem {

    enum Category: Hashable {
        case bus
        case sdk
    }
}

extension AppState.PlatformItem.Category: CustomStringConvertible {

    var description: String {
        switch self {
        case .bus:
            return "开源"
        case .sdk:
            return "官方"
        }
    }
}

extension AppState.PlatformItem.Category {

    mutating func toggle() {
        switch self {
        case .bus:
            self = .sdk
        case .sdk:
            self = .bus
        }
    }

    func toggled() -> Self {
        var copy = self
        copy.toggle()
        return copy
    }
}
