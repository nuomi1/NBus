//
//  Bus+Handler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import UIKit

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

public protocol BusCheckUniversalLinkHandlerHelper: HandlerType {}

extension BusCheckUniversalLinkHandlerHelper {

    fileprivate func checkUniversalLinkSupported() -> Result<Void, Bus.Error> {
        guard isInstalled else {
            return .failure(.missingApplication)
        }

        guard isSupported else {
            return .failure(.unsupportedApplication)
        }

        return .success(())
    }
}

public protocol BusShareHandlerHelper: BusCheckUniversalLinkHandlerHelper {

    var supportedMessage: [Endpoint: [Message]] { get }
}

extension BusShareHandlerHelper {

    public func checkShareSupported(message: MessageType, to endpoint: Endpoint) -> Result<Void, Bus.Error> {
        checkUniversalLinkSupported().flatMap { success in
            supportedMessage[endpoint]?.contains(message.identifier) ?? false
                ? .success(success)
                : .failure(.unsupportedMessage)
        }
    }
}

public protocol BusOauthHandlerHelper: BusCheckUniversalLinkHandlerHelper {}

extension BusOauthHandlerHelper {

    public func checkOauthSupported() -> Result<Void, Bus.Error> {
        checkUniversalLinkSupported()
    }
}

public protocol BusLaunchHandlerHelper: BusCheckUniversalLinkHandlerHelper {}

extension BusLaunchHandlerHelper {

    public func checkLaunchhSupported() -> Result<Void, Bus.Error> {
        checkUniversalLinkSupported()
    }
}

public protocol BusQQHandlerHelper: BusShareHandlerHelper, BusOauthHandlerHelper, BusLaunchHandlerHelper {}

extension BusQQHandlerHelper {

    public var supportedMessage: [Endpoint: [Message]] {
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

public protocol BusWechatHandlerHelper: BusShareHandlerHelper, BusOauthHandlerHelper, BusLaunchHandlerHelper {}

extension BusWechatHandlerHelper {

    public var supportedMessage: [Endpoint: [Message]] {
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

public protocol BusWeiboHandlerHelper: BusShareHandlerHelper, BusOauthHandlerHelper {}

extension BusWeiboHandlerHelper {

    public var supportedMessage: [Endpoint: [Message]] {
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

public protocol BusSystemHandlerHelper: BusShareHandlerHelper, BusOauthHandlerHelper {}

extension BusSystemHandlerHelper {

    public var supportedMessage: [Endpoint: [Message]] {
        [
            Endpoints.System.activity: [
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

public protocol BusOpenExternalURLHelper: HandlerType {}

extension BusOpenExternalURLHelper {

    public func open<Success>(
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

public protocol BusGetCommonInfoHelper: HandlerType {}

extension BusGetCommonInfoHelper {

    public var bundleID: String {
        Bundle.main.bus.identifier!
    }

    public var displayName: String {
        Bundle.main.bus.displayName!
    }

    public var oldText: String? {
        UIPasteboard.general.bus.oldText
    }
}
