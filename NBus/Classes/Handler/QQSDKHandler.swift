//
//  QQSDKHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public class QQSDKHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.QQ.friend,
        Endpoints.QQ.timeline,
    ]

    public var isInstalled: Bool {
        QQApiInterface.isQQInstalled()
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
}

extension QQSDKHandler: ShareHandlerType {

    // swiftlint:disable cyclomatic_complexity function_body_length

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

        let request: SendMessageToQQReq

        switch message {
        case let message as TextMessage:
            let textObject = QQApiTextObject(
                text: message.text
            )

            request = SendMessageToQQReq(content: textObject)

        case let message as ImageMessage:
            let imageObject = QQApiImageObject(
                data: message.data,
                previewImageData: message.thumbnail,
                title: message.title,
                description: message.description
            )

            request = SendMessageToQQReq(content: imageObject)

        case let message as AudioMessage:
            let audioObject = QQApiAudioObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .audio
            )

            request = SendMessageToQQReq(content: audioObject)

        case let message as VideoMessage:
            let videoObject = QQApiVideoObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .video
            )

            request = SendMessageToQQReq(content: videoObject)

        case let message as WebPageMessage:
            let webPageObject = QQApiURLObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .news
            )

            request = SendMessageToQQReq(content: webPageObject)

        case let message as FileMessage:
            let fileObject = QQApiFileObject(
                data: message.data,
                previewImageData: message.thumbnail,
                title: message.title,
                description: message.description
            )

            request = SendMessageToQQReq(content: fileObject)

        case let message as MiniProgramMessage:
            let webPageObject = QQApiURLObject(
                url: message.link,
                title: message.link.absoluteString,
                description: "",
                previewImageData: message.thumbnail,
                targetContentType: .news
            )

            let miniProgramObject = QQApiMiniProgramObject()
            miniProgramObject.qqApiObject = webPageObject
            miniProgramObject.miniAppID = message.miniProgramID
            miniProgramObject.miniPath = message.path
            miniProgramObject.webpageUrl = message.link.absoluteString
            miniProgramObject.miniprogramType = miniProgramType(message.miniProgramType)

            request = SendMessageToQQReq(miniContent: miniProgramObject)

        default:
            assertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        let code: QQApiSendResultCode

        switch endpoint {
        case Endpoints.QQ.friend:
            let cflag = self.cflag(endpoint, message.identifier)
                .reduce(0) { result, flag in result | flag.rawValue }
            request.message?.cflag |= UInt64(cflag)
            code = QQApiInterface.send(request)
        case Endpoints.QQ.timeline:
            code = QQApiInterface.sendReq(toQZone: request)
        default:
            assertionFailure()
            return
        }

        switch code {
        case .EQQAPISENDSUCESS:
            break
        case .EQQAPIMESSAGECONTENTINVALID:
            completionHandler(.failure(.invalidMessage))
        default:
            completionHandler(.failure(.unknown))
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    private func canShare(message: Message, to endpoint: Endpoint) -> Bool {
        switch endpoint {
        case Endpoints.QQ.friend:
            return true
        case Endpoints.QQ.timeline:
            return ![Messages.file, Messages.miniProgram].contains(message)
        default:
            assertionFailure()
            return false
        }
    }

    private func cflag(_ endpoint: Endpoint, _ message: Message) -> [kQQAPICtrlFlag] {
        var result: [kQQAPICtrlFlag] = []

        switch endpoint {
        case Endpoints.QQ.friend:
            result.append(.qqapiCtrlFlagQZoneShareForbid)

            if message == Messages.file {
                result.append(.qqapiCtrlFlagQQShareDataline)
            }
        default:
            assertionFailure()
        }

        return result
    }

    private func miniProgramType(_ miniProgramType: MiniProgramMessage.MiniProgramType) -> MiniProgramType {
        switch miniProgramType {
        case .release:
            return .online
        case .test:
            return .test
        case .preview:
            return .preview
        }
    }
}
