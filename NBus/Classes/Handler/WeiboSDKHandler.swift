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

    public var isInstalled: Bool {
        WeiboSDK.isWeiboAppInstalled()
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
}

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
