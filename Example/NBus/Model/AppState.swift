//
//  AppState.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import NBus
import RxRelay
import UIKit

class AppState {

    let platformItems = BehaviorRelay<[PlatformItem]>(value: [])

    static let shared = AppState()

    private init() {}
}

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
