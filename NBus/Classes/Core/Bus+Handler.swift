//
//  Bus+Handler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

public protocol HandlerType {}

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
