//
//  Bus+Endpoint.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

public struct Endpoint: RawRepresentable, Hashable {

    public typealias RawValue = String

    public let rawValue: Self.RawValue

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}

public enum Endpoints {

    public enum QQ {

        public static let friend = Endpoint(rawValue: "com.nuomi1.bus.endpoint.qq.friend")

        public static let timeline = Endpoint(rawValue: "com.nuomi1.bus.endpoint.qq.timeline")
    }

    public enum Wechat {

        public static let friend = Endpoint(rawValue: "com.nuomi1.bus.endpoint.wechat.friend")

        public static let timeline = Endpoint(rawValue: "com.nuomi1.bus.endpoint.wechat.timeline")

        public static let favorite = Endpoint(rawValue: "com.nuomi1.bus.endpoint.wechat.favorite")
    }

    public enum Weibo {

        public static let timeline = Endpoint(rawValue: "com.nuomi1.bus.endpoint.weibo.timeline")
    }
}
