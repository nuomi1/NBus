//
//  WeiboSDKHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/24.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public class WeiboSDKHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.Weibo.timeline,
    ]

    public let platform: Platform = Platforms.weibo

    public var isInstalled: Bool {
        WeiboSDK.isWeiboAppInstalled()
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?

    public let appID: String
    public let universalLink: URL
    private let redirectLink: URL

    public var logHandler: Bus.LogHandler = { message, _, _, _ in
        #if DEBUG
            print(message)
        #endif
    }

    private var coordinator: Coordinator!

    public init(appID: String, universalLink: URL, redirectLink: URL) {
        self.appID = appID
        self.universalLink = universalLink
        self.redirectLink = redirectLink

        coordinator = Coordinator(owner: self)

        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif

        WeiboSDK.registerApp(
            appID.trimmingCharacters(in: .letters),
            universalLink: universalLink.absoluteString
        )
    }
}

extension WeiboSDKHandler: LogHandlerProxyType {}

extension WeiboSDKHandler: ShareHandlerType {

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
        completionHandler: @escaping Bus.ShareCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        guard canShare(message: message.identifier, to: endpoint) else {
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        shareCompletionHandler = completionHandler

        let request = WBSendMessageToWeiboRequest()
        request.message = WBMessageObject()

        switch message {
        case let message as TextMessage:
            request.message.text = message.text

        case let message as ImageMessage:
            let imageObject = WBImageObject()
            imageObject.imageData = message.data

            request.message.imageObject = imageObject

        case let message as WebPageMessage:
            let webPageObject = WBWebpageObject()
            webPageObject.webpageUrl = message.link.absoluteString
            webPageObject.title = message.title
            webPageObject.description = message.description
            webPageObject.thumbnailData = message.thumbnail

            webPageObject.objectID = UUID().uuidString

            request.message.mediaObject = webPageObject

        default:
            assertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        WeiboSDK.send(request) { result in
            if !result {
                completionHandler(.failure(.invalidMessage))
            }
        }
    }

    private func canShare(message: Message, to endpoint: Endpoint) -> Bool {
        switch endpoint {
        case Endpoints.Weibo.timeline:
            return ![
                Messages.audio,
                Messages.video,
                Messages.file,
                Messages.miniProgram,
            ].contains(message)
        default:
            assertionFailure()
            return false
        }
    }
}

extension WeiboSDKHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        oauthCompletionHandler = completionHandler

        let request = WBAuthorizeRequest()
        request.redirectURI = redirectLink.absoluteString

        WeiboSDK.send(request) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }
}

extension WeiboSDKHandler: OpenURLHandlerType {

    public func openURL(_ url: URL) {
        WeiboSDK.handleOpen(url, delegate: coordinator)
    }
}

extension WeiboSDKHandler: OpenUserActivityHandlerType {

    public func openUserActivity(_ userActivity: NSUserActivity) {
        WeiboSDK.handleOpenUniversalLink(userActivity, delegate: coordinator)
    }
}

extension WeiboSDKHandler {

    public enum OauthInfoKeys {

        public static let accessToken = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.weiboSDKHandler.accessToken")
    }
}

extension WeiboSDKHandler {

    fileprivate class Coordinator: NSObject, WeiboSDKDelegate {

        weak var owner: WeiboSDKHandler?

        required init(owner: WeiboSDKHandler) {
            self.owner = owner
        }

        func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
            assertionFailure("\(String(describing: request))")
        }

        func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
            switch response {
            case let response as WBSendMessageToWeiboResponse:
                switch response.statusCode {
                case .success:
                    owner?.shareCompletionHandler?(.success(()))
                case .userCancel:
                    owner?.shareCompletionHandler?(.failure(.userCancelled))
                default:
                    owner?.shareCompletionHandler?(.failure(.unknown))
                }
            case let response as WBAuthorizeResponse:
                switch (response.statusCode, response.accessToken) {
                case let (.success, accessToken):
                    let parameters = [
                        OauthInfoKeys.accessToken: accessToken,
                    ]
                    .bus
                    .compactMapContent()

                    if !parameters.isEmpty {
                        owner?.oauthCompletionHandler?(.success(parameters))
                    } else {
                        owner?.oauthCompletionHandler?(.failure(.unknown))
                    }
                case (.userCancel, _):
                    owner?.oauthCompletionHandler?(.failure(.userCancelled))
                default:
                    owner?.oauthCompletionHandler?(.failure(.unknown))
                }
            default:
                assertionFailure("\(String(describing: response))")
            }
        }
    }
}
