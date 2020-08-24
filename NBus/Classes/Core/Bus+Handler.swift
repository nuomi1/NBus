//
//  Bus+Handler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

public protocol HandlerType {

    var isInstalled: Bool { get }
}

public protocol LogHandlerProxyType: HandlerType {

    var logHandler: Bus.LogHandler { get }

    func log(
        _ message: String,
        file: String,
        function: String,
        line: UInt
    )
}

extension LogHandlerProxyType {

    public func log(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        logHandler(message, file, function, line)
    }
}

public protocol ShareHandlerType: HandlerType {

    var endpoints: [Endpoint] { get }

    func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any],
        completionHandler: @escaping Bus.ShareCompletionHandler
    )

    func canShare(to endpoint: Endpoint) -> Bool
}

extension ShareHandlerType {

    public func canShare(to endpoint: Endpoint) -> Bool {
        endpoints.contains(endpoint)
    }
}

public protocol OauthHandlerType: HandlerType {

    var platform: Platform { get }

    func oauth(
        options: [Bus.OauthOptionKey: Any],
        completionHandler: @escaping Bus.OauthCompletionHandler
    )

    func canOauth(with platform: Platform) -> Bool
}

extension OauthHandlerType {

    public func canOauth(with platform: Platform) -> Bool {
        self.platform == platform
    }
}

public protocol OpenURLHandlerType: HandlerType {

    var appID: String { get }

    func openURL(_ url: URL)

    func canOpenURL(_ url: URL) -> Bool
}

extension OpenURLHandlerType {

    public func canOpenURL(_ url: URL) -> Bool {
        appID == url.scheme
    }
}

public protocol OpenUserActivityHandlerType: HandlerType {

    var universalLink: URL { get }

    func openUserActivity(_ userActivity: NSUserActivity)

    func canOpenUserActivity(_ userActivity: NSUserActivity) -> Bool
}

extension OpenUserActivityHandlerType {

    public func canOpenUserActivity(_ userActivity: NSUserActivity) -> Bool {
        let lhs = userActivity.webpageURL?.absoluteString ?? ""
        let rhs = universalLink.absoluteString
        return lhs.hasPrefix(rhs)
    }
}
