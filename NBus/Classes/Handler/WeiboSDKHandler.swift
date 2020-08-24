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
    private let redirectLink: URL

    public var logHandler: (String, String, String, UInt) -> Void = { message, _, _, _ in
        #if DEBUG
            print(message)
        #endif
    }

    private var helper: Helper!

    public init(appID: String, redirectLink: URL) {
        self.appID = appID
        self.redirectLink = redirectLink

        helper = Helper(master: self)

        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif

        WeiboSDK.registerApp(
            appID.trimmingCharacters(in: .letters)
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
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        let result = WeiboSDK.send(request)

        if !result {
            completionHandler(.failure(.invalidMessage))
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

        let result = WeiboSDK.send(request)

        if !result {
            completionHandler(.failure(.unknown))
        }
    }
}

extension WeiboSDKHandler {

    fileprivate class Helper: NSObject, WeiboSDKDelegate {

        weak var master: WeiboSDKHandler?

        required init(master: WeiboSDKHandler) {
            self.master = master
        }

        func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
            assertionFailure("\(String(describing: request))")
        }

        func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
            switch response {
            case let response as WBSendMessageToWeiboResponse:
                switch response.statusCode {
                case .success:
                    master?.shareCompletionHandler?(.success(()))
                case .userCancel:
                    master?.shareCompletionHandler?(.failure(.userCancelled))
                default:
                    master?.shareCompletionHandler?(.failure(.unknown))
                }
            default:
                assertionFailure("\(String(describing: response))")
            }
        }
    }
}
