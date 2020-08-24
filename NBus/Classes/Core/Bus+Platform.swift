//
//  Bus+Platform.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

public struct Platform: RawRepresentable, Hashable {

    public typealias RawValue = String

    public let rawValue: Self.RawValue

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}

public enum Platforms {

    public static let qq = Platform(rawValue: "com.nuomi1.bus.platform.qq")

    public static let wechat = Platform(rawValue: "com.nuomi1.bus.platform.wechat")
}
