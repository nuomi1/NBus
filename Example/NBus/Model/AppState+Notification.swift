//
//  AppState+Notification.swift
//  NBus
//
//  Created by nuomi1 on 2022/4/5.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation

extension AppState {

    enum OpenURL {
        static let requestName = Notification.Name("Bus.OpenURL")
        static let responseName = Notification.Name("Bus.OpenURL.Result")
        static let requestURLKey = "url"
        static let requestPasteboardKey = "pasteboard"
        static let responseResultKey = "result"
    }

    enum OpenUserActivity {
        static let requestName = Notification.Name("Bus.OpenUserActivity")
        static let responseName = Notification.Name("Bus.OpenUserActivity.Result")
        static let requestUserActivityKey = "userActivity"
        static let requestPasteboardKey = "pasteboard"
        static let responseResultKey = "result"
    }
}
