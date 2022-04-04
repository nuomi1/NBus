//
//  AppState+Notification.swift
//  NBus
//
//  Created by nuomi1 on 2022/4/5.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation

#if BusTestsTarget
class AppState {

    static let shared = AppState()

    private init() {}
}
#endif

extension AppState {

    enum OpenURL {
        static let requestName = Notification.Name("Bus.OpenURL")
        static let responseName = Notification.Name("Bus.OpenURL.Result")
        static let requestKey = "url"
        static let responseKey = "result"
    }

    enum OpenUserActivity {
        static let requestName = Notification.Name("Bus.OpenUserActivity")
        static let responseName = Notification.Name("Bus.OpenUserActivity.Result")
        static let requestKey = "userActivity"
        static let responseKey = "result"
    }
}
