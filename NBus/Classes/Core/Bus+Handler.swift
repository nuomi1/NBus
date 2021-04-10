//
//  Bus+Handler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public protocol HandlerType {

    var isInstalled: Bool { get }

    var isSupported: Bool { get }
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

public protocol LaunchHandlerType {

    var platform: Platform { get }

    func launch(
        program: MiniProgramMessage,
        options: [Bus.LaunchOptionKey: Any],
        completionHandler: @escaping Bus.LaunchCompletionHandler
    )

    func canLaunch(with platform: Platform) -> Bool
}

extension LaunchHandlerType {

    public func canLaunch(with platform: Platform) -> Bool {
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
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let webpageURL = userActivity.webpageURL
        else {
            return false
        }

        let lhs = webpageURL.absoluteString
        let rhs = universalLink.absoluteString

        return lhs.hasPrefix(rhs)
    }
}

protocol BusShareHandlerHelper: HandlerType {

    var supportedMessage: [Endpoint: [Message]] { get }
}

extension BusShareHandlerHelper {

    func canShare(message: Message, to endpoint: Endpoint) -> Bool {
        supportedMessage[endpoint]?.contains(message) ?? false
    }

    func checkShareSupported(message: MessageType, to endpoint: Endpoint) -> Result<Void, Bus.Error> {
        guard isInstalled else {
            return .failure(.missingApplication)
        }

        guard isSupported else {
            return .failure(.unsupportedApplication)
        }

        guard canShare(message: message.identifier, to: endpoint) else {
            return .failure(.unsupportedMessage)
        }

        return .success(())
    }
}

protocol BusShareQQHandlerHelper: BusShareHandlerHelper {}

extension BusShareQQHandlerHelper {

    var supportedMessage: [Endpoint: [Message]] {
        [
            Endpoints.QQ.friend: [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
                Messages.file,
                Messages.miniProgram,
            ],
            Endpoints.QQ.timeline: [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
            ],
        ]
    }
}

protocol BusShareWechatHandlerHelper: BusShareHandlerHelper {}

extension BusShareWechatHandlerHelper {

    var supportedMessage: [Endpoint: [Message]] {
        [
            Endpoints.Wechat.friend: [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
                Messages.file,
                Messages.miniProgram,
            ],
            Endpoints.Wechat.timeline: [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
            ],
            Endpoints.Wechat.favorite: [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
                Messages.file,
            ],
        ]
    }
}

protocol BusShareWeiboHandlerHelper: BusShareHandlerHelper {}

extension BusShareWeiboHandlerHelper {

    var supportedMessage: [Endpoint: [Message]] {
        [
            Endpoints.Weibo.timeline: [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
            ],
        ]
    }
}

protocol BusOpenExternalURLHelper: HandlerType {}

extension BusOpenExternalURLHelper {

    func open<Success>(
        _ url: URL?,
        completionHandler: ((Result<Success, Bus.Error>) -> Void)?
    ) {
        guard let url = url else {
            busAssertionFailure()
            completionHandler?(.failure(.invalidParameter))
            return
        }

        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = url.scheme == "https"
            ? [.universalLinksOnly: true]
            : [:]

        UIApplication.shared.open(url, options: options) { result in
            if !result {
                completionHandler?(.failure(.unknown))
            }
        }
    }
}

protocol BusGetCommonInfoHelper: HandlerType {}

extension BusGetCommonInfoHelper {

    var bundleID: String {
        Bundle.main.bus.identifier!
    }

    var displayName: String {
        Bundle.main.bus.displayName!
    }

    var oldText: String? {
        UIPasteboard.general.bus.oldText
    }
}
