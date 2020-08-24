//
//  SystemHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/24.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public class SystemHandler {}

extension SystemHandler {

    public enum ShareOptionKeys {

        public static let sourceView = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.sourceView")

        public static let sourceRect = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.sourceRect")
    }
}
