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

    public var isSupported: Bool {
        true
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?

    public let appID: String
    public let universalLink: URL
    private let redirectLink: URL

    private var coordinator: Coordinator!

    private lazy var iso8601DateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()

    public init(appID: String, universalLink: URL, redirectLink: URL) {
        self.appID = appID
        self.universalLink = universalLink
        self.redirectLink = redirectLink

        coordinator = Coordinator(owner: self)

        WeiboSDK.registerApp(
            appID.trimmingCharacters(in: .letters),
            universalLink: universalLink.absoluteString
        )
    }
}

extension WeiboSDKHandler: ShareHandlerType {

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
        completionHandler: @escaping Bus.ShareCompletionHandler
    ) {
        let checkResult = checkShareSupported(message: message, to: endpoint)

        guard case .success = checkResult else {
            completionHandler(checkResult)
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

        case let message as AudioMessage:
            request.message.mediaObject = wbWebpageObject(
                link: message.link,
                title: message.title,
                description: message.description,
                thumbnail: message.thumbnail
            )

        case let message as VideoMessage:
            request.message.mediaObject = wbWebpageObject(
                link: message.link,
                title: message.title,
                description: message.description,
                thumbnail: message.thumbnail
            )

        case let message as WebPageMessage:
            request.message.mediaObject = wbWebpageObject(
                link: message.link,
                title: message.title,
                description: message.description,
                thumbnail: message.thumbnail
            )

        default:
            busAssertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        WeiboSDK.send(request) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }

    private func wbWebpageObject(
        link: URL,
        title: String?,
        description: String?,
        thumbnail: Data?
    ) -> WBWebpageObject {
        let webPageObject = WBWebpageObject()
        webPageObject.webpageUrl = link.absoluteString
        webPageObject.title = title
        webPageObject.description = description
        webPageObject.thumbnailData = thumbnail

        webPageObject.objectID = UUID().uuidString

        return webPageObject
    }
}

extension WeiboSDKHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        let checkResult = checkOauthSupported()

        guard case .success = checkResult else {
            completionHandler(checkResult.flatMap { _ in .failure(.unknown) })
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

extension WeiboSDKHandler: BusWeiboHandlerHelper {}

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

        public static let accessToken = Bus.OauthInfoKeys.Weibo.accessToken

        public static let expirationDate = Bus.OauthInfoKeys.Weibo.expirationDate

        public static let refreshToken = Bus.OauthInfoKeys.Weibo.refreshToken

        public static let userID = Bus.OauthInfoKeys.Weibo.userID
    }
}

extension WeiboSDKHandler {

    fileprivate class Coordinator: NSObject, WeiboSDKDelegate {

        weak var owner: WeiboSDKHandler?

        required init(owner: WeiboSDKHandler) {
            self.owner = owner
        }

        func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
            busAssertionFailure("\(String(describing: request))")
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
                    busAssertionFailure()
                    owner?.shareCompletionHandler?(.failure(.unknown))
                }
            case let response as WBAuthorizeResponse:
                switch response.statusCode {
                case .success:
                    let expirationDate = response.expirationDate.flatMap {
                        owner?.iso8601DateFormatter.string(from: $0)
                    }

                    let parameters = [
                        OauthInfoKeys.accessToken: response.accessToken,
                        OauthInfoKeys.expirationDate: expirationDate,
                        OauthInfoKeys.refreshToken: response.refreshToken,
                        OauthInfoKeys.userID: response.userID,
                    ]
                    .bus
                    .compactMapContent()

                    if !parameters.isEmpty {
                        owner?.oauthCompletionHandler?(.success(parameters))
                    } else {
                        busAssertionFailure()
                        owner?.oauthCompletionHandler?(.failure(.unknown))
                    }
                case .userCancel:
                    owner?.oauthCompletionHandler?(.failure(.userCancelled))
                default:
                    busAssertionFailure()
                    owner?.oauthCompletionHandler?(.failure(.unknown))
                }
            default:
                busAssertionFailure("\(String(describing: response))")
            }
        }
    }
}
