//
//  Bus.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public final class Bus {

    public static let shared = Bus()

    public var handlers: [HandlerType] = []
}

extension Bus {

    public typealias LogHandler = (String, String, String, UInt) -> Void
}

extension Bus {

    public struct ShareOptionKey: RawRepresentable, Hashable {

        public typealias RawValue = String

        public let rawValue: Self.RawValue

        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
    }

    public typealias ShareCompletionHandler = (Result<Void, Bus.Error>) -> Void

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
        completionHandler: @escaping ShareCompletionHandler
    ) {
        let handlers = self.handlers.compactMap { $0 as? ShareHandlerType }

        guard
            let handler = handlers.first(where: { $0.canShare(to: endpoint) })
        else {
            assertionFailure()
            completionHandler(.failure(.missingHandler))
            return
        }

        handler.share(
            message: message,
            to: endpoint,
            options: options,
            completionHandler: completionHandler
        )
    }
}

extension Bus {

    public struct OauthOptionKey: RawRepresentable, Hashable {

        public typealias RawValue = String

        public let rawValue: Self.RawValue

        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
    }

    public struct OauthInfoKey: RawRepresentable, Hashable {

        public typealias RawValue = String

        public let rawValue: Self.RawValue

        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
    }

    public typealias OauthCompletionHandler = (Result<[OauthInfoKey: String], Bus.Error>) -> Void

    public func oauth(
        with platform: Platform,
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping OauthCompletionHandler
    ) {
        let handlers = self.handlers.compactMap { $0 as? OauthHandlerType }

        guard
            let handler = handlers.first(where: { $0.canOauth(with: platform) })
        else {
            assertionFailure()
            completionHandler(.failure(.missingHandler))
            return
        }

        handler.oauth(
            options: options,
            completionHandler: completionHandler
        )
    }
}

extension Bus {

    public func openURL(_ url: URL) -> Bool {
        let handlers = self.handlers.compactMap { $0 as? OpenURLHandlerType }

        guard
            let handler = handlers.first(where: { $0.canOpenURL(url) })
        else {
            return false
        }

        handler.openURL(url)
        return true
    }
}

extension Bus {

    public func openUserActivity(_ userActivity: NSUserActivity) -> Bool {
        let handlers = self.handlers.compactMap { $0 as? OpenUserActivityHandlerType }

        guard
            let handler = handlers.first(where: { $0.canOpenUserActivity(userActivity) })
        else {
            return false
        }

        handler.openUserActivity(userActivity)
        return true
    }
}

extension Bus {

    enum OauthInfoKeys {

        enum QQ {

            static let accessToken = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.qq.accessToken")

            static let openID = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.qq.openID")
        }

        enum Weibo {

            public static let accessToken = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.weibo.accessToken")
        }
    }
}
